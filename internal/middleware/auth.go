package middleware

import (
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"

	"tour_leader_api/internal/config"
	"tour_leader_api/pkg/response"
)

type JWTClaims struct {
	UserID uuid.UUID `json:"user_id"`
	Email  string    `json:"email"`
	Role   string    `json:"role"`
	jwt.RegisteredClaims
}

// AuthRequired middleware checks for valid JWT token
func AuthRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := extractToken(c)
		if token == "" {
			c.JSON(http.StatusUnauthorized, response.Error("Authorization token required"))
			c.Abort()
			return
		}

		cfg := c.MustGet("config").(*config.Config)
		claims, err := validateToken(token, cfg.JWT.SecretKey)
		if err != nil {
			c.JSON(http.StatusUnauthorized, response.Error("Invalid or expired token"))
			c.Abort()
			return
		}

		// Store user information in context
		c.Set("user_id", claims.UserID)
		c.Set("user_email", claims.Email)
		c.Set("user_role", claims.Role)
		c.Next()
	}
}

// AdminRequired middleware checks for admin role
func AdminRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := c.Get("user_role")
		if !exists || userRole != "admin" {
			c.JSON(http.StatusForbidden, response.Error("Admin access required"))
			c.Abort()
			return
		}
		c.Next()
	}
}

// ModeratorRequired middleware checks for moderator or admin role
func ModeratorRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := c.Get("user_role")
		if !exists || (userRole != "admin" && userRole != "moderator") {
			c.JSON(http.StatusForbidden, response.Error("Moderator access required"))
			c.Abort()
			return
		}
		c.Next()
	}
}

// OptionalAuth middleware extracts user info if token is present, but doesn't require it
func OptionalAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := extractToken(c)
		if token != "" {
			cfg := c.MustGet("config").(*config.Config)
			if claims, err := validateToken(token, cfg.JWT.SecretKey); err == nil {
				c.Set("user_id", claims.UserID)
				c.Set("user_email", claims.Email)
				c.Set("user_role", claims.Role)
			}
		}
		c.Next()
	}
}

// extractToken extracts JWT token from request
func extractToken(c *gin.Context) string {
	// Check Authorization header
	bearerToken := c.GetHeader("Authorization")
	if bearerToken != "" {
		// Bearer token format: "Bearer <token>"
		if strings.HasPrefix(bearerToken, "Bearer ") {
			return strings.TrimPrefix(bearerToken, "Bearer ")
		}
	}

	// Check query parameter as fallback
	token := c.Query("token")
	if token != "" {
		return token
	}

	// Check cookie as fallback
	if cookie, err := c.Cookie("auth_token"); err == nil {
		return cookie
	}

	return ""
}

// validateToken validates JWT token and returns claims
func validateToken(tokenString, secretKey string) (*JWTClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		// Validate signing method
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(secretKey), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*JWTClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, jwt.ErrInvalidKey
}

// GenerateToken generates a JWT token for a user
func GenerateToken(userID uuid.UUID, email, role string, cfg *config.Config) (string, error) {
	expirationTime := time.Now().Add(time.Duration(cfg.JWT.ExpirationTime) * time.Hour)

	claims := &JWTClaims{
		UserID: userID,
		Email:  email,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    cfg.App.Name,
			Subject:   userID.String(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(cfg.JWT.SecretKey))
}

// GenerateRefreshToken generates a refresh token with longer expiration
func GenerateRefreshToken(userID uuid.UUID, cfg *config.Config) (string, error) {
	expirationTime := time.Now().Add(7 * 24 * time.Hour) // 7 days

	claims := &jwt.RegisteredClaims{
		ExpiresAt: jwt.NewNumericDate(expirationTime),
		IssuedAt:  jwt.NewNumericDate(time.Now()),
		NotBefore: jwt.NewNumericDate(time.Now()),
		Issuer:    cfg.App.Name,
		Subject:   userID.String(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(cfg.JWT.SecretKey))
}

// ValidateRefreshToken validates refresh token and returns user ID
func ValidateRefreshToken(tokenString, secretKey string) (uuid.UUID, error) {
	token, err := jwt.ParseWithClaims(tokenString, &jwt.RegisteredClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(secretKey), nil
	})

	if err != nil {
		return uuid.Nil, err
	}

	if claims, ok := token.Claims.(*jwt.RegisteredClaims); ok && token.Valid {
		userID, err := uuid.Parse(claims.Subject)
		if err != nil {
			return uuid.Nil, err
		}
		return userID, nil
	}

	return uuid.Nil, jwt.ErrInvalidKey
}

// GetUserID extracts user ID from gin context
func GetUserID(c *gin.Context) (uuid.UUID, bool) {
	if userID, exists := c.Get("user_id"); exists {
		if id, ok := userID.(uuid.UUID); ok {
			return id, true
		}
	}
	return uuid.Nil, false
}

// GetUserRole extracts user role from gin context
func GetUserRole(c *gin.Context) (string, bool) {
	if role, exists := c.Get("user_role"); exists {
		if r, ok := role.(string); ok {
			return r, true
		}
	}
	return "", false
}

// GetUserEmail extracts user email from gin context
func GetUserEmail(c *gin.Context) (string, bool) {
	if email, exists := c.Get("user_email"); exists {
		if e, ok := email.(string); ok {
			return e, true
		}
	}
	return "", false
}

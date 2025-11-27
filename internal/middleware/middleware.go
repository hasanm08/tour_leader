package middleware

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/time/rate"

	"tour_leader_api/internal/config"
	"tour_leader_api/pkg/logger"
	"tour_leader_api/pkg/response"
)

// Logger middleware logs HTTP requests
func Logger(logger *logger.Logger) gin.HandlerFunc {
	return gin.LoggerWithConfig(gin.LoggerConfig{
		Formatter: func(param gin.LogFormatterParams) string {
			return fmt.Sprintf("%s - [%s] \"%s %s %s %d %s \"%s\" %s\"\n",
				param.ClientIP,
				param.TimeStamp.Format(time.RFC1123),
				param.Method,
				param.Path,
				param.Request.Proto,
				param.StatusCode,
				param.Latency,
				param.Request.UserAgent(),
				param.ErrorMessage,
			)
		},
	})
}

// Recovery middleware recovers from panics
func Recovery(logger *logger.Logger) gin.HandlerFunc {
	return gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
		logger.Error("Panic recovered: %v", recovered)
		c.JSON(http.StatusInternalServerError, response.Error("Internal server error"))
	})
}

// CORS middleware handles Cross-Origin Resource Sharing
func CORS(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		
		// In production, you should validate against allowed origins
		if cfg.App.Environment == "development" {
			c.Header("Access-Control-Allow-Origin", "*")
		} else {
			// Add your allowed origins here
			allowedOrigins := []string{
				"https://tourleader.app",
				"https://www.tourleader.app",
				"https://app.tourleader.app",
			}
			
			for _, allowedOrigin := range allowedOrigins {
				if origin == allowedOrigin {
					c.Header("Access-Control-Allow-Origin", origin)
					break
				}
			}
		}

		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Accept, Authorization, X-Requested-With")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Header("Access-Control-Max-Age", "86400")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

// RateLimit middleware implements rate limiting
func RateLimit() gin.HandlerFunc {
	// Create a rate limiter that allows 100 requests per minute
	limiter := rate.NewLimiter(rate.Every(time.Minute/100), 100)

	return func(c *gin.Context) {
		if !limiter.Allow() {
			c.JSON(http.StatusTooManyRequests, response.Error("Rate limit exceeded"))
			c.Abort()
			return
		}
		c.Next()
	}
}

// RequestID middleware adds a unique request ID
func RequestID() gin.HandlerFunc {
	return func(c *gin.Context) {
		requestID := c.GetHeader("X-Request-ID")
		if requestID == "" {
			requestID = generateRequestID()
		}
		c.Header("X-Request-ID", requestID)
		c.Set("request_id", requestID)
		c.Next()
	}
}

// Security middleware adds security headers
func Security() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("X-Content-Type-Options", "nosniff")
		c.Header("X-Frame-Options", "DENY")
		c.Header("X-XSS-Protection", "1; mode=block")
		c.Header("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
		c.Header("Content-Security-Policy", "default-src 'self'")
		c.Header("Referrer-Policy", "strict-origin-when-cross-origin")
		c.Next()
	}
}

// Pagination middleware processes pagination parameters
func Pagination() gin.HandlerFunc {
	return func(c *gin.Context) {
		page := 1
		limit := 20

		if p := c.Query("page"); p != "" {
			if parsedPage, err := strconv.Atoi(p); err == nil && parsedPage > 0 {
				page = parsedPage
			}
		}

		if l := c.Query("limit"); l != "" {
			if parsedLimit, err := strconv.Atoi(l); err == nil && parsedLimit > 0 && parsedLimit <= 100 {
				limit = parsedLimit
			}
		}

		offset := (page - 1) * limit

		c.Set("page", page)
		c.Set("limit", limit)
		c.Set("offset", offset)
		c.Next()
	}
}

// ConfigMiddleware injects configuration into context
func ConfigMiddleware(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Set("config", cfg)
		c.Next()
	}
}

// generateRequestID generates a unique request ID
func generateRequestID() string {
	return fmt.Sprintf("%d", time.Now().UnixNano())
}

// GetPagination extracts pagination parameters from context
func GetPagination(c *gin.Context) (page, limit, offset int) {
	page, _ = c.Get("page")
	limit, _ = c.Get("limit")
	offset, _ = c.Get("offset")
	return page.(int), limit.(int), offset.(int)
}

package models

import (
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type User struct {
	ID                   uuid.UUID  `json:"id" db:"id"`
	Email                string     `json:"email" db:"email" validate:"required,email"`
	Password             string     `json:"-" db:"password"` // Hidden from JSON
	Name                 string     `json:"name" db:"name" validate:"required,min=2,max=100"`
	FirstName            string     `json:"firstName" db:"first_name" validate:"required,min=1,max=50"`
	LastName             string     `json:"lastName" db:"last_name" validate:"required,min=1,max=50"`
	AvatarURL            *string    `json:"avatarUrl" db:"avatar_url"`
	PhoneNumber          *string    `json:"phoneNumber" db:"phone_number"`
	DateOfBirth          *time.Time `json:"dateOfBirth" db:"date_of_birth"`
	Bio                  *string    `json:"bio" db:"bio"`
	Location             *string    `json:"location" db:"location"`
	Interests            []string   `json:"interests" db:"interests"`
	FavoriteDestinations []string   `json:"favoriteDestinations" db:"favorite_destinations"`
	TotalTrips           int        `json:"totalTrips" db:"total_trips"`
	TotalReviews         int        `json:"totalReviews" db:"total_reviews"`
	IsVerified           bool       `json:"isVerified" db:"is_verified"`
	IsOnline             bool       `json:"isOnline" db:"is_online"`
	LastSeen             time.Time  `json:"lastSeen" db:"last_seen"`
	Role                 string     `json:"role" db:"role"` // user, admin, moderator
	Status               string     `json:"status" db:"status"` // active, suspended, deleted
	CreatedAt            time.Time  `json:"createdAt" db:"created_at"`
	UpdatedAt            time.Time  `json:"updatedAt" db:"updated_at"`
}

type RegisterRequest struct {
	Email           string `json:"email" validate:"required,email"`
	Password        string `json:"password" validate:"required,min=8,max=100"`
	ConfirmPassword string `json:"confirmPassword" validate:"required,eqfield=Password"`
	FirstName       string `json:"firstName" validate:"required,min=1,max=50"`
	LastName        string `json:"lastName" validate:"required,min=1,max=50"`
	PhoneNumber     string `json:"phoneNumber" validate:"omitempty,min=10,max=20"`
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

type LoginResponse struct {
	User        User   `json:"user"`
	AccessToken string `json:"accessToken"`
	TokenType   string `json:"tokenType"`
	ExpiresIn   int    `json:"expiresIn"`
}

type UpdateProfileRequest struct {
	FirstName   string     `json:"firstName" validate:"omitempty,min=1,max=50"`
	LastName    string     `json:"lastName" validate:"omitempty,min=1,max=50"`
	PhoneNumber *string    `json:"phoneNumber" validate:"omitempty,min=10,max=20"`
	DateOfBirth *time.Time `json:"dateOfBirth"`
	Bio         *string    `json:"bio" validate:"omitempty,max=500"`
	Location    *string    `json:"location" validate:"omitempty,max=100"`
	Interests   []string   `json:"interests"`
}

type ChangePasswordRequest struct {
	CurrentPassword string `json:"currentPassword" validate:"required"`
	NewPassword     string `json:"newPassword" validate:"required,min=8,max=100"`
	ConfirmPassword string `json:"confirmPassword" validate:"required,eqfield=NewPassword"`
}

type UserProfile struct {
	User
	TourCount         int     `json:"tourCount"`
	CompletedTours    int     `json:"completedTours"`
	AverageRating     float64 `json:"averageRating"`
	RecentActivities  []Activity `json:"recentActivities,omitempty"`
	BadgesEarned      []Badge    `json:"badgesEarned,omitempty"`
}

type Activity struct {
	ID          uuid.UUID `json:"id" db:"id"`
	UserID      uuid.UUID `json:"userId" db:"user_id"`
	Type        string    `json:"type" db:"type"` // tour_created, review_posted, destination_visited
	Title       string    `json:"title" db:"title"`
	Description string    `json:"description" db:"description"`
	Metadata    string    `json:"metadata" db:"metadata"` // JSON field
	CreatedAt   time.Time `json:"createdAt" db:"created_at"`
}

type Badge struct {
	ID          uuid.UUID `json:"id" db:"id"`
	Name        string    `json:"name" db:"name"`
	Description string    `json:"description" db:"description"`
	IconURL     string    `json:"iconUrl" db:"icon_url"`
	Category    string    `json:"category" db:"category"`
	Requirements string   `json:"requirements" db:"requirements"` // JSON field
}

type UserBadge struct {
	UserID    uuid.UUID `json:"userId" db:"user_id"`
	BadgeID   uuid.UUID `json:"badgeId" db:"badge_id"`
	EarnedAt  time.Time `json:"earnedAt" db:"earned_at"`
	Badge     Badge     `json:"badge,omitempty"`
}

func (u *User) BeforeCreate() error {
	u.ID = uuid.New()
	u.Name = u.FirstName + " " + u.LastName
	u.Role = "user"
	u.Status = "active"
	u.IsOnline = false
	u.LastSeen = time.Now()
	u.CreatedAt = time.Now()
	u.UpdatedAt = time.Now()
	return nil
}

func (u *User) BeforeUpdate() {
	u.Name = u.FirstName + " " + u.LastName
	u.UpdatedAt = time.Now()
}

func (u *User) HashPassword() error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	u.Password = string(hashedPassword)
	return nil
}

func (u *User) CheckPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
	return err == nil
}

func (u *User) SetOnlineStatus(isOnline bool) {
	u.IsOnline = isOnline
	if !isOnline {
		u.LastSeen = time.Now()
	}
	u.UpdatedAt = time.Now()
}

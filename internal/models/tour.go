package models

import (
	"time"

	"github.com/google/uuid"
)

type Tour struct {
	ID                  uuid.UUID     `json:"id" db:"id"`
	Name                string        `json:"name" db:"name" validate:"required,min=3,max=150"`
	Description         string        `json:"description" db:"description" validate:"required,min=10,max=1000"`
	CreatorID           uuid.UUID     `json:"userId" db:"creator_id"`
	TotalPrice          float64       `json:"totalPrice" db:"total_price" validate:"min=0"`
	Currency            string        `json:"currency" db:"currency" validate:"required,len=3"`
	Duration            int           `json:"duration" db:"duration" validate:"required,min=1"` // in days
	StartDate           time.Time     `json:"startDate" db:"start_date" validate:"required"`
	EndDate             time.Time     `json:"endDate" db:"end_date" validate:"required"`
	IsBookmarked        bool          `json:"isBookmarked" db:"is_bookmarked"`
	IsShared            bool          `json:"isShared" db:"is_shared"`
	Status              string        `json:"status" db:"status"` // draft, active, completed, cancelled
	CurrentParticipants int           `json:"currentParticipants" db:"current_participants"`
	MinParticipants     int           `json:"minParticipants" db:"min_participants" validate:"min=1"`
	MaxParticipants     int           `json:"maxParticipants" db:"max_participants" validate:"min=1"`
	ShareCode           string        `json:"shareCode" db:"share_code"` // Unique code for sharing
	DeepLinkURL         string        `json:"deepLinkUrl" db:"deep_link_url"`
	ImageURL            *string       `json:"imageUrl" db:"image_url"`
	Tags                []string      `json:"tags" db:"tags"`
	IsPublic            bool          `json:"isPublic" db:"is_public"`
	CreatedAt           time.Time     `json:"createdAt" db:"created_at"`
	UpdatedAt           time.Time     `json:"updatedAt" db:"updated_at"`

	// Related data
	Creator      User              `json:"creator,omitempty"`
	Destinations []Destination     `json:"destinations,omitempty"`
	Participants []TourParticipant `json:"participants,omitempty"`
	Itinerary    []ItineraryItem   `json:"itinerary,omitempty"`
}

type TourParticipant struct {
	ID           uuid.UUID `json:"id" db:"id"`
	TourID       uuid.UUID `json:"tourId" db:"tour_id"`
	UserID       uuid.UUID `json:"userId" db:"user_id"`
	Status       string    `json:"status" db:"status"` // invited, joined, declined, removed
	InvitedBy    uuid.UUID `json:"invitedBy" db:"invited_by"`
	JoinedAt     time.Time `json:"joinedAt" db:"joined_at"`
	Role         string    `json:"role" db:"role"` // participant, moderator
	Permissions  []string  `json:"permissions" db:"permissions"`

	// Related data
	User User `json:"user,omitempty"`
}

type ItineraryItem struct {
	ID            uuid.UUID  `json:"id" db:"id"`
	TourID        uuid.UUID  `json:"tourId" db:"tour_id"`
	DestinationID *uuid.UUID `json:"destinationId" db:"destination_id"`
	Day           int        `json:"day" db:"day" validate:"required,min=1"`
	Order         int        `json:"order" db:"order" validate:"required,min=0"`
	Title         string     `json:"title" db:"title" validate:"required,min=3,max=200"`
	Description   string     `json:"description" db:"description"`
	StartTime     *time.Time `json:"startTime" db:"start_time"`
	EndTime       *time.Time `json:"endTime" db:"end_time"`
	Location      string     `json:"location" db:"location"`
	Notes         string     `json:"notes" db:"notes"`
	EstimatedCost float64    `json:"estimatedCost" db:"estimated_cost"`
	ActivityType  string     `json:"activityType" db:"activity_type"` // transport, sightseeing, meal, accommodation
	CreatedAt     time.Time  `json:"createdAt" db:"created_at"`
	UpdatedAt     time.Time  `json:"updatedAt" db:"updated_at"`

	// Related data
	Destination *Destination `json:"destination,omitempty"`
}

type TourDestination struct {
	TourID        uuid.UUID `json:"tourId" db:"tour_id"`
	DestinationID uuid.UUID `json:"destinationId" db:"destination_id"`
	Order         int       `json:"order" db:"order"`
	DaysSpent     int       `json:"daysSpent" db:"days_spent"`
	AddedAt       time.Time `json:"addedAt" db:"added_at"`
}

type CreateTourRequest struct {
	Name            string   `json:"name" validate:"required,min=3,max=150"`
	Description     string   `json:"description" validate:"required,min=10,max=1000"`
	Duration        int      `json:"duration" validate:"required,min=1"`
	MinParticipants int      `json:"minParticipants" validate:"min=1"`
	MaxParticipants int      `json:"maxParticipants" validate:"min=1"`
	Tags            []string `json:"tags"`
	IsPublic        bool     `json:"isPublic"`
	StartDate       string   `json:"startDate" validate:"required"`
	Currency        string   `json:"currency" validate:"required,len=3"`
}

type UpdateTourRequest struct {
	Name            string   `json:"name" validate:"omitempty,min=3,max=150"`
	Description     string   `json:"description" validate:"omitempty,min=10,max=1000"`
	Duration        int      `json:"duration" validate:"omitempty,min=1"`
	MinParticipants int      `json:"minParticipants" validate:"omitempty,min=1"`
	MaxParticipants int      `json:"maxParticipants" validate:"omitempty,min=1"`
	Tags            []string `json:"tags"`
	IsPublic        *bool    `json:"isPublic"`
	StartDate       string   `json:"startDate"`
	Status          string   `json:"status" validate:"omitempty,oneof=draft active completed cancelled"`
}

type TourInviteRequest struct {
	UserIDs []uuid.UUID `json:"userIds" validate:"required,min=1"`
	Message string      `json:"message" validate:"max=500"`
}

type JoinTourRequest struct {
	ShareCode string `json:"shareCode" validate:"required"`
}

type TourFilter struct {
	CreatorID       *uuid.UUID `json:"creatorId" form:"creatorId"`
	Status          string     `json:"status" form:"status"`
	MinPrice        float64    `json:"minPrice" form:"minPrice"`
	MaxPrice        float64    `json:"maxPrice" form:"maxPrice"`
	MinDuration     int        `json:"minDuration" form:"minDuration"`
	MaxDuration     int        `json:"maxDuration" form:"maxDuration"`
	StartDateFrom   string     `json:"startDateFrom" form:"startDateFrom"`
	StartDateTo     string     `json:"startDateTo" form:"startDateTo"`
	Tags            []string   `json:"tags" form:"tags"`
	IsPublic        *bool      `json:"isPublic" form:"isPublic"`
	HasAvailability *bool      `json:"hasAvailability" form:"hasAvailability"`
	SortBy          string     `json:"sortBy" form:"sortBy"` // created_at, start_date, price, participants
	SortOrder       string     `json:"sortOrder" form:"sortOrder"` // asc, desc
	Page            int        `json:"page" form:"page"`
	Limit           int        `json:"limit" form:"limit"`
	Search          string     `json:"search" form:"search"`
}

type TourStats struct {
	TotalTours       int     `json:"totalTours"`
	ActiveTours      int     `json:"activeTours"`
	CompletedTours   int     `json:"completedTours"`
	TotalParticipants int    `json:"totalParticipants"`
	AverageRating    float64 `json:"averageRating"`
	TotalRevenue     float64 `json:"totalRevenue"`
}

func (t *Tour) BeforeCreate() {
	t.ID = uuid.New()
	t.Status = "draft"
	t.CurrentParticipants = 1 // Creator is first participant
	t.IsShared = false
	t.IsBookmarked = false
	t.ShareCode = generateShareCode()
	t.CreatedAt = time.Now()
	t.UpdatedAt = time.Now()
}

func (t *Tour) BeforeUpdate() {
	t.UpdatedAt = time.Now()
}

func (t *Tour) CanJoin() bool {
	return t.Status == "active" && t.CurrentParticipants < t.MaxParticipants
}

func (t *Tour) IsCreator(userID uuid.UUID) bool {
	return t.CreatorID == userID
}

func (t *Tour) GenerateDeepLink(baseURL string) string {
	return baseURL + "/tour/" + t.ID.String() + "?code=" + t.ShareCode
}

func generateShareCode() string {
	// Generate a random 8-character code
	// In a real implementation, use crypto/rand
	return uuid.New().String()[:8]
}

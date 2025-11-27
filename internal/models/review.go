package models

import (
	"time"

	"github.com/google/uuid"
)

type Review struct {
	ID            uuid.UUID `json:"id" db:"id"`
	UserID        uuid.UUID `json:"userId" db:"user_id"`
	DestinationID uuid.UUID `json:"destinationId" db:"destination_id"`
	TourID        *uuid.UUID `json:"tourId" db:"tour_id"` // Optional: if review is for a tour
	Title         string    `json:"title" db:"title" validate:"required,min=5,max=200"`
	Comment       string    `json:"comment" db:"comment" validate:"required,min=10,max=2000"`
	Rating        float64   `json:"rating" db:"rating" validate:"required,min=1,max=5"`
	ImageUrls     []string  `json:"imageUrls" db:"image_urls"`
	IsVerified    bool      `json:"isVerified" db:"is_verified"`
	HelpfulCount  int       `json:"helpfulCount" db:"helpful_count"`
	Status        string    `json:"status" db:"status"` // pending, approved, rejected
	VisitDate     *time.Time `json:"visitDate" db:"visit_date"`
	TravelType    string    `json:"travelType" db:"travel_type"` // solo, couple, family, business, friends
	CreatedAt     time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt     time.Time `json:"updatedAt" db:"updated_at"`

	// Related data
	User        User         `json:"user,omitempty"`
	Destination *Destination `json:"destination,omitempty"`
	Tour        *Tour        `json:"tour,omitempty"`
}

type ReviewHelpful struct {
	ID       uuid.UUID `json:"id" db:"id"`
	ReviewID uuid.UUID `json:"reviewId" db:"review_id"`
	UserID   uuid.UUID `json:"userId" db:"user_id"`
	IsHelpful bool     `json:"isHelpful" db:"is_helpful"`
	CreatedAt time.Time `json:"createdAt" db:"created_at"`
}

type CreateReviewRequest struct {
	DestinationID uuid.UUID  `json:"destinationId" validate:"required"`
	TourID        *uuid.UUID `json:"tourId"`
	Title         string     `json:"title" validate:"required,min=5,max=200"`
	Comment       string     `json:"comment" validate:"required,min=10,max=2000"`
	Rating        float64    `json:"rating" validate:"required,min=1,max=5"`
	VisitDate     *time.Time `json:"visitDate"`
	TravelType    string     `json:"travelType" validate:"oneof=solo couple family business friends"`
}

type UpdateReviewRequest struct {
	Title      string     `json:"title" validate:"omitempty,min=5,max=200"`
	Comment    string     `json:"comment" validate:"omitempty,min=10,max=2000"`
	Rating     float64    `json:"rating" validate:"omitempty,min=1,max=5"`
	VisitDate  *time.Time `json:"visitDate"`
	TravelType string     `json:"travelType" validate:"omitempty,oneof=solo couple family business friends"`
}

type ReviewFilter struct {
	DestinationID *uuid.UUID `json:"destinationId" form:"destinationId"`
	UserID        *uuid.UUID `json:"userId" form:"userId"`
	TourID        *uuid.UUID `json:"tourId" form:"tourId"`
	MinRating     float64    `json:"minRating" form:"minRating"`
	MaxRating     float64    `json:"maxRating" form:"maxRating"`
	TravelType    string     `json:"travelType" form:"travelType"`
	Status        string     `json:"status" form:"status"`
	IsVerified    *bool      `json:"isVerified" form:"isVerified"`
	HasImages     *bool      `json:"hasImages" form:"hasImages"`
	SortBy        string     `json:"sortBy" form:"sortBy"` // created_at, rating, helpful_count
	SortOrder     string     `json:"sortOrder" form:"sortOrder"` // asc, desc
	Page          int        `json:"page" form:"page"`
	Limit         int        `json:"limit" form:"limit"`
	Search        string     `json:"search" form:"search"`
}

type ReviewStats struct {
	TotalReviews   int     `json:"totalReviews"`
	AverageRating  float64 `json:"averageRating"`
	RatingBreakdown map[int]int `json:"ratingBreakdown"` // rating -> count
	VerifiedCount  int     `json:"verifiedCount"`
	WithImagesCount int    `json:"withImagesCount"`
}

type ReviewResponse struct {
	Review
	UserName      string `json:"userName"`
	UserAvatarUrl string `json:"userAvatarUrl"`
	IsOwner       bool   `json:"isOwner"`
	IsHelpful     *bool  `json:"isHelpful,omitempty"` // null if not logged in, true/false if voted
}

func (r *Review) BeforeCreate() {
	r.ID = uuid.New()
	r.Status = "pending"
	r.IsVerified = false
	r.HelpfulCount = 0
	r.CreatedAt = time.Now()
	r.UpdatedAt = time.Now()
}

func (r *Review) BeforeUpdate() {
	r.UpdatedAt = time.Now()
}

func (r *Review) CanEdit(userID uuid.UUID) bool {
	return r.UserID == userID && time.Since(r.CreatedAt) < 24*time.Hour
}

func (r *Review) CanDelete(userID uuid.UUID) bool {
	return r.UserID == userID
}

// Chat and Message models for real-time communication
type ChatRoom struct {
	ID           uuid.UUID `json:"id" db:"id"`
	TourID       *uuid.UUID `json:"tourId" db:"tour_id"`
	Name         string    `json:"name" db:"name"`
	Type         string    `json:"type" db:"type"` // tour, direct, group
	IsPrivate    bool      `json:"isPrivate" db:"is_private"`
	CreatedBy    uuid.UUID `json:"createdBy" db:"created_by"`
	LastMessage  *Message  `json:"lastMessage,omitempty"`
	LastActivity time.Time `json:"lastActivity" db:"last_activity"`
	CreatedAt    time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt    time.Time `json:"updatedAt" db:"updated_at"`

	// Related data
	Participants []ChatParticipant `json:"participants,omitempty"`
	Messages     []Message         `json:"messages,omitempty"`
}

type ChatParticipant struct {
	ID       uuid.UUID `json:"id" db:"id"`
	ChatID   uuid.UUID `json:"chatId" db:"chat_id"`
	UserID   uuid.UUID `json:"userId" db:"user_id"`
	Role     string    `json:"role" db:"role"` // admin, member
	JoinedAt time.Time `json:"joinedAt" db:"joined_at"`
	LastRead time.Time `json:"lastRead" db:"last_read"`

	// Related data
	User User `json:"user,omitempty"`
}

type Message struct {
	ID           uuid.UUID `json:"id" db:"id"`
	ChatID       uuid.UUID `json:"chatId" db:"chat_id"`
	UserID       uuid.UUID `json:"userId" db:"user_id"`
	Content      string    `json:"content" db:"content"`
	MessageType  string    `json:"messageType" db:"message_type"` // text, image, location, tour_share
	AttachmentURL *string  `json:"attachmentUrl" db:"attachment_url"`
	ReplyToID    *uuid.UUID `json:"replyToId" db:"reply_to_id"`
	IsEdited     bool      `json:"isEdited" db:"is_edited"`
	CreatedAt    time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt    time.Time `json:"updatedAt" db:"updated_at"`

	// Related data
	User    User     `json:"user,omitempty"`
	ReplyTo *Message `json:"replyTo,omitempty"`
}

type SendMessageRequest struct {
	ChatID        uuid.UUID  `json:"chatId" validate:"required"`
	Content       string     `json:"content" validate:"required,min=1,max=1000"`
	MessageType   string     `json:"messageType" validate:"oneof=text image location tour_share"`
	AttachmentURL *string    `json:"attachmentUrl"`
	ReplyToID     *uuid.UUID `json:"replyToId"`
}

func (c *ChatRoom) BeforeCreate() {
	c.ID = uuid.New()
	c.LastActivity = time.Now()
	c.CreatedAt = time.Now()
	c.UpdatedAt = time.Now()
}

func (m *Message) BeforeCreate() {
	m.ID = uuid.New()
	m.IsEdited = false
	m.CreatedAt = time.Now()
	m.UpdatedAt = time.Now()
}

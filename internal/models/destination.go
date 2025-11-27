package models

import (
	"time"

	"github.com/google/uuid"
)

type Destination struct {
	ID               uuid.UUID `json:"id" db:"id"`
	Name             string    `json:"name" db:"name" validate:"required,min=2,max=100"`
	Description      string    `json:"description" db:"description" validate:"required,min=10,max=500"`
	LongDescription  string    `json:"longDescription" db:"long_description" validate:"required,min=50,max=2000"`
	Country          string    `json:"country" db:"country" validate:"required,min=2,max=100"`
	City             string    `json:"city" db:"city" validate:"required,min=2,max=100"`
	Latitude         float64   `json:"latitude" db:"latitude" validate:"required,latitude"`
	Longitude        float64   `json:"longitude" db:"longitude" validate:"required,longitude"`
	ImageUrls        []string  `json:"imageUrls" db:"image_urls"`
	VideoUrls        []string  `json:"videoUrls" db:"video_urls"`
	Rating           float64   `json:"rating" db:"rating"`
	ReviewCount      int       `json:"reviewCount" db:"review_count"`
	Price            float64   `json:"price" db:"price" validate:"min=0"`
	Currency         string    `json:"currency" db:"currency" validate:"required,len=3"`
	IsPopular        bool      `json:"isPopular" db:"is_popular"`
	IsFeatured       bool      `json:"isFeatured" db:"is_featured"`
	BestTimeToVisit  string    `json:"bestTimeToVisit" db:"best_time_to_visit"`
	Activities       []string  `json:"activities" db:"activities"`
	Attractions      []string  `json:"attractions" db:"attractions"`
	Categories       []string  `json:"categories" db:"categories"`
	AdditionalInfo   string    `json:"additionalInfo" db:"additional_info"` // JSON field
	CreatedAt        time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt        time.Time `json:"updatedAt" db:"updated_at"`

	// Related data loaded separately
	Reviews []Review `json:"reviews,omitempty"`
	Hotels  []Hotel  `json:"hotels,omitempty"`
}

type DestinationRequest struct {
	Name            string   `json:"name" validate:"required,min=2,max=100"`
	Description     string   `json:"description" validate:"required,min=10,max=500"`
	LongDescription string   `json:"longDescription" validate:"required,min=50,max=2000"`
	Country         string   `json:"country" validate:"required,min=2,max=100"`
	City            string   `json:"city" validate:"required,min=2,max=100"`
	Latitude        float64  `json:"latitude" validate:"required,latitude"`
	Longitude       float64  `json:"longitude" validate:"required,longitude"`
	Price           float64  `json:"price" validate:"min=0"`
	Currency        string   `json:"currency" validate:"required,len=3"`
	BestTimeToVisit string   `json:"bestTimeToVisit"`
	Activities      []string `json:"activities"`
	Attractions     []string `json:"attractions"`
	Categories      []string `json:"categories"`
	AdditionalInfo  string   `json:"additionalInfo"`
}

type DestinationResponse struct {
	Destination
	TotalReviews int     `json:"totalReviews"`
	AvgRating    float64 `json:"avgRating"`
	HotelCount   int     `json:"hotelCount"`
	MinPrice     float64 `json:"minPrice"`
	MaxPrice     float64 `json:"maxPrice"`
}

type DestinationFilter struct {
	Country       string   `json:"country" form:"country"`
	City          string   `json:"city" form:"city"`
	Categories    []string `json:"categories" form:"categories"`
	MinPrice      float64  `json:"minPrice" form:"minPrice"`
	MaxPrice      float64  `json:"maxPrice" form:"maxPrice"`
	MinRating     float64  `json:"minRating" form:"minRating"`
	IsPopular     *bool    `json:"isPopular" form:"isPopular"`
	IsFeatured    *bool    `json:"isFeatured" form:"isFeatured"`
	Activities    []string `json:"activities" form:"activities"`
	SortBy        string   `json:"sortBy" form:"sortBy"` // price, rating, name, created_at
	SortOrder     string   `json:"sortOrder" form:"sortOrder"` // asc, desc
	Page          int      `json:"page" form:"page"`
	Limit         int      `json:"limit" form:"limit"`
	Search        string   `json:"search" form:"search"`
	NearLatitude  float64  `json:"nearLatitude" form:"nearLatitude"`
	NearLongitude float64  `json:"nearLongitude" form:"nearLongitude"`
	RadiusKm      float64  `json:"radiusKm" form:"radiusKm"`
}

func (d *Destination) BeforeCreate() {
	d.ID = uuid.New()
	d.CreatedAt = time.Now()
	d.UpdatedAt = time.Now()
}

func (d *Destination) BeforeUpdate() {
	d.UpdatedAt = time.Now()
}

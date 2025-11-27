package models

import (
	"time"

	"github.com/google/uuid"
)

type Hotel struct {
	ID            uuid.UUID `json:"id" db:"id"`
	Name          string    `json:"name" db:"name" validate:"required,min=2,max=200"`
	Description   string    `json:"description" db:"description" validate:"required,min=10,max=1000"`
	Address       string    `json:"address" db:"address" validate:"required,min=10,max=300"`
	DestinationID uuid.UUID `json:"destinationId" db:"destination_id"`
	Latitude      float64   `json:"latitude" db:"latitude" validate:"required,latitude"`
	Longitude     float64   `json:"longitude" db:"longitude" validate:"required,longitude"`
	ImageUrls     []string  `json:"imageUrls" db:"image_urls"`
	Rating        float64   `json:"rating" db:"rating"`
	ReviewCount   int       `json:"reviewCount" db:"review_count"`
	PricePerNight float64   `json:"pricePerNight" db:"price_per_night" validate:"min=0"`
	Currency      string    `json:"currency" db:"currency" validate:"required,len=3"`
	Amenities     []string  `json:"amenities" db:"amenities"`
	RoomTypes     []string  `json:"roomTypes" db:"room_types"`
	IsAvailable   bool      `json:"isAvailable" db:"is_available"`
	IsFeatured    bool      `json:"isFeatured" db:"is_featured"`
	ContactPhone  string    `json:"contactPhone" db:"contact_phone"`
	ContactEmail  string    `json:"contactEmail" db:"contact_email" validate:"omitempty,email"`
	Website       string    `json:"website" db:"website"`
	CheckInTime   string    `json:"checkInTime" db:"check_in_time"`
	CheckOutTime  string    `json:"checkOutTime" db:"check_out_time"`
	StarRating    int       `json:"starRating" db:"star_rating" validate:"min=1,max=5"`
	Category      string    `json:"category" db:"category"` // luxury, budget, boutique, resort
	CreatedAt     time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt     time.Time `json:"updatedAt" db:"updated_at"`

	// Related data
	Destination *Destination   `json:"destination,omitempty"`
	Rooms       []Room         `json:"rooms,omitempty"`
	Reviews     []HotelReview  `json:"reviews,omitempty"`
	Bookings    []HotelBooking `json:"bookings,omitempty"`
}

type Room struct {
	ID           uuid.UUID `json:"id" db:"id"`
	HotelID      uuid.UUID `json:"hotelId" db:"hotel_id"`
	Type         string    `json:"type" db:"type" validate:"required"` // single, double, suite, deluxe
	Name         string    `json:"name" db:"name" validate:"required,min=3,max=100"`
	Description  string    `json:"description" db:"description"`
	MaxOccupancy int       `json:"maxOccupancy" db:"max_occupancy" validate:"required,min=1"`
	Size         float64   `json:"size" db:"size"` // in square meters
	PricePerNight float64  `json:"pricePerNight" db:"price_per_night" validate:"min=0"`
	Currency     string    `json:"currency" db:"currency" validate:"required,len=3"`
	ImageUrls    []string  `json:"imageUrls" db:"image_urls"`
	Amenities    []string  `json:"amenities" db:"amenities"`
	IsAvailable  bool      `json:"isAvailable" db:"is_available"`
	TotalRooms   int       `json:"totalRooms" db:"total_rooms" validate:"required,min=1"`
	CreatedAt    time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt    time.Time `json:"updatedAt" db:"updated_at"`
}

type HotelBooking struct {
	ID               uuid.UUID `json:"id" db:"id"`
	UserID           uuid.UUID `json:"userId" db:"user_id"`
	HotelID          uuid.UUID `json:"hotelId" db:"hotel_id"`
	RoomID           uuid.UUID `json:"roomId" db:"room_id"`
	CheckInDate      time.Time `json:"checkInDate" db:"check_in_date" validate:"required"`
	CheckOutDate     time.Time `json:"checkOutDate" db:"check_out_date" validate:"required"`
	Guests           int       `json:"guests" db:"guests" validate:"required,min=1"`
	TotalPrice       float64   `json:"totalPrice" db:"total_price" validate:"min=0"`
	Currency         string    `json:"currency" db:"currency" validate:"required,len=3"`
	Status           string    `json:"status" db:"status"` // pending, confirmed, cancelled, completed
	PaymentStatus    string    `json:"paymentStatus" db:"payment_status"` // pending, paid, refunded
	PaymentMethod    string    `json:"paymentMethod" db:"payment_method"`
	BookingReference string    `json:"bookingReference" db:"booking_reference"`
	GuestName        string    `json:"guestName" db:"guest_name" validate:"required,min=2,max=100"`
	GuestEmail       string    `json:"guestEmail" db:"guest_email" validate:"required,email"`
	GuestPhone       string    `json:"guestPhone" db:"guest_phone"`
	SpecialRequests  string    `json:"specialRequests" db:"special_requests"`
	CreatedAt        time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt        time.Time `json:"updatedAt" db:"updated_at"`

	// Related data
	User  User  `json:"user,omitempty"`
	Hotel Hotel `json:"hotel,omitempty"`
	Room  Room  `json:"room,omitempty"`
}

type HotelReview struct {
	ID             uuid.UUID `json:"id" db:"id"`
	UserID         uuid.UUID `json:"userId" db:"user_id"`
	HotelID        uuid.UUID `json:"hotelId" db:"hotel_id"`
	BookingID      *uuid.UUID `json:"bookingId" db:"booking_id"`
	Rating         float64   `json:"rating" db:"rating" validate:"required,min=1,max=5"`
	Title          string    `json:"title" db:"title" validate:"required,min=5,max=200"`
	Comment        string    `json:"comment" db:"comment" validate:"required,min=10,max=1000"`
	CleanlinessRating float64  `json:"cleanlinessRating" db:"cleanliness_rating" validate:"min=1,max=5"`
	ServiceRating  float64   `json:"serviceRating" db:"service_rating" validate:"min=1,max=5"`
	LocationRating float64   `json:"locationRating" db:"location_rating" validate:"min=1,max=5"`
	ValueRating    float64   `json:"valueRating" db:"value_rating" validate:"min=1,max=5"`
	ImageUrls      []string  `json:"imageUrls" db:"image_urls"`
	IsVerified     bool      `json:"isVerified" db:"is_verified"`
	HelpfulCount   int       `json:"helpfulCount" db:"helpful_count"`
	Status         string    `json:"status" db:"status"` // pending, approved, rejected
	CreatedAt      time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt      time.Time `json:"updatedAt" db:"updated_at"`

	// Related data
	User User `json:"user,omitempty"`
}

type HotelSearchRequest struct {
	DestinationID    *uuid.UUID `json:"destinationId" form:"destinationId"`
	City             string     `json:"city" form:"city"`
	Country          string     `json:"country" form:"country"`
	CheckInDate      string     `json:"checkInDate" form:"checkInDate" validate:"required"`
	CheckOutDate     string     `json:"checkOutDate" form:"checkOutDate" validate:"required"`
	Guests           int        `json:"guests" form:"guests" validate:"required,min=1"`
	MinPrice         float64    `json:"minPrice" form:"minPrice"`
	MaxPrice         float64    `json:"maxPrice" form:"maxPrice"`
	StarRating       []int      `json:"starRating" form:"starRating"`
	Amenities        []string   `json:"amenities" form:"amenities"`
	RoomTypes        []string   `json:"roomTypes" form:"roomTypes"`
	Category         []string   `json:"category" form:"category"`
	SortBy           string     `json:"sortBy" form:"sortBy"` // price, rating, distance, name
	SortOrder        string     `json:"sortOrder" form:"sortOrder"` // asc, desc
	Page             int        `json:"page" form:"page"`
	Limit            int        `json:"limit" form:"limit"`
	NearLatitude     float64    `json:"nearLatitude" form:"nearLatitude"`
	NearLongitude    float64    `json:"nearLongitude" form:"nearLongitude"`
	RadiusKm         float64    `json:"radiusKm" form:"radiusKm"`
}

type CreateBookingRequest struct {
	HotelID         uuid.UUID `json:"hotelId" validate:"required"`
	RoomID          uuid.UUID `json:"roomId" validate:"required"`
	CheckInDate     string    `json:"checkInDate" validate:"required"`
	CheckOutDate    string    `json:"checkOutDate" validate:"required"`
	Guests          int       `json:"guests" validate:"required,min=1"`
	GuestName       string    `json:"guestName" validate:"required,min=2,max=100"`
	GuestEmail      string    `json:"guestEmail" validate:"required,email"`
	GuestPhone      string    `json:"guestPhone"`
	SpecialRequests string    `json:"specialRequests" validate:"max=500"`
	PaymentMethod   string    `json:"paymentMethod" validate:"required"`
}

type HotelAvailability struct {
	HotelID       uuid.UUID `json:"hotelId"`
	RoomID        uuid.UUID `json:"roomId"`
	Date          time.Time `json:"date"`
	AvailableRooms int      `json:"availableRooms"`
	Price         float64   `json:"price"`
	Currency      string    `json:"currency"`
}

func (h *Hotel) BeforeCreate() {
	h.ID = uuid.New()
	h.IsAvailable = true
	h.CheckInTime = "14:00"
	h.CheckOutTime = "12:00"
	h.CreatedAt = time.Now()
	h.UpdatedAt = time.Now()
}

func (h *Hotel) BeforeUpdate() {
	h.UpdatedAt = time.Now()
}

func (hb *HotelBooking) BeforeCreate() {
	hb.ID = uuid.New()
	hb.Status = "pending"
	hb.PaymentStatus = "pending"
	hb.BookingReference = generateBookingReference()
	hb.CreatedAt = time.Now()
	hb.UpdatedAt = time.Now()
}

func (hb *HotelBooking) BeforeUpdate() {
	hb.UpdatedAt = time.Now()
}

func (hb *HotelBooking) CalculateNights() int {
	return int(hb.CheckOutDate.Sub(hb.CheckInDate).Hours() / 24)
}

func (hb *HotelBooking) CanCancel() bool {
	return hb.Status == "confirmed" && time.Now().Before(hb.CheckInDate.AddDate(0, 0, -1))
}

func generateBookingReference() string {
	// Generate a booking reference like "TL-XXXXXXXX"
	return "TL-" + uuid.New().String()[:8]
}

package services

import (
	"database/sql"

	"github.com/redis/go-redis/v9"
	"tour_leader_api/internal/config"
)

// TourService handles tour-related business logic
type TourService struct {
	db     *sql.DB
	rdb    *redis.Client
	config *config.Config
}

func NewTourService(db *sql.DB, rdb *redis.Client, config *config.Config) *TourService {
	return &TourService{db: db, rdb: rdb, config: config}
}

// HotelService handles hotel-related business logic
type HotelService struct {
	db  *sql.DB
	rdb *redis.Client
}

func NewHotelService(db *sql.DB, rdb *redis.Client) *HotelService {
	return &HotelService{db: db, rdb: rdb}
}

// ReviewService handles review-related business logic
type ReviewService struct {
	db  *sql.DB
	rdb *redis.Client
}

func NewReviewService(db *sql.DB, rdb *redis.Client) *ReviewService {
	return &ReviewService{db: db, rdb: rdb}
}

// BookingService handles booking-related business logic
type BookingService struct {
	db  *sql.DB
	rdb *redis.Client
}

func NewBookingService(db *sql.DB, rdb *redis.Client) *BookingService {
	return &BookingService{db: db, rdb: rdb}
}

// ChatService handles chat-related business logic
type ChatService struct {
	db  *sql.DB
	rdb *redis.Client
}

func NewChatService(db *sql.DB, rdb *redis.Client) *ChatService {
	return &ChatService{db: db, rdb: rdb}
}

// FileService handles file upload and management
type FileService struct {
	config *config.Config
}

func NewFileService(config *config.Config) *FileService {
	return &FileService{config: config}
}

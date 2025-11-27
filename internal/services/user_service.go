package services

import (
	"database/sql"

	"github.com/redis/go-redis/v9"
	"tour_leader_api/internal/config"
)

type UserService struct {
	db     *sql.DB
	rdb    *redis.Client
	config *config.Config
}

func NewUserService(db *sql.DB, rdb *redis.Client, config *config.Config) *UserService {
	return &UserService{
		db:     db,
		rdb:    rdb,
		config: config,
	}
}

// TODO: Implement user service methods
// - Register user
// - Login user
// - Update profile
// - Change password
// - Get user by ID
// - Get user activities
// - Get user statistics

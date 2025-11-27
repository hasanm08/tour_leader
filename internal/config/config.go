package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	Server   ServerConfig
	Database DatabaseConfig
	Redis    RedisConfig
	JWT      JWTConfig
	AWS      AWSConfig
	App      AppConfig
}

type ServerConfig struct {
	Port     string
	Host     string
	Mode     string
	CORSMode string
}

type DatabaseConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	DBName   string
	SSLMode  string
}

type RedisConfig struct {
	Host     string
	Port     string
	Password string
	DB       int
}

type JWTConfig struct {
	SecretKey      string
	ExpirationTime int // in hours
}

type AWSConfig struct {
	AccessKey string
	SecretKey string
	Region    string
	S3Bucket  string
}

type AppConfig struct {
	Name        string
	Version     string
	Environment string
	BaseURL     string
	DeepLinkURL string
}

func LoadConfig() *Config {
	// Load .env file if it exists
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	redisDB, _ := strconv.Atoi(getEnv("REDIS_DB", "0"))
	jwtExp, _ := strconv.Atoi(getEnv("JWT_EXPIRATION_HOURS", "24"))

	return &Config{
		Server: ServerConfig{
			Port:     getEnv("SERVER_PORT", "8080"),
			Host:     getEnv("SERVER_HOST", "localhost"),
			Mode:     getEnv("GIN_MODE", "debug"),
			CORSMode: getEnv("CORS_MODE", "development"),
		},
		Database: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "5432"),
			User:     getEnv("DB_USER", "postgres"),
			Password: getEnv("DB_PASSWORD", "password"),
			DBName:   getEnv("DB_NAME", "tour_leader"),
			SSLMode:  getEnv("DB_SSL_MODE", "disable"),
		},
		Redis: RedisConfig{
			Host:     getEnv("REDIS_HOST", "localhost"),
			Port:     getEnv("REDIS_PORT", "6379"),
			Password: getEnv("REDIS_PASSWORD", ""),
			DB:       redisDB,
		},
		JWT: JWTConfig{
			SecretKey:      getEnv("JWT_SECRET_KEY", "your-super-secret-key-change-in-production"),
			ExpirationTime: jwtExp,
		},
		AWS: AWSConfig{
			AccessKey: getEnv("AWS_ACCESS_KEY_ID", ""),
			SecretKey: getEnv("AWS_SECRET_ACCESS_KEY", ""),
			Region:    getEnv("AWS_REGION", "us-east-1"),
			S3Bucket:  getEnv("AWS_S3_BUCKET", "tour-leader-uploads"),
		},
		App: AppConfig{
			Name:        getEnv("APP_NAME", "TourLeader API"),
			Version:     getEnv("APP_VERSION", "1.0.0"),
			Environment: getEnv("APP_ENV", "development"),
			BaseURL:     getEnv("APP_BASE_URL", "http://localhost:8080"),
			DeepLinkURL: getEnv("DEEP_LINK_URL", "https://tourleader.app"),
		},
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func (c *Config) GetDSN() string {
	return "host=" + c.Database.Host +
		" port=" + c.Database.Port +
		" user=" + c.Database.User +
		" password=" + c.Database.Password +
		" dbname=" + c.Database.DBName +
		" sslmode=" + c.Database.SSLMode
}

func (c *Config) GetRedisAddr() string {
	return c.Redis.Host + ":" + c.Redis.Port
}

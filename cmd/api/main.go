package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"tour_leader_api/internal/config"
	"tour_leader_api/internal/database"
	"tour_leader_api/internal/handlers"
	"tour_leader_api/internal/middleware"
	"tour_leader_api/internal/services"
	"tour_leader_api/internal/websocket"
	"tour_leader_api/pkg/logger"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	_ "tour_leader_api/docs" // Import docs for swagger
	ginSwagger "github.com/swaggo/gin-swagger"
	"github.com/swaggo/gin-swagger/swaggerFiles"
)

// @title TourLeader API
// @version 1.0
// @description A comprehensive travel platform API for managing destinations, tours, hotels, and bookings
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url http://www.tourleader.app/support
// @contact.email support@tourleader.app

// @license.name MIT
// @license.url https://opensource.org/licenses/MIT

// @host localhost:8080
// @BasePath /api/v1

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

func main() {
	// Load configuration
	cfg := config.LoadConfig()

	// Initialize logger
	logger := logger.NewLogger(cfg.App.Environment)

	// Set Gin mode
	gin.SetMode(cfg.Server.Mode)

	// Connect to database
	db, err := database.Connect(cfg.GetDSN())
	if err != nil {
		logger.Fatal("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Run migrations
	if err := database.RunMigrations(cfg.GetDSN()); err != nil {
		logger.Error("Failed to run migrations: %v", err)
	}

	// Connect to Redis
	rdb := redis.NewClient(&redis.Options{
		Addr:     cfg.GetRedisAddr(),
		Password: cfg.Redis.Password,
		DB:       cfg.Redis.DB,
	})

	// Test Redis connection
	ctx := context.Background()
	if err := rdb.Ping(ctx).Err(); err != nil {
		logger.Error("Failed to connect to Redis: %v", err)
	} else {
		logger.Info("Connected to Redis successfully")
	}

	// Initialize services
	userService := services.NewUserService(db, rdb, cfg)
	destinationService := services.NewDestinationService(db, rdb)
	tourService := services.NewTourService(db, rdb, cfg)
	hotelService := services.NewHotelService(db, rdb)
	reviewService := services.NewReviewService(db, rdb)
	bookingService := services.NewBookingService(db, rdb)
	chatService := services.NewChatService(db, rdb)
	fileService := services.NewFileService(cfg)

	// Initialize WebSocket hub
	wsHub := websocket.NewHub()
	go wsHub.Run()

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(userService, cfg)
	destinationHandler := handlers.NewDestinationHandler(destinationService)
	tourHandler := handlers.NewTourHandler(tourService, userService)
	hotelHandler := handlers.NewHotelHandler(hotelService)
	reviewHandler := handlers.NewReviewHandler(reviewService, userService)
	bookingHandler := handlers.NewBookingHandler(bookingService, userService)
	chatHandler := handlers.NewChatHandler(chatService, wsHub)
	fileHandler := handlers.NewFileHandler(fileService)
	webhookHandler := handlers.NewWebhookHandler(cfg)

	// Initialize router
	router := setupRouter(cfg, logger, authHandler, destinationHandler, tourHandler,
		hotelHandler, reviewHandler, bookingHandler, chatHandler, fileHandler, webhookHandler)

	// Create HTTP server
	server := &http.Server{
		Addr:         cfg.Server.Host + ":" + cfg.Server.Port,
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in a goroutine
	go func() {
		logger.Info("Starting server on %s:%s", cfg.Server.Host, cfg.Server.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatal("Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Info("Shutting down server...")

	// The context is used to inform the server it has 30 seconds to finish
	// the request it is currently handling
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Shutdown server
	if err := server.Shutdown(ctx); err != nil {
		logger.Fatal("Server forced to shutdown: %v", err)
	}

	// Close WebSocket hub
	wsHub.Close()

	// Close Redis connection
	if err := rdb.Close(); err != nil {
		logger.Error("Failed to close Redis connection: %v", err)
	}

	logger.Info("Server exited")
}

func setupRouter(cfg *config.Config, logger *logger.Logger, authHandler *handlers.AuthHandler,
	destinationHandler *handlers.DestinationHandler, tourHandler *handlers.TourHandler,
	hotelHandler *handlers.HotelHandler, reviewHandler *handlers.ReviewHandler,
	bookingHandler *handlers.BookingHandler, chatHandler *handlers.ChatHandler,
	fileHandler *handlers.FileHandler, webhookHandler *handlers.WebhookHandler) *gin.Engine {

	router := gin.New()

	// Middleware
	router.Use(middleware.Logger(logger))
	router.Use(middleware.Recovery(logger))
	router.Use(middleware.CORS(cfg))
	router.Use(middleware.RateLimit())

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"timestamp": time.Now().Unix(),
			"version":   cfg.App.Version,
		})
	})

	// Swagger documentation
	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Static files
	router.Static("/static", "./static")

	// API routes
	api := router.Group("/api")
	{
		v1 := api.Group("/v1")
		{
			// Authentication routes
			auth := v1.Group("/auth")
			{
				auth.POST("/register", authHandler.Register)
				auth.POST("/login", authHandler.Login)
				auth.POST("/refresh", authHandler.RefreshToken)
				auth.POST("/logout", middleware.AuthRequired(), authHandler.Logout)
				auth.POST("/forgot-password", authHandler.ForgotPassword)
				auth.POST("/reset-password", authHandler.ResetPassword)
				auth.GET("/verify-email/:token", authHandler.VerifyEmail)
			}

			// User routes
			users := v1.Group("/users")
			users.Use(middleware.AuthRequired())
			{
				users.GET("/profile", authHandler.GetProfile)
				users.PUT("/profile", authHandler.UpdateProfile)
				users.POST("/change-password", authHandler.ChangePassword)
				users.POST("/upload-avatar", fileHandler.UploadAvatar)
				users.GET("/activities", authHandler.GetUserActivities)
				users.GET("/stats", authHandler.GetUserStats)
			}

			// Destination routes
			destinations := v1.Group("/destinations")
			{
				destinations.GET("", destinationHandler.GetDestinations)
				destinations.GET("/featured", destinationHandler.GetFeaturedDestinations)
				destinations.GET("/popular", destinationHandler.GetPopularDestinations)
				destinations.GET("/categories", destinationHandler.GetCategories)
				destinations.GET("/countries", destinationHandler.GetCountries)
				destinations.GET("/:id", destinationHandler.GetDestination)
				destinations.GET("/:id/hotels", destinationHandler.GetDestinationHotels)
				destinations.GET("/:id/reviews", destinationHandler.GetDestinationReviews)
				destinations.POST("/search", destinationHandler.SearchDestinations)

				// Protected destination routes
				destinationsAuth := destinations.Group("")
				destinationsAuth.Use(middleware.AuthRequired())
				{
					destinationsAuth.POST("", middleware.AdminRequired(), destinationHandler.CreateDestination)
					destinationsAuth.PUT("/:id", middleware.AdminRequired(), destinationHandler.UpdateDestination)
					destinationsAuth.DELETE("/:id", middleware.AdminRequired(), destinationHandler.DeleteDestination)
					destinationsAuth.POST("/:id/favorite", destinationHandler.ToggleFavorite)
					destinationsAuth.POST("/:id/upload-images", middleware.AdminRequired(), fileHandler.UploadDestinationImages)
				}
			}

			// Tour routes
			tours := v1.Group("/tours")
			{
				tours.GET("", tourHandler.GetTours)
				tours.GET("/public", tourHandler.GetPublicTours)
				tours.GET("/:id", tourHandler.GetTour)
				tours.POST("/:id/join", middleware.AuthRequired(), tourHandler.JoinTour)

				// Protected tour routes
				toursAuth := tours.Group("")
				toursAuth.Use(middleware.AuthRequired())
				{
					toursAuth.POST("", tourHandler.CreateTour)
					toursAuth.PUT("/:id", tourHandler.UpdateTour)
					toursAuth.DELETE("/:id", tourHandler.DeleteTour)
					toursAuth.POST("/:id/invite", tourHandler.InviteTour)
					toursAuth.POST("/:id/leave", tourHandler.LeaveTour)
					toursAuth.GET("/:id/participants", tourHandler.GetTourParticipants)
					toursAuth.POST("/:id/destinations", tourHandler.AddDestinationToTour)
					toursAuth.DELETE("/:id/destinations/:destinationId", tourHandler.RemoveDestinationFromTour)
					toursAuth.GET("/my", tourHandler.GetUserTours)
					toursAuth.GET("/:id/share", tourHandler.GenerateShareLink)
				}
			}

			// Hotel routes
			hotels := v1.Group("/hotels")
			{
				hotels.GET("", hotelHandler.GetHotels)
				hotels.GET("/:id", hotelHandler.GetHotel)
				hotels.POST("/search", hotelHandler.SearchHotels)
				hotels.GET("/:id/availability", hotelHandler.CheckAvailability)
				hotels.GET("/:id/reviews", hotelHandler.GetHotelReviews)

				// Protected hotel routes
				hotelsAuth := hotels.Group("")
				hotelsAuth.Use(middleware.AuthRequired())
				{
					hotelsAuth.POST("", middleware.AdminRequired(), hotelHandler.CreateHotel)
					hotelsAuth.PUT("/:id", middleware.AdminRequired(), hotelHandler.UpdateHotel)
					hotelsAuth.DELETE("/:id", middleware.AdminRequired(), hotelHandler.DeleteHotel)
				}
			}

			// Booking routes
			bookings := v1.Group("/bookings")
			bookings.Use(middleware.AuthRequired())
			{
				bookings.POST("/hotels", bookingHandler.CreateHotelBooking)
				bookings.GET("", bookingHandler.GetUserBookings)
				bookings.GET("/:id", bookingHandler.GetBooking)
				bookings.PUT("/:id/cancel", bookingHandler.CancelBooking)
				bookings.GET("/:id/receipt", bookingHandler.GetBookingReceipt)
			}

			// Review routes
			reviews := v1.Group("/reviews")
			{
				reviews.GET("", reviewHandler.GetReviews)
				reviews.GET("/:id", reviewHandler.GetReview)

				// Protected review routes
				reviewsAuth := reviews.Group("")
				reviewsAuth.Use(middleware.AuthRequired())
				{
					reviewsAuth.POST("", reviewHandler.CreateReview)
					reviewsAuth.PUT("/:id", reviewHandler.UpdateReview)
					reviewsAuth.DELETE("/:id", reviewHandler.DeleteReview)
					reviewsAuth.POST("/:id/helpful", reviewHandler.MarkHelpful)
					reviewsAuth.POST("/:id/upload-images", fileHandler.UploadReviewImages)
				}
			}

			// Chat routes
			chats := v1.Group("/chats")
			chats.Use(middleware.AuthRequired())
			{
				chats.GET("", chatHandler.GetUserChats)
				chats.POST("", chatHandler.CreateChat)
				chats.GET("/:id", chatHandler.GetChat)
				chats.GET("/:id/messages", chatHandler.GetChatMessages)
				chats.POST("/:id/messages", chatHandler.SendMessage)
				chats.PUT("/messages/:messageId", chatHandler.EditMessage)
				chats.DELETE("/messages/:messageId", chatHandler.DeleteMessage)
				chats.POST("/:id/join", chatHandler.JoinChat)
				chats.POST("/:id/leave", chatHandler.LeaveChat)
			}

			// WebSocket endpoint
			v1.GET("/ws", middleware.AuthRequired(), chatHandler.HandleWebSocket)

			// File upload routes
			files := v1.Group("/files")
			files.Use(middleware.AuthRequired())
			{
				files.POST("/upload", fileHandler.UploadFile)
				files.DELETE("/:id", fileHandler.DeleteFile)
			}

			// Webhook routes (for payment processing, etc.)
			webhooks := v1.Group("/webhooks")
			{
				webhooks.POST("/payment", webhookHandler.HandlePaymentWebhook)
				webhooks.POST("/email", webhookHandler.HandleEmailWebhook)
			}

			// Deep link routes
			deeplinks := v1.Group("/deeplinks")
			{
				deeplinks.GET("/tour/:id", tourHandler.HandleTourDeepLink)
			}
		}
	}

	return router
}

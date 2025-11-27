package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"tour_leader_api/internal/models"
	"tour_leader_api/internal/services"
	"tour_leader_api/pkg/response"
	"tour_leader_api/pkg/validation"
)

type DestinationHandler struct {
	destinationService *services.DestinationService
}

func NewDestinationHandler(destinationService *services.DestinationService) *DestinationHandler {
	return &DestinationHandler{
		destinationService: destinationService,
	}
}

// GetDestinations godoc
// @Summary Get destinations
// @Description Retrieve destinations with optional filtering and pagination
// @Tags destinations
// @Accept json
// @Produce json
// @Param country query string false "Filter by country"
// @Param city query string false "Filter by city"
// @Param categories query []string false "Filter by categories"
// @Param minPrice query number false "Minimum price filter"
// @Param maxPrice query number false "Maximum price filter"
// @Param minRating query number false "Minimum rating filter"
// @Param isPopular query boolean false "Filter popular destinations"
// @Param isFeatured query boolean false "Filter featured destinations"
// @Param search query string false "Search in name, description, country, city"
// @Param sortBy query string false "Sort by field (name, price, rating, created_at)"
// @Param sortOrder query string false "Sort order (asc, desc)"
// @Param page query int false "Page number"
// @Param limit query int false "Items per page"
// @Success 200 {object} response.APIResponse{data=[]models.DestinationResponse}
// @Failure 400 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /destinations [get]
func (h *DestinationHandler) GetDestinations(c *gin.Context) {
	var filter models.DestinationFilter

	// Parse query parameters
	if err := c.ShouldBindQuery(&filter); err != nil {
		response.BadRequest(c, "Invalid query parameters")
		return
	}

	// Set default values
	if filter.Page == 0 {
		filter.Page = 1
	}
	if filter.Limit == 0 {
		filter.Limit = 20
	}

	destinations, total, err := h.destinationService.GetDestinations(filter)
	if err != nil {
		response.InternalServerError(c, "Failed to retrieve destinations")
		return
	}

	response.PaginatedOK(c, destinations, filter.Page, filter.Limit, total)
}

// GetDestination godoc
// @Summary Get destination by ID
// @Description Retrieve a single destination by its ID
// @Tags destinations
// @Accept json
// @Produce json
// @Param id path string true "Destination ID"
// @Success 200 {object} response.APIResponse{data=models.DestinationResponse}
// @Failure 400 {object} response.APIResponse
// @Failure 404 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /destinations/{id} [get]
func (h *DestinationHandler) GetDestination(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		response.BadRequest(c, "Invalid destination ID")
		return
	}

	destination, err := h.destinationService.GetDestinationByID(id)
	if err != nil {
		response.InternalServerError(c, "Failed to retrieve destination")
		return
	}

	if destination == nil {
		response.NotFound(c, "Destination not found")
		return
	}

	response.OK(c, destination)
}

// CreateDestination godoc
// @Summary Create a new destination
// @Description Create a new destination (Admin only)
// @Tags destinations
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param destination body models.DestinationRequest true "Destination data"
// @Success 201 {object} response.APIResponse{data=models.Destination}
// @Failure 400 {object} response.APIResponse
// @Failure 401 {object} response.APIResponse
// @Failure 403 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /destinations [post]
func (h *DestinationHandler) CreateDestination(c *gin.Context) {
	var req models.DestinationRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request data")
		return
	}

	// Validate request
	if err := validation.ValidateStruct(&req); err != nil {
		response.ValidationError(c, err)
		return
	}

	destination, err := h.destinationService.CreateDestination(req)
	if err != nil {
		response.InternalServerError(c, "Failed to create destination")
		return
	}

	response.Created(c, destination)
}

// UpdateDestination godoc
// @Summary Update a destination
// @Description Update an existing destination (Admin only)
// @Tags destinations
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Destination ID"
// @Param destination body models.DestinationRequest true "Destination data"
// @Success 200 {object} response.APIResponse{data=models.Destination}
// @Failure 400 {object} response.APIResponse
// @Failure 401 {object} response.APIResponse
// @Failure 403 {object} response.APIResponse
// @Failure 404 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /destinations/{id} [put]
func (h *DestinationHandler) UpdateDestination(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		response.BadRequest(c, "Invalid destination ID")
		return
	}

	var req models.DestinationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request data")
		return
	}

	// Validate request
	if err := validation.ValidateStruct(&req); err != nil {
		response.ValidationError(c, err)
		return
	}

	destination, err := h.destinationService.UpdateDestination(id, req)
	if err != nil {
		if err.Error() == "destination not found" {
			response.NotFound(c, "Destination not found")
			return
		}
		response.InternalServerError(c, "Failed to update destination")
		return
	}

	response.OK(c, destination)
}

// DeleteDestination godoc
// @Summary Delete a destination
// @Description Delete an existing destination (Admin only)
// @Tags destinations
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Destination ID"
// @Success 204
// @Failure 400 {object} response.APIResponse
// @Failure 401 {object} response.APIResponse
// @Failure 403 {object} response.APIResponse
// @Failure 404 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /destinations/{id} [delete]
func (h *DestinationHandler) DeleteDestination(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		response.BadRequest(c, "Invalid destination ID")
		return
	}

	err = h.destinationService.DeleteDestination(id)
	if err != nil {
		if err.Error() == "destination not found" {
			response.NotFound(c, "Destination not found")
			return
		}
		response.InternalServerError(c, "Failed to delete destination")
		return
	}

	response.NoContent(c)
}

// GetFeaturedDestinations godoc
// @Summary Get featured destinations
// @Description Retrieve all featured destinations
// @Tags destinations
// @Accept json
// @Produce json
// @Success 200 {object} response.APIResponse{data=[]models.DestinationResponse}
// @Failure 500 {object} response.APIResponse
// @Router /destinations/featured [get]
func (h *DestinationHandler) GetFeaturedDestinations(c *gin.Context) {
	destinations, err := h.destinationService.GetFeaturedDestinations()
	if err != nil {
		response.InternalServerError(c, "Failed to retrieve featured destinations")
		return
	}

	response.OK(c, destinations)
}

// GetPopularDestinations godoc
// @Summary Get popular destinations
// @Description Retrieve all popular destinations
// @Tags destinations
// @Accept json
// @Produce json
// @Success 200 {object} response.APIResponse{data=[]models.DestinationResponse}
// @Failure 500 {object} response.APIResponse
// @Router /destinations/popular [get]
func (h *DestinationHandler) GetPopularDestinations(c *gin.Context) {
	destinations, err := h.destinationService.GetPopularDestinations()
	if err != nil {
		response.InternalServerError(c, "Failed to retrieve popular destinations")
		return
	}

	response.OK(c, destinations)
}

// GetCategories godoc
// @Summary Get destination categories
// @Description Retrieve all available destination categories
// @Tags destinations
// @Accept json
// @Produce json
// @Success 200 {object} response.APIResponse{data=[]string}
// @Failure 500 {object} response.APIResponse
// @Router /destinations/categories [get]
func (h *DestinationHandler) GetCategories(c *gin.Context) {
	categories, err := h.destinationService.GetCategories()
	if err != nil {
		response.InternalServerError(c, "Failed to retrieve categories")
		return
	}

	response.OK(c, categories)
}

// GetCountries godoc
// @Summary Get destination countries
// @Description Retrieve all available destination countries
// @Tags destinations
// @Accept json
// @Produce json
// @Success 200 {object} response.APIResponse{data=[]string}
// @Failure 500 {object} response.APIResponse
// @Router /destinations/countries [get]
func (h *DestinationHandler) GetCountries(c *gin.Context) {
	countries, err := h.destinationService.GetCountries()
	if err != nil {
		response.InternalServerError(c, "Failed to retrieve countries")
		return
	}

	response.OK(c, countries)
}

// SearchDestinations godoc
// @Summary Search destinations
// @Description Search destinations with advanced filtering
// @Tags destinations
// @Accept json
// @Produce json
// @Param filter body models.DestinationFilter true "Search filters"
// @Success 200 {object} response.APIResponse{data=[]models.DestinationResponse}
// @Failure 400 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /destinations/search [post]
func (h *DestinationHandler) SearchDestinations(c *gin.Context) {
	var filter models.DestinationFilter

	if err := c.ShouldBindJSON(&filter); err != nil {
		response.BadRequest(c, "Invalid search filters")
		return
	}

	// Set default values
	if filter.Page == 0 {
		filter.Page = 1
	}
	if filter.Limit == 0 {
		filter.Limit = 20
	}

	destinations, total, err := h.destinationService.GetDestinations(filter)
	if err != nil {
		response.InternalServerError(c, "Failed to search destinations")
		return
	}

	response.PaginatedOK(c, destinations, filter.Page, filter.Limit, total)
}

// GetDestinationHotels godoc
// @Summary Get hotels for a destination
// @Description Retrieve all hotels for a specific destination
// @Tags destinations
// @Accept json
// @Produce json
// @Param id path string true "Destination ID"
// @Param page query int false "Page number"
// @Param limit query int false "Items per page"
// @Success 200 {object} response.APIResponse{data=[]models.Hotel}
// @Failure 400 {object} response.APIResponse
// @Failure 404 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /destinations/{id}/hotels [get]
func (h *DestinationHandler) GetDestinationHotels(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		response.BadRequest(c, "Invalid destination ID")
		return
	}

	// Check if destination exists
	destination, err := h.destinationService.GetDestinationByID(id)
	if err != nil {
		response.InternalServerError(c, "Failed to verify destination")
		return
	}

	if destination == nil {
		response.NotFound(c, "Destination not found")
		return
	}

	// Parse pagination parameters
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

	// This would be implemented in hotel service
	// For now, return empty array
	hotels := []models.Hotel{}
	total := int64(0)

	response.PaginatedOK(c, hotels, page, limit, total)
}

// GetDestinationReviews godoc
// @Summary Get reviews for a destination
// @Description Retrieve all reviews for a specific destination
// @Tags destinations
// @Accept json
// @Produce json
// @Param id path string true "Destination ID"
// @Param page query int false "Page number"
// @Param limit query int false "Items per page"
// @Success 200 {object} response.APIResponse{data=[]models.Review}
// @Failure 400 {object} response.APIResponse
// @Failure 404 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /destinations/{id}/reviews [get]
func (h *DestinationHandler) GetDestinationReviews(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		response.BadRequest(c, "Invalid destination ID")
		return
	}

	// Check if destination exists
	destination, err := h.destinationService.GetDestinationByID(id)
	if err != nil {
		response.InternalServerError(c, "Failed to verify destination")
		return
	}

	if destination == nil {
		response.NotFound(c, "Destination not found")
		return
	}

	// Parse pagination parameters
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

	// This would be implemented in review service
	// For now, return empty array
	reviews := []models.Review{}
	total := int64(0)

	response.PaginatedOK(c, reviews, page, limit, total)
}

// ToggleFavorite godoc
// @Summary Toggle favorite destination
// @Description Add or remove a destination from user's favorites
// @Tags destinations
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Destination ID"
// @Success 200 {object} response.APIResponse{data=map[string]bool}
// @Failure 400 {object} response.APIResponse
// @Failure 401 {object} response.APIResponse
// @Failure 404 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /destinations/{id}/favorite [post]
func (h *DestinationHandler) ToggleFavorite(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		response.BadRequest(c, "Invalid destination ID")
		return
	}

	// Check if destination exists
	destination, err := h.destinationService.GetDestinationByID(id)
	if err != nil {
		response.InternalServerError(c, "Failed to verify destination")
		return
	}

	if destination == nil {
		response.NotFound(c, "Destination not found")
		return
	}

	// This would be implemented with user service to update favorites
	// For now, return a success response
	response.OK(c, map[string]bool{"favorited": true})
}

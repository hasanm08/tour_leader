package services

import (
	"database/sql"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"github.com/redis/go-redis/v9"

	"tour_leader_api/internal/models"
)

type DestinationService struct {
	db  *sql.DB
	rdb *redis.Client
}

func NewDestinationService(db *sql.DB, rdb *redis.Client) *DestinationService {
	return &DestinationService{
		db:  db,
		rdb: rdb,
	}
}

// GetDestinations retrieves destinations with filtering and pagination
func (s *DestinationService) GetDestinations(filter models.DestinationFilter) ([]models.DestinationResponse, int64, error) {
	query := `
		SELECT d.id, d.name, d.description, d.long_description, d.country, d.city,
			   d.latitude, d.longitude, d.image_urls, d.video_urls, d.rating, d.review_count,
			   d.price, d.currency, d.is_popular, d.is_featured, d.best_time_to_visit,
			   d.activities, d.attractions, d.categories, d.additional_info,
			   d.created_at, d.updated_at,
			   COUNT(*) OVER() as total_count
		FROM destinations d
		WHERE 1=1
	`

	args := []interface{}{}
	argIndex := 1

	// Apply filters
	if filter.Country != "" {
		query += fmt.Sprintf(" AND LOWER(d.country) = LOWER($%d)", argIndex)
		args = append(args, filter.Country)
		argIndex++
	}

	if filter.City != "" {
		query += fmt.Sprintf(" AND LOWER(d.city) = LOWER($%d)", argIndex)
		args = append(args, filter.City)
		argIndex++
	}

	if len(filter.Categories) > 0 {
		query += fmt.Sprintf(" AND d.categories && $%d", argIndex)
		args = append(args, pq.Array(filter.Categories))
		argIndex++
	}

	if filter.MinPrice > 0 {
		query += fmt.Sprintf(" AND d.price >= $%d", argIndex)
		args = append(args, filter.MinPrice)
		argIndex++
	}

	if filter.MaxPrice > 0 {
		query += fmt.Sprintf(" AND d.price <= $%d", argIndex)
		args = append(args, filter.MaxPrice)
		argIndex++
	}

	if filter.MinRating > 0 {
		query += fmt.Sprintf(" AND d.rating >= $%d", argIndex)
		args = append(args, filter.MinRating)
		argIndex++
	}

	if filter.IsPopular != nil {
		query += fmt.Sprintf(" AND d.is_popular = $%d", argIndex)
		args = append(args, *filter.IsPopular)
		argIndex++
	}

	if filter.IsFeatured != nil {
		query += fmt.Sprintf(" AND d.is_featured = $%d", argIndex)
		args = append(args, *filter.IsFeatured)
		argIndex++
	}

	if filter.Search != "" {
		searchTerm := "%" + strings.ToLower(filter.Search) + "%"
		query += fmt.Sprintf(" AND (LOWER(d.name) LIKE $%d OR LOWER(d.description) LIKE $%d OR LOWER(d.country) LIKE $%d OR LOWER(d.city) LIKE $%d)", argIndex, argIndex, argIndex, argIndex)
		args = append(args, searchTerm)
		argIndex++
	}

	// Location-based filtering
	if filter.NearLatitude != 0 && filter.NearLongitude != 0 && filter.RadiusKm > 0 {
		query += fmt.Sprintf(" AND earth_distance(ll_to_earth(d.latitude, d.longitude), ll_to_earth($%d, $%d)) <= $%d", argIndex, argIndex+1, argIndex+2)
		args = append(args, filter.NearLatitude, filter.NearLongitude, filter.RadiusKm*1000) // Convert km to meters
		argIndex += 3
	}

	// Sorting
	orderBy := "d.created_at DESC"
	if filter.SortBy != "" {
		validSortFields := map[string]string{
			"name":       "d.name",
			"price":      "d.price",
			"rating":     "d.rating",
			"created_at": "d.created_at",
		}
		if field, ok := validSortFields[filter.SortBy]; ok {
			direction := "ASC"
			if filter.SortOrder == "desc" {
				direction = "DESC"
			}
			orderBy = fmt.Sprintf("%s %s", field, direction)
		}
	}
	query += " ORDER BY " + orderBy

	// Pagination
	if filter.Limit == 0 {
		filter.Limit = 20
	}
	if filter.Page == 0 {
		filter.Page = 1
	}
	offset := (filter.Page - 1) * filter.Limit

	query += fmt.Sprintf(" LIMIT $%d OFFSET $%d", argIndex, argIndex+1)
	args = append(args, filter.Limit, offset)

	rows, err := s.db.Query(query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var destinations []models.DestinationResponse
	var total int64

	for rows.Next() {
		var dest models.DestinationResponse
		var additionalInfo sql.NullString

		err := rows.Scan(
			&dest.ID, &dest.Name, &dest.Description, &dest.LongDescription,
			&dest.Country, &dest.City, &dest.Latitude, &dest.Longitude,
			pq.Array(&dest.ImageUrls), pq.Array(&dest.VideoUrls),
			&dest.Rating, &dest.ReviewCount, &dest.Price, &dest.Currency,
			&dest.IsPopular, &dest.IsFeatured, &dest.BestTimeToVisit,
			pq.Array(&dest.Activities), pq.Array(&dest.Attractions),
			pq.Array(&dest.Categories), &additionalInfo,
			&dest.CreatedAt, &dest.UpdatedAt, &total,
		)
		if err != nil {
			return nil, 0, err
		}

		if additionalInfo.Valid {
			dest.AdditionalInfo = additionalInfo.String
		}

		destinations = append(destinations, dest)
	}

	return destinations, total, nil
}

// GetDestinationByID retrieves a single destination by ID
func (s *DestinationService) GetDestinationByID(id uuid.UUID) (*models.DestinationResponse, error) {
	query := `
		SELECT d.id, d.name, d.description, d.long_description, d.country, d.city,
			   d.latitude, d.longitude, d.image_urls, d.video_urls, d.rating, d.review_count,
			   d.price, d.currency, d.is_popular, d.is_featured, d.best_time_to_visit,
			   d.activities, d.attractions, d.categories, d.additional_info,
			   d.created_at, d.updated_at
		FROM destinations d
		WHERE d.id = $1
	`

	var dest models.DestinationResponse
	var additionalInfo sql.NullString

	err := s.db.QueryRow(query, id).Scan(
		&dest.ID, &dest.Name, &dest.Description, &dest.LongDescription,
		&dest.Country, &dest.City, &dest.Latitude, &dest.Longitude,
		pq.Array(&dest.ImageUrls), pq.Array(&dest.VideoUrls),
		&dest.Rating, &dest.ReviewCount, &dest.Price, &dest.Currency,
		&dest.IsPopular, &dest.IsFeatured, &dest.BestTimeToVisit,
		pq.Array(&dest.Activities), pq.Array(&dest.Attractions),
		pq.Array(&dest.Categories), &additionalInfo,
		&dest.CreatedAt, &dest.UpdatedAt,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	if additionalInfo.Valid {
		dest.AdditionalInfo = additionalInfo.String
	}

	// Get additional statistics
	err = s.getDestinationStats(&dest)
	if err != nil {
		return nil, err
	}

	return &dest, nil
}

// getDestinationStats retrieves additional statistics for a destination
func (s *DestinationService) getDestinationStats(dest *models.DestinationResponse) error {
	// Get review statistics
	reviewQuery := `
		SELECT COUNT(*), COALESCE(AVG(rating), 0)
		FROM reviews
		WHERE destination_id = $1 AND status = 'approved'
	`
	err := s.db.QueryRow(reviewQuery, dest.ID).Scan(&dest.TotalReviews, &dest.AvgRating)
	if err != nil {
		return err
	}

	// Get hotel statistics
	hotelQuery := `
		SELECT COUNT(*), COALESCE(MIN(price_per_night), 0), COALESCE(MAX(price_per_night), 0)
		FROM hotels
		WHERE destination_id = $1 AND is_available = true
	`
	err = s.db.QueryRow(hotelQuery, dest.ID).Scan(&dest.HotelCount, &dest.MinPrice, &dest.MaxPrice)
	if err != nil {
		return err
	}

	return nil
}

// CreateDestination creates a new destination
func (s *DestinationService) CreateDestination(req models.DestinationRequest) (*models.Destination, error) {
	dest := &models.Destination{
		Name:            req.Name,
		Description:     req.Description,
		LongDescription: req.LongDescription,
		Country:         req.Country,
		City:            req.City,
		Latitude:        req.Latitude,
		Longitude:       req.Longitude,
		Price:           req.Price,
		Currency:        req.Currency,
		BestTimeToVisit: req.BestTimeToVisit,
		Activities:      req.Activities,
		Attractions:     req.Attractions,
		Categories:      req.Categories,
		AdditionalInfo:  req.AdditionalInfo,
	}
	dest.BeforeCreate()

	query := `
		INSERT INTO destinations (
			id, name, description, long_description, country, city, latitude, longitude,
			price, currency, best_time_to_visit, activities, attractions, categories,
			additional_info, created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17
		)
	`

	_, err := s.db.Exec(query,
		dest.ID, dest.Name, dest.Description, dest.LongDescription,
		dest.Country, dest.City, dest.Latitude, dest.Longitude,
		dest.Price, dest.Currency, dest.BestTimeToVisit,
		pq.Array(dest.Activities), pq.Array(dest.Attractions),
		pq.Array(dest.Categories), dest.AdditionalInfo,
		dest.CreatedAt, dest.UpdatedAt,
	)

	if err != nil {
		return nil, err
	}

	return dest, nil
}

// UpdateDestination updates an existing destination
func (s *DestinationService) UpdateDestination(id uuid.UUID, req models.DestinationRequest) (*models.Destination, error) {
	dest, err := s.GetDestinationByID(id)
	if err != nil {
		return nil, err
	}
	if dest == nil {
		return nil, fmt.Errorf("destination not found")
	}

	query := `
		UPDATE destinations SET
			name = $2, description = $3, long_description = $4, country = $5,
			city = $6, latitude = $7, longitude = $8, price = $9, currency = $10,
			best_time_to_visit = $11, activities = $12, attractions = $13,
			categories = $14, additional_info = $15, updated_at = NOW()
		WHERE id = $1
	`

	_, err = s.db.Exec(query,
		id, req.Name, req.Description, req.LongDescription,
		req.Country, req.City, req.Latitude, req.Longitude,
		req.Price, req.Currency, req.BestTimeToVisit,
		pq.Array(req.Activities), pq.Array(req.Attractions),
		pq.Array(req.Categories), req.AdditionalInfo,
	)

	if err != nil {
		return nil, err
	}

	// Return updated destination
	updatedDest, err := s.GetDestinationByID(id)
	if err != nil {
		return nil, err
	}

	return &updatedDest.Destination, nil
}

// DeleteDestination deletes a destination
func (s *DestinationService) DeleteDestination(id uuid.UUID) error {
	query := "DELETE FROM destinations WHERE id = $1"
	result, err := s.db.Exec(query, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return fmt.Errorf("destination not found")
	}

	return nil
}

// GetFeaturedDestinations retrieves featured destinations
func (s *DestinationService) GetFeaturedDestinations() ([]models.DestinationResponse, error) {
	filter := models.DestinationFilter{
		IsFeatured: &[]bool{true}[0],
		Limit:      10,
		Page:       1,
	}
	destinations, _, err := s.GetDestinations(filter)
	return destinations, err
}

// GetPopularDestinations retrieves popular destinations
func (s *DestinationService) GetPopularDestinations() ([]models.DestinationResponse, error) {
	filter := models.DestinationFilter{
		IsPopular: &[]bool{true}[0],
		SortBy:    "rating",
		SortOrder: "desc",
		Limit:     10,
		Page:      1,
	}
	destinations, _, err := s.GetDestinations(filter)
	return destinations, err
}

// GetCategories retrieves all unique categories
func (s *DestinationService) GetCategories() ([]string, error) {
	query := `
		SELECT DISTINCT unnest(categories) as category
		FROM destinations
		WHERE categories IS NOT NULL
		ORDER BY category
	`

	rows, err := s.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var categories []string
	for rows.Next() {
		var category string
		if err := rows.Scan(&category); err != nil {
			return nil, err
		}
		categories = append(categories, category)
	}

	return categories, nil
}

// GetCountries retrieves all unique countries
func (s *DestinationService) GetCountries() ([]string, error) {
	query := `
		SELECT DISTINCT country
		FROM destinations
		ORDER BY country
	`

	rows, err := s.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var countries []string
	for rows.Next() {
		var country string
		if err := rows.Scan(&country); err != nil {
			return nil, err
		}
		countries = append(countries, country)
	}

	return countries, nil
}

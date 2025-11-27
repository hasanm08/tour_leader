package response

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// APIResponse represents the standard API response structure
type APIResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
	Error   *APIError   `json:"error,omitempty"`
	Meta    *Meta       `json:"meta,omitempty"`
}

// APIError represents error details
type APIError struct {
	Code    string      `json:"code"`
	Message string      `json:"message"`
	Details interface{} `json:"details,omitempty"`
}

// Meta represents metadata for paginated responses
type Meta struct {
	Page         int   `json:"page"`
	Limit        int   `json:"limit"`
	Total        int64 `json:"total"`
	TotalPages   int   `json:"totalPages"`
	HasNext      bool  `json:"hasNext"`
	HasPrevious  bool  `json:"hasPrevious"`
}

// Success creates a successful response
func Success(data interface{}) APIResponse {
	return APIResponse{
		Success: true,
		Data:    data,
	}
}

// SuccessWithMessage creates a successful response with a message
func SuccessWithMessage(message string, data interface{}) APIResponse {
	return APIResponse{
		Success: true,
		Message: message,
		Data:    data,
	}
}

// Error creates an error response
func Error(message string) APIResponse {
	return APIResponse{
		Success: false,
		Error: &APIError{
			Code:    "GENERAL_ERROR",
			Message: message,
		},
	}
}

// ErrorWithCode creates an error response with a specific error code
func ErrorWithCode(code, message string) APIResponse {
	return APIResponse{
		Success: false,
		Error: &APIError{
			Code:    code,
			Message: message,
		},
	}
}

// ErrorWithDetails creates an error response with details
func ErrorWithDetails(code, message string, details interface{}) APIResponse {
	return APIResponse{
		Success: false,
		Error: &APIError{
			Code:    code,
			Message: message,
			Details: details,
		},
	}
}

// ValidationError creates a validation error response
func ValidationError(details interface{}) APIResponse {
	return APIResponse{
		Success: false,
		Error: &APIError{
			Code:    "VALIDATION_ERROR",
			Message: "Validation failed",
			Details: details,
		},
	}
}

// Paginated creates a paginated response
func Paginated(data interface{}, page, limit int, total int64) APIResponse {
	totalPages := int((total + int64(limit) - 1) / int64(limit))
	
	return APIResponse{
		Success: true,
		Data:    data,
		Meta: &Meta{
			Page:        page,
			Limit:       limit,
			Total:       total,
			TotalPages:  totalPages,
			HasNext:     page < totalPages,
			HasPrevious: page > 1,
		},
	}
}

// JSON sends a JSON response
func JSON(c *gin.Context, statusCode int, response APIResponse) {
	c.JSON(statusCode, response)
}

// Created sends a 201 Created response
func Created(c *gin.Context, data interface{}) {
	JSON(c, http.StatusCreated, Success(data))
}

// OK sends a 200 OK response
func OK(c *gin.Context, data interface{}) {
	JSON(c, http.StatusOK, Success(data))
}

// OKWithMessage sends a 200 OK response with a message
func OKWithMessage(c *gin.Context, message string, data interface{}) {
	JSON(c, http.StatusOK, SuccessWithMessage(message, data))
}

// BadRequest sends a 400 Bad Request response
func BadRequest(c *gin.Context, message string) {
	JSON(c, http.StatusBadRequest, Error(message))
}

// Unauthorized sends a 401 Unauthorized response
func Unauthorized(c *gin.Context, message string) {
	JSON(c, http.StatusUnauthorized, Error(message))
}

// Forbidden sends a 403 Forbidden response
func Forbidden(c *gin.Context, message string) {
	JSON(c, http.StatusForbidden, Error(message))
}

// NotFound sends a 404 Not Found response
func NotFound(c *gin.Context, message string) {
	JSON(c, http.StatusNotFound, Error(message))
}

// Conflict sends a 409 Conflict response
func Conflict(c *gin.Context, message string) {
	JSON(c, http.StatusConflict, Error(message))
}

// InternalServerError sends a 500 Internal Server Error response
func InternalServerError(c *gin.Context, message string) {
	JSON(c, http.StatusInternalServerError, Error(message))
}

// PaginatedOK sends a paginated 200 OK response
func PaginatedOK(c *gin.Context, data interface{}, page, limit int, total int64) {
	JSON(c, http.StatusOK, Paginated(data, page, limit, total))
}

// NoContent sends a 204 No Content response
func NoContent(c *gin.Context) {
	c.Status(http.StatusNoContent)
}

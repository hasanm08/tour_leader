package validation

import (
	"fmt"
	"reflect"
	"strings"

	"github.com/go-playground/validator/v10"
)

var validate *validator.Validate

func init() {
	validate = validator.New()
	
	// Register custom tag name function
	validate.RegisterTagNameFunc(func(fld reflect.StructField) string {
		name := strings.SplitN(fld.Tag.Get("json"), ",", 2)[0]
		if name == "-" {
			return ""
		}
		return name
	})
	
	// Register custom validators
	validate.RegisterValidation("latitude", validateLatitude)
	validate.RegisterValidation("longitude", validateLongitude)
}

// ValidateStruct validates a struct and returns formatted errors
func ValidateStruct(s interface{}) map[string]string {
	err := validate.Struct(s)
	if err == nil {
		return nil
	}

	errors := make(map[string]string)
	for _, err := range err.(validator.ValidationErrors) {
		field := err.Field()
		tag := err.Tag()
		
		switch tag {
		case "required":
			errors[field] = fmt.Sprintf("%s is required", field)
		case "email":
			errors[field] = fmt.Sprintf("%s must be a valid email address", field)
		case "min":
			errors[field] = fmt.Sprintf("%s must be at least %s characters", field, err.Param())
		case "max":
			errors[field] = fmt.Sprintf("%s must be at most %s characters", field, err.Param())
		case "len":
			errors[field] = fmt.Sprintf("%s must be exactly %s characters", field, err.Param())
		case "latitude":
			errors[field] = fmt.Sprintf("%s must be a valid latitude (-90 to 90)", field)
		case "longitude":
			errors[field] = fmt.Sprintf("%s must be a valid longitude (-180 to 180)", field)
		case "oneof":
			errors[field] = fmt.Sprintf("%s must be one of: %s", field, err.Param())
		case "eqfield":
			errors[field] = fmt.Sprintf("%s must match %s", field, err.Param())
		default:
			errors[field] = fmt.Sprintf("%s is invalid", field)
		}
	}

	return errors
}

// validateLatitude validates latitude values
func validateLatitude(fl validator.FieldLevel) bool {
	lat := fl.Field().Float()
	return lat >= -90 && lat <= 90
}

// validateLongitude validates longitude values
func validateLongitude(fl validator.FieldLevel) bool {
	lng := fl.Field().Float()
	return lng >= -180 && lng <= 180
}

// ValidatePassword validates password strength
func ValidatePassword(password string) []string {
	var errors []string

	if len(password) < 8 {
		errors = append(errors, "Password must be at least 8 characters long")
	}

	if len(password) > 100 {
		errors = append(errors, "Password must be at most 100 characters long")
	}

	hasUpper := false
	hasLower := false
	hasNumber := false
	hasSpecial := false

	for _, char := range password {
		switch {
		case 'A' <= char && char <= 'Z':
			hasUpper = true
		case 'a' <= char && char <= 'z':
			hasLower = true
		case '0' <= char && char <= '9':
			hasNumber = true
		case strings.ContainsRune("!@#$%^&*()_+-=[]{}|;:,.<>?", char):
			hasSpecial = true
		}
	}

	if !hasUpper {
		errors = append(errors, "Password must contain at least one uppercase letter")
	}

	if !hasLower {
		errors = append(errors, "Password must contain at least one lowercase letter")
	}

	if !hasNumber {
		errors = append(errors, "Password must contain at least one number")
	}

	if !hasSpecial {
		errors = append(errors, "Password must contain at least one special character")
	}

	return errors
}

// ValidateEmail validates email format
func ValidateEmail(email string) bool {
	return validate.Var(email, "required,email") == nil
}

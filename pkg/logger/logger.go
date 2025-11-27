package logger

import (
	"fmt"
	"log"
	"os"
	"time"
)

type Logger struct {
	logger      *log.Logger
	environment string
}

// NewLogger creates a new logger instance
func NewLogger(environment string) *Logger {
	return &Logger{
		logger:      log.New(os.Stdout, "", 0),
		environment: environment,
	}
}

// formatMessage formats log messages with timestamp and level
func (l *Logger) formatMessage(level, message string) string {
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	return fmt.Sprintf("[%s] %s: %s", timestamp, level, message)
}

// Info logs info level messages
func (l *Logger) Info(format string, v ...interface{}) {
	message := fmt.Sprintf(format, v...)
	l.logger.Println(l.formatMessage("INFO", message))
}

// Error logs error level messages
func (l *Logger) Error(format string, v ...interface{}) {
	message := fmt.Sprintf(format, v...)
	l.logger.Println(l.formatMessage("ERROR", message))
}

// Warning logs warning level messages
func (l *Logger) Warning(format string, v ...interface{}) {
	message := fmt.Sprintf(format, v...)
	l.logger.Println(l.formatMessage("WARNING", message))
}

// Debug logs debug level messages (only in development)
func (l *Logger) Debug(format string, v ...interface{}) {
	if l.environment == "development" {
		message := fmt.Sprintf(format, v...)
		l.logger.Println(l.formatMessage("DEBUG", message))
	}
}

// Fatal logs fatal level messages and exits
func (l *Logger) Fatal(format string, v ...interface{}) {
	message := fmt.Sprintf(format, v...)
	l.logger.Println(l.formatMessage("FATAL", message))
	os.Exit(1)
}

# TourLeader API

A comprehensive travel platform API built with Go, providing backend services for managing destinations, tours, hotels, bookings, and real-time chat functionality.

## Features

### Core Features
- **User Management**: Registration, authentication, profiles, and role-based access
- **Destination Management**: CRUD operations, search, filtering, and categorization
- **Tour Planning**: Create, manage, and share custom tours with participants
- **Hotel Booking**: Hotel search, availability checking, and booking management
- **Review System**: User reviews and ratings for destinations and hotels
- **Real-time Chat**: WebSocket-based messaging for tour coordination
- **File Upload**: Image and document upload with cloud storage integration
- **Deep Linking**: Tour invitation and sharing via deep links

### Advanced Features
- **Geographic Search**: Location-based filtering with radius search
- **Real-time Notifications**: Push notifications for tour updates and messages
- **Payment Integration**: Secure payment processing for bookings
- **Social Sharing**: Integration with social media platforms
- **Analytics**: User activity tracking and tour statistics
- **Multi-language Support**: Internationalization ready
- **API Documentation**: Swagger/OpenAPI integration

## Tech Stack

- **Language**: Go 1.21+
- **Framework**: Gin (HTTP router)
- **Database**: PostgreSQL with spatial extensions
- **Cache**: Redis
- **Authentication**: JWT tokens
- **File Storage**: AWS S3 / Cloudinary
- **Real-time**: WebSockets
- **Documentation**: Swagger/OpenAPI
- **Migration**: golang-migrate

## Project Structure

```
tour_leader_api/
├── cmd/
│   ├── api/                 # Main application entry point
│   └── migrate/             # Database migration tool
├── internal/
│   ├── auth/                # Authentication logic
│   ├── config/              # Configuration management
│   ├── database/            # Database connection and setup
│   ├── handlers/            # HTTP handlers
│   ├── middleware/          # HTTP middleware
│   ├── models/              # Data models
│   ├── services/            # Business logic
│   ├── utils/               # Utility functions
│   └── websocket/           # WebSocket handling
├── pkg/
│   ├── logger/              # Logging utilities
│   ├── response/            # API response utilities
│   └── validation/          # Validation utilities
├── migrations/              # Database migrations
├── docs/                    # API documentation
├── static/                  # Static files
└── deployments/             # Deployment configurations
```

## Getting Started

### Prerequisites

- Go 1.21 or higher
- PostgreSQL 13+ with PostGIS extension
- Redis 6+
- AWS account (for file storage) or Cloudinary account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tour_leader_api
   ```

2. **Install dependencies**
   ```bash
   go mod download
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Set up PostgreSQL database**
   ```sql
   CREATE DATABASE tour_leader;
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   CREATE EXTENSION IF NOT EXISTS "earthdistance";
   CREATE EXTENSION IF NOT EXISTS "cube";
   ```

5. **Run database migrations**
   ```bash
   go run cmd/migrate/main.go up
   ```

6. **Start the server**
   ```bash
   go run cmd/api/main.go
   ```

The API will be available at `http://localhost:8080`

### Development

#### Running Tests
```bash
go test ./...
```

#### Generating API Documentation
```bash
swag init -g cmd/api/main.go
```

#### Creating Database Migrations
```bash
migrate create -ext sql -dir migrations -seq create_new_table
```

#### Build for Production
```bash
go build -o bin/api cmd/api/main.go
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `POST /api/v1/auth/logout` - User logout

### Users
- `GET /api/v1/users/profile` - Get user profile
- `PUT /api/v1/users/profile` - Update user profile
- `POST /api/v1/users/change-password` - Change password

### Destinations
- `GET /api/v1/destinations` - List destinations with filtering
- `GET /api/v1/destinations/:id` - Get destination details
- `GET /api/v1/destinations/featured` - Get featured destinations
- `GET /api/v1/destinations/popular` - Get popular destinations
- `GET /api/v1/destinations/categories` - Get destination categories
- `POST /api/v1/destinations` - Create destination (Admin)
- `PUT /api/v1/destinations/:id` - Update destination (Admin)
- `DELETE /api/v1/destinations/:id` - Delete destination (Admin)

### Tours
- `GET /api/v1/tours` - List tours
- `POST /api/v1/tours` - Create tour
- `GET /api/v1/tours/:id` - Get tour details
- `PUT /api/v1/tours/:id` - Update tour
- `DELETE /api/v1/tours/:id` - Delete tour
- `POST /api/v1/tours/:id/join` - Join tour
- `POST /api/v1/tours/:id/invite` - Invite users to tour
- `GET /api/v1/tours/:id/participants` - Get tour participants

### Hotels
- `GET /api/v1/hotels` - List hotels
- `GET /api/v1/hotels/:id` - Get hotel details
- `POST /api/v1/hotels/search` - Search hotels
- `GET /api/v1/hotels/:id/availability` - Check hotel availability

### Bookings
- `POST /api/v1/bookings/hotels` - Create hotel booking
- `GET /api/v1/bookings` - Get user bookings
- `GET /api/v1/bookings/:id` - Get booking details
- `PUT /api/v1/bookings/:id/cancel` - Cancel booking

### Reviews
- `GET /api/v1/reviews` - List reviews
- `POST /api/v1/reviews` - Create review
- `PUT /api/v1/reviews/:id` - Update review
- `DELETE /api/v1/reviews/:id` - Delete review
- `POST /api/v1/reviews/:id/helpful` - Mark review helpful

### Chat
- `GET /api/v1/chats` - Get user chats
- `POST /api/v1/chats` - Create chat room
- `GET /api/v1/chats/:id/messages` - Get chat messages
- `POST /api/v1/chats/:id/messages` - Send message
- `GET /api/v1/ws` - WebSocket connection

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SERVER_HOST` | Server host | localhost |
| `SERVER_PORT` | Server port | 8080 |
| `DB_HOST` | Database host | localhost |
| `DB_PORT` | Database port | 5432 |
| `DB_NAME` | Database name | tour_leader |
| `JWT_SECRET_KEY` | JWT secret key | (required) |
| `REDIS_HOST` | Redis host | localhost |
| `AWS_S3_BUCKET` | S3 bucket name | (required) |

### Database Configuration

The API uses PostgreSQL with the following extensions:
- `uuid-ossp` - For UUID generation
- `earthdistance` and `cube` - For geographic calculations
- `gin` indexes - For array field searches

## API Design Principles

### RESTful Design
- Consistent URI naming conventions
- Proper HTTP methods and status codes
- Resource-based endpoints

### Response Format
All API responses follow a consistent format:

```json
{
  "success": true,
  "message": "Optional message",
  "data": { ... },
  "error": null,
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Authentication
- JWT-based authentication
- Role-based access control (user, admin, moderator)
- Token refresh mechanism

### Error Handling
- Consistent error response format
- Detailed validation errors
- Proper HTTP status codes

## Deployment

### Docker
```bash
docker build -t tour-leader-api .
docker run -p 8080:8080 --env-file .env tour-leader-api
```

### Production Considerations
- Use environment variables for sensitive configuration
- Enable SSL/TLS termination
- Set up database connection pooling
- Configure log aggregation
- Set up monitoring and alerting
- Use a reverse proxy (nginx, traefik)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Email: support@tourleader.app
- Documentation: [API Docs](http://localhost:8080/swagger/index.html)
- Issues: GitHub Issues
package websocket

import (
	"sync"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

// Hub maintains the set of active clients and broadcasts messages to the clients
type Hub struct {
	// Registered clients
	clients map[*Client]bool

	// Inbound messages from the clients
	broadcast chan []byte

	// Register requests from the clients
	register chan *Client

	// Unregister requests from clients
	unregister chan *Client

	// User connections map for direct messaging
	userConnections map[uuid.UUID]*Client

	// Room connections for group chats
	rooms map[string]map[*Client]bool

	// Mutex for thread safety
	mu sync.RWMutex
}

// Client represents a WebSocket client
type Client struct {
	// The websocket connection
	conn *websocket.Conn

	// User ID associated with this client
	userID uuid.UUID

	// Buffered channel of outbound messages
	send chan []byte

	// Current room/chat ID (if any)
	roomID string

	// Hub reference
	hub *Hub
}

// Message represents a WebSocket message
type Message struct {
	Type    string      `json:"type"`
	UserID  uuid.UUID   `json:"userId"`
	RoomID  string      `json:"roomId,omitempty"`
	Content interface{} `json:"content"`
}

// NewHub creates a new Hub
func NewHub() *Hub {
	return &Hub{
		clients:         make(map[*Client]bool),
		broadcast:       make(chan []byte),
		register:        make(chan *Client),
		unregister:      make(chan *Client),
		userConnections: make(map[uuid.UUID]*Client),
		rooms:           make(map[string]map[*Client]bool),
	}
}

// Run starts the hub's main loop
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.registerClient(client)

		case client := <-h.unregister:
			h.unregisterClient(client)

		case message := <-h.broadcast:
			h.broadcastMessage(message)
		}
	}
}

// registerClient registers a new client
func (h *Hub) registerClient(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	h.clients[client] = true
	h.userConnections[client.userID] = client

	// Join room if specified
	if client.roomID != "" {
		if h.rooms[client.roomID] == nil {
			h.rooms[client.roomID] = make(map[*Client]bool)
		}
		h.rooms[client.roomID][client] = true
	}
}

// unregisterClient unregisters a client
func (h *Hub) unregisterClient(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.clients[client]; ok {
		delete(h.clients, client)
		delete(h.userConnections, client.userID)

		// Remove from room
		if client.roomID != "" && h.rooms[client.roomID] != nil {
			delete(h.rooms[client.roomID], client)
			if len(h.rooms[client.roomID]) == 0 {
				delete(h.rooms, client.roomID)
			}
		}

		close(client.send)
	}
}

// broadcastMessage broadcasts a message to all clients
func (h *Hub) broadcastMessage(message []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	for client := range h.clients {
		select {
		case client.send <- message:
		default:
			h.closeClient(client)
		}
	}
}

// SendToUser sends a message to a specific user
func (h *Hub) SendToUser(userID uuid.UUID, message []byte) {
	h.mu.RLock()
	client, exists := h.userConnections[userID]
	h.mu.RUnlock()

	if exists {
		select {
		case client.send <- message:
		default:
			h.closeClient(client)
		}
	}
}

// SendToRoom sends a message to all clients in a room
func (h *Hub) SendToRoom(roomID string, message []byte) {
	h.mu.RLock()
	room, exists := h.rooms[roomID]
	h.mu.RUnlock()

	if exists {
		for client := range room {
			select {
			case client.send <- message:
			default:
				h.closeClient(client)
			}
		}
	}
}

// closeClient closes a client connection
func (h *Hub) closeClient(client *Client) {
	delete(h.clients, client)
	delete(h.userConnections, client.userID)

	if client.roomID != "" && h.rooms[client.roomID] != nil {
		delete(h.rooms[client.roomID], client)
		if len(h.rooms[client.roomID]) == 0 {
			delete(h.rooms, client.roomID)
		}
	}

	close(client.send)
}

// GetActiveUsers returns the count of active users
func (h *Hub) GetActiveUsers() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

// GetRoomUsers returns the count of users in a specific room
func (h *Hub) GetRoomUsers(roomID string) int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	
	if room, exists := h.rooms[roomID]; exists {
		return len(room)
	}
	return 0
}

// IsUserOnline checks if a user is currently online
func (h *Hub) IsUserOnline(userID uuid.UUID) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	
	_, exists := h.userConnections[userID]
	return exists
}

// Close shuts down the hub
func (h *Hub) Close() {
	h.mu.Lock()
	defer h.mu.Unlock()

	// Close all client connections
	for client := range h.clients {
		close(client.send)
	}

	// Clear all maps
	h.clients = make(map[*Client]bool)
	h.userConnections = make(map[uuid.UUID]*Client)
	h.rooms = make(map[string]map[*Client]bool)
}

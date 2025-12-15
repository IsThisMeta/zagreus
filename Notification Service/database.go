package main

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"log"
	"math/rand"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
	"github.com/redis/go-redis/v9"
)

var (
	db    *sql.DB
	rdb   *redis.Client
	ctx   = context.Background()
)

func init() {
	// Initialize PostgreSQL if DATABASE_URL is set
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL != "" {
		var err error
		db, err = sql.Open("postgres", dbURL)
		if err != nil {
			log.Printf("Failed to connect to database: %v", err)
			// Don't fatal, let the app run without DB for now
		} else {
			db.SetMaxOpenConns(10)
			db.SetMaxIdleConns(5)
			db.SetConnMaxLifetime(5 * time.Minute)

			if err = db.Ping(); err != nil {
				log.Printf("Failed to ping database: %v", err)
				// Don't fatal, let the app run without DB for now
			} else {
				log.Println("Database connection initialized")
			}
		}
	} else {
		log.Println("DATABASE_URL not set, running without database")
	}

	// Initialize Redis if REDIS_URL is set
	redisURL := os.Getenv("REDIS_URL")
	if redisURL != "" {
		opt, err := redis.ParseURL(redisURL)
		if err != nil {
			log.Printf("Failed to parse Redis URL: %v", err)
		} else {
			rdb = redis.NewClient(opt)
			
			if err = rdb.Ping(ctx).Err(); err != nil {
				log.Printf("Failed to connect to Redis: %v", err)
			} else {
				log.Println("Redis connection initialized")
			}
		}
	} else {
		log.Println("REDIS_URL not set, running without Redis")
	}
}

// Device registration
type DeviceRegistration struct {
	UserID      string `json:"user_id"`
	DeviceToken string `json:"device_token"`
	DeviceType  string `json:"device_type"`
	Anonymous   bool   `json:"anonymous"` // New field for anonymous mode
}

// Webhook registration response
type WebhookRegistration struct {
	WebhookID string `json:"webhook_id"`
	Success   bool   `json:"success"`
}

func handleRegister(c *gin.Context) {
	var req DeviceRegistration
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}

	if db == nil {
		log.Printf("Device registration request received but database not connected")
		c.JSON(200, gin.H{
			"success": true,
			"device_id": "mock-device-id",
			"message": "Database not connected, registration simulated",
		})
		return
	}

	// Check if device exists
	var deviceID string
	err := db.QueryRow(`
		SELECT id::text FROM notification_devices 
		WHERE user_id = $1 AND device_token = $2
	`, req.UserID, req.DeviceToken).Scan(&deviceID)

	if err == sql.ErrNoRows {
		// Insert new device
		err = db.QueryRow(`
			INSERT INTO notification_devices (user_id, device_token, device_type)
			VALUES ($1, $2, $3)
			RETURNING id::text
		`, req.UserID, req.DeviceToken, req.DeviceType).Scan(&deviceID)
		
		if err != nil {
			log.Printf("Failed to insert device: %v", err)
			c.JSON(500, gin.H{"error": "Failed to register device"})
			return
		}
	} else if err != nil {
		log.Printf("Database error: %v", err)
		c.JSON(500, gin.H{"error": "Database error"})
		return
	}

	// Update last seen
	_, err = db.Exec(`
		UPDATE notification_devices 
		SET last_seen_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, deviceID)

	if err != nil {
		log.Printf("Failed to update last seen: %v", err)
	}

	// Generate or retrieve webhook ID and signature
	webhookID, signature, err := getOrCreateWebhookID(req.UserID, req.DeviceToken, req.Anonymous)
	if err != nil {
		log.Printf("Failed to generate webhook ID: %v", err)
		c.JSON(500, gin.H{"error": "Failed to generate webhook ID"})
		return
	}

	log.Printf("Device registered: %s for user %s with webhook %s", deviceID, req.UserID, webhookID)

	c.JSON(200, gin.H{
		"success": true,
		"device_id": deviceID,
		"webhook_id": webhookID,
		"webhook_signature": signature,
	})
}

// Get device tokens for a user
func getDeviceTokensForUser(userID string) ([]string, error) {
	if db == nil {
		log.Printf("getDeviceTokensForUser called but database not connected")
		return []string{}, nil
	}
	
	rows, err := db.Query(`
		SELECT device_token FROM notification_devices
		WHERE user_id = $1 AND is_active = true
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tokens []string
	for rows.Next() {
		var token string
		if err := rows.Scan(&token); err != nil {
			continue
		}
		tokens = append(tokens, token)
	}

	return tokens, nil
}

// Generate a random 6-character webhook ID
func generateWebhookID() string {
	const charset = "abcdefghijklmnopqrstuvwxyz0123456789"
	b := make([]byte, 6)
	for i := range b {
		b[i] = charset[rand.Intn(len(charset))]
	}
	return string(b)
}

// Generate HMAC signature for webhook validation
func generateWebhookSignature(webhookID string) string {
	secret := os.Getenv("WEBHOOK_SECRET")
	if secret == "" {
		secret = "zagreus-default-secret-change-me" // Fallback for dev
	}

	h := hmac.New(sha256.New, []byte(secret))
	h.Write([]byte(webhookID))
	return base64.StdEncoding.EncodeToString(h.Sum(nil))
}

// Verify webhook signature
func verifyWebhookSignature(webhookID string, signature string) bool {
	expected := generateWebhookSignature(webhookID)
	return hmac.Equal([]byte(expected), []byte(signature))
}

// Get or create webhook ID for a user/device
func getOrCreateWebhookID(userID string, deviceToken string, anonymous bool) (string, string, error) {
	if db == nil {
		// Return a mock webhook ID and signature for testing
		webhookID := "test123"
		signature := generateWebhookSignature(webhookID)
		return webhookID, signature, nil
	}

	// For anonymous mode, generate a new webhook ID each time
	if anonymous {
		webhookID := generateWebhookID()

		// Store the anonymous webhook mapping
		_, err := db.Exec(`
			INSERT INTO webhook_mappings (webhook_id, user_id, device_tokens, is_anonymous)
			VALUES ($1, NULL, ARRAY[$2], true)
			ON CONFLICT (webhook_id) DO UPDATE
			SET device_tokens = ARRAY[$2], updated_at = CURRENT_TIMESTAMP
		`, webhookID, deviceToken)

		if err != nil {
			// If collision, try again with new ID
			return getOrCreateWebhookID(userID, deviceToken, anonymous)
		}

		signature := generateWebhookSignature(webhookID)
		return webhookID, signature, nil
	}

	// For authenticated users, check if they already have a webhook ID
	var webhookID string
	err := db.QueryRow(`
		SELECT webhook_id FROM webhook_mappings
		WHERE user_id = $1 AND is_anonymous = false
	`, userID).Scan(&webhookID)

	if err == sql.ErrNoRows {
		// Generate new webhook ID for this user
		webhookID = generateWebhookID()

		_, err = db.Exec(`
			INSERT INTO webhook_mappings (webhook_id, user_id, device_tokens, is_anonymous)
			VALUES ($1, $2, ARRAY[$3], false)
		`, webhookID, userID, deviceToken)

		if err != nil {
			// If collision, try again
			return getOrCreateWebhookID(userID, deviceToken, anonymous)
		}
	} else if err == nil {
		// Update device tokens array
		_, err = db.Exec(`
			UPDATE webhook_mappings
			SET device_tokens = array_append(
				array_remove(device_tokens, $2), $2
			),
			updated_at = CURRENT_TIMESTAMP
			WHERE webhook_id = $1
		`, webhookID, deviceToken)

		if err != nil {
			return "", "", err
		}
	} else {
		return "", "", err
	}

	signature := generateWebhookSignature(webhookID)
	return webhookID, signature, nil
}

// Get device tokens for a webhook ID
func getDeviceTokensForWebhook(webhookID string) ([]string, error) {
	if db == nil {
		return []string{}, nil
	}

	// Use pq.Array to properly scan PostgreSQL array types
	var tokens pq.StringArray
	err := db.QueryRow(`
		SELECT device_tokens FROM webhook_mappings
		WHERE webhook_id = $1
	`, webhookID).Scan(&tokens)

	if err != nil {
		if err == sql.ErrNoRows {
			// No mapping found for this webhook ID
			return []string{}, nil
		}
		return nil, err
	}

	// Convert pq.StringArray to []string
	return []string(tokens), nil
}

// Remove a device token from webhook mappings (e.g., when APNs returns 410 Unregistered)
func removeDeviceToken(deviceToken string) error {
	if db == nil {
		return nil
	}

	// Remove token from all webhook_mappings
	_, err := db.Exec(`
		UPDATE webhook_mappings
		SET device_tokens = array_remove(device_tokens, $1),
		    updated_at = CURRENT_TIMESTAMP
		WHERE $1 = ANY(device_tokens)
	`, deviceToken)

	if err != nil {
		return err
	}

	// Also mark device as inactive in notification_devices
	_, err = db.Exec(`
		UPDATE notification_devices
		SET is_active = false
		WHERE device_token = $1
	`, deviceToken)

	return err
}

// Set Overseerr notification preference for a webhook ID
func setOverseerrEnabled(webhookID string, enabled bool) error {
	if db == nil {
		return nil
	}

	_, err := db.Exec(`
		UPDATE webhook_mappings
		SET overseerr_enabled = $1,
		    updated_at = CURRENT_TIMESTAMP
		WHERE webhook_id = $2
	`, enabled, webhookID)

	return err
}

// Check if Overseerr notifications are enabled for a webhook ID
func isOverseerrEnabled(webhookID string) bool {
	if db == nil {
		return true // Default to enabled if no database
	}

	var enabled bool
	err := db.QueryRow(`
		SELECT COALESCE(overseerr_enabled, true) FROM webhook_mappings
		WHERE webhook_id = $1
	`, webhookID).Scan(&enabled)

	if err != nil {
		log.Printf("Failed to check Overseerr enabled status: %v", err)
		return true // Default to enabled on error
	}

	return enabled
}

// Handle setting Overseerr notification preference
func handleSetOverseerrPreference(c *gin.Context) {
	var req struct {
		WebhookID string `json:"webhook_id"`
		Enabled   bool   `json:"enabled"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}

	if req.WebhookID == "" {
		c.JSON(400, gin.H{"error": "Webhook ID required"})
		return
	}

	if err := setOverseerrEnabled(req.WebhookID, req.Enabled); err != nil {
		log.Printf("Failed to update Overseerr preference: %v", err)
		c.JSON(500, gin.H{"error": "Failed to update preference"})
		return
	}

	log.Printf("Updated Overseerr preference for webhook %s: enabled=%v", req.WebhookID, req.Enabled)
	c.JSON(200, gin.H{
		"success": true,
		"webhook_id": req.WebhookID,
		"overseerr_enabled": req.Enabled,
	})
}


package main

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
)

var apnsClient *APNsClient

type NotificationParams struct {
	ImageURL string
	Metadata map[string]string
}

func initAPNs() error {
	keyID := os.Getenv("APNS_KEY_ID")
	teamID := os.Getenv("APNS_TEAM_ID")
	keyPath := os.Getenv("APNS_AUTH_KEY_PATH")

	if keyPath == "" {
		keyPath = "/app/AuthKey_PTTBS94D2P.p8"
	}

	// If key ID or team ID not set, skip APNs init
	if keyID == "" || teamID == "" {
		log.Println("APNS_KEY_ID or APNS_TEAM_ID not set, running without APNs")
		return nil
	}

	client, err := NewAPNsClient(keyID, teamID, "com.zebrralabs.zagreus", keyPath)
	if err != nil {
		log.Printf("Failed to create APNs client: %v", err)
		// Don't fail the whole app, just run without APNs
		return nil
	}

	apnsClient = client
	log.Println("APNs client initialized successfully")
	return nil
}

// Direct test handler - THE ONE THAT WORKS!
func handleDirectTest(c *gin.Context) {
	deviceToken := c.Param("token")

	// Check for delay query parameter
	delayStr := c.Query("delay")
	var delay int
	if delayStr != "" {
		fmt.Sscanf(delayStr, "%d", &delay)
		if delay > 30 {
			delay = 30 // Cap at 30 seconds
		}
	}

	if apnsClient == nil {
		c.JSON(500, gin.H{
			"success": false,
			"error":   "APNs client not initialized",
		})
		return
	}

	if delay > 0 {
		log.Printf("Will send DIRECT test notification to token %s after %d seconds", deviceToken, delay)
		c.JSON(200, gin.H{
			"success": true,
			"message": fmt.Sprintf("Notification will be sent in %d seconds", delay),
		})

		// Send notification in background after delay
		go func() {
			time.Sleep(time.Duration(delay) * time.Second)
			log.Printf("Sending DELAYED test notification to token: %s", deviceToken)

			err := apnsClient.SendNotification(
				deviceToken,
				"Zagreus Test",
				fmt.Sprintf("Delayed test after %d seconds", delay),
				false, // sandbox for testing
			)

			if err != nil {
				log.Printf("Failed to send delayed notification: %v", err)
			} else {
				log.Printf("Delayed notification sent successfully")
			}
		}()
		return
	}

	log.Printf("Sending DIRECT test notification to token: %s", deviceToken)

	err := apnsClient.SendNotification(
		deviceToken,
		"Zagreus Test",
		"Direct APNs Test - Can you see this?",
		false, // sandbox for testing
	)

	if err != nil {
		log.Printf("Failed to send notification: %v", err)
		c.JSON(500, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}

	c.JSON(200, gin.H{
		"success": true,
		"message": "Notification sent successfully",
	})
}

// Test push handler (to replace the broken node-apn one)
func handleTestPush(c *gin.Context) {
	deviceToken := c.Param("token")

	if apnsClient == nil {
		c.JSON(500, gin.H{
			"success": false,
			"error":   "APNs client not initialized",
		})
		return
	}

	log.Printf("Sending test notification to token: %s", deviceToken)

	err := apnsClient.SendNotification(
		deviceToken,
		"Test Notification",
		"Test Notification - Can you see this?",
		false, // sandbox for testing
	)

	if err != nil {
		log.Printf("Failed to send notification: %v", err)
		c.JSON(500, gin.H{
			"success": false,
			"error":   err.Error(),
		})
		return
	}

	c.JSON(200, gin.H{
		"success": true,
		"result": gin.H{
			"sent":   1,
			"failed": []string{},
		},
	})
}

// Send notification to all user's devices
func sendNotificationToUser(userID, title, body string, params *NotificationParams) error {
	if apnsClient == nil {
		return fmt.Errorf("APNs client not initialized")
	}

	tokens, err := getDeviceTokensForUser(userID)
	if err != nil {
		return fmt.Errorf("failed to get device tokens: %w", err)
	}

	if len(tokens) == 0 {
		return fmt.Errorf("no devices registered for user %s", userID)
	}

	// Build payload once so we can reuse it across tokens
	payload := buildAPNsPayload(title, body, params)

	var lastErr error
	successCount := 0

	for _, token := range tokens {
		// Check environment to determine production/sandbox
		isProduction := os.Getenv("APNS_ENVIRONMENT") == "production"

		if err := apnsClient.SendRichNotification(token, payload, isProduction); err != nil {
			log.Printf("Failed to send to token %s: %v", token, err)
			lastErr = err

			// Mark token as inactive if it's invalid
			if err.Error() == "BadDeviceToken" && db != nil {
				db.Exec(`
					UPDATE notification_devices 
					SET is_active = false 
					WHERE device_token = $1
				`, token)
			}
		} else {
			successCount++
		}
	}

	if successCount == 0 && lastErr != nil {
		return lastErr
	}

	log.Printf("Sent notification to %d/%d devices for user %s", successCount, len(tokens), userID)
	return nil
}

func buildAPNsPayload(title, body string, params *NotificationParams) APNsPayload {
	aps := APNsAps{
		Alert: APNsAlert{
			Title: title,
			Body:  body,
		},
		Sound: "default",
	}

	payload := APNsPayload{Aps: aps}

	if params != nil {
		if params.ImageURL != "" {
			aps.MutableContent = 1
			payload.MediaURL = params.ImageURL
		}
		if len(params.Metadata) > 0 {
			payload.Metadata = params.Metadata
		}
	}

	payload.Aps = aps
	return payload
}

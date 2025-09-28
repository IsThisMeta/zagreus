package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/gin-gonic/gin"
)

// Sonarr webhook structures
type SonarrWebhook struct {
	EventType string        `json:"eventType"`
	Series    SonarrSeries  `json:"series"`
	Episodes  []SonarrEpisode `json:"episodes"`
}

type SonarrSeries struct {
	Title    string `json:"title"`
	Year     int    `json:"year"`
	TvdbID   int    `json:"tvdbId"`
	TvMazeID int    `json:"tvMazeId"`
	ImdbID   string `json:"imdbId"`
}

type SonarrEpisode struct {
	Title         string `json:"title"`
	SeasonNumber  int    `json:"seasonNumber"`
	EpisodeNumber int    `json:"episodeNumber"`
	Quality       string `json:"quality"`
}

// Radarr webhook structures
type RadarrWebhook struct {
	EventType     string                 `json:"eventType"`
	Movie         RadarrMovie           `json:"movie"`
	AddMethod     string                 `json:"addMethod,omitempty"`
	InstanceName  string                 `json:"instanceName,omitempty"`
	ApplicationURL string                `json:"applicationUrl,omitempty"`
}

type RadarrMovie struct {
	ID            int                    `json:"id"`
	Title         string                 `json:"title"`
	Year          int                    `json:"year"`
	ImdbID        string                 `json:"imdbId,omitempty"`
	TmdbID        int                    `json:"tmdbId"`
	TitleSlug     string                 `json:"titleSlug,omitempty"`
	FolderName    string                 `json:"folderName,omitempty"`
	Path          string                 `json:"path,omitempty"`
	Genres        []string               `json:"genres,omitempty"`
	Images        []map[string]interface{} `json:"images,omitempty"`
	Tags          []interface{}          `json:"tags,omitempty"`
	Overview      string                 `json:"overview,omitempty"`
}

// Generic webhook response
type WebhookResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

func handleSonarrWebhook(c *gin.Context) {
	// Parse as generic JSON first to handle flexible structure
	var genericWebhook map[string]interface{}
	if err := c.ShouldBindJSON(&genericWebhook); err != nil {
		c.JSON(400, gin.H{"error": "Invalid webhook data"})
		return
	}

	// Get user ID from headers (this is how the Node.js version does it)
	userID := c.GetHeader("X-User-Id")
	if userID == "" {
		c.JSON(401, gin.H{"error": "Missing user ID"})
		return
	}

	eventType, _ := genericWebhook["eventType"].(string)
	log.Printf("Received Sonarr webhook: %s for user %s", eventType, userID)

	// Extract series info
	seriesTitle := "Unknown Series"
	if series, ok := genericWebhook["series"].(map[string]interface{}); ok {
		if t, ok := series["title"].(string); ok {
			seriesTitle = t
		}
	}

	// Extract episodes info
	var episodes []map[string]interface{}
	if eps, ok := genericWebhook["episodes"].([]interface{}); ok {
		for _, ep := range eps {
			if episode, ok := ep.(map[string]interface{}); ok {
				episodes = append(episodes, episode)
			}
		}
	}

	// Handle different event types
	var title, body string
	
	switch eventType {
	case "Test":
		title = "Sonarr Test"
		body = "Test notification from Sonarr"
		
	case "Grab":
		if len(episodes) > 0 {
			seasonNum := 0
			episodeNum := 0
			if s, ok := episodes[0]["seasonNumber"].(float64); ok {
				seasonNum = int(s)
			}
			if e, ok := episodes[0]["episodeNumber"].(float64); ok {
				episodeNum = int(e)
			}
			title = "Episode Grabbed"
			body = fmt.Sprintf("%s S%02dE%02d has been grabbed", 
				seriesTitle, seasonNum, episodeNum)
		}
		
	case "Download":
		if len(episodes) > 0 {
			seasonNum := 0
			episodeNum := 0
			if s, ok := episodes[0]["seasonNumber"].(float64); ok {
				seasonNum = int(s)
			}
			if e, ok := episodes[0]["episodeNumber"].(float64); ok {
				episodeNum = int(e)
			}
			title = "Episode Downloaded"
			body = fmt.Sprintf("%s S%02dE%02d is ready to watch", 
				seriesTitle, seasonNum, episodeNum)
		}
		
	case "Rename":
		title = "Episodes Renamed"
		body = fmt.Sprintf("%d episodes of %s have been renamed", 
			len(episodes), seriesTitle)
		
	case "SeriesDelete":
		title = "Series Deleted"
		body = fmt.Sprintf("%s has been removed from your library", seriesTitle)
		
	case "SeriesAdd":
		title = "Series Added"
		body = fmt.Sprintf("%s has been added to your library", seriesTitle)
		
	case "EpisodeFileDelete":
		if len(episodes) > 0 {
			seasonNum := 0
			episodeNum := 0
			if s, ok := episodes[0]["seasonNumber"].(float64); ok {
				seasonNum = int(s)
			}
			if e, ok := episodes[0]["episodeNumber"].(float64); ok {
				episodeNum = int(e)
			}
			title = "Episode File Deleted"
			body = fmt.Sprintf("File deleted for %s S%02dE%02d", 
				seriesTitle, seasonNum, episodeNum)
		}
		
	default:
		log.Printf("Unknown Sonarr event type: %s", eventType)
		c.JSON(200, WebhookResponse{Success: true, Message: "Event ignored"})
		return
	}

	// Send notification
	if title != "" && body != "" {
		if err := sendNotificationToUser(userID, title, body); err != nil {
			log.Printf("Failed to send notification: %v", err)
			c.JSON(500, gin.H{"error": "Failed to send notification"})
			return
		}
	}

	c.JSON(200, WebhookResponse{
		Success: true,
		Message: "Webhook processed successfully",
	})
}

func handleRadarrWebhook(c *gin.Context) {
	var webhook RadarrWebhook
	if err := c.ShouldBindJSON(&webhook); err != nil {
		c.JSON(400, gin.H{"error": "Invalid webhook data"})
		return
	}

	userID := c.GetHeader("X-User-Id")
	if userID == "" {
		c.JSON(401, gin.H{"error": "Missing user ID"})
		return
	}

	log.Printf("Received Radarr webhook: %s for user %s", webhook.EventType, userID)

	var title, body string
	
	switch webhook.EventType {
	case "Grab":
		title = "Movie Grabbed"
		body = fmt.Sprintf("%s (%d) has been grabbed", webhook.Movie.Title, webhook.Movie.Year)
		
	case "Download":
		title = "Movie Downloaded"
		body = fmt.Sprintf("%s (%d) is ready to watch", webhook.Movie.Title, webhook.Movie.Year)
		
	case "Rename":
		title = "Movie Renamed"
		body = fmt.Sprintf("%s has been renamed", webhook.Movie.Title)
		
	case "MovieDelete":
		title = "Movie Deleted"
		body = fmt.Sprintf("%s has been removed from your library", webhook.Movie.Title)
		
	case "Test":
		title = "Zagreus Test"
		body = "Test notification from Zagreus"
		
	case "MovieAdded":
		title = "Movie Added"
		body = fmt.Sprintf("%s has been added to your library", webhook.Movie.Title)
		
	case "MovieFileDelete":
		title = "Movie File Deleted"
		body = fmt.Sprintf("File deleted for %s", webhook.Movie.Title)
		
	default:
		log.Printf("Unknown Radarr event type: %s", webhook.EventType)
		c.JSON(200, WebhookResponse{Success: true, Message: "Event ignored"})
		return
	}

	if title != "" && body != "" {
		if err := sendNotificationToUser(userID, title, body); err != nil {
			log.Printf("Failed to send notification: %v", err)
			c.JSON(500, gin.H{"error": "Failed to send notification"})
			return
		}
	}

	c.JSON(200, WebhookResponse{
		Success: true,
		Message: "Webhook processed successfully",
	})
}

// Custom webhook handler
func handleCustomWebhook(c *gin.Context) {
	var data map[string]interface{}
	if err := c.ShouldBindJSON(&data); err != nil {
		c.JSON(400, gin.H{"error": "Invalid JSON"})
		return
	}

	userID := c.GetHeader("X-User-Id")
	if userID == "" {
		c.JSON(401, gin.H{"error": "Missing user ID"})
		return
	}

	// Extract title and body from custom webhook
	title, _ := data["title"].(string)
	body, _ := data["body"].(string)
	
	if title == "" {
		title = "Custom Notification"
	}
	if body == "" {
		body = "You have a new notification"
	}

	log.Printf("Received custom webhook for user %s: %s - %s", userID, title, body)

	if err := sendNotificationToUser(userID, title, body); err != nil {
		log.Printf("Failed to send notification: %v", err)
		c.JSON(500, gin.H{"error": "Failed to send notification"})
		return
	}

	c.JSON(200, WebhookResponse{
		Success: true,
		Message: "Custom notification sent",
	})
}

// Helper to validate webhook auth
func validateWebhookAuth(c *gin.Context) bool {
	// For now, just check for user ID
	// In production, you'd want proper webhook secrets
	return c.GetHeader("X-User-Id") != ""
}

// Other webhook handlers remain as stubs for now
func handleLidarrWebhook(c *gin.Context) {
	// Similar to Sonarr/Radarr
	c.JSON(200, gin.H{"message": "Lidarr webhook received"})
}

func handleOverseerrWebhook(c *gin.Context) {
	// Similar structure
	c.JSON(200, gin.H{"message": "Overseerr webhook received"})
}

func handleTautulliWebhook(c *gin.Context) {
	// Similar structure
	c.JSON(200, gin.H{"message": "Tautulli webhook received"})
}

// Handle webhook with user ID in URL path (Flutter app compatibility)
func handleWebhookWithPayload(c *gin.Context) {
	webhookID := c.Param("payload")

	// Extract signature from Basic Auth password field (Radarr/Sonarr webhook format)
	_, password, hasAuth := c.Request.BasicAuth()
	if !hasAuth || password == "" {
		log.Printf("Missing webhook signature for %s", webhookID)
		c.JSON(401, gin.H{"error": "Missing signature"})
		return
	}

	// Verify the signature
	if !verifyWebhookSignature(webhookID, password) {
		log.Printf("Invalid webhook signature for %s", webhookID)
		c.JSON(401, gin.H{"error": "Invalid signature"})
		return
	}

	// Get device tokens for this webhook ID
	deviceTokens, err := getDeviceTokensForWebhook(webhookID)
	if err != nil {
		log.Printf("Failed to get device tokens for webhook %s: %v", webhookID, err)
		c.JSON(400, gin.H{"error": "Invalid webhook ID"})
		return
	}
	
	// First read the raw body for debugging
	bodyBytes, _ := c.GetRawData()
	log.Printf("Raw webhook body: %s", string(bodyBytes))
	
	// Restore body for parsing
	c.Request.Body = io.NopCloser(bytes.NewReader(bodyBytes))
	
	// Parse as generic JSON first to get eventType
	var genericWebhook map[string]interface{}
	if err := c.ShouldBindJSON(&genericWebhook); err != nil {
		log.Printf("Failed to parse webhook JSON: %v", err)
		c.JSON(400, gin.H{"error": "Invalid webhook data"})
		return
	}
	
	eventType, _ := genericWebhook["eventType"].(string)
	log.Printf("Received webhook via payload URL: %s for webhook %s (%d devices)", eventType, webhookID, len(deviceTokens))
	
	var title, body string
	
	// Check if this is a movie event (Radarr) or series event (Sonarr)
	isMovieEvent := genericWebhook["movie"] != nil
	isSeriesEvent := genericWebhook["series"] != nil
	
	if isMovieEvent {
		// Extract movie info from the webhook
		movieTitle := "Unknown Movie"
		movieYear := 0
		
		if movie, ok := genericWebhook["movie"].(map[string]interface{}); ok {
			if t, ok := movie["title"].(string); ok {
				movieTitle = t
			}
			if y, ok := movie["year"].(float64); ok {
				movieYear = int(y)
			}
		}
		
		// Handle Radarr events
		switch eventType {
		case "Test":
			title = "Radarr Test"
			body = "Test notification from Radarr"
			
		case "MovieAdded":
			title = "Movie Added"
			body = fmt.Sprintf("%s (%d) has been added to your library", movieTitle, movieYear)
			
		case "Grab":
			title = "Movie Grabbed"
			body = fmt.Sprintf("%s (%d) has been grabbed", movieTitle, movieYear)
			
		case "Download":
			title = "Movie Downloaded"
			body = fmt.Sprintf("%s (%d) is ready to watch", movieTitle, movieYear)
			
		case "Rename":
			title = "Movie Renamed"
			body = fmt.Sprintf("%s has been renamed", movieTitle)
			
		case "MovieDelete":
			title = "Movie Deleted"
			body = fmt.Sprintf("%s has been removed from your library", movieTitle)
			
		case "MovieFileDelete":
			title = "Movie File Deleted"
			body = fmt.Sprintf("File deleted for %s", movieTitle)
			
		default:
			log.Printf("Unknown Radarr event type: %s", eventType)
			c.JSON(200, gin.H{"success": true, "message": "Event type not handled: " + eventType})
			return
		}
		
	} else if isSeriesEvent {
		// Extract series info
		seriesTitle := "Unknown Series"
		if series, ok := genericWebhook["series"].(map[string]interface{}); ok {
			if t, ok := series["title"].(string); ok {
				seriesTitle = t
			}
		}
		
		// Extract episodes info
		var episodes []map[string]interface{}
		if eps, ok := genericWebhook["episodes"].([]interface{}); ok {
			for _, ep := range eps {
				if episode, ok := ep.(map[string]interface{}); ok {
					episodes = append(episodes, episode)
				}
			}
		}
		
		// Handle Sonarr events
		switch eventType {
		case "Test":
			title = "Sonarr Test"
			body = "Test notification from Sonarr"
			
		case "Grab":
			if len(episodes) > 0 {
				seasonNum := 0
				episodeNum := 0
				if s, ok := episodes[0]["seasonNumber"].(float64); ok {
					seasonNum = int(s)
				}
				if e, ok := episodes[0]["episodeNumber"].(float64); ok {
					episodeNum = int(e)
				}
				title = "Episode Grabbed"
				body = fmt.Sprintf("%s S%02dE%02d has been grabbed", 
					seriesTitle, seasonNum, episodeNum)
			}
			
		case "Download":
			if len(episodes) > 0 {
				seasonNum := 0
				episodeNum := 0
				if s, ok := episodes[0]["seasonNumber"].(float64); ok {
					seasonNum = int(s)
				}
				if e, ok := episodes[0]["episodeNumber"].(float64); ok {
					episodeNum = int(e)
				}
				title = "Episode Downloaded"
				body = fmt.Sprintf("%s S%02dE%02d is ready to watch", 
					seriesTitle, seasonNum, episodeNum)
			}
			
		case "Rename":
			title = "Episodes Renamed"
			body = fmt.Sprintf("%d episodes of %s have been renamed", 
				len(episodes), seriesTitle)
			
		case "SeriesDelete":
			title = "Series Deleted"
			body = fmt.Sprintf("%s has been removed from your library", seriesTitle)
			
		case "SeriesAdd":
			title = "Series Added"
			body = fmt.Sprintf("%s has been added to your library", seriesTitle)
			
		case "EpisodeFileDelete":
			if len(episodes) > 0 {
				seasonNum := 0
				episodeNum := 0
				if s, ok := episodes[0]["seasonNumber"].(float64); ok {
					seasonNum = int(s)
				}
				if e, ok := episodes[0]["episodeNumber"].(float64); ok {
					episodeNum = int(e)
				}
				title = "Episode File Deleted"
				body = fmt.Sprintf("File deleted for %s S%02dE%02d", 
					seriesTitle, seasonNum, episodeNum)
			}
			
		default:
			log.Printf("Unknown Sonarr event type: %s", eventType)
			c.JSON(200, gin.H{"success": true, "message": "Event type not handled: " + eventType})
			return
		}
		
	} else {
		// Generic test notification fallback
		if eventType == "Test" {
			title = "Test Notification"
			body = "Test notification from Zagreus"
		} else {
			log.Printf("Unknown webhook format for event: %s", eventType)
			c.JSON(200, gin.H{"success": true, "message": "Unknown webhook format"})
			return
		}
	}
	
	// Send notification to all device tokens
	successCount := 0
	for _, token := range deviceTokens {
		// Check environment to determine production/sandbox
		isProduction := os.Getenv("APNS_ENVIRONMENT") == "production"

		if err := apnsClient.SendNotification(token, title, body, isProduction); err != nil {
			log.Printf("Failed to send to token %s: %v", token, err)
		} else {
			successCount++
		}
	}

	if successCount == 0 && len(deviceTokens) > 0 {
		c.JSON(500, gin.H{"error": "Failed to send any notifications"})
		return
	}

	c.JSON(200, gin.H{
		"success": true,
		"message": fmt.Sprintf("Notification sent for %s to %d/%d devices", eventType, successCount, len(deviceTokens)),
	})
}
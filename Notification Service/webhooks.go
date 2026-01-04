package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
)

// Sonarr webhook structures
type SonarrWebhook struct {
	EventType string          `json:"eventType"`
	Series    SonarrSeries    `json:"series"`
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
	EventType      string      `json:"eventType"`
	Movie          RadarrMovie `json:"movie"`
	AddMethod      string      `json:"addMethod,omitempty"`
	InstanceName   string      `json:"instanceName,omitempty"`
	ApplicationURL string      `json:"applicationUrl,omitempty"`
}

type RadarrMovie struct {
	ID         int                      `json:"id"`
	Title      string                   `json:"title"`
	Year       int                      `json:"year"`
	ImdbID     string                   `json:"imdbId,omitempty"`
	TmdbID     int                      `json:"tmdbId"`
	TitleSlug  string                   `json:"titleSlug,omitempty"`
	FolderName string                   `json:"folderName,omitempty"`
	Path       string                   `json:"path,omitempty"`
	Genres     []string                 `json:"genres,omitempty"`
	Images     []map[string]interface{} `json:"images,omitempty"`
	Tags       []interface{}            `json:"tags,omitempty"`
	Overview   string                   `json:"overview,omitempty"`
}

// Seerr webhook structures
type SeerrWebhook struct {
	NotificationType string                   `json:"notification_type"` // Kept for compatibility
	Type             string                   `json:"type"`              // Actual field Seerr sends
	Event            string                   `json:"event"`
	Subject          string                   `json:"subject"`
	Message          string                   `json:"message"`
	Image            string                   `json:"image"`
	Media            *SeerrMedia          `json:"media"`
	Request          *SeerrRequest        `json:"request"`
	Issue            *SeerrIssue          `json:"issue"`
	Comment          *SeerrComment        `json:"comment"`
	Extra            []interface{}            `json:"extra"` // Array, not map
}

type SeerrMedia struct {
	MediaType string `json:"media_type"`
	TmdbID    string `json:"tmdbId"`
	ImdbID    string `json:"imdbId"`
	TvdbID    string `json:"tvdbId"`
	Status    string `json:"status"`
	Status4k  string `json:"status4k"`
}

type SeerrRequest struct {
	RequestID                       string `json:"request_id"`
	RequestedByUsername             string `json:"requestedBy_username"`
	RequestedByEmail                string `json:"requestedBy_email"`
	RequestedByAvatar               string `json:"requestedBy_avatar"`
	RequestedBySettingsDiscordID    string `json:"requestedBy_settings_discordId"`
	RequestedBySettingsTelegramChatID string `json:"requestedBy_settings_telegramChatId"`
}

type SeerrIssue struct {
	IssueID           int    `json:"issue_id"`
	IssueType         string `json:"issue_type"`
	IssueStatus       string `json:"issue_status"`
	CreatedByEmail    string `json:"createdBy_email"`
	CreatedByUsername string `json:"createdBy_username"`
	CreatedByAvatar   string `json:"createdBy_avatar"`
}

type SeerrComment struct {
	CommentMessage       string `json:"comment_message"`
	CommentedByEmail     string `json:"commentedBy_email"`
	CommentedByUsername  string `json:"commentedBy_username"`
	CommentedByAvatar    string `json:"commentedBy_avatar"`
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

	// DEBUG: Print series images
	if seriesData, ok := genericWebhook["series"].(map[string]interface{}); ok {
		if images, ok := seriesData["images"].([]interface{}); ok {
			log.Printf("📺 SONARR IMAGES DEBUG: %+v", images)
		}
	}

	// Extract series info and identifiers
	seriesTitle := "Unknown Series"
	seriesData, _ := genericWebhook["series"].(map[string]interface{})
	if seriesData != nil {
		if t, ok := seriesData["title"].(string); ok {
			seriesTitle = t
		}
	}

	tmdbID := 0
	tvdbID := 0
	imdbID := ""
	if seriesData != nil {
		tmdbID = intFromInterface(seriesData["tmdbId"])
		tvdbID = intFromInterface(seriesData["tvdbId"])
		imdbID = stringFromInterface(seriesData["imdbId"])
	}

	// Extract poster URL from images array
	var posterURL string
	if seriesData != nil {
		if images, ok := seriesData["images"].([]interface{}); ok {
			for _, img := range images {
				if imgMap, ok := img.(map[string]interface{}); ok {
					if coverType, ok := imgMap["coverType"].(string); ok && coverType == "poster" {
						if remoteURL, ok := imgMap["remoteUrl"].(string); ok {
							posterURL = remoteURL
							break
						}
					}
				}
			}
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

	seasonNum := 0
	episodeNum := 0
	if len(episodes) > 0 {
		seasonNum = intFromInterface(episodes[0]["seasonNumber"])
		episodeNum = intFromInterface(episodes[0]["episodeNumber"])
	}

	// Handle different event types
	var title, body string

	switch eventType {
	case "Test":
		title = "Sonarr Test"
		body = "Test notification from Sonarr"

	case "Grab":
		if len(episodes) > 0 {
			title = "Episode Grabbed"
			body = fmt.Sprintf("%s S%02dE%02d has been grabbed",
				seriesTitle, seasonNum, episodeNum)
		}

	case "Download":
		if len(episodes) > 0 {
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
		metadata := map[string]string{
			"event_type":   eventType,
			"content_type": "series",
			"title":        seriesTitle,
		}
		if seasonNum > 0 {
			metadata["season"] = strconv.Itoa(seasonNum)
		}
		if episodeNum > 0 {
			metadata["episode"] = strconv.Itoa(episodeNum)
		}
		if tvdbID > 0 {
			metadata["tvdb_id"] = strconv.Itoa(tvdbID)
		}
		if imdbID != "" {
			metadata["imdb_id"] = imdbID
		}
		if tmdbID > 0 {
			metadata["tmdb_id"] = strconv.Itoa(tmdbID)
		}

		var params *NotificationParams
		if posterURL != "" || len(metadata) > 0 {
			params = &NotificationParams{
				ImageURL: posterURL,
				Metadata: metadata,
			}
		}

		if err := sendNotificationToUser(userID, title, body, params); err != nil {
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

	// Extract poster URL from images array
	var posterURL string
	for _, img := range webhook.Movie.Images {
		if coverType, ok := img["coverType"].(string); ok && coverType == "poster" {
			if remoteURL, ok := img["remoteUrl"].(string); ok {
				posterURL = remoteURL
				break
			}
		}
	}

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
		metadata := map[string]string{
			"event_type":   webhook.EventType,
			"content_type": "movie",
			"title":        webhook.Movie.Title,
		}
		if webhook.Movie.Year != 0 {
			metadata["year"] = strconv.Itoa(webhook.Movie.Year)
		}
		if webhook.Movie.ImdbID != "" {
			metadata["imdb_id"] = webhook.Movie.ImdbID
		}
		if webhook.Movie.TmdbID != 0 {
			metadata["tmdb_id"] = strconv.Itoa(webhook.Movie.TmdbID)
		}

		var params *NotificationParams
		if posterURL != "" || len(metadata) > 0 {
			params = &NotificationParams{
				ImageURL: posterURL,
				Metadata: metadata,
			}
		}

		if err := sendNotificationToUser(userID, title, body, params); err != nil {
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

	var params *NotificationParams

	if imageURL := stringFromInterface(data["image_url"]); imageURL != "" {
		params = &NotificationParams{ImageURL: imageURL}
	} else if posterURL := stringFromInterface(data["poster_url"]); posterURL != "" {
		params = &NotificationParams{ImageURL: posterURL}
	}

	if rawMetadata, ok := data["metadata"].(map[string]interface{}); ok {
		metadata := make(map[string]string)
		for key, value := range rawMetadata {
			if str := stringFromInterface(value); str != "" {
				metadata[key] = str
			}
		}
		if len(metadata) > 0 {
			if params == nil {
				params = &NotificationParams{}
			}
			params.Metadata = metadata
		}
	}

	if err := sendNotificationToUser(userID, title, body, params); err != nil {
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

func handleProwlarrWebhook(c *gin.Context) {
	// Similar to other *arr webhooks
	c.JSON(200, gin.H{"message": "Prowlarr webhook received"})
}

func handleSeerrWebhook(c *gin.Context) {
	var webhook SeerrWebhook
	if err := c.ShouldBindJSON(&webhook); err != nil {
		c.JSON(400, gin.H{"error": "Invalid webhook data"})
		return
	}

	userID := c.GetHeader("X-User-Id")
	if userID == "" {
		c.JSON(401, gin.H{"error": "Missing user ID"})
		return
	}

	// Use Type field if set, otherwise fall back to NotificationType
	notificationType := webhook.Type
	if notificationType == "" {
		notificationType = webhook.NotificationType
	}

	log.Printf("Received Seerr webhook: %s for user %s", notificationType, userID)

	var title, body string
	var posterURL string

	// Get poster from TMDB based on media type
	if webhook.Media != nil {
		if webhook.Media.MediaType == "movie" {
			tmdbID := 0
			if webhook.Media.TmdbID != "" {
				if id, err := strconv.Atoi(webhook.Media.TmdbID); err == nil {
					tmdbID = id
				}
			}
			if url, _, err := getMoviePosterURL(tmdbID, webhook.Media.ImdbID); err == nil {
				posterURL = url
			}
		} else if webhook.Media.MediaType == "tv" {
			tmdbID := 0
			tvdbID := 0
			if webhook.Media.TmdbID != "" {
				if id, err := strconv.Atoi(webhook.Media.TmdbID); err == nil {
					tmdbID = id
				}
			}
			if webhook.Media.TvdbID != "" {
				if id, err := strconv.Atoi(webhook.Media.TvdbID); err == nil {
					tvdbID = id
				}
			}
			if url, _, err := getTVPosterURL(tmdbID, tvdbID, webhook.Media.ImdbID); err == nil {
				posterURL = url
			}
		}
	}

	// Build notification based on event type
	requester := ""
	if webhook.Request != nil && webhook.Request.RequestedByUsername != "" {
		requester = webhook.Request.RequestedByUsername
	}

	switch notificationType {
	case "TEST_NOTIFICATION":
		title = "Seerr Test"
		body = "Zagreus is ready for Seerr notifications!"

	case "MEDIA_PENDING":
		title = webhook.Event
		if title == "" {
			title = "New Request"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "MEDIA_APPROVED":
		title = webhook.Event
		if title == "" {
			title = "Request Approved"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "MEDIA_AUTO_APPROVED":
		title = webhook.Event
		if title == "" {
			title = "Request Auto-Approved"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "MEDIA_AVAILABLE":
		title = webhook.Event
		if title == "" {
			title = "Media Available"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "MEDIA_DECLINED":
		title = webhook.Event
		if title == "" {
			title = "Request Declined"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "MEDIA_FAILED":
		title = webhook.Event
		if title == "" {
			title = "Request Failed"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "ISSUE_CREATED":
		title = webhook.Event
		if title == "" {
			title = "Issue Reported"
		}
		body = webhook.Subject
		if webhook.Message != "" {
			body = fmt.Sprintf("%s\n%s", body, webhook.Message)
		}

	case "ISSUE_RESOLVED":
		title = webhook.Event
		if title == "" {
			title = "Issue Resolved"
		}
		body = webhook.Subject
		if webhook.Message != "" {
			body = fmt.Sprintf("%s\n%s", body, webhook.Message)
		}

	case "ISSUE_REOPENED":
		title = webhook.Event
		if title == "" {
			title = "Issue Reopened"
		}
		body = webhook.Subject
		if webhook.Message != "" {
			body = fmt.Sprintf("%s\n%s", body, webhook.Message)
		}

	case "ISSUE_COMMENT":
		title = webhook.Event
		if title == "" {
			title = "New Comment"
		}
		body = webhook.Subject
		if webhook.Comment != nil && webhook.Comment.CommentMessage != "" {
			body = fmt.Sprintf("%s\n%s", body, webhook.Comment.CommentMessage)
		}

	default:
		log.Printf("Unknown Seerr notification type: %s", notificationType)
		c.JSON(200, WebhookResponse{Success: true, Message: "Event ignored"})
		return
	}

	if title != "" && body != "" {
		metadata := map[string]string{
			"event_type": notificationType,
			"source":     "seerr",
		}
		if webhook.Media != nil {
			metadata["content_type"] = webhook.Media.MediaType
			if webhook.Media.TmdbID != "" {
				metadata["tmdb_id"] = webhook.Media.TmdbID
			}
			if webhook.Media.ImdbID != "" {
				metadata["imdb_id"] = webhook.Media.ImdbID
			}
			if webhook.Media.TvdbID != "" {
				metadata["tvdb_id"] = webhook.Media.TvdbID
			}
		}

		var params *NotificationParams
		if posterURL != "" || len(metadata) > 0 {
			params = &NotificationParams{
				ImageURL: posterURL,
				Metadata: metadata,
			}
		}

		if err := sendNotificationToUser(userID, title, body, params); err != nil {
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

func handleSeerrWebhookWithID(c *gin.Context) {
	webhookID := c.Param("id")
	if webhookID == "" {
		c.JSON(400, gin.H{"error": "Missing webhook ID"})
		return
	}

	// Check if Seerr notifications are enabled for this webhook
	if !isSeerrEnabled(webhookID) {
		log.Printf("Seerr notifications disabled for webhook %s, skipping", webhookID)
		c.JSON(200, gin.H{
			"success": true,
			"message": "Seerr notifications disabled for this webhook",
		})
		return
	}

	// Get device tokens for this webhook ID from database
	deviceTokens, err := getDeviceTokensForWebhook(webhookID)
	if err != nil {
		log.Printf("Failed to get device tokens for webhook %s: %v", webhookID, err)
		c.JSON(400, gin.H{"error": "Invalid webhook ID"})
		return
	}

	if len(deviceTokens) == 0 {
		log.Printf("No device tokens found for webhook %s", webhookID)
		c.JSON(404, gin.H{"error": "No devices registered for this webhook"})
		return
	}

	var webhook SeerrWebhook
	if err := c.ShouldBindJSON(&webhook); err != nil {
		log.Printf("Failed to parse Seerr webhook: %v", err)
		c.JSON(400, gin.H{"error": "Invalid webhook data"})
		return
	}

	// Use Type field if set, otherwise fall back to NotificationType
	notificationType := webhook.Type
	if notificationType == "" {
		notificationType = webhook.NotificationType
	}

	log.Printf("Received Seerr webhook: %s for webhook %s (%d devices)", notificationType, webhookID, len(deviceTokens))

	var title, body string
	var posterURL string

	// Get poster from TMDB based on media type
	if webhook.Media != nil {
		if webhook.Media.MediaType == "movie" {
			tmdbID := 0
			if webhook.Media.TmdbID != "" {
				if id, err := strconv.Atoi(webhook.Media.TmdbID); err == nil {
					tmdbID = id
				}
			}
			if url, _, err := getMoviePosterURL(tmdbID, webhook.Media.ImdbID); err == nil {
				posterURL = url
			}
		} else if webhook.Media.MediaType == "tv" {
			tmdbID := 0
			tvdbID := 0
			if webhook.Media.TmdbID != "" {
				if id, err := strconv.Atoi(webhook.Media.TmdbID); err == nil {
					tmdbID = id
				}
			}
			if webhook.Media.TvdbID != "" {
				if id, err := strconv.Atoi(webhook.Media.TvdbID); err == nil {
					tvdbID = id
				}
			}
			if url, _, err := getTVPosterURL(tmdbID, tvdbID, webhook.Media.ImdbID); err == nil {
				posterURL = url
			}
		}
	}

	// Build notification based on event type
	requester := ""
	if webhook.Request != nil && webhook.Request.RequestedByUsername != "" {
		requester = webhook.Request.RequestedByUsername
	}

	switch notificationType {
	case "TEST_NOTIFICATION":
		title = "Seerr Test"
		body = "Zagreus is ready for Seerr notifications!"

	case "MEDIA_PENDING":
		title = webhook.Event
		if title == "" {
			title = "New Request"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "MEDIA_APPROVED":
		title = webhook.Event
		if title == "" {
			title = "Request Approved"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "MEDIA_AUTO_APPROVED":
		title = webhook.Event
		if title == "" {
			title = "Request Auto-Approved"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "MEDIA_AVAILABLE":
		title = webhook.Event
		if title == "" {
			title = "Media Available"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "MEDIA_DECLINED":
		title = webhook.Event
		if title == "" {
			title = "Request Declined"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "MEDIA_FAILED":
		title = webhook.Event
		if title == "" {
			title = "Request Failed"
		}
		body = webhook.Subject
		if requester != "" {
			body = fmt.Sprintf("%s\nRequested by %s", body, requester)
		}

	case "ISSUE_CREATED":
		title = webhook.Event
		if title == "" {
			title = "Issue Reported"
		}
		body = webhook.Subject
		if webhook.Message != "" {
			body = fmt.Sprintf("%s\n%s", body, webhook.Message)
		}

	case "ISSUE_RESOLVED":
		title = webhook.Event
		if title == "" {
			title = "Issue Resolved"
		}
		body = webhook.Subject
		if webhook.Message != "" {
			body = fmt.Sprintf("%s\n%s", body, webhook.Message)
		}

	case "ISSUE_REOPENED":
		title = webhook.Event
		if title == "" {
			title = "Issue Reopened"
		}
		body = webhook.Subject
		if webhook.Message != "" {
			body = fmt.Sprintf("%s\n%s", body, webhook.Message)
		}

	case "ISSUE_COMMENT":
		title = webhook.Event
		if title == "" {
			title = "New Comment"
		}
		body = webhook.Subject
		if webhook.Comment != nil && webhook.Comment.CommentMessage != "" {
			body = fmt.Sprintf("%s\n%s", body, webhook.Comment.CommentMessage)
		}

	default:
		log.Printf("Unknown Seerr notification type: %s", notificationType)
		c.JSON(200, WebhookResponse{Success: true, Message: "Event ignored"})
		return
	}

	if title != "" && body != "" {
		metadata := map[string]string{
			"event_type": notificationType,
			"source":     "seerr",
		}
		if webhook.Media != nil {
			metadata["content_type"] = webhook.Media.MediaType
			if webhook.Media.TmdbID != "" {
				metadata["tmdb_id"] = webhook.Media.TmdbID
			}
			if webhook.Media.ImdbID != "" {
				metadata["imdb_id"] = webhook.Media.ImdbID
			}
			if webhook.Media.TvdbID != "" {
				metadata["tvdb_id"] = webhook.Media.TvdbID
			}
		}

		var params *NotificationParams
		if posterURL != "" || len(metadata) > 0 {
			params = &NotificationParams{
				ImageURL: posterURL,
				Metadata: metadata,
			}
		}

		// Send notification to all device tokens
		successCount := 0
		payload := buildAPNsPayload(title, body, params)
		isProduction := os.Getenv("APNS_ENVIRONMENT") == "production"

		for _, token := range deviceTokens {
			if err := apnsClient.SendRichNotification(token, payload, isProduction); err != nil {
				log.Printf("Failed to send to token %s: %v", token, err)

				// Check if error is 410 (Unregistered) - token is no longer valid
				if strings.Contains(err.Error(), "status 410") || strings.Contains(err.Error(), "Unregistered") {
					log.Printf("Token %s is unregistered, removing from database", token)
					if removeErr := removeDeviceToken(token); removeErr != nil {
						log.Printf("Failed to remove invalid token: %v", removeErr)
					}
					// Don't count 410 as a real failure - it's expected cleanup
					successCount++
				}
			} else {
				successCount++
			}
		}

		if successCount == 0 && len(deviceTokens) > 0 {
			c.JSON(500, gin.H{"error": "Failed to send any notifications"})
			return
		}

		log.Printf("Successfully sent Seerr notification to %d/%d devices", successCount, len(deviceTokens))
	}

	c.JSON(200, WebhookResponse{
		Success: true,
		Message: fmt.Sprintf("Notification sent to %d device(s)", len(deviceTokens)),
	})
}

// handleTautulliWebhookWithID handles Tautulli webhooks using webhook ID for auth
func handleTautulliWebhookWithID(c *gin.Context) {
	webhookID := c.Param("id")
	if webhookID == "" {
		c.JSON(400, gin.H{"error": "Missing webhook ID"})
		return
	}

	// Get device tokens for this webhook ID from database
	deviceTokens, err := getDeviceTokensForWebhook(webhookID)
	if err != nil {
		log.Printf("Failed to get device tokens for webhook %s: %v", webhookID, err)
		c.JSON(400, gin.H{"error": "Invalid webhook ID"})
		return
	}

	if len(deviceTokens) == 0 {
		log.Printf("No device tokens found for webhook %s", webhookID)
		c.JSON(404, gin.H{"error": "No devices registered for this webhook"})
		return
	}

	// Parse the webhook data - try JSON first, then form data
	var webhookData map[string]interface{}
	contentType := c.GetHeader("Content-Type")
	log.Printf("Tautulli webhook content-type: %s", contentType)

	// Try to bind JSON first
	if err := c.ShouldBindJSON(&webhookData); err != nil {
		log.Printf("JSON parsing failed, trying form data: %v", err)

		// Try form data
		if err := c.Request.ParseForm(); err != nil {
			log.Printf("Form parsing also failed: %v", err)
			c.JSON(400, gin.H{"error": "Invalid webhook data"})
			return
		}

		// Convert form data to map
		webhookData = make(map[string]interface{})
		for key, values := range c.Request.PostForm {
			if len(values) == 1 {
				webhookData[key] = values[0]
			} else {
				webhookData[key] = values
			}
		}

		// If still empty, try reading raw body for debugging
		if len(webhookData) == 0 {
			log.Printf("No form data found, webhook data is empty")
			c.JSON(400, gin.H{"error": "Invalid webhook data"})
			return
		}
	}

	log.Printf("Tautulli webhook data keys: %v", getMapKeys(webhookData))

	action := stringFromInterface(webhookData["action"])
	if action == "" {
		// Try event_type as fallback
		action = stringFromInterface(webhookData["event_type"])
	}

	log.Printf("Received Tautulli webhook: %s for webhook %s (%d devices)", action, webhookID, len(deviceTokens))

	// Extract common fields
	userName := stringFromInterface(webhookData["user"])
	mediaTitle := stringFromInterface(webhookData["title"])
	serverName := stringFromInterface(webhookData["server_name"])

	var title, body string
	metadata := map[string]string{
		"event_type":   action,
		"content_type": "plex",
	}
	if userName != "" {
		metadata["user"] = userName
	}
	if mediaTitle != "" {
		metadata["title"] = mediaTitle
	}

	// Handle Tautulli events
	switch action {
	case "Test":
		title = "Tautulli Test"
		body = "Test notification from Tautulli"

	case "PlaybackStart":
		title = "Playback Started"
		if userName != "" && mediaTitle != "" {
			body = fmt.Sprintf("%s started watching %s", userName, mediaTitle)
		} else if mediaTitle != "" {
			body = fmt.Sprintf("Started playing: %s", mediaTitle)
		} else {
			body = "Playback started"
		}

	case "PlaybackStop":
		title = "Playback Stopped"
		if userName != "" && mediaTitle != "" {
			body = fmt.Sprintf("%s stopped watching %s", userName, mediaTitle)
		} else {
			body = "Playback stopped"
		}

	case "PlaybackPause":
		title = "Playback Paused"
		if mediaTitle != "" {
			body = fmt.Sprintf("Paused: %s", mediaTitle)
		} else {
			body = "Playback paused"
		}

	case "PlaybackResume":
		title = "Playback Resumed"
		if mediaTitle != "" {
			body = fmt.Sprintf("Resumed: %s", mediaTitle)
		} else {
			body = "Playback resumed"
		}

	case "BufferWarning":
		title = "Buffer Warning"
		if userName != "" {
			body = fmt.Sprintf("Buffering issues for %s", userName)
		} else {
			body = "Buffering issues detected"
		}

	case "RecentlyAdded":
		title = "Recently Added"
		if mediaTitle != "" {
			body = fmt.Sprintf("%s has been added to Plex", mediaTitle)
		} else {
			body = "New content added to Plex"
		}

	case "PlexServerDown":
		title = "Plex Server Down"
		if serverName != "" {
			body = fmt.Sprintf("%s is not responding", serverName)
		} else {
			body = "Plex server is not responding"
		}

	case "PlexServerBackUp":
		title = "Plex Server Back Up"
		if serverName != "" {
			body = fmt.Sprintf("%s is back online", serverName)
		} else {
			body = "Plex server is back online"
		}

	case "PlexRemoteAccessDown":
		title = "Remote Access Down"
		body = "Plex remote access is down"

	case "PlexRemoteAccessBackUp":
		title = "Remote Access Restored"
		body = "Plex remote access is back up"

	case "PlexUpdateAvailable":
		title = "Plex Update Available"
		body = "A new version of Plex is available"

	case "TautulliUpdateAvailable":
		title = "Tautulli Update Available"
		body = "A new version of Tautulli is available"

	case "UserConcurrentStreams":
		title = "Concurrent Streams"
		if userName != "" {
			body = fmt.Sprintf("%s has multiple concurrent streams", userName)
		} else {
			body = "Multiple concurrent streams detected"
		}

	case "UserNewDevice":
		title = "New Device"
		if userName != "" {
			body = fmt.Sprintf("%s is streaming from a new device", userName)
		} else {
			body = "New device detected"
		}

	default:
		log.Printf("Unknown Tautulli action: %s", action)
		c.JSON(200, gin.H{"success": true, "message": "Action not handled: " + action})
		return
	}

	// Build notification params
	var params *NotificationParams
	if len(metadata) > 0 {
		params = &NotificationParams{
			Metadata: metadata,
		}
	}

	// Send notification to all device tokens
	successCount := 0
	payload := buildAPNsPayload(title, body, params)
	for _, token := range deviceTokens {
		isProduction := os.Getenv("APNS_ENVIRONMENT") == "production"
		if err := apnsClient.SendRichNotification(token, payload, isProduction); err != nil {
			log.Printf("Failed to send to token %s: %v", token, err)

			// Check if error is 410 (Unregistered) - token is no longer valid
			if strings.Contains(err.Error(), "status 410") || strings.Contains(err.Error(), "Unregistered") {
				log.Printf("Token %s is unregistered, removing from database", token)
				if removeErr := removeDeviceToken(token); removeErr != nil {
					log.Printf("Failed to remove invalid token: %v", removeErr)
				}
				successCount++
			}
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
		"message": fmt.Sprintf("Notification sent for %s to %d/%d devices", action, successCount, len(deviceTokens)),
	})
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
	metadata := map[string]string{
		"event_type": eventType,
	}
	posterURL := ""

	// Check if this is a movie event (Radarr) or series event (Sonarr)
	isMovieEvent := genericWebhook["movie"] != nil
	isSeriesEvent := genericWebhook["series"] != nil

	if isMovieEvent {
		// Extract movie info from the webhook
		movieTitle := "Unknown Movie"
		movieYear := 0
		var tmdbID int
		imdbID := ""

		if movie, ok := genericWebhook["movie"].(map[string]interface{}); ok {
			if t := stringFromInterface(movie["title"]); t != "" {
				movieTitle = t
			}
			movieYear = intFromInterface(movie["year"])
			tmdbID = intFromInterface(movie["tmdbId"])
			if imdb := stringFromInterface(movie["imdbId"]); imdb != "" {
				imdbID = imdb
			} else {
				imdbID = stringFromInterface(movie["imdb"])
			}
		}

		metadata["event_type"] = eventType
		metadata["content_type"] = "movie"
		metadata["title"] = movieTitle
		if movieYear != 0 {
			metadata["year"] = strconv.Itoa(movieYear)
		}
		if imdbID != "" {
			metadata["imdb_id"] = imdbID
		}

		if url, resolvedID, err := getMoviePosterURL(tmdbID, imdbID); err == nil {
			posterURL = url
			if resolvedID != 0 {
				metadata["tmdb_id"] = strconv.Itoa(resolvedID)
			} else if tmdbID != 0 {
				metadata["tmdb_id"] = strconv.Itoa(tmdbID)
			}
		} else if err != nil {
			log.Printf("TMDB lookup failed for webhook movie %s: %v", movieTitle, err)
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
		seriesData, _ := genericWebhook["series"].(map[string]interface{})
		tmdbID := 0
		tvdbID := 0
		imdbID := ""
		if seriesData != nil {
			if t := stringFromInterface(seriesData["title"]); t != "" {
				seriesTitle = t
			}
			tmdbID = intFromInterface(seriesData["tmdbId"])
			tvdbID = intFromInterface(seriesData["tvdbId"])
			imdbID = stringFromInterface(seriesData["imdbId"])
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

		seasonNum := 0
		episodeNum := 0
		if len(episodes) > 0 {
			seasonNum = intFromInterface(episodes[0]["seasonNumber"])
			episodeNum = intFromInterface(episodes[0]["episodeNumber"])
		}

		metadata["event_type"] = eventType
		metadata["content_type"] = "series"
		metadata["title"] = seriesTitle
		if seasonNum > 0 {
			metadata["season"] = strconv.Itoa(seasonNum)
		}
		if episodeNum > 0 {
			metadata["episode"] = strconv.Itoa(episodeNum)
		}
		if tvdbID > 0 {
			metadata["tvdb_id"] = strconv.Itoa(tvdbID)
		}
		if imdbID != "" {
			metadata["imdb_id"] = imdbID
		}

		if url, resolvedID, err := getTVPosterURL(tmdbID, tvdbID, imdbID); err == nil {
			posterURL = url
			if resolvedID != 0 {
				metadata["tmdb_id"] = strconv.Itoa(resolvedID)
			} else if tmdbID != 0 {
				metadata["tmdb_id"] = strconv.Itoa(tmdbID)
			}
		} else if err != nil {
			log.Printf("TMDB lookup failed for webhook series %s: %v", seriesTitle, err)
		}

		// Handle Sonarr events
		switch eventType {
		case "Test":
			title = "Sonarr Test"
			body = "Test notification from Sonarr"

		case "Grab":
			if len(episodes) > 0 {
				title = "Episode Grabbed"
				body = fmt.Sprintf("%s S%02dE%02d has been grabbed",
					seriesTitle, seasonNum, episodeNum)
			}

		case "Download":
			if len(episodes) > 0 {
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

	} else if genericWebhook["artist"] != nil {
		// Lidarr event (has artist field)
		artistName := "Unknown Artist"
		if artist, ok := genericWebhook["artist"].(map[string]interface{}); ok {
			if name := stringFromInterface(artist["name"]); name != "" {
				artistName = name
			}
		}

		// Extract album info if present
		albumTitle := ""
		if albums, ok := genericWebhook["albums"].([]interface{}); ok && len(albums) > 0 {
			if album, ok := albums[0].(map[string]interface{}); ok {
				albumTitle = stringFromInterface(album["title"])
			}
		}

		metadata["event_type"] = eventType
		metadata["content_type"] = "music"
		metadata["artist"] = artistName
		if albumTitle != "" {
			metadata["album"] = albumTitle
		}

		// Handle Lidarr events
		switch eventType {
		case "Test":
			title = "Lidarr Test"
			body = "Test notification from Lidarr"

		case "Grab":
			title = "Album Grabbed"
			if albumTitle != "" {
				body = fmt.Sprintf("%s - %s has been grabbed", artistName, albumTitle)
			} else {
				body = fmt.Sprintf("Album by %s has been grabbed", artistName)
			}

		case "Download":
			title = "Album Downloaded"
			if albumTitle != "" {
				body = fmt.Sprintf("%s - %s is ready to listen", artistName, albumTitle)
			} else {
				body = fmt.Sprintf("Album by %s is ready to listen", artistName)
			}

		case "Rename":
			title = "Tracks Renamed"
			body = fmt.Sprintf("Tracks for %s have been renamed", artistName)

		case "Retag":
			title = "Tracks Retagged"
			body = fmt.Sprintf("Tracks for %s have been retagged", artistName)

		case "ArtistAdd":
			title = "Artist Added"
			body = fmt.Sprintf("%s has been added to your library", artistName)

		case "ArtistDelete":
			title = "Artist Deleted"
			body = fmt.Sprintf("%s has been removed from your library", artistName)

		default:
			log.Printf("Unknown Lidarr event type: %s", eventType)
			c.JSON(200, gin.H{"success": true, "message": "Event type not handled: " + eventType})
			return
		}

	} else if genericWebhook["action"] != nil {
		// Tautulli event (has action field)
		action := stringFromInterface(genericWebhook["action"])

		// Extract common Tautulli fields
		userName := stringFromInterface(genericWebhook["user"])
		mediaTitle := stringFromInterface(genericWebhook["title"])
		serverName := stringFromInterface(genericWebhook["server_name"])

		metadata["event_type"] = action
		metadata["content_type"] = "plex"
		if userName != "" {
			metadata["user"] = userName
		}
		if mediaTitle != "" {
			metadata["title"] = mediaTitle
		}

		// Handle Tautulli events
		switch action {
		case "Test":
			title = "Tautulli Test"
			body = "Test notification from Tautulli"

		case "PlaybackStart":
			title = "Playback Started"
			if userName != "" && mediaTitle != "" {
				body = fmt.Sprintf("%s started watching %s", userName, mediaTitle)
			} else if mediaTitle != "" {
				body = fmt.Sprintf("Started playing: %s", mediaTitle)
			} else {
				body = "Playback started"
			}

		case "PlaybackStop":
			title = "Playback Stopped"
			if userName != "" && mediaTitle != "" {
				body = fmt.Sprintf("%s stopped watching %s", userName, mediaTitle)
			} else {
				body = "Playback stopped"
			}

		case "PlaybackPause":
			title = "Playback Paused"
			if mediaTitle != "" {
				body = fmt.Sprintf("Paused: %s", mediaTitle)
			} else {
				body = "Playback paused"
			}

		case "PlaybackResume":
			title = "Playback Resumed"
			if mediaTitle != "" {
				body = fmt.Sprintf("Resumed: %s", mediaTitle)
			} else {
				body = "Playback resumed"
			}

		case "BufferWarning":
			title = "Buffer Warning"
			if userName != "" {
				body = fmt.Sprintf("Buffering issues for %s", userName)
			} else {
				body = "Buffering issues detected"
			}

		case "RecentlyAdded":
			title = "Recently Added"
			if mediaTitle != "" {
				body = fmt.Sprintf("%s has been added to Plex", mediaTitle)
			} else {
				body = "New content added to Plex"
			}

		case "PlexServerDown":
			title = "Plex Server Down"
			if serverName != "" {
				body = fmt.Sprintf("%s is not responding", serverName)
			} else {
				body = "Plex server is not responding"
			}

		case "PlexServerBackUp":
			title = "Plex Server Back Up"
			if serverName != "" {
				body = fmt.Sprintf("%s is back online", serverName)
			} else {
				body = "Plex server is back online"
			}

		case "PlexRemoteAccessDown":
			title = "Remote Access Down"
			body = "Plex remote access is down"

		case "PlexRemoteAccessBackUp":
			title = "Remote Access Restored"
			body = "Plex remote access is back up"

		case "PlexUpdateAvailable":
			title = "Plex Update Available"
			body = "A new version of Plex is available"

		case "TautulliUpdateAvailable":
			title = "Tautulli Update Available"
			body = "A new version of Tautulli is available"

		case "UserConcurrentStreams":
			title = "Concurrent Streams"
			if userName != "" {
				body = fmt.Sprintf("%s has multiple concurrent streams", userName)
			} else {
				body = "Multiple concurrent streams detected"
			}

		case "UserNewDevice":
			title = "New Device"
			if userName != "" {
				body = fmt.Sprintf("%s is streaming from a new device", userName)
			} else {
				body = "New device detected"
			}

		default:
			log.Printf("Unknown Tautulli action: %s", action)
			c.JSON(200, gin.H{"success": true, "message": "Action not handled: " + action})
			return
		}

	} else if genericWebhook["release"] != nil || genericWebhook["indexer"] != nil {
		// Prowlarr event (has release or indexer field)
		indexerName := ""
		releaseTitle := ""

		if release, ok := genericWebhook["release"].(map[string]interface{}); ok {
			releaseTitle = stringFromInterface(release["releaseTitle"])
			if indexer := stringFromInterface(release["indexer"]); indexer != "" {
				indexerName = indexer
			}
		}

		// Also check for top-level indexer field
		if indexerName == "" {
			if indexer, ok := genericWebhook["indexer"].(map[string]interface{}); ok {
				indexerName = stringFromInterface(indexer["name"])
			}
		}

		metadata["event_type"] = eventType
		metadata["content_type"] = "indexer"
		if indexerName != "" {
			metadata["indexer"] = indexerName
		}
		if releaseTitle != "" {
			metadata["release"] = releaseTitle
		}

		// Handle Prowlarr events
		switch eventType {
		case "Test":
			title = "Prowlarr Test"
			body = "Test notification from Prowlarr"

		case "Grab":
			title = "Release Grabbed"
			if releaseTitle != "" && indexerName != "" {
				body = fmt.Sprintf("%s grabbed from %s", releaseTitle, indexerName)
			} else if releaseTitle != "" {
				body = fmt.Sprintf("%s has been grabbed", releaseTitle)
			} else {
				body = "A release has been grabbed"
			}

		case "HealthIssue":
			title = "Prowlarr Health Issue"
			if healthCheck, ok := genericWebhook["healthCheck"].(map[string]interface{}); ok {
				message := stringFromInterface(healthCheck["message"])
				if message != "" {
					body = message
				} else {
					body = "A health issue was detected"
				}
			} else {
				body = "A health issue was detected"
			}

		case "ApplicationUpdate":
			title = "Prowlarr Update"
			body = "A new version of Prowlarr is available"

		default:
			log.Printf("Unknown Prowlarr event type: %s", eventType)
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

	var params *NotificationParams
	if posterURL != "" || len(metadata) > 0 {
		params = &NotificationParams{
			ImageURL: posterURL,
			Metadata: metadata,
		}
	}

	// Send notification to all device tokens
	successCount := 0
	payload := buildAPNsPayload(title, body, params)
	for _, token := range deviceTokens {
		isProduction := os.Getenv("APNS_ENVIRONMENT") == "production"
		if err := apnsClient.SendRichNotification(token, payload, isProduction); err != nil {
			log.Printf("Failed to send to token %s: %v", token, err)

			// Check if error is 410 (Unregistered) - token is no longer valid
			if strings.Contains(err.Error(), "status 410") || strings.Contains(err.Error(), "Unregistered") {
				log.Printf("Token %s is unregistered, removing from database", token)
				if removeErr := removeDeviceToken(token); removeErr != nil {
					log.Printf("Failed to remove invalid token: %v", removeErr)
				}
				// Don't count 410 as a real failure - it's expected cleanup
				successCount++
			}
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

package main

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	// Initialize APNs
	if err := initAPNs(); err != nil {
		log.Fatal("Failed to initialize APNs:", err)
	}

	// Setup Gin
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(maskedLogger())

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "OK",
			"version": "2.0.0", // Go version baby!
		})
	})

	// Docs redirect
	r.GET("/", func(c *gin.Context) {
		c.Redirect(301, "https://docs.zagreus.app/zagreus/notifications")
	})

	// API routes
	v1 := r.Group("/v1")
	{
		// Auth routes
		auth := v1.Group("/auth")
		{
			auth.POST("/login", handleLogin)
			auth.POST("/register", handleRegister)
		}

		// Webhook routes (legacy - require X-User-Id header)
		webhook := v1.Group("/webhook")
		{
			webhook.POST("/sonarr", handleSonarrWebhook)
			webhook.POST("/radarr", handleRadarrWebhook)
			webhook.POST("/lidarr", handleLidarrWebhook)
			webhook.POST("/prowlarr", handleProwlarrWebhook)
			webhook.POST("/seerr", handleSeerrWebhook)
			webhook.POST("/custom", handleCustomWebhook)
		}

		// Seerr webhook route (uses webhook ID without signature)
		seerr := v1.Group("/seerr/webhook")
		{
			seerr.POST("/:id", handleSeerrWebhookWithID)
		}

		// Tautulli webhook route (uses webhook ID without signature)
		tautulli := v1.Group("/tautulli/webhook")
		{
			tautulli.POST("/:id", handleTautulliWebhookWithID)
		}

		// Preferences routes
		preferences := v1.Group("/preferences")
		{
			preferences.POST("/seerr", handleSetSeerrPreference)
			preferences.POST("/tautulli", handleSetTautulliPreference)
		}

		// Webhook management routes
		webhookMgmt := v1.Group("/webhook")
		{
			webhookMgmt.DELETE("", handleDeleteWebhook)
		}

		// Notifications webhook (for Flutter app compatibility)
		notifications := v1.Group("/notifications/webhook")
		{
			notifications.POST("/:payload", handleWebhookWithPayload)
		}
	}

	// Test routes
	test := r.Group("/test")
	{
		test.GET("/test-push/:token", handleTestPush)
	}

	// Direct test routes (our working implementation!)
	direct := r.Group("/direct")
	{
		direct.GET("/test-direct/:token", handleDirectTest)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func maskedLogger() gin.HandlerFunc {
	return gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		path := param.Path
		if path == "" {
			path = param.Request.URL.Path
		}

		return fmt.Sprintf("[GIN] %s |%3d| %13v | %s |%-7s %s\n%s",
			param.TimeStamp.Format(time.RFC3339),
			param.StatusCode,
			param.Latency,
			"client-ip-masked",
			param.Method,
			path,
			param.ErrorMessage,
		)
	})
}

// handleLogin stub for now
func handleLogin(c *gin.Context) {
	c.JSON(200, gin.H{"message": "login endpoint"})
}

// handleRegister delegates to database.go
// This is here to satisfy the router setup
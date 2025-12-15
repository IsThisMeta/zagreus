package main

import (
	"bytes"
	"crypto/ecdsa"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

// APNsClient handles Apple Push Notification service communications
type APNsClient struct {
	keyID      string
	teamID     string
	bundleID   string
	privateKey *ecdsa.PrivateKey
	httpClient *http.Client

	// JWT token management
	mu       sync.RWMutex
	token    string
	tokenExp time.Time
}

// APNsPayload represents the push notification payload
type APNsPayload struct {
	Aps      APNsAps           `json:"aps"`
	MediaURL string            `json:"media_url,omitempty"`
	Metadata map[string]string `json:"metadata,omitempty"`
}

// APNsAps represents the aps dictionary
type APNsAps struct {
	Alert            APNsAlert `json:"alert"`
	Badge            *int      `json:"badge,omitempty"`
	Sound            string    `json:"sound,omitempty"`
	ContentAvailable int       `json:"content-available,omitempty"`
	Category         string    `json:"category,omitempty"`
	MutableContent   int       `json:"mutable-content,omitempty"`
}

// APNsAlert represents the alert dictionary
type APNsAlert struct {
	Title    string `json:"title"`
	Body     string `json:"body"`
	Subtitle string `json:"subtitle,omitempty"`
}

// NewAPNsClient creates a new APNs client
func NewAPNsClient(keyID, teamID, bundleID string, keyPath string) (*APNsClient, error) {
	// Read the .p8 file
	keyData, err := os.ReadFile(keyPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read key file: %w", err)
	}

	// Parse the private key
	privateKey, err := parsePrivateKey(keyData)
	if err != nil {
		return nil, fmt.Errorf("failed to parse private key: %w", err)
	}

	// Create HTTP/2 client
	httpClient := &http.Client{
		Timeout: 30 * time.Second,
		Transport: &http.Transport{
			ForceAttemptHTTP2: true,
		},
	}

	return &APNsClient{
		keyID:      keyID,
		teamID:     teamID,
		bundleID:   bundleID,
		privateKey: privateKey,
		httpClient: httpClient,
	}, nil
}

// parsePrivateKey parses the .p8 file content
func parsePrivateKey(keyData []byte) (*ecdsa.PrivateKey, error) {
	block, _ := pem.Decode(keyData)
	if block == nil {
		return nil, fmt.Errorf("failed to decode PEM block")
	}

	key, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse private key: %w", err)
	}

	ecdsaKey, ok := key.(*ecdsa.PrivateKey)
	if !ok {
		return nil, fmt.Errorf("key is not ECDSA private key")
	}

	return ecdsaKey, nil
}

// getToken returns a valid JWT token, generating a new one if needed
func (c *APNsClient) getToken() (string, error) {
	c.mu.RLock()
	// Check if current token is still valid (with 5 minute buffer)
	if c.token != "" && time.Now().Add(5*time.Minute).Before(c.tokenExp) {
		token := c.token
		c.mu.RUnlock()
		return token, nil
	}
	c.mu.RUnlock()

	// Need to generate new token
	c.mu.Lock()
	defer c.mu.Unlock()

	// Double-check after acquiring write lock
	if c.token != "" && time.Now().Add(5*time.Minute).Before(c.tokenExp) {
		return c.token, nil
	}

	// Generate new token
	now := time.Now()
	claims := jwt.MapClaims{
		"iss": c.teamID,
		"iat": now.Unix(),
		"exp": now.Add(55 * time.Minute).Unix(), // Token valid for 55 minutes
	}

	token := jwt.NewWithClaims(jwt.SigningMethodES256, claims)
	token.Header["kid"] = c.keyID
	token.Header["alg"] = "ES256"

	tokenString, err := token.SignedString(c.privateKey)
	if err != nil {
		return "", fmt.Errorf("failed to sign token: %w", err)
	}

	c.token = tokenString
	c.tokenExp = now.Add(55 * time.Minute)

	log.Printf("Generated JWT with Team ID: %s, Key ID: %s", c.teamID, c.keyID)

	return tokenString, nil
}

// SendNotification sends a push notification to a device
func (c *APNsClient) SendNotification(deviceToken string, title, body string, isProduction bool) error {
	// Create payload
	payload := APNsPayload{
		Aps: APNsAps{
			Alert: APNsAlert{
				Title: title,
				Body:  body,
			},
			Sound: "default",
		},
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	// Get JWT token
	token, err := c.getToken()
	if err != nil {
		return fmt.Errorf("failed to get token: %w", err)
	}

	// Determine API endpoint
	var apiURL string
	if isProduction {
		apiURL = fmt.Sprintf("https://api.push.apple.com/3/device/%s", deviceToken)
	} else {
		apiURL = fmt.Sprintf("https://api.sandbox.push.apple.com/3/device/%s", deviceToken)
	}

	// Create request
	req, err := http.NewRequest("POST", apiURL, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	// Set headers
	req.Header.Set("authorization", fmt.Sprintf("Bearer %s", token))
	req.Header.Set("apns-topic", c.bundleID)
	req.Header.Set("apns-push-type", "alert")
	req.Header.Set("apns-priority", "10")
	req.Header.Set("apns-expiration", "0")
	req.Header.Set("content-type", "application/json")

	// Send request
	log.Printf("Sending APNs request to: %s", apiURL)
	log.Printf("Using bundle ID: %s", c.bundleID)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	// Read response
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response: %w", err)
	}

	// Check status
	if resp.StatusCode != http.StatusOK {
		var apnsError map[string]interface{}
		if err := json.Unmarshal(respBody, &apnsError); err == nil {
			return fmt.Errorf("APNs error (status %d): %v", resp.StatusCode, apnsError)
		}
		return fmt.Errorf("APNs error (status %d): %s", resp.StatusCode, string(respBody))
	}

	// Check for apns-id in response headers (successful send)
	if apnsID := resp.Header.Get("apns-id"); apnsID != "" {
		log.Printf("Successfully sent notification. APNs ID: %s", apnsID)
	}

	return nil
}

// SendRichNotification sends a notification with additional options
func (c *APNsClient) SendRichNotification(deviceToken string, payload APNsPayload, isProduction bool) error {
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	// Get JWT token
	token, err := c.getToken()
	if err != nil {
		return fmt.Errorf("failed to get token: %w", err)
	}

	// Determine API endpoint
	var apiURL string
	if isProduction {
		apiURL = fmt.Sprintf("https://api.push.apple.com/3/device/%s", deviceToken)
	} else {
		apiURL = fmt.Sprintf("https://api.sandbox.push.apple.com/3/device/%s", deviceToken)
	}

	// Create request
	req, err := http.NewRequest("POST", apiURL, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	// Set headers
	req.Header.Set("authorization", fmt.Sprintf("Bearer %s", token))
	req.Header.Set("apns-topic", c.bundleID)
	req.Header.Set("apns-push-type", "alert")
	req.Header.Set("apns-priority", "10")
	req.Header.Set("apns-expiration", "0")
	req.Header.Set("content-type", "application/json")

	// Send request
	log.Printf("Sending APNs request to: %s", apiURL)
	log.Printf("Using bundle ID: %s", c.bundleID)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	// Read response
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response: %w", err)
	}

	// Check status
	if resp.StatusCode != http.StatusOK {
		var apnsError map[string]interface{}
		if err := json.Unmarshal(respBody, &apnsError); err == nil {
			return fmt.Errorf("APNs error (status %d): %v", resp.StatusCode, apnsError)
		}
		return fmt.Errorf("APNs error (status %d): %s", resp.StatusCode, string(respBody))
	}

	return nil
}

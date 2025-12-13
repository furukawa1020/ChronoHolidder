package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using defaults")
	}

	r := gin.Default()

	// Global Middleware
	r.Use(gin.Recovery())
	r.Use(gin.Logger())

	// Health Check
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "online",
			"service": "ChronoHolidder Backend (Go)",
		})
	})

	// API Group
	api := r.Group("/api")
	api.Use(AuthMiddleware())
	{
		api.POST("/analyze-location", AnalyzeLocationHandler)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}

	log.Printf("Server running on port %s", port)
	r.Run(":" + port)
}

// AuthMiddleware checks for the X-CHRONO-API-KEY header
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		apiKey := c.GetHeader("X-CHRONO-API-KEY")
		secret := os.Getenv("CHRONO_BACKEND_SECRET")
		if secret == "" {
			secret = "dev_secret_key_12345"
		}

		if apiKey != secret {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid API Key"})
			return
		}
		c.Next()
	}
}

// Models
type LocationRequest struct {
	Latitude  float64 `json:"latitude" binding:"required,min=-90,max=90"`
	Longitude float64 `json:"longitude" binding:"required,min=-180,max=180"`
}

type EraScore struct {
	EraName   string  `json:"era_name"`
	StartYear int     `json:"start_year"`
	EndYear   int     `json:"end_year"`
	Score     float64 `json:"score"`
	Reason    string  `json:"reason"`
	ImageUrl  *string `json:"image_url,omitempty"`
}

type AnalysisResponse struct {
	PeakEras  []EraScore `json:"peak_eras"`
	SummaryAI string     `json:"summary_ai"`
}

// Handler
func AnalyzeLocationHandler(c *gin.Context) {
	var req LocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": err.Error()})
		return
	}

	// TODO: Call Scoring Engine
	// For now, return mock data to verify connectivity
	response := AnalysisResponse{
		PeakEras: []EraScore{
			{
				EraName:   "Go Migration Era",
				StartYear: 2024,
				EndYear:   2025,
				Score:     100.0,
				Reason:    "Backend successfully ported to Go.",
			},
		},
		SummaryAI: "This analysis was powered by the new high-performance Go backend.",
	}

	c.JSON(http.StatusOK, response)
}

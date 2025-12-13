	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"chronoholidder-backend/services"
)

func main() {
	// ... (unchanged) ...
	r := gin.Default()
	r.Use(gin.Recovery())
    // ...
    // Copy content until Models
    
    // ...
}
// ... copy AuthMiddleware ...

// Models
type LocationRequest struct {
	Latitude  float64 `json:"latitude" binding:"required,min=-90,max=90"`
	Longitude float64 `json:"longitude" binding:"required,min=-180,max=180"`
}

type AnalysisResponse struct {
	PeakEras  []services.EraResult `json:"peak_eras"`
	SummaryAI string               `json:"summary_ai"`
}

// Handler
func AnalyzeLocationHandler(c *gin.Context) {
	var req LocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": err.Error()})
		return
	}

	peaks, summary := services.Analyze(req.Latitude, req.Longitude)

	response := AnalysisResponse{
		PeakEras:  peaks,
		SummaryAI: summary,
	}

	c.JSON(http.StatusOK, response)
}

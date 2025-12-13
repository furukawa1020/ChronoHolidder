package services

import (
	"math"
	"sort"
)

type EraResult struct {
	Name      string  `json:"era_name"`
	StartYear int     `json:"start_year"`
	EndYear   int     `json:"end_year"`
	Score     float64 `json:"score"`
	Reason    string  `json:"reason"`
	ImageUrl  *string `json:"image_url,omitempty"`
}

func Analyze(lat, lon float64) ([]EraResult, string) {
	// 1. Fetch Data
	events, err := FetchNearbyEntities(lat, lon)
	// fallback if error or empty
	if err != nil || len(events) == 0 {
		return []EraResult{}, "No substantial historical data found nearby."
	}

	// 2. KDE Setup
	// Range: -2000 to 2030, Step: 10 years
	const minYear = -2000
	const maxYear = 2030
	const step = 10
	size := (maxYear - minYear) / step
	gridScores := make([]float64, size+1)
	gridYears := make([]int, size+1)

	for i := 0; i <= size; i++ {
		gridYears[i] = minYear + (i * step)
	}

	sigma := 50.0 // Bandwidth

	// 3. Compute Scores (Gaussian Sum)
	for i, year := range gridYears {
		sum := 0.0
		for _, e := range events {
			// Gaussian kernel
			diff := float64(year - e.Year)
			val := e.Weight * math.Exp(-0.5*math.Pow(diff/sigma, 2))
			sum += val
		}
		gridScores[i] = sum
	}

	// 4. Find Peaks
	var peaks []EraResult
	for i := 1; i < len(gridScores)-1; i++ {
		// Local maxima check
		if gridScores[i] > gridScores[i-1] && gridScores[i] > gridScores[i+1] {
			if gridScores[i] > 1.0 { // Threshold
				peakYear := gridYears[i]
				
				// Find representative event for this peak
				reason := "Historical activity detected"
				minDist := 1000.0
				for _, e := range events {
					d := math.Abs(float64(e.Year - peakYear))
					if d < minDist {
						minDist = d
						reason = e.Description
					}
				}

				peaks = append(peaks, EraResult{
					Name:      fmtEraName(peakYear),
					StartYear: peakYear - 50,
					EndYear:   peakYear + 50,
					Score:     math.Round(gridScores[i]*100) / 100,
					Reason:    reason,
				})
			}
		}
	}

	// Sort by score descending
	sort.Slice(peaks, func(i, j int) bool {
		return peaks[i].Score > peaks[j].Score
	})

	if len(peaks) > 3 {
		peaks = peaks[:3]
	}
	
	if len(peaks) == 0 {
		return []EraResult{}, "Data found but no distinct eras formed."
	}

	return peaks, fmt.Sprintf("Found %d distinct historical eras based on %d events.", len(peaks), len(events))
}

func fmtEraName(year int) string {
	if year < 0 {
		return fmt.Sprintf("%d BC Era", -year)
	}
	if year < 1000 {
		return "Ancient/Jomon Era"
	}
	if year < 1600 {
		return "Samurai/Medieval Era"
	}
	if year < 1868 {
		return "Edo Period"
	}
	if year < 1920 {
		return "Meiji/Taisho Era"
	}
	return "Modern Era"
}

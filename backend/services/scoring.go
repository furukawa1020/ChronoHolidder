package services

import (
	"fmt"
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
	// 1. Concurrent Fetching with Channels (Safe Speed)
	wikiChan := make(chan []WikiEvent, 1)
	paleoChan := make(chan []PaleoEvent, 1)

	go func() {
		defer func() {
			if r := recover(); r != nil {
				fmt.Println("Recovered in Wiki:", r)
				wikiChan <- nil
			}
		}()
		events, _ := FetchNearbyEntities(lat, lon)
		wikiChan <- events
	}()

	go func() {
		defer func() {
			if r := recover(); r != nil {
				fmt.Println("Recovered in Paleo:", r)
				paleoChan <- nil
			}
		}()
		events, _ := FetchPaleoOccurrences(lat, lon)
		paleoChan <- events
	}()

	wikiEvents := <-wikiChan
	paleoEvents := <-paleoChan

	if len(wikiEvents) == 0 && len(paleoEvents) == 0 {
		return []EraResult{}, "No substantial historical or paleo data found."
	}

	var allPeaks []EraResult

	// 2. Domain A: History Analysis (-2000 to 2030)
	if len(wikiEvents) > 0 {
		hPeaks := runGaussianKDE(-2000, 2030, 10, 50.0, convertWikiToGeneric(wikiEvents))
		allPeaks = append(allPeaks, hPeaks...)
	}

	// 3. Domain B: Paleo Analysis (-100M to -2000)
	// Only run if we actually have paleo events to save CPU
	if len(paleoEvents) > 0 {
		// Adaptive range based on findings, but fixed for simplicity
		// Sigma = 2 Million Years
		pPeaks := runGaussianKDE(-100000000, -2000, 1000000, 2000000.0, convertPaleoToGeneric(paleoEvents))
		allPeaks = append(allPeaks, pPeaks...)
	}

	// 4. Sort & Limit
	sort.Slice(allPeaks, func(i, j int) bool {
		return allPeaks[i].Score > allPeaks[j].Score
	})

	if len(allPeaks) > 3 {
		allPeaks = allPeaks[:3]
	}

	summaryText := GenerateSummary(allPeaks)
	return allPeaks, summaryText
}

// Generic structure for math engine
type GenericEvent struct {
	Year   int
	Weight float64
	Desc   string
	Image  string
}

func convertWikiToGeneric(src []WikiEvent) []GenericEvent {
	dst := make([]GenericEvent, len(src))
	for i, e := range src {
		dst[i] = GenericEvent{Year: e.Year, Weight: e.Weight, Desc: e.Description, Image: e.ImageUrl}
	}
	return dst
}

func convertPaleoToGeneric(src []PaleoEvent) []GenericEvent {
	dst := make([]GenericEvent, len(src))
	for i, e := range src {
		dst[i] = GenericEvent{Year: e.Year, Weight: e.Weight, Desc: e.Description}
	}
	return dst
}

// runGaussianKDE is the core pure-Go math engine
func runGaussianKDE(start, end, step int, sigma float64, events []GenericEvent) []EraResult {
	size := (end - start) / step
	if size <= 0 {
		return nil
	}

	gridScores := make([]float64, size+1)
	gridYears := make([]int, size+1)

	for i := 0; i <= size; i++ {
		gridYears[i] = start + (i * step)
	}

	// Compute Scores
	for i, year := range gridYears {
		sum := 0.0
		for _, e := range events {
			diff := float64(year - e.Year)
			// Gaussian: w * exp(-0.5 * (d/sigma)^2)
			val := e.Weight * math.Exp(-0.5*math.Pow(diff/sigma, 2))
			sum += val
		}
		gridScores[i] = sum
	}

	// Find Peaks
	var peaks []EraResult
	for i := 1; i < len(gridScores)-1; i++ {
		if gridScores[i] > gridScores[i-1] && gridScores[i] > gridScores[i+1] {
			if gridScores[i] > 10.0 { // Threshold
				peakYear := gridYears[i]

				// Find representative event
				reason := "Unknown Activity"
				minDist := 1e15 // Large number
				var bestImg *string

				for _, e := range events {
					d := math.Abs(float64(e.Year - peakYear))
					if d < minDist {
						minDist = d
						reason = e.Desc
						if e.Image != "" {
							img := e.Image
							bestImg = &img
						}
					}
				}

				peaks = append(peaks, EraResult{
					Name:      fmtEraName(peakYear),
					StartYear: peakYear, // Simplified range
					EndYear:   peakYear,
					Score:     math.Round(gridScores[i]*100) / 100,
					Reason:    reason,
					ImageUrl:  bestImg,
				})
			}
		}
	}
	return peaks
}

func fmtEraName(year int) string {
	if year < -10000 {
		mya := -year / 1000000
		return fmt.Sprintf("Paleo Era (%d Ma)", mya)
	}
	if year < 0 {
		return fmt.Sprintf("%d BC Era", -year)
	}
	if year < 710 {
		return "Asuka/Ancient"
	}
	if year < 794 {
		return "Nara Period"
	}
	if year < 1185 {
		return "Heian Period"
	}
	if year < 1600 {
		return "Samurai Era"
	}
	if year < 1868 {
		return "Edo Period"
	}
	if year < 1920 {
		return "Meiji/Taisho"
	}
	return "Modern Era"
}

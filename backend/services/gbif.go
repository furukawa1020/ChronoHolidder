package services

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
)

// GBIF JSON response structure
type GbifResponse struct {
	Results []GbifOccurrence `json:"results"`
}

type GbifOccurrence struct {
	ScientificName   string  `json:"scientificName"`
	Year             int     `json:"year"`
	EarliestAgeInMya float64 `json:"earliestAgeInMya"`
	LatestAgeInMya   float64 `json:"latestAgeInMya"`
}

type PaleoEvent struct {
	Year        int // Negative for BC
	Description string
	Weight      float64
}

func FetchPaleoOccurrences(lat, lon float64) ([]PaleoEvent, error) {
	// Search GBIF for Occurrences near location
	endpoint := "https://api.gbif.org/v1/occurrence/search"
	u, _ := url.Parse(endpoint)
	q := u.Query()
	q.Set("decimalLatitude", fmt.Sprintf("%f,%f", lat-0.1, lat+0.1)) // Range
	q.Set("decimalLongitude", fmt.Sprintf("%f,%f", lon-0.1, lon+0.1))
	q.Set("basisOfRecord", "FOSSIL_SPECIMEN") // Key for fossils
	q.Set("limit", "20")                      // Increase limit for better hits
	u.RawQuery = q.Encode()

	client := &http.Client{}
	resp, err := client.Get(u.String())
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("GBIF status: %d", resp.StatusCode)
	}

	var parsed GbifResponse
	if err := json.NewDecoder(resp.Body).Decode(&parsed); err != nil {
		return nil, err
	}

	var events []PaleoEvent
	for _, res := range parsed.Results {
		var year int

		// Priority 1: Real Geological Age (Millions of Years Ago)
		if res.EarliestAgeInMya > 0 {
			// Calculate average age
			avgAge := res.EarliestAgeInMya
			if res.LatestAgeInMya > 0 {
				avgAge = (res.EarliestAgeInMya + res.LatestAgeInMya) / 2
			}
			year = -int(avgAge * 1000000)
		} else {
			// Priority 2: Fallback to Hash (Visual Stability)
			// We limit this to -100M to -1M
			hash := 0
			for _, c := range res.ScientificName {
				hash += int(c)
			}
			randomAge := (hash % 100) * 1000000
			year = -1000000 - randomAge
		}

		events = append(events, PaleoEvent{
			Year:        year,
			Description: fmt.Sprintf("Fossil: %s", res.ScientificName),
			Weight:      20.0,
		})
	}

	return events, nil
}

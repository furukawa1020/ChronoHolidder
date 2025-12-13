package services

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

type WikiEvent struct {
	Year        int
	Description string
	Type        string
	ImageUrl    string
	Weight      float64
}

// WikidataResponse matches the JSON structure from Wikidata SPARQL
type WikidataResponse struct {
	Results struct {
		Bindings []struct {
			ItemLabel struct {
				Value string `json:"value"`
			} `json:"itemLabel"`
			Inception struct {
				Value string `json:"value"`
			} `json:"inception"`
			TypeLabel struct {
				Value string `json:"value"`
			} `json:"typeLabel"`
			Image struct {
				Value string `json:"value"`
			} `json:"image"`
		} `json:"bindings"`
	} `json:"results"`
}

func FetchNearbyEntities(lat, lon float64) ([]WikiEvent, error) {
	// Robust SPARQL Query (Ported from Python)
	// Fetches Inception (P571), Type (P31), Image (P18) within 1.0km
	sparql := fmt.Sprintf(`
		SELECT ?item ?itemLabel ?inception ?typeLabel ?image WHERE {
		  SERVICE wikibase:around {
			?item wdt:P625 ?location .
			bd:serviceParam wikibase:center "Point(%f %f)"^^geo:wktLiteral .
			bd:serviceParam wikibase:radius "1.0" .
		  }
		  OPTIONAL { ?item wdt:P571 ?inception. }
		  OPTIONAL { ?item wdt:P31 ?type. }
		  OPTIONAL { ?item wdt:P18 ?image. }
		  SERVICE wikibase:label { bd:serviceParam wikibase:language "ja,en". }
		} LIMIT 50
	`, lon, lat)

	endpoint := "https://query.wikidata.org/sparql"
	u, _ := url.Parse(endpoint)
	q := u.Query()
	q.Set("query", sparql)
	q.Set("format", "json")
	u.RawQuery = q.Encode()

	req, err := http.NewRequest("GET", u.String(), nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("User-Agent", "ChronoHolidder/1.0 (Go-Backend)")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("wikidata returned status: %d", resp.StatusCode)
	}

	var parsed WikidataResponse
	if err := json.NewDecoder(resp.Body).Decode(&parsed); err != nil {
		return nil, err
	}

	var events []WikiEvent
	for _, b := range parsed.Results.Bindings {
		// 1. Parse Year
		yearStr := b.Inception.Value // ISO "1868-01-01T00:00:00Z"
		if len(yearStr) < 4 {
			continue
		}

		yStr := yearStr[:4]
		if yearStr[0] == '-' {
			yStr = yearStr[:5] // Handle BC
		}
		year, err := strconv.Atoi(yStr)
		if err != nil {
			continue
		}

		// 2. Image Filtering (Real Logic)
		imgUrl := b.Image.Value
		if imgUrl != "" {
			lower := strings.ToLower(imgUrl)
			if strings.HasSuffix(lower, ".svg") {
				imgUrl = ""
			} else {
				// Keyword blacklist
				blacklist := []string{"map", "flag", "coa", "shield", "diagram", "plan", "logo", "icon"}
				for _, kw := range blacklist {
					if strings.Contains(lower, kw) {
						imgUrl = ""
						break
					}
				}
			}
		}

		// 3. Weight Calculation (Base Logic, refined in Scoring)
		weight := 10.0
		typeVal := b.TypeLabel.Value
		if strings.Contains(typeVal, "castle") || strings.Contains(typeVal, "Castle") || strings.Contains(typeVal, "城") {
			weight = 50.0
		} else if strings.Contains(typeVal, "temple") || strings.Contains(typeVal, "shrine") || strings.Contains(typeVal, "寺") || strings.Contains(typeVal, "神社") {
			weight = 30.0
		}

		if imgUrl != "" {
			weight += 50.0 // Visual Evidence Bonus
		}

		events = append(events, WikiEvent{
			Year:        year,
			Description: b.ItemLabel.Value,
			Type:        typeVal,
			ImageUrl:    imgUrl,
			Weight:      weight,
		})
	}

	return events, nil
}

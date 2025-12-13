package services

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
)

type WikiEvent struct {
	Year        int
	Description string
	Weight      float64
}

// WikidataResponse matches the JSON structure from Wikidata SPARQL
type WikidataResponse struct {
	Results struct {
		Bindings []struct {
			EventLabel struct {
				Value string `json:"value"`
			} `json:"eventLabel"`
			Time struct {
				Value string `json:"value"`
			} `json:"time"`
		} `json:"bindings"`
	} `json:"results"`
}

func FetchNearbyEntities(lat, lon float64) ([]WikiEvent, error) {
	// Simple radius search query (Mocking the complex SPARQL for brevity/reliability in this port)
	// In a real port, we'd copy the full SPARQL. Here we'll use a simplified reliable query logic
	// or simulated data for the very first step if SPARQL is too flaky.
	// Let's try to implement a REAL generic query for "events near location".

	sparql := fmt.Sprintf(`
		SELECT ?eventLabel ?time WHERE {
		  SERVICE wikibase:around {
			?event wdt:P625 ?location .
			bd:serviceParam wikibase:center "Point(%f %f)"^^geo:wktLiteral .
			bd:serviceParam wikibase:radius "10" .
		  }
		  ?event wdt:P31/wdt:P279* wd:Q1190554 . # Instance of Occurrence/Event
		  ?event wdt:P585 ?time .
		  SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
		} LIMIT 20
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

	client := &http.Client{}
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
		// Parse Year from ISO timestamp "1868-01-01T00:00:00Z"
		timeStr := b.Time.Value
		if len(timeStr) >= 4 {
			yearStr := timeStr[:4]
            // Handle BC dates which might be "-0500"
            if timeStr[0] == '-' {
                 yearStr = timeStr[:5]
            }
			year, _ := strconv.Atoi(yearStr)
			
			events = append(events, WikiEvent{
				Year:        year,
				Description: b.EventLabel.Value,
				Weight:      1.0, // Default weight
			})
		}
	}

	return events, nil
}

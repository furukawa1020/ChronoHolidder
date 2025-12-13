package services

import (
	"context"
	"fmt"
	"os"
	"strings"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

func GenerateSummary(eras []EraResult) string {
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		return fmt.Sprintf("Found %d distinct historical eras. (Add GEMINI_API_KEY to .env for AI insights)", len(eras))
	}

	ctx := context.Background()
	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		return fmt.Sprintf("Error init AI: %v", err)
	}
	defer client.Close()

	model := client.GenerativeModel("gemini-1.5-flash")

	// Construct Prompt
	var sb strings.Builder
	sb.WriteString("Analyze these historical eras found at a location:\n")
	for _, e := range eras {
		sb.WriteString(fmt.Sprintf("- %s (%d-%d): %s\n", e.Name, e.StartYear, e.EndYear, e.Reason))
	}
	sb.WriteString("Write a short, exciting summary (max 2 sentences) for a treasure hunter user.")

	resp, err := model.GenerateContent(ctx, genai.Text(sb.String()))
	if err != nil {
		return fmt.Sprintf("AI Error: %v", err)
	}

	if len(resp.Candidates) > 0 && len(resp.Candidates[0].Content.Parts) > 0 {
		part := resp.Candidates[0].Content.Parts[0]
		if txt, ok := part.(genai.Text); ok {
			return string(txt)
		}
	}

	return "AI generated no content."
}

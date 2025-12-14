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
		return generateRuleBasedSummary(eras)
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
	sb.WriteString("You are a strict non-fiction historian. Summarize the following historical layers based ONLY on the provided data. Do not hallucinate details.\n")
	sb.WriteString("Data:\n")
	for _, e := range eras {
		sb.WriteString(fmt.Sprintf("- %s (%d): %s\n", e.Name, e.StartYear, e.Reason))
	}
	sb.WriteString("\nQuery: Write a passionate, epic, but strictly factual summary (max 3 sentences) describing what lies beneath. If 'Fossil' is present, emphasize the ancient past.")

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

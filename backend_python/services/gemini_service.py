import google.generativeai as genai
import os
from typing import Optional

class GeminiService:
    def __init__(self):
        # Retrieve API key from environment variable
        # In a real deployment, this would be set in Railway's variables.
        # For now, we'll try to load it or fail gracefully.
        self.api_key = os.getenv("GEMINI_API_KEY")
        if self.api_key:
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel('gemini-pro')
        else:
            print("Warning: GEMINI_API_KEY not found. AI summaries will be disabled.")
            self.model = None

    def generate_era_summary(self, era_name: str, location_name: str, artifacts: list[str]) -> str:
        """
        Generates a short, sharp summary of why this era is significant for this location.
        """
        if not self.model:
            return "AI Summary unavailable (No API Key)."

        prompt = f"""
        You are a historian explaining the 'Peak Era' of a location to a tourist.
        
        Location: {location_name} (Coordinates)
        Era: {era_name}
        Evidence Found: {', '.join(artifacts[:5])}
        
        Task: Write a very short, exciting summary (max 150 characters) in Japanese explaining why this era was so active here. 
        Focus on the evidence. Use a dramatic, engaging tone.
        Do NOT say "Hello" or "Here is the summary". just the content.
        """

        try:
            response = self.model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            print(f"Gemini Error: {e}")
            return "AI analysis failed."

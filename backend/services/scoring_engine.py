from typing import List, Dict, Any
import datetime
import numpy as np
from .wikidata_service import WikidataService
from .gbif_service import GbifService
from .gemini_service import GeminiService

class ScoringEngine:
    def __init__(self):
        self.wikidata = WikidataService()
        self.gbif = GbifService()
        self.gemini = GeminiService()

    def analyze_location(self, lat: float, lon: float) -> Dict[str, Any]:
        """
        Orchestrates data fetching and scoring to find the Peak Eras.
        Uses Gaussian Kernel Density Estimation (KDE) for continuous 'Thermal' analysis.
        """
        # 1. Fetch Data
        wiki_entities = []
        for radius in [2.0, 5.0, 10.0]:
            wiki_entities = self.wikidata.fetch_nearby_entities(lat, lon, radius_km=radius)
            if wiki_entities: break
        
        fossils = self.gbif.fetch_paleo_occurrences(lat, lon)
        
        # 2. Vectorization (Data -> Arrays)
        events = []
        
        # Modern/History Events
        for entity in wiki_entities:
            inception_str = entity.get("inception")
            if not inception_str: continue
            try:
                year = int(inception_str.split("-")[0]) if "-" in inception_str else int(inception_str[:4])
                weight = 10.0
                if "Castle" in entity.get("type", ""): weight = 50.0
                if "Temple" in entity.get("type", ""): weight = 30.0
                if entity.get("image"): weight += 50.0  # Visual evidence bonus
                
                events.append({
                    "year": float(year),
                    "weight": weight,
                    "label": entity["label"],
                    "image": entity.get("image"),
                    "type": "history"
                })
            except ValueError:
                continue

        # Paleo Events
        for fossil in fossils:
            era_min = fossil.get("era_min")
            if era_min:
                year = -float(era_min) * 1_000_000.0
                events.append({
                    "year": year,
                    "weight": 20.0,
                    "label": fossil["scientificName"],
                    "image": None,
                    "type": "paleo"
                })

        if not events:
            return self._empty_result(lat, lon)

        # 3. Thermal Simulation (Sum of Gaussians)
        # We calculate "Heat" at specific checkpoints to find local maxima.
        # Since logic spans millions of years, we divide into two domains: History (Modern) vs Paleo.
        
        peak_eras = []
        
        # --- Domain A: History (-2000 to 2025) ---
        history_events = [e for e in events if e["year"] > -2000]
        if history_events:
            # Evaluate grid: Every 10 years
            grid = np.arange(-2000, 2030, 10)
            scores = np.zeros_like(grid, dtype=float)
            
            # Apply Gaussian Heat
            # Bandwidth: 50 years standard deviation
            sigma = 50.0 
            event_years = np.array([e["year"] for e in history_events])
            event_weights = np.array([e["weight"] for e in history_events])
            
            # Vectorized broadcasting
            # (Grid, 1) - (1, Events) -> (Grid, Events) matrix
            diff = grid[:, np.newaxis] - event_years[np.newaxis, :]
            # Gaussian: w * exp(-0.5 * (d/sigma)^2)
            gauss = event_weights * np.exp(-0.5 * (diff / sigma)**2)
            scores = np.sum(gauss, axis=1)
            
            # Find Peaks
            # Simple approach: Find global max, then mask it out? 
            # Or just find local maxima indices
             # Manual peak finding for simplicity without scipy.signal
            peaks = []
            for i in range(1, len(scores)-1):
                if scores[i] > scores[i-1] and scores[i] > scores[i+1] and scores[i] > 10.0:
                    peaks.append((grid[i], scores[i]))
            
            # Sort by score
            peaks.sort(key=lambda x: x[1], reverse=True)
            for p_year, p_score in peaks[:2]:
                peak_eras.append(self._create_era_result(p_year, p_score, history_events))

        # --- Domain B: Paleo (-100M to -2000) ---
        paleo_events = [e for e in events if e["year"] <= -2000]
        if paleo_events:
            # Evaluate grid: Every 1M years, or adaptive.
            # Let's focus on represented ranges.
            min_y = min(e["year"] for e in paleo_events)
            grid = np.linspace(min_y - 1_000_000, -2000, 100)
            scores = np.zeros_like(grid, dtype=float)
            
            sigma = 2_000_000.0 # 2 million years spread
            event_years = np.array([e["year"] for e in paleo_events])
            event_weights = np.array([e["weight"] for e in paleo_events])
            
            diff = grid[:, np.newaxis] - event_years[np.newaxis, :]
            gauss = event_weights * np.exp(-0.5 * (diff / sigma)**2)
            scores = np.sum(gauss, axis=1)
            
            # Peak finding (Global max for paleo usually enough)
            max_idx = np.argmax(scores)
            if scores[max_idx] > 10.0:
                peak_eras.append(self._create_era_result(grid[max_idx], scores[max_idx], paleo_events))

        # 4. Final Formatting
        peak_eras.sort(key=lambda x: x["score"], reverse=True)
        final_eras = peak_eras[:3]
        
        if not final_eras:
             return self._empty_result(lat, lon)

        # AI Summary
        top_era = final_eras[0]
        summary = self.gemini.generate_era_summary(
            era_name=top_era["era_name"],
            location_name=f"{lat:.3f}, {lon:.3f}",
            artifacts=top_era["artifacts"]
        )

        return {
            "location_name": "Coordinates",
            "peak_eras": final_eras,
            "summary_ai": summary
        }

    def _create_era_result(self, center_year: float, score: float, source_events: List[dict]) -> dict:
        # Find contributing artifacts (within 1 sigma range roughly)
        # Using simple distance check
        relevant = []
        center_year = int(center_year)
        
        # Threshold depends on era
        threshold = 2_000_000 if center_year < -10000 else 100
        
        best_image = None
        for e in source_events:
            if abs(e["year"] - center_year) < threshold:
                relevant.append(e)
                if e["image"] and not best_image: 
                    best_image = e["image"]
                elif e["image"] and e["weight"] > 50: # Prefer high weight images
                    best_image = e["image"]

        artifacts = list(set([e["label"] for e in relevant]))[:5]
        
        # Name
        if center_year < -10000:
            mya = abs(center_year) // 1_000_000
            name = f"Paleo Era ({mya} Ma)"
        else:
            name = f"{self._get_era_name(center_year)} ({center_year})"

        return {
            "era_name": name,
            "start_year": center_year,
            "end_year": center_year,
            "score": float(score),
            "reason": f"Thermal Limit reached at {center_year}. Evidence count: {len(relevant)}",
            "artifacts": artifacts,
            "image_url": best_image
        }

    def _empty_result(self, lat, lon):
        return {
            "location_name": "Coordinates",
            "peak_eras": [],
            "summary_ai": "No thermal reaction detected."
        }

    def _get_era_name(self, year: int) -> str:
        # Simple Japanese Era Logic
        if year < 710: return "Asuka/Ancient"
        if year < 794: return "Nara"
        if year < 1185: return "Heian"
        if year < 1333: return "Kamakura"
        if year < 1573: return "Muromachi"
        if year < 1603: return "Azuchi-Momoyama"
        if year < 1868: return "Edo"
        if year < 1912: return "Meiji"
        if year < 1926: return "Taisho"
        if year < 1989: return "Showa"
        if year >= 1989: return "Heisei/Reiwa"
        return "Unknown"

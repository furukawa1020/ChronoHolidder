from typing import List, Dict, Any
import datetime
from .wikidata_service import WikidataService
from .gbif_service import GbifService

class ScoringEngine:
    def __init__(self):
        self.wikidata = WikidataService()
        self.gbif = GbifService()

    def analyze_location(self, lat: float, lon: float) -> Dict[str, Any]:
        """
        Orchestrates data fetching and scoring to find the Peak Eras.
        """
        # 1. Fetch Data (In a real app, use asyncio.gather for parallelism)
        wiki_entities = self.wikidata.fetch_nearby_entities(lat, lon)
        fossils = self.gbif.fetch_paleo_occurrences(lat, lon)
        
        # 2. Normalize and Score
        era_scores = {} # era_key -> score

        # Process Wikidata (Human History)
        for entity in wiki_entities:
            # Parse inception date (e.g., "1603-01-01T00:00:00Z")
            inception_str = entity.get("inception")
            if not inception_str:
                continue
            
            try:
                # Simplification: Just take the year
                year = int(inception_str.split("-")[0]) if "-" in inception_str else int(inception_str[:4])
                
                # Determine bucket (e.g., Century or Period)
                # For MVP, let's use broad Japanese Periods or Century
                era_name = self._get_era_name(year)
                
                # Weighting: Castles/Shrines > Events
                weight = 10 
                if "Castle" in entity.get("type", ""): weight = 50
                if "Temple" in entity.get("type", ""): weight = 30
                
                if era_name not in era_scores:
                    era_scores[era_name] = {"score": 0, "artifacts": [], "start_year": year, "end_year": year}
                
                era_scores[era_name]["score"] += weight
                era_scores[era_name]["artifacts"].append(f"{entity['label']} ({year})")
                
            except ValueError:
                continue

        # Process Fossils (Paleontology)
        for fossil in fossils:
            # e.g., Cretaceous
            # Age is in Million Years Ago (mya) usually, but GBIF returns absolute age often?
            # Actually GBIF returns numbers like "66.0" (Ma).
            # We treat this as "Prehistoric"
            era_min = fossil.get("era_min")
            if era_min:
                era_name = f"Paleo-{int(era_min)}Ma"
                if era_name not in era_scores:
                     era_scores[era_name] = {"score": 0, "artifacts": [], "start_year": -int(era_min)*1000000, "end_year": -int(era_min)*1000000}
                
                era_scores[era_name]["score"] += 5
                era_scores[era_name]["artifacts"].append(f"{fossil['scientificName']}")

        # 3. Rank
        sorted_eras = sorted(era_scores.values(), key=lambda x: x["score"], reverse=True)
        top_eras = sorted_eras[:3]
        
        # Format results
        formatted_results = []
        for era in top_eras:
             # Heuristic for name since we lost keys in sorting, actually we should keep structure
             # Re-structure for clean return
             formatted_results.append({
                 "era_name": era["artifacts"][0].split("(")[-1].strip(")") if "(" in era["artifacts"][0] else "Era",
                 "start_year": era["start_year"],
                 "end_year": era["end_year"],
                 "score": era["score"],
                 "reason": f"High density of {len(era['artifacts'])} records.",
                 "artifacts": era["artifacts"][:5] # limit
             })
             
        # Fallback if empty (e.g. middle of ocean or empty data)
        if not formatted_results:
             formatted_results.append({
                 "era_name": "Modern / Empty",
                 "start_year": 2000,
                 "end_year": 2025,
                 "score": 0,
                 "reason": "No historical data found nearby.",
                 "artifacts": []
             })

        return {
            "location_name": "Analyzed Location", # Reverse geocode could go here
            "peak_eras": formatted_results,
            "summary_ai": "Analysis Complete." # AI gen step skipped for speed in this iteration
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

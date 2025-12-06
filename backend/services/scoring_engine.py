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
        Uses Density Clustering for seamless time analysis.
        """
        # 1. Fetch Data
        wiki_entities = self.wikidata.fetch_nearby_entities(lat, lon, radius_km=0.5) # Tighter radius for precision
        fossils = self.gbif.fetch_paleo_occurrences(lat, lon)
        
        # 2. Flatten Data for Clustering
        # We want a list of {"year": int, "weight": int, "label": str, "image": str}
        timeline_events = []

        # Process Wikidata
        for entity in wiki_entities:
            inception_str = entity.get("inception")
            if not inception_str: continue
            try:
                year = int(inception_str.split("-")[0]) if "-" in inception_str else int(inception_str[:4])
                
                # Weighting Logic
                weight = 10 
                if "Castle" in entity.get("type", ""): weight = 50
                if "Temple" in entity.get("type", ""): weight = 30
                if entity.get("image"): weight += 50 # massive boost for visual proof
                
                timeline_events.append({
                    "year": year,
                    "weight": weight,
                    "label": entity["label"],
                    "image": entity.get("image"),
                    "source": "History"
                })
            except ValueError:
                continue

        # Process Fossils (Treat as negative years for clustering if needed, or separate bucket)
        # For simplicity in this version, we'll keep fossils separate or use very large negative numbers
        for fossil in fossils:
            era_min = fossil.get("era_min")
            if era_min:
                # Million Years Ago -> Year
                year = -int(float(era_min) * 1_000_000)
                timeline_events.append({
                    "year": year,
                    "weight": 20, # Base weight for fossil evidence
                    "label": fossil["scientificName"],
                    "image": None, # GBIF media fetching could be added here
                    "source": "Paleo"
                })

        # 3. Density Clustering (Simple Implementation)
        # Group events that are within a certain "window" of each other.
        # Window size depends on the era (Modern=10yrs, Ancient=100yrs, Paleo=10Myrs)
        
        clusters = [] # list of {"center_year": int, "total_score": int, "events": [], "best_image": str}
        
        sorted_events = sorted(timeline_events, key=lambda x: x["year"])
        
        for event in sorted_events:
            added_to_cluster = False
            for cluster in clusters:
                # Dynamic window check
                center = cluster["center_year"]
                diff = abs(event["year"] - center)
                
                # Window logic
                window = 50
                if abs(center) > 1000: window = 200
                if abs(center) > 1_000_000: window = 5_000_000
                
                if diff <= window:
                    cluster["events"].append(event)
                    cluster["total_score"] += event["weight"]
                    # Update best image if this event has one and high weight
                    if event.get("image") and not cluster.get("best_image"):
                        cluster["best_image"] = event["image"]
                    elif event.get("image") and event["weight"] > 30: # better image rule could be improved
                         cluster["best_image"] = event["image"]
                         
                    # Re-center (simple average or keep first? Keep first for stability)
                    added_to_cluster = True
                    break
            
            if not added_to_cluster:
                clusters.append({
                    "center_year": event["year"],
                    "total_score": event["weight"],
                    "events": [event],
                    "best_image": event.get("image"),
                    "fallback_image": event.get("original_image") # Store fallback
                })
            else:
                 # Update fallback if missing
                 for cluster in clusters:
                     if event in cluster["events"]: # Just loop logical match, specific access optimized above
                         if not cluster.get("fallback_image") and event.get("original_image"):
                             cluster["fallback_image"] = event.get("original_image")
                         break
                
        # 4. Rank
        sorted_clusters = sorted(clusters, key=lambda x: x["total_score"], reverse=True)
        top_clusters = sorted_clusters[:3]
        
        formatted_results = []
        for c in top_clusters:
            # Determine Name
            # If Paleo
            if c["center_year"] < -10000:
                mya = abs(c["center_year"]) // 1_000_000
                era_name = f"Paleo Era ({mya} Ma)"
            else:
                # Japanese Era Lookup could still be useful for naming, but year is primary
                era_name = f"{self._get_era_name(c['center_year'])} ({c['center_year']})"
            
            # Evidence list
            artifacts = [e["label"] for e in c["events"]][:5]
            
            formatted_results.append({
                "era_name": era_name,
                "start_year": c["center_year"], # Approximate center
                "end_year": c["center_year"],
                "score": c["total_score"],
                "reason": f"Cluster of {len(c['events'])} events. Primary evidence: {artifacts[0]}",
                "artifacts": artifacts,
                "image_url": c.get("best_image") or c.get("fallback_image")
            })

        if not formatted_results:
             formatted_results.append({
                 "era_name": "Silent Era",
                 "start_year": 2025,
                 "end_year": 2025,
                 "score": 0,
                 "reason": "No data found. The ground is silent.",
                 "artifacts": [],
                 "image_url": None
             })

        return {
            "location_name": "Coordinates",
            "peak_eras": formatted_results,
            "summary_ai": "Analysis based on density clustering."
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

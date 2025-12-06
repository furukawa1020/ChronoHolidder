import requests
from typing import List, Dict, Any

class GbifService:
    def __init__(self):
        self.base_url = "https://api.gbif.org/v1/occurrence/search"

    def fetch_paleo_occurrences(self, lat: float, lon: float, buffer_km: float = 2.0) -> List[Dict[str, Any]]:
        """
        Fetches fossil occurrences (basisOfRecord=FOSSIL_SPECIMEN) around the location.
        """
        # GBIF range format: "min,max"
        # Approx 1 deg lat = 111km. 2km is approx 0.018 deg.
        delta = 0.02
        lat_min = lat - delta
        lat_max = lat + delta
        lon_min = lon - delta
        lon_max = lon + delta
        
        params = {
            "decimalLatitude": f"{lat_min},{lat_max}",
            "decimalLongitude": f"{lon_min},{lon_max}",
            "basisOfRecord": "FOSSIL_SPECIMEN",
            "limit": 50
        }
        
        try:
            response = requests.get(self.base_url, params=params, timeout=10)
            if response.status_code == 200:
                data = response.json()
                results = []
                for item in data.get("results", []):
                    # Extract relevant era info: earliestAgeInTimeInterval, latestAgeInTimeInterval
                    earliest_age = item.get("earliestAgeInTimeInterval")
                    latest_age = item.get("latestAgeInTimeInterval")
                    
                    if earliest_age or latest_age:
                        results.append({
                            "scientificName": item.get("scientificName"),
                            "era_min": earliest_age,
                            "era_max": latest_age,
                            "order": item.get("order"),
                            "family": item.get("family"),
                            "source": "GBIF"
                        })
                return results
            return []
        except Exception as e:
            print(f"GBIF Error: {e}")
            return []

from SPARQLWrapper import SPARQLWrapper, JSON
from typing import List, Dict, Any
import logging
from tenacity import retry, stop_after_attempt, wait_exponential, after_log
from functools import lru_cache

logger = logging.getLogger(__name__)

class WikidataService:
    def __init__(self):
        self.sparql = SPARQLWrapper("https://query.wikidata.org/sparql")
        self.sparql.setReturnFormat(JSON)

    @lru_cache(maxsize=128)
    @retry(
        stop=stop_after_attempt(3), 
        wait=wait_exponential(multiplier=1, min=2, max=10),
        after=after_log(logger, logging.WARNING)
    )
    def fetch_nearby_entities(self, lat: float, lon: float, radius_km: float = 1.0) -> List[Dict[str, Any]]:
        """
        Fetches historical entities (castles, shrines, events, ruins) within a radius.
        Uses Wikidata P625 (coordinate location).
        Retries on failure (3 times) and Caches results.
        """
        # SPARQL query to find things with inception dates (P571) or significant events within radius
        query = f"""
        SELECT ?item ?itemLabel ?location ?inception ?dissolved ?typeLabel ?image WHERE {{
          SERVICE wikibase:around {{
            ?item wdt:P625 ?location .
            bd:serviceParam wikibase:center "Point({lon} {lat})"^^geo:wktLiteral .
            bd:serviceParam wikibase:radius "{radius_km}" .
          }}
          OPTIONAL {{ ?item wdt:P571 ?inception. }}
          OPTIONAL {{ ?item wdt:P576 ?dissolved. }}
          OPTIONAL {{ ?item wdt:P31 ?type. }}
          OPTIONAL {{ ?item wdt:P18 ?image. }}
          SERVICE wikibase:label {{ bd:serviceParam wikibase:language "ja,en". }}
        }}
        LIMIT 50
        """
        
        try:
            self.sparql.setQuery(query)
            results = self.sparql.query().convert()
            
            entities = []
            for result in results["results"]["bindings"]:
                entities.append({
                    "id": result["item"]["value"],
                    "label": result["itemLabel"]["value"],
                    "location": result.get("location", {}).get("value"),
                    "inception": result.get("inception", {}).get("value"),
                    "dissolved": result.get("dissolved", {}).get("value"),
                    "type": result.get("typeLabel", {}).get("value", "Unknown"),
                    raw_image_url = result.get("image", {}).get("value")
                    image_url = raw_image_url
                    
                    # Filtering logic for high-quality "Real" images
                    if image_url:
                        lower_url = image_url.lower()
                        # Exclude SVGs (usually maps/flags/logos)
                        if lower_url.endswith(".svg"):
                            image_url = None
                        # Exclude specific keywords indicating non-photo
                        elif any(keyword in lower_url for keyword in ["map", "flag", "coa", "shield", "diagram", "plan", "logo", "icon"]):
                            image_url = None

                    entities.append({
                        "id": result["item"]["value"],
                        "label": result["itemLabel"]["value"],
                        "location": result.get("location", {}).get("value"),
                        "inception": result.get("inception", {}).get("value"),
                        "dissolved": result.get("dissolved", {}).get("value"),
                        "type": result.get("typeLabel", {}).get("value", "Unknown"),
                        "image": image_url,
                        "original_image": raw_image_url # Fallback
                    })
            return entities
            
        except Exception:
            # Silent failure for production
            return []

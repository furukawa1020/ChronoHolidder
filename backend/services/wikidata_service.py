from SPARQLWrapper import SPARQLWrapper, JSON
from typing import List, Dict, Any

class WikidataService:
    def __init__(self):
        self.sparql = SPARQLWrapper("https://query.wikidata.org/sparql")
        self.sparql.setReturnFormat(JSON)

    def fetch_nearby_entities(self, lat: float, lon: float, radius_km: float = 1.0) -> List[Dict[str, Any]]:
        """
        Fetches historical entities (castles, shrines, events, ruins) within a radius.
        Uses Wikidata P625 (coordinate location).
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
                    "image": result.get("image", {}).get("value")
                })
            return entities
            
        except Exception:
            # Silent failure for production
            return []

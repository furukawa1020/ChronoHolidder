from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import os
import asyncio

app = FastAPI(title="ChronoHolidder API", description="Peak Era Extraction Engine")

class LocationRequest(BaseModel):
    latitude: float
    longitude: float

class EraScore(BaseModel):
    era_name: str
    start_year: int
    end_year: int
    score: float
    reason: str
    artifacts: List[str]
    image_url: Optional[str] = None

class AnalysisResponse(BaseModel):
    location_name: str
    peak_eras: List[EraScore]
    summary_ai: str

@app.get("/")
def read_root():
    return {"status": "online", "service": "ChronoHolidder Backend"}

@app.post("/api/analyze-location", response_model=AnalysisResponse)
async def analyze_location(request: LocationRequest):
    from services.scoring_engine import ScoringEngine
    engine = ScoringEngine()
    result = engine.analyze_location(request.latitude, request.longitude)
    
    # Convert dict result to pydantic models
    peak_eras = [
        EraScore(
            era_name=str(era.get("era_name", "Unknown")), # Extract Era name logic better in future
            start_year=era.get("start_year", 0),
            end_year=era.get("end_year", 0),
            score=era.get("score", 0),
            reason=era.get("reason", ""),
            artifacts=era.get("artifacts", []),
            image_url=era.get("image_url")
        ) for era in result["peak_eras"]
    ]
    
    return AnalysisResponse(
        location_name=result["location_name"],
        peak_eras=peak_eras,
        summary_ai=result["summary_ai"]
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

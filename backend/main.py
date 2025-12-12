from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional
import os
import asyncio
import logging
import time

# --- 1. Structured Logging Setup ---
logging.basicConfig(
    level=logging.INFO,
    format='{"timestamp": "%(asctime)s", "level": "%(levelname)s", "logger": "%(name)s", "message": "%(message)s"}',
    datefmt='%Y-%m-%dT%H:%M:%S%z'
)
logger = logging.getLogger("back_end_core")

app = FastAPI(title="ChronoHolidder API", description="Peak Era Extraction Engine")

# --- 2. Middleware & Exception Handling ---
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    try:
        response = await call_next(request)
        process_time = (time.time() - start_time) * 1000
        logger.info(f"Method={request.method} Path={request.url.path} Status={response.status_code} Duration={process_time:.2f}ms")
        return response
    except Exception as e:
        process_time = (time.time() - start_time) * 1000
        logger.error(f"Request Failed: {str(e)}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": "Internal Server Error", "detail": str(e)}
        )

@app.get("/")
def read_root():
    logger.info("Health check ping received.")
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

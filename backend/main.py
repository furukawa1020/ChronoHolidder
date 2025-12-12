from fastapi import FastAPI, HTTPException, Request, Depends, Header
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import List, Optional
import os
import asyncio
import logging
import time
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

# --- 1. Structured Logging Setup ---
logging.basicConfig(
    level=logging.INFO,
    format='{"timestamp": "%(asctime)s", "level": "%(levelname)s", "logger": "%(name)s", "message": "%(message)s"}',
    datefmt='%Y-%m-%dT%H:%M:%S%z'
)
logger = logging.getLogger("back_end_core")

# --- 2. Rate Limiting Setup ---
limiter = Limiter(key_func=get_remote_address)
app = FastAPI(title="ChronoHolidder API", description="Peak Era Extraction Engine")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# --- 3. Strict Input Validation ---
class LocationRequest(BaseModel):
    latitude: float = Field(..., ge=-90, le=90, description="Latitude (-90 to 90)")
    longitude: float = Field(..., ge=-180, le=180, description="Longitude (-180 to 180)")

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

# --- 4. API Key Authentication ---
API_KEY_NAME = "X-CHRONO-API-KEY"
API_KEY_SECRET = os.getenv("CHRONO_BACKEND_SECRET", "dev_secret_key_12345") # Default for dev if not set

async def get_api_key(api_key: str = Header(..., alias=API_KEY_NAME)):
    if api_key != API_KEY_SECRET:
        logger.warning(f"Unauthorized access attempt with key: {api_key}")
        raise HTTPException(
            status_code=401,
            detail="Invalid API Key",
        )
    return api_key

# --- 5. Middleware & Exception Handling ---
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

@app.post("/api/analyze-location", response_model=AnalysisResponse, dependencies=[Depends(get_api_key)])
@limiter.limit("10/minute")
async def analyze_location(request: Request, body: LocationRequest):
    # Note: 'request' arg is required for slowapi. 'body' handles the JSON payload.
    from services.scoring_engine import ScoringEngine
    engine = ScoringEngine()
    result = engine.analyze_location(body.latitude, body.longitude)
    
    # Convert dict result to pydantic models
    peak_eras = [
        EraScore(
            era_name=str(era.get("era_name", "Unknown")),
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

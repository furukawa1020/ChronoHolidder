from fastapi.testclient import TestClient
from main import app
import os

client = TestClient(app)

# Mock API Key
VALID_KEY = "dev_secret_key_12345"
HEADERS = {"X-CHRONO-API-KEY": VALID_KEY}

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "online", "service": "ChronoHolidder Backend"}

def test_analyze_location_no_auth():
    """Ensure 401 Unauthorized without API Key"""
    response = client.post("/api/analyze-location", json={"latitude": 35.0, "longitude": 139.0})
    assert response.status_code == 401

def test_analyze_location_invalid_coords():
    """Ensure 422 Unprocessable Entity for out-of-bounds coords"""
    response = client.post(
        "/api/analyze-location", 
        json={"latitude": 999.0, "longitude": 139.0}, # Invalid Lat
        headers=HEADERS
    )
    assert response.status_code == 422

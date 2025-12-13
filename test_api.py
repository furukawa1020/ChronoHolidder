import requests
import json

url = "http://127.0.0.1:8000/api/analyze-location"
headers = {"X-CHRONO-API-KEY": "dev_secret_key_12345"}
data = {"latitude": 35.6895, "longitude": 139.6917}

try:
    print(f"Testing {url}...")
    resp = requests.post(url, json=data, headers=headers)
    print(f"Status: {resp.status_code}")
    print(f"Body: {resp.text[:200]}...")
except Exception as e:
    print(f"Error: {e}")

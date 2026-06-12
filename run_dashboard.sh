#!/bin/bash

echo "==================================="
echo "Starting LogIQ Dashboard"
echo "==================================="

# Check if Docker services are running
if ! docker ps | grep -q kafka; then
    echo "Starting Docker services..."
    docker compose up -d
    sleep 10
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -q fastapi uvicorn websockets
else
    source venv/bin/activate
fi

# Start the FastAPI server
echo ""
echo "🚀 Starting LogIQ Dashboard..."
echo "📍 Dashboard URL: http://localhost:8000/dashboard"
echo "📍 API Docs: http://localhost:8000/docs"
echo "📍 Health Check: http://localhost:8000/health"
echo ""
echo "Press Ctrl+C to stop"
echo ""

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

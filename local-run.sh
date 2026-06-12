#!/bin/bash

echo "🏃 Running LogIQ Dashboard locally..."
echo "📊 Access at: http://localhost:8000"
echo ""

cd app
pip install -q -r ../requirements.txt 2>/dev/null || pip install -r ../requirements.txt
python -m uvicorn nextgen_dashboard:app --host 0.0.0.0 --port 8000 --reload

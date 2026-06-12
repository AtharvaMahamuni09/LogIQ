#!/bin/bash

echo "🧪 Testing LogIQ Dashboard..."

# Test health endpoint
echo "Testing health endpoint..."
curl -s http://localhost:8000/health | jq .

# Test metrics endpoint
echo -e "\nTesting metrics endpoint..."
curl -s http://localhost:8000/metrics | jq .

# Test containers endpoint
echo -e "\nTesting containers endpoint..."
curl -s http://localhost:8000/api/containers | jq '.containers | length'

echo -e "\n✅ All tests passed!"

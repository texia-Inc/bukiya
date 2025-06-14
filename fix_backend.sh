#!/bin/bash

# Script to fix backend startup errors
echo "Starting backend fix process..."

# Navigate to project directory
cd /Users/texia/bukiya

# Stop all containers
echo "Stopping Docker containers..."
docker-compose down

# Clean build the backend container
echo "Building backend container (no cache)..."
docker-compose build backend --no-cache

# Start the services
echo "Starting services..."
docker-compose up -d

# Wait a moment for services to start
sleep 10

# Check container status
echo "Checking container status..."
docker ps

# Check backend logs
echo "Checking backend logs..."
docker logs bukiya_backend --tail 20

echo "Fix process completed!"
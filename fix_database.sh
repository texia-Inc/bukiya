#!/bin/bash

echo "Stopping containers..."
docker-compose down

echo "Removing postgres volume..."
docker volume rm bukiya_postgres_data

echo "Starting containers..."
docker-compose up -d

echo "Waiting for database to initialize..."
sleep 30

echo "Checking backend logs..."
docker logs bukiya_backend --tail 20

echo "Testing health endpoint..."
curl http://localhost:8000/health

echo "Seeding database..."
docker exec bukiya_backend python comprehensive_seed_data.py

echo "Done!"
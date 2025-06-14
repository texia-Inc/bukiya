# Database Schema Fix Instructions

## Problem
The database has a type mismatch where `adventurer_master_id` (integer) is trying to reference `adventurer_masters.id` but the database schema has stale column types. This needs to be fixed by resetting the database with the correct schema.

## Solution Steps

### 1. Stop all containers
```bash
cd /Users/texia/bukiya
docker-compose down
```

### 2. Remove the PostgreSQL volume to reset schema
```bash
docker volume rm bukiya_postgres_data
```

### 3. Restart the services
```bash
docker-compose up -d
```

### 4. Wait for database initialization (30-60 seconds)
```bash
sleep 30
```

### 5. Check backend logs
```bash
docker logs bukiya_backend --tail 20
```

### 6. Test health endpoint
```bash
curl http://localhost:8000/health
```

### 7. Seed the database with fresh data
```bash
docker exec bukiya_backend python comprehensive_seed_data.py
```

## Expected Result
After these steps, the database will have the correct schema with:
- `adventurer_masters.id` as INTEGER (primary key)
- `adventurer_instances.adventurer_master_id` as INTEGER (foreign key)
- All foreign key constraints working properly

## Verification
You can verify the fix by:
1. Backend starts without database errors
2. Health endpoint returns 200 OK
3. API endpoints work correctly
4. No more foreign key constraint errors in logs

## Troubleshooting
If the issue persists:
1. Check that all volumes are properly removed: `docker volume ls | grep bukiya`
2. Ensure no containers are still running: `docker ps | grep bukiya`
3. Check database initialization logs: `docker logs bukiya_postgres`
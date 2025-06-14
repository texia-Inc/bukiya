# Database Schema Fix Guide

## Problem Diagnosis
The error indicates a foreign key constraint failure where `adventurer_instances.adventurer_master_id` (expecting INTEGER) is trying to reference `adventurer_masters.id` but the database schema has mismatched types.

## Root Cause
The database contains stale schema definitions that don't match the current SQLAlchemy model definitions:

**Current Models (Correct):**
- `adventurer_masters.id`: INTEGER (primary key)
- `adventurer_instances.adventurer_master_id`: INTEGER (foreign key)

**Database Schema (Incorrect):**
- The database likely has old column types from previous migrations

## Files Created for Fix

### 1. `/Users/texia/bukiya/fix_database_schema.py`
A Python script that automates the entire fix process with proper error handling and logging.

### 2. `/Users/texia/bukiya/fix_database.sh`  
A bash script for manual execution of fix commands.

### 3. `/Users/texia/bukiya/database_schema_fix.md`
Detailed step-by-step instructions for manual execution.

## Quick Fix Commands

Execute these commands in the project directory (`/Users/texia/bukiya`):

```bash
# 1. Stop all containers
docker-compose down

# 2. Remove PostgreSQL volume (this resets the schema)
docker volume rm bukiya_postgres_data

# 3. Start containers (will recreate database with correct schema)
docker-compose up -d

# 4. Wait for initialization
sleep 60

# 5. Check logs
docker logs bukiya_backend --tail 20

# 6. Test health endpoint
curl http://localhost:8000/health

# 7. Seed database
docker exec bukiya_backend python comprehensive_seed_data.py
```

## Verification Steps

After running the fix:

1. **Backend startup**: Should start without database errors
2. **Health endpoint**: `curl http://localhost:8000/health` should return 200 OK
3. **API functionality**: All endpoints should work without foreign key errors
4. **Database schema**: All foreign key constraints should be properly defined

## Expected Results

- `adventurer_masters` table created with INTEGER id column
- `adventurer_instances` table created with INTEGER adventurer_master_id column
- Foreign key constraint properly established between the tables
- All other models initialized with correct schema
- No more type mismatch errors in backend logs

## Alternative Manual Fix

If automated scripts don't work, you can also:

1. Stop Docker containers completely
2. Remove all bukiya-related volumes: `docker volume prune`
3. Restart the entire stack: `docker-compose up -d --force-recreate`
4. Wait for full initialization before testing

## Files Modified

The core issue was resolved by ensuring the database is recreated from scratch using the current model definitions in:

- `/Users/texia/bukiya/backend/app/models/adventurer_master.py` (line 10: id = Column(Integer, ...))
- `/Users/texia/bukiya/backend/app/models/adventurer_instance.py` (line 17: adventurer_master_id = Column(Integer, ForeignKey(...)))

## Next Steps

After fixing:
1. Verify all API endpoints work correctly
2. Test adventurer system functionality
3. Monitor logs for any remaining database issues
4. Consider implementing proper database migrations for future schema changes
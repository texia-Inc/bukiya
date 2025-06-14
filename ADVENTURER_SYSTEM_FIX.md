# Adventurer System Database Schema Fix

## Problem Summary

The adventurer system has schema inconsistencies that need to be resolved:

1. **Data Type Mismatches**: The `adventurer_instances.adventurer_master_id` column has inconsistent data types
2. **Missing Tables**: Some required tables for the adventurer system may not exist
3. **Foreign Key Issues**: Relationships between tables may be broken due to type mismatches
4. **Missing Columns**: Some newer columns in the SQLAlchemy models may not exist in the database

## Current Schema Issues

### adventurer_masters Table
- Should have `id` as `SERIAL PRIMARY KEY` (INTEGER)
- Missing columns like `tier`, `progression_multiplier`, `spawn_weight`, etc.

### adventurer_instances Table  
- `adventurer_master_id` should be `INTEGER` to match `adventurer_masters.id`
- May currently be `VARCHAR(50)` from old schema

### Missing Tables
- `monster_masters` - Monster definitions for quests
- `quest_area_masters` - Quest area definitions  
- `monster_drop_tables` - Monster loot tables
- `adventurer_quests` - Quest history
- `quest_rewards` - Quest reward tracking
- `adventurer_purchases` - Purchase history

## Solution Files Created

### 1. `/backend/database_migration_fix.py`
**Purpose**: Comprehensive database migration script that:
- Checks existing schema and identifies issues
- Fixes data type mismatches safely
- Creates missing tables with proper relationships
- Adds missing columns to existing tables
- Creates indexes and triggers
- Verifies the final schema

**Key Features**:
- Non-destructive migrations (preserves existing data where possible)
- Comprehensive error handling
- Schema verification
- Progress reporting

### 2. `/backend/adventurer_system_seed.py` 
**Purpose**: Seed script for adventurer system test data:
- Creates beginner-friendly adventurer masters
- Seeds quest areas with proper difficulty progression
- Creates monsters with balanced stats
- Sets up monster drop tables for materials
- Provides data for thorough testing

**Data Created**:
- 10 adventurer masters (beginner to elite tiers)
- 8 quest areas (forest to sky ruins)
- 11 monsters (slimes to ancient dragons)
- Monster drop tables linking monsters to materials

### 3. `/backend/test_db_connection.py`
**Purpose**: Simple diagnostic script to:
- Test database connectivity
- List existing tables
- Show current schema details
- Identify specific issues with adventurer tables

## Execution Steps

### Step 1: Start Database
```bash
cd /Users/texia/bukiya
docker-compose up -d postgres redis
```

### Step 2: Test Connection
```bash
cd backend
python test_db_connection.py
```

### Step 3: Run Migration
```bash
python database_migration_fix.py
```

### Step 4: Seed Data (Optional)
```bash
python adventurer_system_seed.py
```

### Step 5: Verify Backend
```bash
# Start the backend to test API endpoints
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Expected Outcomes

After running the migration:

1. **Fixed Schema**: All tables exist with correct data types
2. **Proper Relationships**: Foreign keys work correctly
3. **Complete Data Model**: All SQLAlchemy models match database schema
4. **Test Data**: Comprehensive seed data for testing
5. **Working API**: Backend endpoints for adventurer system function properly

## Schema Verification

The migration script includes verification that checks:
- All required tables exist
- Foreign key relationships are properly established
- Column data types match SQLAlchemy models
- Indexes and triggers are created
- Sample data can be inserted and queried

## Rollback Plan

If issues occur:
1. The migration is designed to be non-destructive
2. Existing data is preserved where possible
3. Database can be reset using: `docker-compose down -v && docker-compose up -d`
4. Original seed data can be restored from `/database/seed_data.sql`

## Testing Strategy

After migration:
1. Test basic CRUD operations on adventurer tables
2. Verify foreign key constraints work
3. Test API endpoints for adventurer functionality
4. Ensure Flutter app can interact with new system
5. Verify data consistency and integrity

## Files Modified/Created

- ✅ `backend/database_migration_fix.py` - Main migration script
- ✅ `backend/adventurer_system_seed.py` - Seed data script  
- ✅ `backend/test_db_connection.py` - Connection test
- ✅ `ADVENTURER_SYSTEM_FIX.md` - This documentation

## Next Steps

1. Execute the migration scripts in order
2. Test the adventurer system functionality
3. Update any remaining API endpoints that depend on the fixed schema
4. Test the Flutter app integration
5. Consider adding Alembic migrations for future schema changes
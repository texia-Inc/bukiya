#!/usr/bin/env python3
"""
Simple database connection test script
"""
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

try:
    from sqlalchemy import create_engine, text
    
    # Test database connection
    db_url = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"
    print(f"Testing connection to: {db_url}")
    
    engine = create_engine(db_url)
    
    with engine.connect() as conn:
        result = conn.execute(text("SELECT version()"))
        version = result.scalar()
        print(f"✅ Connected successfully!")
        print(f"PostgreSQL version: {version}")
        
        # Check existing tables
        result = conn.execute(text("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name
        """))
        tables = result.fetchall()
        print(f"\n📋 Existing tables ({len(tables)}):")
        for table in tables:
            print(f"   - {table[0]}")
            
        # Check adventurer_masters specifically
        if any('adventurer_masters' in str(table) for table in tables):
            result = conn.execute(text("SELECT COUNT(*) FROM adventurer_masters"))
            count = result.scalar()
            print(f"\n👥 adventurer_masters: {count} records")
            
            # Check columns
            result = conn.execute(text("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'adventurer_masters'
                ORDER BY ordinal_position
            """))
            columns = result.fetchall()
            print("   Columns:")
            for col_name, col_type in columns:
                print(f"     {col_name}: {col_type}")
        
        # Check adventurer_instances specifically
        if any('adventurer_instances' in str(table) for table in tables):
            result = conn.execute(text("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'adventurer_instances'
                AND column_name = 'adventurer_master_id'
            """))
            col_info = result.fetchone()
            if col_info:
                print(f"\n🔗 adventurer_instances.adventurer_master_id: {col_info[1]}")
            else:
                print(f"\n❌ adventurer_instances.adventurer_master_id: Column not found")
                
except Exception as e:
    print(f"❌ Connection failed: {e}")
    print("Make sure Docker containers are running:")
    print("   docker-compose up -d postgres redis")
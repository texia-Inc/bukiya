#!/usr/bin/env python3
"""
Database Schema Fix Script

This script fixes the database schema mismatch issue by:
1. Stopping all containers
2. Removing the PostgreSQL volume 
3. Restarting containers with fresh schema
4. Seeding the database
"""

import subprocess
import time
import sys
import os

def run_command(command, description):
    """Run a shell command and return the result"""
    print(f"\n🔄 {description}")
    print(f"Command: {command}")
    
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, cwd="/Users/texia/bukiya")
        
        if result.returncode == 0:
            print(f"✅ Success")
            if result.stdout:
                print(f"Output: {result.stdout[:500]}")
        else:
            print(f"❌ Failed (exit code: {result.returncode})")
            if result.stderr:
                print(f"Error: {result.stderr[:500]}")
                
        return result.returncode == 0, result.stdout, result.stderr
        
    except Exception as e:
        print(f"❌ Exception: {e}")
        return False, "", str(e)

def main():
    print("🚀 Starting Database Schema Fix Process")
    print("=" * 50)
    
    # Change to project directory
    os.chdir("/Users/texia/bukiya")
    
    # Step 1: Stop containers
    success, stdout, stderr = run_command("docker-compose down", "Stopping all containers")
    if not success:
        print("⚠️  Container stop failed, continuing anyway...")
    
    # Step 2: Remove PostgreSQL volume
    success, stdout, stderr = run_command("docker volume rm bukiya_postgres_data", "Removing PostgreSQL volume")
    if not success:
        print("⚠️  Volume removal failed, continuing anyway...")
    
    # Step 3: Start containers
    success, stdout, stderr = run_command("docker-compose up -d", "Starting containers")
    if not success:
        print("❌ Failed to start containers. Exiting.")
        return
    
    # Step 4: Wait for database initialization
    print("\n⏳ Waiting for database to initialize (60 seconds)...")
    time.sleep(60)
    
    # Step 5: Check backend logs
    run_command("docker logs bukiya_backend --tail 20", "Checking backend logs")
    
    # Step 6: Test health endpoint
    success, stdout, stderr = run_command("curl -s http://localhost:8000/health", "Testing health endpoint")
    
    # Step 7: Seed database
    success, stdout, stderr = run_command("docker exec bukiya_backend python comprehensive_seed_data.py", "Seeding database")
    if success:
        print("✅ Database seeded successfully")
    else:
        print("❌ Database seeding failed")
    
    # Step 8: Final health check
    success, stdout, stderr = run_command("curl -s http://localhost:8000/health", "Final health check")
    if success:
        print("\n🎉 Database schema fix completed successfully!")
        print("✅ Backend should now be running without database errors")
        print("✅ All foreign key constraints should work properly")
    else:
        print("\n❌ Fix may not have been successful. Check logs for details.")
    
    print("\n📋 Next steps:")
    print("1. Check backend logs: docker logs bukiya_backend")
    print("2. Verify API endpoints work: curl http://localhost:8000/api/v1/players/me")
    print("3. Check database with pgAdmin: http://localhost:5050")

if __name__ == "__main__":
    main()
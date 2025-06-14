#!/usr/bin/env python3
"""
Fix Docker backend startup errors
"""
import subprocess
import os
import time

def run_command(cmd, description):
    """Run a shell command and capture output"""
    print(f"\n=== {description} ===")
    print(f"Running: {cmd}")
    
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd="/Users/texia/bukiya")
        print(f"Return code: {result.returncode}")
        if result.stdout:
            print(f"STDOUT:\n{result.stdout}")
        if result.stderr:
            print(f"STDERR:\n{result.stderr}")
        return result.returncode == 0
    except Exception as e:
        print(f"Error running command: {e}")
        return False

def main():
    print("=== Docker Backend Fix Process ===")
    
    # Change to project directory
    os.chdir("/Users/texia/bukiya")
    print(f"Working directory: {os.getcwd()}")
    
    # Step 1: Stop containers
    run_command("docker-compose down", "Stopping Docker containers")
    
    # Step 2: Clean build backend
    run_command("docker-compose build backend --no-cache", "Building backend container (no cache)")
    
    # Step 3: Start services
    run_command("docker-compose up -d", "Starting services")
    
    # Step 4: Wait for startup
    print("\n=== Waiting for services to start ===")
    time.sleep(15)
    
    # Step 5: Check status
    run_command("docker ps", "Checking container status")
    
    # Step 6: Check backend logs
    run_command("docker logs bukiya_backend --tail 30", "Checking backend logs")
    
    # Step 7: Test API health
    print("\n=== Testing API Health ===")
    time.sleep(5)
    run_command("curl -f http://localhost:8000/health || echo 'Health check failed'", "Testing health endpoint")
    
    print("\n=== Fix process completed! ===")

if __name__ == "__main__":
    main()
#!/usr/bin/env python3
import subprocess
import time
import requests
import sys

def run_command(cmd, description):
    print(f"\n{description}")
    print(f"Command: {cmd}")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd="/Users/texia/bukiya")
        print(f"Return code: {result.returncode}")
        if result.stdout:
            print(f"STDOUT:\n{result.stdout}")
        if result.stderr:
            print(f"STDERR:\n{result.stderr}")
        return result.returncode == 0
    except Exception as e:
        print(f"Error executing command: {e}")
        return False

def check_api_health():
    try:
        response = requests.get("http://localhost:8000/health", timeout=5)
        print(f"API Health Check: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {data}")
            return True
    except Exception as e:
        print(f"API Health Check failed: {e}")
    return False

def main():
    print("=== Docker Backend Restart Script ===")
    
    # 1. Check current status
    run_command("docker-compose ps", "1. Current container status")
    
    # 2. Restart containers
    run_command("docker-compose restart", "2. Restarting all containers")
    
    # 3. Wait for containers to start
    print("\n3. Waiting for containers to start...")
    time.sleep(15)
    
    # 4. Check container status
    run_command("docker-compose ps", "4. Container status after restart")
    
    # 5. Check backend logs
    run_command("docker-compose logs --tail=20 backend", "5. Latest backend logs")
    
    # 6. Test API health
    print("\n6. Testing API health...")
    for attempt in range(5):
        print(f"Attempt {attempt + 1}/5")
        if check_api_health():
            print("✅ API is healthy!")
            break
        time.sleep(5)
    else:
        print("❌ API health check failed after 5 attempts")
    
    # 7. Check database connectivity
    run_command("docker-compose exec -T postgres pg_isready -U bukiya_user -d bukiya_game", "7. PostgreSQL connectivity test")

if __name__ == "__main__":
    main()
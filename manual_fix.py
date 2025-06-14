#!/usr/bin/env python3
"""
Manual backend fix and validation
"""
import os
import sys
import subprocess
from pathlib import Path

def check_docker_status():
    """Check if Docker is running and show current status"""
    print("=== Docker Status Check ===")
    try:
        result = subprocess.run(['docker', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✓ Docker version: {result.stdout.strip()}")
        else:
            print("✗ Docker not available")
            return False
            
        # Check if containers are running
        result = subprocess.run(['docker', 'ps', '-a', '--format', 'table {{.Names}}\t{{.Status}}'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("Current containers:")
            print(result.stdout)
        
        return True
    except FileNotFoundError:
        print("✗ Docker command not found")
        return False

def execute_fix_commands():
    """Execute the Docker fix commands"""
    print("\n=== Executing Fix Commands ===")
    
    commands = [
        ['docker-compose', 'down'],
        ['docker-compose', 'build', 'backend', '--no-cache'],
        ['docker-compose', 'up', '-d']
    ]
    
    # Change to project directory
    project_dir = Path("/Users/texia/bukiya")
    if not project_dir.exists():
        print(f"✗ Project directory not found: {project_dir}")
        return False
    
    os.chdir(project_dir)
    print(f"Working directory: {os.getcwd()}")
    
    for cmd in commands:
        print(f"\nRunning: {' '.join(cmd)}")
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
            print(f"Return code: {result.returncode}")
            if result.stdout:
                print(f"STDOUT: {result.stdout}")
            if result.stderr:
                print(f"STDERR: {result.stderr}")
                
            if result.returncode != 0:
                print(f"✗ Command failed: {' '.join(cmd)}")
                return False
            else:
                print(f"✓ Command succeeded: {' '.join(cmd)}")
                
        except subprocess.TimeoutExpired:
            print(f"✗ Command timed out: {' '.join(cmd)}")
            return False
        except Exception as e:
            print(f"✗ Error running command: {e}")
            return False
    
    return True

def wait_and_check_services():
    """Wait for services to start and check status"""
    print("\n=== Waiting for Services ===")
    import time
    
    print("Waiting 15 seconds for services to start...")
    time.sleep(15)
    
    # Check container status
    try:
        result = subprocess.run(['docker', 'ps'], capture_output=True, text=True)
        print("Container Status:")
        print(result.stdout)
        
        # Check backend logs
        result = subprocess.run(['docker', 'logs', 'bukiya_backend', '--tail', '20'], 
                              capture_output=True, text=True)
        print("\nBackend Logs:")
        print(result.stdout)
        if result.stderr:
            print("Backend Errors:")
            print(result.stderr)
        
        # Test health endpoint
        try:
            import requests
            response = requests.get('http://localhost:8000/health', timeout=5)
            if response.status_code == 200:
                print("✓ Health endpoint responding successfully")
                print(f"Response: {response.json()}")
                return True
            else:
                print(f"✗ Health endpoint returned status {response.status_code}")
        except ImportError:
            print("? requests module not available, using curl")
            result = subprocess.run(['curl', '-f', 'http://localhost:8000/health'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                print("✓ Health endpoint responding (curl)")
                print(f"Response: {result.stdout}")
                return True
            else:
                print("✗ Health endpoint not responding (curl)")
        except Exception as e:
            print(f"✗ Error testing health endpoint: {e}")
    
    except Exception as e:
        print(f"Error checking services: {e}")
    
    return False

def main():
    print("=== Manual Backend Fix Process ===\n")
    
    # Check Docker
    if not check_docker_status():
        print("Docker is not available. Please install Docker and try again.")
        return 1
    
    # Execute fix commands
    if not execute_fix_commands():
        print("Fix commands failed. Check the errors above.")
        return 1
    
    # Wait and check
    if wait_and_check_services():
        print("\n✓ Backend fix completed successfully!")
        print("Backend should now be running at http://localhost:8000")
        return 0
    else:
        print("\n✗ Backend fix completed but services may not be healthy")
        print("Check the logs above for errors")
        return 1

if __name__ == "__main__":
    sys.exit(main())
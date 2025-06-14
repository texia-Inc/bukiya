#!/usr/bin/env python3
"""
Backend cleanup and fix script
"""
import os
import shutil
import glob
from pathlib import Path

def clean_python_cache():
    """Clean Python cache files"""
    print("=== Cleaning Python cache files ===")
    
    backend_dir = Path("/Users/texia/bukiya/backend")
    
    # Remove __pycache__ directories
    pycache_dirs = list(backend_dir.rglob("__pycache__"))
    print(f"Found {len(pycache_dirs)} __pycache__ directories")
    
    for cache_dir in pycache_dirs:
        try:
            shutil.rmtree(cache_dir)
            print(f"✓ Removed {cache_dir}")
        except Exception as e:
            print(f"✗ Failed to remove {cache_dir}: {e}")
    
    # Remove .pyc files
    pyc_files = list(backend_dir.rglob("*.pyc"))
    print(f"Found {len(pyc_files)} .pyc files")
    
    for pyc_file in pyc_files:
        try:
            pyc_file.unlink()
            print(f"✓ Removed {pyc_file}")
        except Exception as e:
            print(f"✗ Failed to remove {pyc_file}: {e}")

def check_syntax_errors():
    """Check for Python syntax errors"""
    print("\n=== Checking Python syntax ===")
    
    backend_dir = Path("/Users/texia/bukiya/backend")
    python_files = list(backend_dir.rglob("*.py"))
    
    error_files = []
    
    for py_file in python_files:
        try:
            # Compile the file to check for syntax errors
            with open(py_file, 'r', encoding='utf-8') as f:
                source = f.read()
            compile(source, str(py_file), 'exec')
            print(f"✓ {py_file.relative_to(backend_dir)}")
        except SyntaxError as e:
            print(f"✗ SYNTAX ERROR in {py_file.relative_to(backend_dir)}: {e}")
            error_files.append(py_file)
        except Exception as e:
            print(f"? Error reading {py_file.relative_to(backend_dir)}: {e}")
    
    return error_files

def check_requirements():
    """Check requirements.txt"""
    print("\n=== Checking requirements.txt ===")
    
    req_file = Path("/Users/texia/bukiya/backend/requirements.txt")
    
    if not req_file.exists():
        print("✗ requirements.txt not found")
        return False
    
    with open(req_file, 'r') as f:
        content = f.read()
    
    required_packages = ['openai==1.3.8', 'aiofiles==23.2.1', 'fastapi', 'uvicorn']
    
    for package in required_packages:
        if package.split('==')[0] in content:
            print(f"✓ {package.split('==')[0]} found")
        else:
            print(f"✗ {package} missing")
    
    return True

def create_docker_fix_commands():
    """Create Docker fix commands"""
    print("\n=== Creating Docker fix commands ===")
    
    commands = [
        "cd /Users/texia/bukiya",
        "docker-compose down",
        "docker system prune -f",
        "docker-compose build backend --no-cache",
        "docker-compose up -d",
        "sleep 10",
        "docker ps",
        "docker logs bukiya_backend --tail 20",
        "curl http://localhost:8000/health"
    ]
    
    script_path = Path("/Users/texia/bukiya/fix_commands.sh")
    
    with open(script_path, 'w') as f:
        f.write("#!/bin/bash\n")
        f.write("# Auto-generated Docker fix commands\n\n")
        for cmd in commands:
            f.write(f"{cmd}\n")
    
    # Make executable
    os.chmod(script_path, 0o755)
    
    print(f"✓ Created fix script: {script_path}")
    print("\nTo run the fix:")
    print(f"chmod +x {script_path}")
    print(f"{script_path}")

def main():
    print("=== Backend Cleanup and Fix ===\n")
    
    # Clean cache files
    clean_python_cache()
    
    # Check syntax
    error_files = check_syntax_errors()
    
    # Check requirements
    check_requirements()
    
    # Create fix commands
    create_docker_fix_commands()
    
    print("\n=== Summary ===")
    if error_files:
        print(f"✗ Found {len(error_files)} files with syntax errors:")
        for file in error_files:
            print(f"  - {file}")
    else:
        print("✓ No syntax errors found")
    
    print("\nNext steps:")
    print("1. Run: chmod +x /Users/texia/bukiya/fix_commands.sh")
    print("2. Run: /Users/texia/bukiya/fix_commands.sh")
    print("3. Check the output for any remaining errors")

if __name__ == "__main__":
    main()
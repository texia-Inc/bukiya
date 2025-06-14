#!/usr/bin/env python3
"""
Debug script to check backend dependencies and configuration
"""
import sys
import os
from pathlib import Path

def check_imports():
    """Check if all required imports are available"""
    print("Checking imports...")
    
    try:
        import fastapi
        print(f"✓ FastAPI: {fastapi.__version__}")
    except ImportError as e:
        print(f"✗ FastAPI import failed: {e}")
        return False
    
    try:
        from fastapi.staticfiles import StaticFiles
        print("✓ StaticFiles import successful")
    except ImportError as e:
        print(f"✗ StaticFiles import failed: {e}")
        return False
    
    try:
        import aiofiles
        print(f"✓ aiofiles: {aiofiles.__version__}")
    except ImportError as e:
        print(f"✗ aiofiles import failed: {e}")
        return False
    
    try:
        import sqlalchemy
        print(f"✓ SQLAlchemy: {sqlalchemy.__version__}")
    except ImportError as e:
        print(f"✗ SQLAlchemy import failed: {e}")
        return False
    
    try:
        import redis
        print(f"✓ Redis client available")
    except ImportError as e:
        print(f"✗ Redis import failed: {e}")
        return False
    
    return True

def check_directories():
    """Check if required directories exist and are writable"""
    print("\nChecking directories...")
    
    static_dir = Path("/app/static")
    weapons_dir = Path("/app/static/images/weapons")
    
    try:
        static_dir.mkdir(parents=True, exist_ok=True)
        print(f"✓ Static directory created: {static_dir}")
        
        weapons_dir.mkdir(parents=True, exist_ok=True)  
        print(f"✓ Weapons directory created: {weapons_dir}")
        
        # Test write permission
        test_file = static_dir / "test_write.txt"
        test_file.write_text("test")
        test_file.unlink()
        print("✓ Write permissions OK")
        
    except Exception as e:
        print(f"✗ Directory setup failed: {e}")
        return False
    
    return True

def check_environment():
    """Check environment variables"""
    print("\nChecking environment variables...")
    
    required_vars = [
        "DATABASE_URL",
        "REDIS_URL", 
        "SECRET_KEY"
    ]
    
    all_good = True
    for var in required_vars:
        value = os.getenv(var)
        if value:
            print(f"✓ {var}: {value[:20]}..." if len(value) > 20 else f"✓ {var}: {value}")
        else:
            print(f"✗ {var}: Not set")
            all_good = False
    
    return all_good

def main():
    print("=== Backend Startup Debug ===\n")
    
    success = True
    success &= check_imports()
    success &= check_directories()
    success &= check_environment()
    
    print(f"\n=== Result ===")
    if success:
        print("✓ All checks passed! Backend should start successfully.")
        sys.exit(0)
    else:
        print("✗ Some checks failed. Backend may not start properly.")
        sys.exit(1)

if __name__ == "__main__":
    main()
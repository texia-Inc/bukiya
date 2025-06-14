#!/usr/bin/env python3
"""
Simple test script to check backend dependencies and imports
"""
import sys
import subprocess

def test_python_version():
    print(f"Python version: {sys.version}")
    print(f"Python executable: {sys.executable}")

def test_import(module_name):
    try:
        __import__(module_name)
        print(f"✅ {module_name} - OK")
        return True
    except ImportError as e:
        print(f"❌ {module_name} - FAILED: {e}")
        return False

def install_package(package_name):
    try:
        print(f"Installing {package_name}...")
        result = subprocess.run([sys.executable, "-m", "pip", "install", package_name], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {package_name} installed successfully")
            return True
        else:
            print(f"❌ Failed to install {package_name}: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Error installing {package_name}: {e}")
        return False

def main():
    print("=== Backend Dependencies Test ===")
    test_python_version()
    print()
    
    # Test critical imports
    required_modules = [
        "fastapi",
        "uvicorn",
        "sqlalchemy",
        "passlib",
        "pydantic",
        "python_jose",
        "redis",
        "psycopg2"
    ]
    
    print("Testing required modules:")
    failed_modules = []
    
    for module in required_modules:
        if not test_import(module):
            failed_modules.append(module)
    
    print(f"\n=== Summary ===")
    print(f"Total modules tested: {len(required_modules)}")
    print(f"Failed modules: {len(failed_modules)}")
    
    if failed_modules:
        print(f"Missing modules: {', '.join(failed_modules)}")
        
        # Try to install missing modules
        print("\nAttempting to install missing modules...")
        for module in failed_modules:
            if module == "python_jose":
                install_package("python-jose[cryptography]")
            elif module == "passlib":
                install_package("passlib[bcrypt]")
            else:
                install_package(module)
    else:
        print("All modules are available!")

if __name__ == "__main__":
    main()
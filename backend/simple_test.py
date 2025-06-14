import sys
print("Python version:", sys.version)
try:
    import passlib
    print("passlib is available")
except ImportError:
    print("passlib is NOT available")
    
try:
    import fastapi
    print("fastapi is available")
except ImportError:
    print("fastapi is NOT available")
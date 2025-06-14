# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **武器屋放置ゲーム** (Weapon Shop Idle Game) - a comprehensive gaming platform with three integrated applications:

1. **Flutter Mobile App** (`/bukiya_game`) - Primary game client for players
2. **FastAPI Backend** (`/backend`) - Game server with PostgreSQL database
3. **React Admin Panel** (`/admin`) - Management interface for game data

## Development Commands

### Backend (FastAPI)
```bash
# Start full development environment
docker-compose up -d

# Start lightweight environment (no admin panel)
docker-compose -f docker-compose.light.yml up -d

# Local development without Docker
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Database operations
python seed_data.py                    # Seed basic game data
python create_adventurer_tables.py     # Create adventurer system
python enchantment_seed_data.py        # Seed enchantment data

# Code quality
black app/                              # Format code
isort app/                              # Sort imports
flake8 app/                            # Lint code
pytest                                 # Run tests
```

### Flutter App
```bash
cd bukiya_game

# Development
flutter run -d chrome --web-port 3000  # Web development
flutter run -d ios                     # iOS simulator
flutter run -d android                 # Android emulator

# Code generation (required after model changes)
dart run build_runner build --delete-conflicting-outputs

# Build & Analysis
flutter build web                       # Production web build
flutter build apk                       # Android release
flutter build ios                       # iOS release
flutter analyze                        # Static analysis
flutter test                          # Run tests

# Clean builds (if having issues)
flutter clean && flutter pub get
```

### Admin Panel (React)
```bash
cd admin

# Development
npm install                            # Install dependencies
npm run dev                           # Development server (http://localhost:5173)
npm run build                         # Production build
npm run lint                          # ESLint check
npm run preview                       # Preview production build

# No explicit typecheck command - TypeScript checking happens during build
```

## Architecture Overview

### Backend Architecture (FastAPI)
- **Multi-layered design**: `api/endpoints` → `core/business logic` → `models/database`
- **SQLAlchemy 2.0 ORM** with async/await pattern
- **Pydantic schemas** for request/response validation
- **JWT authentication** with refresh token support
- **Redis caching** for session management
- **Structured error handling** with JSON API responses

Key patterns:
- All database models in `/backend/app/models/`
- API schemas in `/backend/app/schemas/`
- Endpoints organized by feature in `/backend/app/api/v1/endpoints/`
- Configuration via environment variables in `/backend/app/core/config.py`

### Flutter Architecture (Provider + Feature Modules)
- **Feature-driven structure**: Each game feature has `providers/`, `screens/`, `widgets/`
- **Provider state management** with `ChangeNotifier` pattern
- **Dio HTTP client** with custom interceptors for authentication
- **Hive local storage** for caching and offline data
- **JSON serialization** with code generation

Key patterns:
- Feature modules: `auth`, `shop`, `crafting`, `enchantment`, `inventory`, `mission`, `adventurer`, `idle`, `dragon_event`, `character`, `admin`, `puzzle`
- Each feature has a dedicated Provider for state management
- API services in `/lib/core/services/`
- Shared models in `/lib/core/models/` with `.g.dart` generated files
- App-wide constants in `/lib/core/constants/app_constants.dart`
- Tutorial system with overlay widgets and tutorial wrapper

### Database Design
The game uses a sophisticated **26+ table PostgreSQL schema**:
- **Master data**: `weapon_masters`, `material_masters`, `rarity_levels`, `season_masters`
- **Player data**: `players`, `player_weapons`, `player_materials`, `player_statistics`
- **Game systems**: Crafting recipes, enchantment system, adventurer interactions, dragon events
- **Real-time processes**: Active crafting, mission progress, idle income generation
- **Advanced features**: Adventurer character system, material targeting, quest areas

## Service Integration

### API Endpoints Structure
```
/api/v1/
├── auth/          # Authentication (login, register, refresh)
├── players/       # Player profiles and statistics
├── weapons/       # Weapon catalog and player inventory
├── materials/     # Material system and inventory
├── crafting/      # Weapon crafting and recipes
├── shop/          # Weapon trading and transactions
├── enchantment/   # Weapon enhancement system
├── missions/      # Quest system and rewards
├── adventurers/   # NPC adventurer interactions
├── idle/          # Passive income system
├── idle-income/   # Enhanced idle income management
├── seasons/       # Seasonal content and events
├── dragon-events/ # Dragon raid events
└── image-generation/ # AI weapon image generation
```

### Authentication Flow
1. **Client login** → JWT access token (24h) + refresh token (30d)
2. **API requests** → `Authorization: Bearer <token>` header
3. **Token refresh** → Automatic renewal via refresh token
4. **Flutter storage** → `flutter_secure_storage` for token persistence

### State Management Pattern (Flutter)
```dart
// Provider pattern with API integration
class FeatureProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  Future<void> loadData() async {
    setLoading(true);
    try {
      final data = await _apiService.getData();
      updateState(data);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
```

## Development Environment

### Required Services
- **Backend API**: http://localhost:8000 (with docs at `/docs`)
- **PostgreSQL**: localhost:5432 (bukiya_user/bukiya_password/bukiya_game)
- **Redis**: localhost:6379
- **pgAdmin**: http://localhost:5050 (admin@example.com/admin_password)
- **Flutter Web**: http://localhost:3000
- **React Admin**: http://localhost:5173

### Docker Environment Options
```bash
# Full environment (backend + database + admin)
docker-compose up -d

# Lightweight environment (backend + database only)
docker-compose -f docker-compose.light.yml up -d

# Production environment
docker-compose -f docker-compose.production.yml up -d
```

### Environment Variables
Backend uses environment-based configuration:
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string  
- `JWT_SECRET_KEY`: JWT signing key
- `JWT_ALGORITHM`: JWT algorithm (default: HS256)

### Code Generation Dependencies
Flutter requires code generation for:
- **JSON serialization**: `@JsonSerializable()` classes need `dart run build_runner build`
- **Hive adapters**: Local storage models
- **Retrofit APIs**: HTTP client generation

### Common Development Issues

**Flutter Hot Reload Issues**:
```bash
# Clear build cache and regenerate
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Backend Database Connection**:
```bash
# Recreate database if schema changes
docker-compose down -v
docker-compose up -d
# Wait for DB to initialize, then seed data
python backend/seed_data.py

# Alternative: Use provided database scripts
python backend/create_adventurer_tables.py       # Create adventurer system
python backend/enchantment_seed_data.py          # Seed enchantment data
python backend/create_dragon_event_tables.py     # Create dragon event tables
python backend/idle_seed_data.py                 # Seed idle system data
```

**Authentication Token Expiry**:
- Flutter app automatically handles token refresh
- Manual testing requires fresh tokens from `/api/v1/auth/login`

## Testing Integration

### API Testing
```bash
# Health check
curl http://localhost:8000/health

# Authentication test
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Authenticated request
curl -X GET http://localhost:8000/api/v1/players/me \
  -H "Authorization: Bearer <token>"
```

### Flutter Widget Testing
```bash
cd bukiya_game
flutter test                           # Run all tests
flutter test test/widget_test.dart     # Specific test file
```

## Processing Sequence Diagrams

For detailed processing flows and sequence diagrams of the game systems, see:
**@sequence_diagrams.md** - Complete Mermaid sequence diagrams covering:
- Authentication flow (login, register, token refresh)
- Weapon purchase and trading system
- Crafting system with success/failure handling
- Enchantment system with multiple outcomes
- Mission progression and reward claiming
- Idle income calculation and collection
- Overall system architecture overview

## Key Dependencies

### Backend Core
- **FastAPI 0.104.1**: Web framework with automatic OpenAPI
- **SQLAlchemy 2.0.23**: Async ORM with relationship management
- **Pydantic 2.5.0**: Data validation and serialization
- **Redis 5.0.1**: Caching and session storage
- **PostgreSQL**: Primary database with advanced features
- **Alembic 1.12.1**: Database migration tool

### Flutter Core  
- **Provider 6.1.1**: State management with ChangeNotifier
- **Dio 5.4.0**: HTTP client with interceptors
- **Hive 2.2.3**: Local NoSQL database
- **flutter_secure_storage 9.0.0**: Encrypted token storage
- **retrofit 4.0.3**: Type-safe HTTP client generation
- **google_fonts 6.1.0**: Custom font integration

### Admin Panel (React)
- **React 18.3.1**: UI framework
- **Material-UI 5.15.10**: Component library
- **Redux Toolkit 2.8.2**: State management
- **Vite 6.3.5**: Build tool and dev server
- **TypeScript ~5.8.3**: Static type checking

### Development Tools
- **build_runner**: Dart code generation
- **retrofit_generator**: HTTP client generation  
- **json_serializable**: JSON serialization
- **black/isort/flake8**: Python code formatting and linting
- **pytest**: Python testing framework
- **flutter_lints**: Dart/Flutter linting

## Common Development Tasks

### Database Schema Changes
When making model changes that affect the database schema:
```bash
# Stop containers and reset database
docker-compose down -v
docker-compose up -d

# Or use the provided migration scripts
python backend/database_migration_fix.py
python backend/schema_migration.py
```

### Game Data Seeding
Multiple specialized seed scripts are available:
```bash
# Basic game data
python backend/seed_data.py

# Specific systems
python backend/comprehensive_material_seed.py
python backend/comprehensive_monster_seed.py  
python backend/massive_weapon_seed.py
python backend/adventurer_system_seed.py
```

### Error Handling and Debugging
- **Backend logs**: `docker logs bukiya_backend --tail 50`
- **Database connection issues**: Check `backend/test_db_connection.py`
- **API testing**: Use `backend/test_api.py` for endpoint validation
- **Flutter debugging**: Enable verbose logging in `lib/core/services/`

### Production Deployment
```bash
# Use production docker compose
docker-compose -f docker-compose.production.yml up -d

# Environment variables required:
# - DATABASE_URL
# - REDIS_URL  
# - JWT_SECRET_KEY
```
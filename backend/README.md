# TripBond Backend

FastAPI backend for the TripBond travel planning application.

## Architecture

```
app/
├── routers/           # API endpoint modules
│   ├── auth.py       # Authentication & user management
│   ├── personality.py # Big 5 personality assessment
│   ├── preferences.py # Travel preferences (trip & user level)
│   ├── profile.py    # User profile management
│   ├── adventures.py # Trips, favorites management
│   └── settings.py   # User settings & app configuration
├── config.py         # Application configuration
├── database.py       # Supabase database client
└── main.py          # FastAPI application & middleware
```

## Setup

### Prerequisites
- Python 3.10+
- Supabase account
- PostgreSQL database (via Supabase)

### Installation

1. **Install dependencies**
```bash
pip install -r requirements.txt
```

2. **Configure environment**
```bash
cp .env.example .env
```

Edit `.env` with your credentials:
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=your-service-role-key
SUPABASE_ANON_KEY=your-anon-key
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True
```

3. **Start server**
```bash
python run.py
```

Or with hot reload:
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## API Documentation

Interactive API docs available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API Endpoints Overview

### Authentication (`/api/auth`)
Complete user authentication flow with Supabase Auth.

**Key Endpoints:**
- `POST /signup` - Register with email/password + profile data
- `POST /signin` - Login and get access token
- `POST /reset-password` - Send password reset email
- `POST /update-password` - Update password with reset token
- `POST /verify-email` - Verify email with OTP

### Personality Quiz (`/api/personality`)
Big 5 personality trait assessment for travel compatibility matching.

**Features:**
- 10 question quiz covering all Big 5 traits
- Automatic score calculation (0.0 - 1.0 scale)
- Stores both scores and individual answers
- Update capability for retakes

**Endpoints:**
- `GET /questions` - Get quiz questions
- `POST /submit` - Calculate & save scores
- `GET /scores/{user_id}` - Retrieve scores
- `PUT /update/{user_id}` - Manual score updates

### Preferences (`/api/preferences`)
Two-level preference system: trip-specific and general user preferences.

**Trip Preferences** (per trip, per user):
- Activity tags (array)
- Pace (slow/moderate/fast)
- Stored in `trip_preferences` table

**General Preferences** (user-level):
- Budget level
- Travel style
- Dietary preferences
- Accommodation preferences
- Transport preferences
- Stored in `profiles` table

**Endpoints:**
- `GET /questionnaire` - Get questionnaire structure
- `POST /trip/submit` - Save trip preferences
- `GET /trip/{trip_id}/{user_id}` - Get trip preferences
- `POST /user/general` - Update general preferences
- `GET /user/general/{user_id}` - Get general preferences

### Profile (`/api/profile`)
User profile management with stats and privacy controls.

**Profile Data:**
- Basic info (name, username, bio, avatar)
- Contact (email, phone)
- Location & privacy settings
- Statistics (trips, favorites, etc.)

**Endpoints:**
- `GET /me?user_id={id}` - Get own profile with stats
- `GET /{user_id}` - Get public profile
- `PUT /update/{user_id}` - Update profile
- `POST /change-password/{user_id}` - Change password
- `DELETE /delete/{user_id}` - Delete account

### Adventures (`/api/adventures`)
Trip creation, management, and favorites system.

**Trips:**
- Create and manage trips
- Set visibility (public/private)
- Add type, description, images
- Track trip members

**Favorites:**
- Save trips, destinations, POIs
- Organize favorites by type
- Quick access to saved items

**Endpoints:**
- `GET /trips/{user_id}` - User's trips
- `POST /trips/create` - Create new trip
- `GET /trips/detail/{trip_id}` - Trip details
- `DELETE /trips/delete/{trip_id}` - Remove trip
- `GET /favorites/{user_id}` - User favorites
- `POST /favorites/add` - Add favorite
- `DELETE /favorites/remove/{favorite_id}` - Remove favorite

### Settings (`/api/settings`)
App settings and user preferences management.

**Settings Include:**
- Security toggle
- Notifications toggle
- Privacy mode (public/friends/private)
- Data saver mode
- Storage management

**Endpoints:**
- `GET /settings/{user_id}` - Get settings
- `PUT /settings/{user_id}` - Update settings
- `POST /cache/clear/{user_id}` - Clear cache
- `GET /storage/{user_id}` - Storage info
- `GET /support/help` - Help resources
- `GET /support/terms` - Terms & policies

## Database Schema

### Core Tables

**profiles**
- User profile data
- Big 5 personality scores
- General travel preferences
- Extended with: username, bio, avatar_url, current_location, is_public

**trips**
- Trip information
- Created by user
- Extended with: trip_type, description, image_url, is_public, location

**trip_preferences**
- Per-trip, per-user preferences
- Activity tags (array)
- Pace preference
- Composite key: (trip_id, user_id)

**personality_answers**
- Individual quiz responses
- Question text & answer value
- Links to user

**user_favorites**
- Saved trips, destinations, POIs
- References: trips, pois
- Unique per user per item

**user_settings**
- App configuration per user
- Security, privacy, data settings
- Storage tracking

### Additional Tables

- `trip_members` - Group trip participants
- `itineraries` - Trip itineraries with versioning
- `itinerary_items` - Individual itinerary activities
- `pois` - Points of interest database
- `ratings` - User ratings & reviews
- `comments` - Trip/itinerary comments
- `votes` - Voting on itinerary items
- `groups` - User groups
- `friends` - Friend connections

## Development

### Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py           # FastAPI app initialization
│   ├── config.py         # Settings via pydantic-settings
│   ├── database.py       # Supabase client wrapper
│   └── routers/
│       ├── __init__.py   # Router exports
│       └── *.py          # Individual router modules
├── .env                  # Environment variables (gitignored)
├── .env.example          # Environment template
├── requirements.txt      # Python dependencies
└── run.py               # Server entry point
```

### Adding New Endpoints

1. Create new router in `app/routers/`
2. Define pydantic models for request/response
3. Import router in `app/routers/__init__.py`
4. Register router in `app/main.py`

Example:
```python
# app/routers/example.py
from fastapi import APIRouter
router = APIRouter()

@router.get("/test")
async def test_endpoint():
    return {"status": "ok"}

# app/main.py
from .routers import example
app.include_router(example.router, prefix="/api/example", tags=["Example"])
```

### Database Operations

Use the `SupabaseDB` wrapper for database operations:

```python
from ..database import SupabaseDB

db = SupabaseDB()
result = db.client.table("profiles").select("*").eq("id", user_id).execute()
```

### Error Handling

Use FastAPI's `HTTPException` for errors:

```python
from fastapi import HTTPException, status

raise HTTPException(
    status_code=status.HTTP_404_NOT_FOUND,
    detail="User not found"
)
```

## Testing

Run the development server and test via:
1. Swagger UI: http://localhost:8000/docs
2. HTTP client (Postman, curl, etc.)
3. Python requests library

Example test:
```bash
curl -X POST http://localhost:8000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "securepass123",
    "full_name": "Test User"
  }'
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | Yes |
| `SUPABASE_KEY` | Service role key | Yes |
| `SUPABASE_ANON_KEY` | Anonymous key | Yes |
| `API_HOST` | Server host | No (default: 0.0.0.0) |
| `API_PORT` | Server port | No (default: 8000) |
| `DEBUG` | Debug mode | No (default: False) |

## Deployment

### Production Checklist

- [ ] Set `DEBUG=False` in production
- [ ] Configure CORS allowed origins
- [ ] Set up proper RLS policies in Supabase
- [ ] Use environment secrets manager
- [ ] Enable HTTPS
- [ ] Set up logging & monitoring
- [ ] Configure rate limiting
- [ ] Add authentication middleware

### Recommended Platforms

- **Railway** - Easy deployment with GitHub integration
- **Render** - Free tier available
- **AWS EC2** - Full control
- **Heroku** - Simple deployment
- **DigitalOcean App Platform** - Managed service

## Troubleshooting

### Common Issues

**Database connection fails:**
- Check Supabase URL and keys in `.env`
- Verify Supabase project is active
- Check network connectivity

**Import errors:**
- Ensure virtual environment is activated
- Run `pip install -r requirements.txt`
- Check Python version (3.10+)

**Migration errors:**
- Verify SQL syntax in migration files
- Check table exists before altering
- Review Supabase logs for details

### Debug Mode

Enable detailed logging:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## Contributing

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Update documentation
5. Submit pull request

## License

TBD

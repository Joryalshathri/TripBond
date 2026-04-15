# TripBond

AI-powered group travel planning and companion matching application with Flutter mobile frontend.

## Overview

TripBond helps travelers find compatible travel companions and plan trips together using personality-based matching and intelligent itinerary generation. Built with a FastAPI backend and Flutter frontend.

## Features

✅ **Authentication** - Complete user authentication with email verification
✅ **Personality Quiz** - Big 5 personality trait assessment for matching (MBTI in mobile)
✅ **Travel Preferences** - Trip-specific and general user preferences
✅ **User Profiles** - Rich profiles with stats, bio, and privacy settings
✅ **Trip Management** - Create, manage, and share trips
✅ **Favorites** - Save favorite destinations and trips
✅ **Settings** - Comprehensive app settings and privacy controls
✅ **Smooth Animations** - Flutter Animate integration
✅ **Responsive Design** - Works on iOS, Android, Web, and Desktop

##  Tech Stack

- **Backend**: FastAPI (Python)
- **Frontend**: Flutter (Dart)
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Custom JWT + Supabase Auth
- **Deployment**: TBD

## Project Structure

```
TripBond/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── routers/        # API endpoints
│   │   │   ├── auth.py
│   │   │   ├── personality.py
│   │   │   ├── preferences.py
│   │   │   ├── trips.py
│   │   │   ├── users.py
│   │   │   ├── favorites.py
│   │   │   ├── chat.py
│   │   │   └── ...
│   │   ├── config.py
│   │   ├── database.py
│   │   └── main.py
│   ├── requirements.txt
│   ├── .env.example
│   └── run.py
├── frontend/                # Flutter frontend
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   ├── services/
│   │   ├── providers/
│   │   ├── core/
│   │   └── utils/
│   ├── pubspec.yaml
│   └── android/, ios/, web/
└── README.md
```

## Quick Start

### Backend Setup

1. **Install Python dependencies**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

3. **Start the server**
   ```bash
   python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

   API Documentation: http://localhost:8000/docs

### Frontend Setup

1. **Install Flutter dependencies**
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

3. **Build for production**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   
   # Web
   flutter build web --release
   ```

## API Endpoints

### Authentication (`/api/auth`)
- `POST /signup` - Register new user
- `POST /signin` - Login
- `POST /signout` - Logout
- `POST /reset-password` - Request password reset
- `POST /update-password` - Update password
- `POST /verify-email-code` - Verify email with 6-digit code

### Personality (`/api/personality`)
- `GET /questions` - Get quiz questions
- `POST /submit` - Submit quiz answers
- `GET /scores/{user_id}` - Get personality scores

### Preferences (`/api/preferences`)
- `GET /questionnaire` - Get questionnaire structure
- `POST /trip/submit` - Submit trip preferences
- `GET /trip/{trip_id}/{user_id}` - Get trip preferences

### Trips (`/api/trips`)
- `GET /{user_id}` - Get user trips
- `POST /create` - Create trip
- `GET /{trip_id}` - Get trip details

### Users (`/api/users`)
- `GET /me` - Get current user profile
- `GET /{user_id}` - Get user profile
- `PUT /update` - Update profile

### Chat (`/api/chat`)
- `POST /send` - Send message
- `GET /conversations` - Get conversations
- `GET /messages/{conversation_id}` - Get messages

### Favorites (`/api/favorites`)
- `GET /{user_id}` - Get user favorites
- `POST /add` - Add favorite
- `DELETE /{id}` - Remove favorite

## Database Schema

Supabase PostgreSQL with tables:
- `profiles` - User profiles with personality traits
- `trips` - Trip information
- `trip_preferences` - Per-trip preferences
- `trip_members` - Group trip members
- `personality_answers` - Quiz responses
- `user_favorites` - Saved destinations
- `user_settings` - App settings
- `chat_conversations` - Chat conversations
- `chat_messages` - Chat messages
- And more...

## Development

### Backend Development

Enable hot reload:
```bash
cd backend
python -m uvicorn app.main:app --reload
```

### Frontend Development

Watch for changes:
```bash
cd frontend
flutter run
# Then press 'r' for hot reload, 'R' for hot restart
```

## Documentation

- [API Docs](http://localhost:8000/docs) - Interactive API documentation (Swagger UI)
- [Backend README](backend/README.md) - Backend documentation
- [Frontend README](frontend/README.md) - Frontend documentation

## Coming Soon

- 🔄 AI-powered itinerary generation
- 🔄 Companion matching algorithm
- 🔄 Real-time collaboration
- 🔄 Social features (comments, ratings, votes)
- 🔄 Payment integration

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is private and not licensed for public use.

## 👥 Team

Developed by the TripBond team.

---

Built with ❤️ using FastAPI & Flutter

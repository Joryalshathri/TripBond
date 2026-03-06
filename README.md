# TripBond

<<<<<<< HEAD
AI-powered group travel planning and companion matching application.

## Overview

TripBond helps travelers find compatible travel companions and plan trips together using personality-based matching and intelligent itinerary generation.

## Features

✅ **Authentication** - Complete user authentication with email verification
✅ **Personality Quiz** - Big 5 personality trait assessment for matching
✅ **Travel Preferences** - Trip-specific and general user preferences
✅ **User Profiles** - Rich profiles with stats, bio, and privacy settings
✅ **Trip Management** - Create, manage, and share trips
✅ **Favorites** - Save favorite destinations and trips
✅ **Settings** - Comprehensive app settings and privacy controls

## Project Structure

```
TripBond/
├── backend/
│   ├── app/
│   │   ├── routers/          # API endpoints
│   │   │   ├── auth.py       # Authentication
│   │   │   ├── personality.py # Big 5 quiz
│   │   │   ├── preferences.py # Travel preferences
│   │   │   ├── profile.py    # User profiles
│   │   │   ├── adventures.py # Trips & favorites
│   │   │   └── settings.py   # App settings
│   │   ├── config.py         # Configuration
│   │   ├── database.py       # Database connection
│   │   └── main.py           # FastAPI app
│   ├── requirements.txt      # Python dependencies
│   ├── .env.example          # Environment template
│   └── run.py                # Server entry point
└── README.md
```

## Quick Start

### 1. Setup Backend

```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment

Copy `.env.example` to `.env` and add your Supabase credentials:

```bash
cp .env.example .env
```

Edit `.env` with your Supabase project details.

### 3. Start Server

```bash
python run.py
```

API Documentation: http://localhost:8000/docs

## API Endpoints

### Authentication (`/api/auth`)
- `POST /signup` - Register new user
- `POST /signin` - Login
- `POST /signout` - Logout
- `POST /reset-password` - Request password reset
- `POST /update-password` - Update password
- `POST /verify-email` - Verify email

### Personality (`/api/personality`)
- `GET /questions` - Get quiz questions
- `POST /submit` - Submit quiz answers
- `GET /scores/{user_id}` - Get personality scores
- `PUT /update/{user_id}` - Update scores

### Preferences (`/api/preferences`)
- `GET /questionnaire` - Get questionnaire structure
- `POST /trip/submit` - Submit trip preferences
- `GET /trip/{trip_id}/{user_id}` - Get trip preferences
- `POST /user/general` - Update general preferences

### Profile (`/api/profile`)
- `GET /me` - Get current user profile
- `GET /{user_id}` - Get user profile
- `PUT /update/{user_id}` - Update profile
- `POST /change-password/{user_id}` - Change password

### Adventures (`/api/adventures`)
- `GET /trips/{user_id}` - Get user trips
- `POST /trips/create` - Create trip
- `GET /favorites/{user_id}` - Get favorites
- `POST /favorites/add` - Add favorite

### Settings (`/api/settings`)
- `GET /settings/{user_id}` - Get settings
- `PUT /settings/{user_id}` - Update settings
- `POST /cache/clear/{user_id}` - Clear cache

## Database Schema

Supabase PostgreSQL with tables:
- `profiles` - User profiles with personality traits
- `trips` - Trip information
- `trip_preferences` - Per-trip preferences
- `trip_members` - Group trip members
- `personality_answers` - Quiz responses
- `user_favorites` - Saved destinations
- `user_settings` - App settings
- `itineraries` - Trip itineraries
- `pois` - Points of interest
- And more...

## Tech Stack

- **Backend**: FastAPI (Python)
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Deployment**: TBD

## Development

Enable hot reload:
```bash
uvicorn app.main:app --reload
```

## Documentation

- [API Docs](http://localhost:8000/docs) - Interactive API documentation
- [Backend README](backend/README.md) - Backend documentation

## Coming Soon

- 🔄 AI-powered itinerary generation
- 🔄 Companion matching algorithm
- 🔄 Real-time collaboration
- 🔄 Flutter mobile app
- 🔄 Social features (comments, ratings, votes)
=======
A Flutter-based travel companion application that helps users connect through shared travel experiences and personality compatibility.

## 📱 About

TripBond is a mobile application designed to help travelers bond through personalized travel experiences. The app features:

- **MBTI Personality Assessment**: Understand your travel personality
- **Personalized Recommendations**: Travel suggestions based on your preferences
- **Modern UI/UX**: Smooth animations and intuitive design
- **Cross-Platform**: Built with Flutter for iOS, Android, and Web support

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.6.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- A code editor (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tripbond_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── animations/          # Animation utilities and page transitions
│   └── constants/           # App-wide constants (colors, text styles, dimensions)
└── screens/                 # UI screens
    ├── auth_screen.dart
    ├── onboarding_screen.dart
    ├── mbti_screen.dart
    ├── home_screen.dart
    └── ...
```

## 🎨 Features

- ✅ **Authentication**: User login and registration
- ✅ **Onboarding**: Welcome experience for new users
- ✅ **MBTI Assessment**: Travel personality questionnaire
- ✅ **Profile Management**: User profile customization
- ✅ **Smooth Animations**: Flutter Animate integration
- ✅ **Responsive Design**: Adapts to different screen sizes

## 📦 Dependencies

Key packages used in this project:

- `google_fonts` - Beautiful typography
- `shared_preferences` - Local data storage
- `flutter_animate` - Smooth animations
- `lottie` - Vector animations
- `animations` - Material Design motion

See [pubspec.yaml](pubspec.yaml) for the complete list.

## 🧪 Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test
```

## 📸 Screenshots

*Coming soon*

<!-- 
Add your app screenshots here:
| Home | Profile | MBTI Assessment |
|------|---------|----------------|
| ![Home](screenshots/home.png) | ![Profile](screenshots/profile.png) | ![MBTI](screenshots/mbti.png) |
-->

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is private and not licensed for public use.

## 👥 Team

Developed by the TripBond team.

## 📞 Contact

For questions or support, please contact: [your-email@example.com]

---

Built with ❤️ using Flutter
>>>>>>> 64e63e462e56f19c432aa5a2d9c1fea7e4e4094d

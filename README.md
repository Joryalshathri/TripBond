# TripBond ✈️

> **Tired of endless group chats, conflicting plans, and the classic "I don't mind" friend?**

## One Plan. Every Preference.

After a year of development, meet **TripBond** — an AI-powered social travel app that makes group trip planning smarter, fairer, and more enjoyable.

No more compromise chaos. No more decision paralysis. Just seamless trip planning powered by machine learning.

---

## 🎯 Why TripBond?

**The Problem:** Group travel planning is broken. Too many opinions. Too many platforms. Too many "I don't cares" that lead nowhere.

**The Solution:** TripBond learns everyone's preferences and creates travel plans that balance what everyone actually wants — not just what the loudest voice demands.

---

## ✨ Core Features

### 🤖 AI-Powered Planning
- **Personalized Recommendations** — Machine learning algorithms understand each traveler's unique preferences
- **Smart Itinerary Generation** — Automatically creates optimal day-by-day plans based on group interests
- **Balanced Group Preferences** — Ensures every group member's preferences are fairly represented

### 🌍 Real-Time Intelligence
- **Real-time Travel Suggestions** — Get the best local spots, timings, and routes updated live
- **Collaborative Trip Planning** — Plan together, but smarter—with AI mediation to prevent endless debates

### 🎭 Social Experience
- Make trip planning social and fun, not stressful
- Transparent preference voting and decision-making
- In-app chat and real-time notifications

### 🎨 Seamless UX
- Cross-platform (iOS, Android, Web, Desktop)
- Smooth animations and intuitive design
- POI explorer with photos and details

---

## 🚀 How It Works

1. **Create Your Trip** — Set destination, dates, and group members
2. **Share Preferences** — Add what you love (food, adventure, culture, budget, activity level)
3. **Let AI Work** — TripBond's ML engine learns and balances everyone's preferences
4. **Review & Customize** — Explore AI-generated itinerary and make tweaks as needed
5. **Travel Together** — Access your plan in real-time with built-in guidance and updates

---

## 💡 What Makes TripBond Different?

| Aspect | Traditional Apps | TripBond |
|--------|------------------|----------|
| Group Planning | ❌ | ✅ |
| Fair Decision Making | ❌ | ✅ |
| AI Personalization | Limited | ✅ Advanced |
| Real-time Adaptation | ❌ | ✅ |
| Balanced Recommendations | ❌ | ✅ No one ignored |
| All-in-one Platform | ❌ | ✅ |

---

## 🏆 Results

- **ML Accuracy**: 83.63%
- **ROC-AUC Score**: 85.88%
- Strong predictive performance for preference balancing

---

## 🏗️ Tech Stack

### Frontend
- **Flutter** — Cross-platform mobile & web (iOS, Android, Web, Desktop)
- **Riverpod** — State management

### Backend
- **Python + FastAPI** — Fast, scalable REST API
- **SQLAlchemy** — Database ORM
- **JWT Auth** — Secure authentication
- **PostgreSQL** — Reliable data storage

### AI & ML
- **Random Forest** — Preference prediction
- **Genetic Algorithm** — Itinerary optimization
- **Collaborative Filtering** — Smart recommendations
- **Decision Trees** — User profiling

---

## 📦 Project Structure

```
tripbond-app/
├── frontend/                  # Flutter mobile & web app
├── backend/                   # FastAPI server & API
├── ai/                        # ML models & AI engine
├── tripbond_ai_backend/       # AI backend services
└── models/                    # Data & training models
```

---

## 🛠️ Getting Started

### Prerequisites
- Python 3.9+
- Flutter 3.x+
- PostgreSQL

### Quick Start

**Backend:**
```bash
cd backend
pip install -r requirements.txt
python run.py
```

**Frontend:**
```bash
cd frontend
flutter pub get
flutter run
```

**AI Services:**
```bash
cd tripbond_ai_backend
pip install -r requirements.txt
python run_ai.py
```

For detailed setup instructions, see individual folder READMEs.

---

## 🤝 Contributing

We love contributions! Whether it's features, bug fixes, or improvements—feel free to fork, branch, and submit a PR.

---

## 📄 License

This project is licensed under the MIT License — see the LICENSE file for details.

---

## 🎉 The Future of Group Travel Planning

**TripBond** isn't just another travel app. It's the end of group travel chaos.

Start planning smarter trips today. ✈️

---

*Built with ❤️ for travelers who actually enjoy planning together.*
**Database**: Supabase (PostgreSQL with RLS)

### AI
- Random Forest (preference prediction)
- Decision Trees (explainability)
- Genetic Algorithm (itinerary optimization)
- Collaborative Filtering (learning)

### External APIs
- Google Places
- Foursquare
- Geoapify
- TomTom

### Infrastructure
- Docker
- WebSockets (chat)
- PowerShell automation scripts

---

## System Architecture

### Backend Services
- AI recommendation engine
- Itinerary generation
- Authentication and security
- Notifications and email
- External API integrations

### Frontend Services
- Trip management
- Chat and messaging
- POI exploration and maps
- AI interaction layer
- State management

---

## Project Structure

```
tripbond-app/
├── backend/              # FastAPI backend
├── tripbond_ai_backend/  # AI/ML service
├── frontend/             # Flutter app
└── test_*.py             # Tests
```

---

## Database Overview

**Core tables**:
- profiles
- trips
- trip_members
- personality_scores
- user_preferences
- suggestions + voting
- chat (messages & conversations)
- feedback

Includes Supabase Row-Level Security (RLS)

---

## Quick Start

### One-Command Setup (Windows)

```powershell
.\start-dev.ps1
.\start-full-stack.ps1
```

### Manual Setup

**Backend**
```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python run_migration.py
uvicorn app.main:app --reload
```

**Frontend**
```bash
cd frontend
flutter pub get
flutter run
```

**AI Backend** (optional)
```bash
cd tripbond_ai_backend
python run_ai.py
```

---

## API Documentation

**Swagger**: http://localhost:8000/docs
**ReDoc**: http://localhost:8000/redoc

---

## Testing

```bash
pytest
flutter test
```

---

## Roadmap

- Companion matching (AI bonding system)
- Real-time itinerary updates
- Expense splitting
- Payment integration
- Interactive maps

---

## Contributing

1. Fork the repo
2. Create branch (feature/name)
3. Commit changes
4. Open Pull Request

---

## Team

- Jory Alshathri
- Ghala Alroumaih
- Dana Alanzi
- Basmah Aljishi
- Hawaraa Aljanabi

---

## License

Academic and research use only.

---

**Time to Bond!**

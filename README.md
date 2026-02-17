# TripBond

Group travel planning app with AI recommendations.

## What's in here

Backend is Python FastAPI talking to Supabase (PostgreSQL). Flutter app coming soon.

```
TripBond/
├── backend/
│   ├── app/
│   │   ├── routers/     # auth endpoints
│   │   ├── config.py
│   │   ├── database.py
│   │   └── main.py
│   ├── requirements.txt
│   └── run.py
└── README.md
```

## Running it

```bash
cd backend
pip install -r requirements.txt

# edit .env with your Supabase credentials

python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

API docs: http://127.0.0.1:8000/docs

## What works right now

Authentication stuff - signup, signin, password reset. Creates user profiles in Supabase with travel preferences and personality traits.

## Database tables

Using existing Supabase setup with profiles, trips, trip_members, itineraries, personality_answers, votes, ratings, and a bunch more for social features.

## TODO

- Test the auth endpoints
- Build the Flutter UI
- Add trip planning features
- Wire up the AI recommendation stuff

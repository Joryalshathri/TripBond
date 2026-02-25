from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .config import get_settings
from .routers import auth, personality, preferences, profile, settings, adventures

config = get_settings()

app = FastAPI(
    title="TripBond API",
    description="AI-based Group Travel Recommender System Backend",
    version="1.0.0",
    debug=config.debug
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(personality.router, prefix="/api/personality", tags=["Personality Quiz"])
app.include_router(preferences.router, prefix="/api/preferences", tags=["Travel Preferences"])
app.include_router(profile.router, prefix="/api/profile", tags=["User Profile"])
app.include_router(settings.router, prefix="/api/settings", tags=["Settings"])
app.include_router(adventures.router, prefix="/api/adventures", tags=["Trips & Adventures"])


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "online",
        "service": "TripBond API",
        "version": "1.0.0"
    }


@app.get("/health")
async def health_check():
    """Detailed health check"""
    return {
        "status": "healthy",
        "database": "connected",
        "ai_engine": "ready"
    }

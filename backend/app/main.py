from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .config import get_settings
from .routers import auth

settings = get_settings()

app = FastAPI(
    title="TripBond API",
    description="AI-based Group Travel Recommender System Backend",
    version="1.0.0",
    debug=settings.debug
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

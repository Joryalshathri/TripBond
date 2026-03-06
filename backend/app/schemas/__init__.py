"""
Schemas - Pydantic Models

Request/response validation models for all API endpoints.
"""
from . import auth, profile, preferences, personality, group, pois, feedback, settings, trips, favorites

__all__ = [
    "auth",
    "profile",
    "preferences",
    "personality",
    "group",
    "pois",
    "feedback",
    "settings",
    "trips",
    "favorites",
]
"""API Router modules for TripBond backend."""

from . import auth, personality, preferences, trips, group, feedback, users, pois, favorites

__all__ = [
    "auth",
    "personality",
    "preferences",
    "trips",
    "users",
    "favorites",
    "pois",
    "group",
    "feedback",
]

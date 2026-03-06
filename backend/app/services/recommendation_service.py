"""
Recommendation Service

Handles POI (Point of Interest) scoring and recommendation logic.
Uses preferences, trip context, and ratings to score locations.
"""
from typing import Optional
import logging

logger = logging.getLogger(__name__)

# Scoring weights (adjustable parameters)
RATING_W = 0.2      # POI rating contribution
TYPE_W = 0.15       # Trip type alignment
PREF_W = 0.1        # Activity preference matching
BUDGET_W = 0.1      # Budget compatibility


def calculate_poi_score(
    poi: dict, 
    preferences: dict, 
    trip: dict
) -> tuple[float, str]:
    """
    Calculate relevance score for a POI based on preferences and trip context.
    
    Scoring factors:
    - Base rating (from POI data)
    - Trip type alignment (adventure, cultural, relaxing, etc.)
    - User preference matching
    - Budget compatibility
    
    Args:
        poi: POI data (name, type, tags, rating, price_level, etc.)
        preferences: User/group preferences
        trip: Trip data (type, budget, etc.)
    
    Returns:
        tuple: (score: float [0-1], reason: str)
    
    Future improvements:
    - Add distance/proximity scoring
    - Incorporate opening hours compatibility
    - Use ML model for scoring (Random Forest, etc.)
    - Learn from user selections (collaborative filtering)
    """
    # Normalize preferences to handle None safely
    preferences = preferences or {}
    
    base_score = 0.5
    reason_parts = []
    
    # Factor 1: POI rating
    if poi.get("rating"):
        rating_contribution = (poi["rating"] / 5.0) * RATING_W
        base_score += rating_contribution
    
    # Factor 2: Trip type alignment
    trip_type = trip.get("trip_type", "").lower()
    poi_type = poi.get("poi_type", "").lower()
    raw_tags = poi.get("tags") or []
    poi_tags = [str(t).lower() for t in raw_tags]
    
    if trip_type in ["adventure", "outdoor"] and poi_type in ["activity", "attraction"]:
        base_score += TYPE_W
        reason_parts.append("matches adventure preferences")
    elif trip_type in ["relaxing", "beach"] and poi_type in ["restaurant", "accommodation"]:
        base_score += TYPE_W
        reason_parts.append("suitable for relaxing trip")
    elif trip_type == "cultural" and ("museum" in poi_tags or "historical" in poi_tags):
        base_score += TYPE_W
        reason_parts.append("cultural significance")
    
    # Factor 3: Activity preferences matching
    if preferences:
        activity_prefs = preferences.get("activities", {})
        for pref_key, pref_value in activity_prefs.items():
            pref_key_l = str(pref_key).lower()
            if pref_key_l in poi_tags or pref_key_l == poi_type:
                # Safely convert and clamp preference value to 0.0-1.0 range
                try:
                    v = float(pref_value)
                except (TypeError, ValueError):
                    v = 0.0
                v = max(0.0, min(v, 1.0))  # assume weights are 0..1
                base_score += v * PREF_W
                reason_parts.append(f"high preference for {pref_key}")
    
    # Factor 4: Budget compatibility
    if preferences.get("budget") and poi.get("price_level"):
        budget_level = preferences["budget"]
        if poi["price_level"] <= budget_level:
            base_score += BUDGET_W
            reason_parts.append("within budget")
    
    # Build explanation
    reason = (
        "Based on " + ", ".join(reason_parts) 
        if reason_parts 
        else "Popular destination"
    )
    
    # Cap score at 1.0
    return min(base_score, 1.0), reason


def rank_recommendations(
    pois: list[dict], 
    preferences: dict, 
    trip: dict, 
    limit: int = 20
) -> list[tuple[dict, float, str]]:
    """
    Score and rank multiple POIs.
    
    Args:
        pois: List of POI data
        preferences: User/group preferences
        trip: Trip context
        limit: Maximum number of recommendations to return
    
    Returns:
        list: Tuples of (poi, score, reason) sorted by score descending
    """
    scored_pois = []
    
    for poi in pois:
        score, reason = calculate_poi_score(poi, preferences, trip)
        scored_pois.append((poi, score, reason))
    
    # Sort by score descending
    scored_pois.sort(key=lambda x: x[1], reverse=True)
    
    return scored_pois[:limit]

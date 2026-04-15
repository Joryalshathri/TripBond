"""
AI POI Service - Integration with TripBond AI Backend Dataset + Google Places Photo Enrichment

Combines:
1. Primary: Pre-trained AI recommendations from CSV datasets
2. Enrichment: Google Places API for photos and nearby place matching
"""

import pandas as pd
import logging
import requests
from pathlib import Path
from typing import List, Optional, Dict
from app.config import get_settings

logger = logging.getLogger(__name__)

# Paths to AI backend datasets
AI_BACKEND_ROOT = Path(__file__).parent.parent.parent.parent / "tripbond_ai_backend"
DATA_DIR = AI_BACKEND_ROOT / "data"

# Cache datasets in memory
_pois_cache = None
_group_recs_cache = None

# Initialize PLACES_BASE_URL for photo URL construction
PLACES_BASE_URL = "https://maps.googleapis.com/maps/api/place"


def _load_poi_dataset() -> Optional[pd.DataFrame]:
    """Load integrated POI dataset."""
    global _pois_cache
    if _pois_cache is not None:
        return _pois_cache
    
    try:
        poi_file = DATA_DIR / "final_integrated_poi_dataset.csv"
        if not poi_file.exists():
            logger.warning(f"POI dataset not found at {poi_file}")
            return None
        
        _pois_cache = pd.read_csv(poi_file)
        logger.info(f"Loaded {len(_pois_cache)} POIs from AI backend dataset")
        return _pois_cache
    except Exception as e:
        logger.error(f"Failed to load POI dataset: {e}")
        return None


def _load_group_recommendations() -> Optional[pd.DataFrame]:
    """Load group-recommended POIs."""
    global _group_recs_cache
    if _group_recs_cache is not None:
        return _group_recs_cache
    
    try:
        recs_file = DATA_DIR / "top_pois_for_group.csv"
        if not recs_file.exists():
            logger.warning(f"Group recommendations not found at {recs_file}")
            return None
        
        _group_recs_cache = pd.read_csv(recs_file)
        logger.info(f"Loaded {len(_group_recs_cache)} group recommendations from AI backend")
        return _group_recs_cache
    except Exception as e:
        logger.error(f"Failed to load group recommendations: {e}")
        return None


def _enrich_with_photos(poi: Dict, lat: Optional[float], lng: Optional[float]) -> Dict:
    """
    Enrich a POI with photos from Google Places API (Foursquare backup).
    
    Args:
        poi: POI dictionary from CSV
        lat: Latitude for photo lookup
        lng: Longitude for photo lookup
    
    Returns:
        Enhanced POI dictionary with photo data
    """
    settings = get_settings()
    poi_name = poi.get('name', 'Unknown')
    
    # Only skip if coordinates are NONE/NaN, not if they're 0
    if lat is None or lng is None:
        logger.debug(f"Skipping enrichment for {poi_name}: lat={lat}, lng={lng}")
        return poi
    
    # Try to Google Photos API using nearby search
    if settings.google_maps_api_key:
        try:
            from .google_places_service import nearby_search_places
            
            # Search for nearby places matching our POI
            results = nearby_search_places(
                lat=lat,
                lng=lng,
                radius=500,  # 500m radius for nearby match
                keyword=poi_name,
                language='en'
            )
            
            if results and results.results:
                google_place = results.results[0]
                
                photo_data = {
                    "photo_url": None,
                }
                
                # Get photos from Google Places
                if google_place.photos:
                    first_photo = google_place.photos[0]
                    # Build Google photo URL with correct parameter name
                    photo_data["photo_url"] = f"{PLACES_BASE_URL}/photo?maxwidth=800&photo_reference={first_photo.photo_reference}&key={settings.google_maps_api_key}"
                    logger.info(f"✅ Enriched {poi_name} with Google Places photo")
                else:
                    logger.debug(f"Google Places found {poi_name} but no photos")
                
                poi.update(photo_data)
                return poi
            else:
                logger.debug(f"No Google Places results near {poi_name}: ({lat}, {lng})")
                
        except Exception as e:
            logger.debug(f"Google Places enrichment failed for {poi_name}: {e}")
    
    # No enrichment available
    return poi


def get_pois_for_destination(destination: str, limit: int = 15) -> List[Dict]:
    """
    Get POIs for a destination from the AI backend dataset, enriched with Foursquare.
    
    Args:
        destination: City or destination name
        limit: Number of POIs to return
    
    Returns:
        List of POI dictionaries with CSV data + Foursquare enrichment
    """
    pois_df = _load_poi_dataset()
    if pois_df is None:
        logger.warning("POI dataset unavailable")
        return []
    
    # Filter by city (case-insensitive)
    dest_lower = destination.lower()
    matching = pois_df[pois_df['city'].str.lower() == dest_lower]
    
    if matching.empty:
        # Fallback: search in name or description
        pattern = f".*{dest_lower}.*"
        matching = pois_df[
            (pois_df['city'].str.lower().str.contains(dest_lower, na=False)) |
            (pois_df['name'].str.lower().str.contains(dest_lower, na=False))
        ]
    
    if matching.empty:
        logger.warning(f"No POIs found for destination: {destination}")
        return []
    
    # Convert to output format and enrich with Foursquare
    result = []
    for _, row in matching.head(limit).iterrows():
        poi = {
            "id": str(row.get('poi_id', '')),
            "name": str(row.get('name', 'Unknown')),
            "location": str(row.get('city', destination)),
            "type": str(row.get('category', 'attraction')),
            "rating": float(row.get('rating', 4.0)),
            "description": str(row.get('description', '')),
            "latitude": float(row.get('latitude', 0)) if pd.notna(row.get('latitude')) else None,
            "longitude": float(row.get('longitude', 0)) if pd.notna(row.get('longitude')) else None,
            "review_count": int(row.get('review_count', 0)) if pd.notna(row.get('review_count')) else 0,
            "opening_hours": str(row.get('opening_hours', '')),
            "province": str(row.get('province', '')),
        }
        
        # Enrich with photos (Google Places API)
        poi = _enrich_with_photos(poi, poi["latitude"], poi["longitude"])
        
        result.append(poi)
    
    logger.info(f"Loaded {len(result)} POIs from AI backend for {destination} (with Foursquare enrichment)")
    return result


def get_recommended_pois(limit: int = 20) -> List[Dict]:
    """
    Get the AI-recommended top POIs from the group recommender, enriched with Foursquare.
    
    Returns:
        List of recommended POI dictionaries with Foursquare enrichment
    """
    group_recs = _load_group_recommendations()
    pois_df = _load_poi_dataset()
    
    if group_recs is None or pois_df is None:
        logger.warning("Cannot load recommended POIs")
        return []
    
    # Get top N by final_group_score
    top_recs = group_recs.nlargest(limit, 'final_group_score')
    
    result = []
    for _, rec in top_recs.iterrows():
        poi_id = rec.get('poi_id')
        
        # Find matching POI details
        poi_details = pois_df[pois_df['poi_id'] == poi_id]
        
        if poi_details.empty:
            # Fallback: create record from recommendations row
            poi = {
                "id": str(poi_id),
                "name": f"POI {poi_id}",
                "location": "Multiple",
                "type": str(rec.get('poi_category', 'attraction')),
                "rating": float(rec.get('poi_normalized_rating', 4.0)),
                "latitude": float(rec.get('poi_latitude', 0)) if pd.notna(rec.get('poi_latitude')) else None,
                "longitude": float(rec.get('poi_longitude', 0)) if pd.notna(rec.get('poi_longitude')) else None,
                "group_score": float(rec.get('final_group_score', 0)),
                "fairness_score": float(rec.get('fairness_score', 0)),
            }
        else:
            poi_row = poi_details.iloc[0]
            poi = {
                "id": str(poi_id),
                "name": str(poi_row.get('name', 'Unknown')),
                "location": str(poi_row.get('city', 'Multiple')),
                "type": str(poi_row.get('category', 'attraction')),
                "rating": float(poi_row.get('rating', 4.0)),
                "description": str(poi_row.get('description', '')),
                "latitude": float(poi_row.get('latitude', 0)) if pd.notna(poi_row.get('latitude')) else None,
                "longitude": float(poi_row.get('longitude', 0)) if pd.notna(poi_row.get('longitude')) else None,
                "group_score": float(rec.get('final_group_score', 0)),
                "fairness_score": float(rec.get('fairness_score', 0)),
            }
        
        # Enrich with Foursquare data
        poi = _enrich_with_foursquare(poi, poi.get("latitude"), poi.get("longitude"))
        result.append(poi)
    
    return result


def search_pois(query: str, limit: int = 20) -> List[Dict]:
    """
    Search POIs by name or description, enriched with Foursquare.
    
    Args:
        query: Search query
        limit: Number of results
    
    Returns:
        List of matching POIs with Foursquare enrichment
    """
    pois_df = _load_poi_dataset()
    if pois_df is None:
        return []
    
    query_lower = query.lower()
    
    # Search in name and description
    matching = pois_df[
        (pois_df['name'].str.lower().str.contains(query_lower, na=False)) |
        (pois_df['description'].str.lower().str.contains(query_lower, na=False)) |
        (pois_df['category'].str.lower().str.contains(query_lower, na=False))
    ]
    
    result = []
    for _, row in matching.head(limit).iterrows():
        poi = {
            "id": str(row.get('poi_id', '')),
            "name": str(row.get('name', 'Unknown')),
            "location": str(row.get('city', '')),
            "type": str(row.get('category', 'attraction')),
            "rating": float(row.get('rating', 4.0)),
            "description": str(row.get('description', '')),
            "latitude": float(row.get('latitude', 0)) if pd.notna(row.get('latitude')) else None,
            "longitude": float(row.get('longitude', 0)) if pd.notna(row.get('longitude')) else None,
        }
        
        # Enrich with Foursquare
        poi = _enrich_with_foursquare(poi, poi.get("latitude"), poi.get("longitude"))
        result.append(poi)
    
    return result

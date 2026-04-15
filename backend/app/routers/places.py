"""
Google Places & Places Router

Exposes Google Places API endpoints consumed by the TripBond app:
  GET /api/places/search          – text/fuzzy search (destination search bar)
  GET /api/places/nearby          – nearby places search (proximity search)
  GET /api/places/details/{id}    – full place details
  GET /api/places/photo-url       – photo URL helper
"""

from fastapi import APIRouter, Query
from typing import Optional
from ..schemas.places import PlacesSearchResponse, PlaceDetailsResponse
from ..services import google_places_service

router = APIRouter()


@router.get("/search", response_model=PlacesSearchResponse)
async def search_places(
    q: str = Query(..., description="Free-text search query, e.g. 'beaches in Bali'"),
    lat: Optional[float] = Query(None, description="Optional latitude for spatial biasing"),
    lng: Optional[float] = Query(None, description="Optional longitude for spatial biasing"),
    language: str = Query("en", description="BCP-47 language code for results"),
    limit: int = Query(20, ge=1, le=100, description="Max results to return (1-100)"),
):
    """
    Free-text/Fuzzy search using Google Places Text Search API.
    Ideal for the homepage destination search bar.
    Returns up to 20 results per call.
    """
    return google_places_service.text_search_places(
        query=q,
        language=language,
    )


@router.get("/nearby", response_model=PlacesSearchResponse)
async def nearby_places(
    lat: float = Query(..., description="Latitude of the search centre"),
    lng: float = Query(..., description="Longitude of the search centre"),
    radius: int = Query(5000, ge=100, le=50000, description="Search radius in metres (min 100, max 50000)"),
    q: Optional[str] = Query(None, description="Keyword to filter results (e.g., 'restaurants')"),
    language: str = Query("en", description="BCP-47 language code for results"),
    limit: int = Query(20, ge=1, le=100, description="Max results to return (1-100)"),
):
    """
    Search for places near a coordinate using Google Places Nearby Search API.
    Ideal for the 'Explore Nearby' homepage section.
    Returns up to 20 results per call.
    """
    return google_places_service.nearby_search_places(
        lat=lat,
        lng=lng,
        radius=radius,
        keyword=q,
        language=language,
    )


@router.get("/details/{place_id}", response_model=PlaceDetailsResponse)
async def get_place_details(
    place_id: str,
    language: str = Query("en", description="BCP-47 language code for results"),
):
    """
    Retrieve full details for a Google Places location using its place_id.
    Includes photos, ratings, phone number, website, and opening hours.
    """
    return google_places_service.get_place_details(
        place_id=place_id,
        language=language,
    )


@router.get("/photo-url")
async def get_photo_url(
    photo_reference: str = Query(..., description="Photo reference from Google Places API"),
    max_width: int = Query(800, ge=100, le=1600, description="Maximum image width in pixels"),
):
    """
    Return a photo URL that can be used directly in <img src>.
    For Google Places, constructs the complete photo endpoint URL.
    """
    url = google_places_service.get_photo_url(
        photo_reference=photo_reference,
        max_width=max_width,
    )
    return {"photo_url": url}

"""
TomTom Search & Places Router

Exposes TomTom Search API endpoints consumed by the TripBond app:
  GET /api/places/search          – text/fuzzy search (destination search bar)
  GET /api/places/nearby          – nearby places search (proximity search)
  GET /api/places/details/{id}    – full place details
  GET /api/places/photo-url       – photo URL helper
"""

from fastapi import APIRouter, Query
from typing import Optional
from ..schemas.places import PlacesSearchResponse, PlaceDetailsResponse
from ..services import tomtom_service

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
    Free-text/Fuzzy search using TomTom Search API.
    Ideal for the homepage destination search bar.
    Optionally biased by coordinates if provided.
    Returns up to 100 results per call.
    """
    return tomtom_service.text_search_places(
        query=q,
        language=language,
        lat=lat,
        lng=lng,
        limit=limit,
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
    Search for places near a coordinate using TomTom Nearby Search API.
    Ideal for the 'Explore Nearby' homepage section.
    Returns up to 100 results per call.
    """
    return tomtom_service.nearby_search_places(
        lat=lat,
        lng=lng,
        radius=radius,
        keyword=q,
        language=language,
        limit=limit,
    )


@router.get("/details/{place_id}", response_model=PlaceDetailsResponse)
async def get_place_details(
    place_id: str,
    language: str = Query("en", description="BCP-47 language code for results"),
    latitude: Optional[float] = Query(None, description="Original latitude for fallback matching"),
    longitude: Optional[float] = Query(None, description="Original longitude for fallback matching"),
    country: Optional[str] = Query(None, description="Country code (e.g., 'SA') for filtering"),
    fallback_name: Optional[str] = Query(None, description="Place name to use for fallback search"),
):
    """
    Retrieve full details for a TomTom place using its entity ID.
    
    If direct lookup fails, uses intelligent fallback:
    - Searches by name with geographic context (lat/lng)
    - Filters by country code if provided
    - Matches closest result by coordinates
    - Returns original data if no accurate match found
    
    This ensures that searching for "Ithra" in Dhahran, SA returns 
    the correct location instead of "Ithra Tower" from Dubai.
    """
    return tomtom_service.get_place_details(
        entity_id=place_id,
        language=language,
        latitude=latitude,
        longitude=longitude,
        country=country,
        fallback_name=fallback_name,
    )


@router.get("/photo-url")
async def get_photo_url(
    photo_reference: str = Query(..., description="Photo URL or reference from TomTom place details"),
    max_width: int = Query(800, ge=100, le=1600, description="Maximum image width in pixels"),
):
    """
    Return a photo URL that can be used directly in <img src>.
    For TomTom, the photo_reference is typically already a full URL.
    """
    url = tomtom_service.get_photo_url(
        photo_reference=photo_reference,
        max_width=max_width,
    )
    return {"photo_url": url}

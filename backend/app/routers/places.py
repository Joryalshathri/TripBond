"""
Google Places Router

Exposes Google Places API endpoints consumed by the TripBond homepage:
  GET /api/places/search          – text search (destination search bar)
  GET /api/places/nearby          – nearby places search
  GET /api/places/details/{id}    – full place details
  GET /api/places/photo-url       – build a photo URL for a given photo_reference
"""

from fastapi import APIRouter, Query
from typing import Optional
from ..schemas.places import PlacesSearchResponse, PlaceDetailsResponse
from ..services import google_places_service

router = APIRouter()


@router.get("/search", response_model=PlacesSearchResponse)
async def search_places(
    query: str = Query(..., description="Free-text search query, e.g. 'beaches in Bali'"),
    language: str = Query("en", description="BCP-47 language code for results"),
    next_page_token: Optional[str] = Query(None, description="Pagination token from a previous response"),
):
    """
    Text-search Google Places.
    Intended for the homepage destination search bar.
    Returns up to 20 results per call; use next_page_token for subsequent pages.
    """
    return google_places_service.text_search_places(
        query=query,
        language=language,
        next_page_token=next_page_token,
    )


@router.get("/nearby", response_model=PlacesSearchResponse)
async def nearby_places(
    lat: float = Query(..., description="Latitude of the search centre"),
    lng: float = Query(..., description="Longitude of the search centre"),
    radius: int = Query(5000, ge=1, le=50000, description="Search radius in metres (max 50 000)"),
    type: Optional[str] = Query(None, description="Google place type, e.g. 'tourist_attraction'"),
    keyword: Optional[str] = Query(None, description="Keyword to filter results"),
    language: str = Query("en", description="BCP-47 language code for results"),
    next_page_token: Optional[str] = Query(None, description="Pagination token from a previous response"),
):
    """
    Search for places near a coordinate.
    Ideal for the 'Explore Nearby' homepage section.
    Returns up to 20 results per call.
    """
    return google_places_service.nearby_search_places(
        lat=lat,
        lng=lng,
        radius=radius,
        place_type=type,
        keyword=keyword,
        language=language,
        next_page_token=next_page_token,
    )


@router.get("/details/{place_id}", response_model=PlaceDetailsResponse)
async def get_place_details(
    place_id: str,
    language: str = Query("en", description="BCP-47 language code for results"),
):
    """
    Retrieve full details for a Google Places place_id.
    Includes contact info, opening hours, photos, website, and more.
    """
    return google_places_service.get_place_details(place_id=place_id, language=language)


@router.get("/photo-url")
async def get_photo_url(
    photo_reference: str = Query(..., description="photo_reference string from a PlacePhoto object"),
    max_width: int = Query(800, ge=100, le=1600, description="Maximum image width in pixels"),
):
    """
    Return the URL to fetch a place photo directly from Google.
    The frontend can use this URL as an <img src> value.
    """
    url = google_places_service.get_photo_url(
        photo_reference=photo_reference,
        max_width=max_width,
    )
    return {"photo_url": url}

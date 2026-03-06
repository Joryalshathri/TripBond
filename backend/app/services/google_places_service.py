"""
Google Places Service

Wraps the Google Places API (Text Search, Nearby Search, Place Details)
for use on the TripBond homepage and POI discovery features.

Requires GOOGLE_MAPS_API_KEY to be set in the environment / .env file.
"""

import httpx
import logging
from fastapi import HTTPException, status
from typing import Optional
from ..config import get_settings
from ..schemas.places import (
    PlacesSearchResponse,
    PlaceDetailsResponse,
    PlaceResult,
    PlaceDetailsResult,
    PlaceGeometry,
    PlacePhoto,
    PlaceOpeningHours,
)

logger = logging.getLogger(__name__)

PLACES_BASE_URL = "https://maps.googleapis.com/maps/api/place"


def _get_api_key() -> str:
    """Return the configured Google Maps API key or raise 503."""
    key = get_settings().google_maps_api_key
    if not key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Google Maps API key is not configured. Set GOOGLE_MAPS_API_KEY in your environment.",
        )
    return key


def _parse_place_result(place: dict) -> PlaceResult:
    """Convert a raw Google Places result dict into a PlaceResult schema."""
    geo = place.get("geometry", {}).get("location")
    geometry = PlaceGeometry(lat=geo["lat"], lng=geo["lng"]) if geo else None

    photos = [
        PlacePhoto(
            photo_reference=p["photo_reference"],
            height=p.get("height", 0),
            width=p.get("width", 0),
        )
        for p in place.get("photos", [])
    ]

    opening = place.get("opening_hours")
    opening_hours = PlaceOpeningHours(open_now=opening.get("open_now")) if opening else None

    return PlaceResult(
        place_id=place["place_id"],
        name=place.get("name", ""),
        formatted_address=place.get("formatted_address"),
        vicinity=place.get("vicinity"),
        geometry=geometry,
        rating=place.get("rating"),
        user_ratings_total=place.get("user_ratings_total"),
        price_level=place.get("price_level"),
        types=place.get("types", []),
        opening_hours=opening_hours,
        photos=photos,
        icon=place.get("icon"),
        business_status=place.get("business_status"),
    )


def text_search_places(
    query: str,
    language: str = "en",
    next_page_token: Optional[str] = None,
) -> PlacesSearchResponse:
    """
    Search Google Places using a free-text query.
    Ideal for homepage destination search bar.

    Args:
        query: Free-text search string, e.g. "restaurants in Paris".
        language: BCP-47 language code for results.
        next_page_token: Token returned by a previous search to get the next page.

    Returns:
        PlacesSearchResponse with up to 20 results per page.
    """
    api_key = _get_api_key()
    params: dict = {
        "query": query,
        "language": language,
        "key": api_key,
    }
    if next_page_token:
        params["pagetoken"] = next_page_token

    try:
        with httpx.Client(timeout=10.0) as client:
            resp = client.get(f"{PLACES_BASE_URL}/textsearch/json", params=params)
            resp.raise_for_status()
            data = resp.json()
    except httpx.HTTPError as exc:
        logger.error("Google Places text search failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Google Places API request failed: {exc}",
        )

    google_status = data.get("status", "UNKNOWN_ERROR")
    if google_status not in ("OK", "ZERO_RESULTS"):
        logger.warning("Google Places API returned status: %s", google_status)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Google Places API error: {google_status}",
        )

    return PlacesSearchResponse(
        results=[_parse_place_result(p) for p in data.get("results", [])],
        next_page_token=data.get("next_page_token"),
        status=google_status,
    )


def nearby_search_places(
    lat: float,
    lng: float,
    radius: int = 5000,
    place_type: Optional[str] = None,
    keyword: Optional[str] = None,
    language: str = "en",
    next_page_token: Optional[str] = None,
) -> PlacesSearchResponse:
    """
    Search for places near a geographic coordinate.
    Ideal for "Explore Nearby" homepage section.

    Args:
        lat: Latitude of the search centre.
        lng: Longitude of the search centre.
        radius: Search radius in metres (max 50 000).
        place_type: Optional Google place type, e.g. "tourist_attraction".
        keyword: Optional keyword to filter results.
        language: BCP-47 language code for results.
        next_page_token: Pagination token from a previous response.

    Returns:
        PlacesSearchResponse with up to 20 results per page.
    """
    api_key = _get_api_key()
    params: dict = {
        "location": f"{lat},{lng}",
        "radius": min(radius, 50000),
        "language": language,
        "key": api_key,
    }
    if place_type:
        params["type"] = place_type
    if keyword:
        params["keyword"] = keyword
    if next_page_token:
        params["pagetoken"] = next_page_token

    try:
        with httpx.Client(timeout=10.0) as client:
            resp = client.get(f"{PLACES_BASE_URL}/nearbysearch/json", params=params)
            resp.raise_for_status()
            data = resp.json()
    except httpx.HTTPError as exc:
        logger.error("Google Places nearby search failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Google Places API request failed: {exc}",
        )

    google_status = data.get("status", "UNKNOWN_ERROR")
    if google_status not in ("OK", "ZERO_RESULTS"):
        logger.warning("Google Places API returned status: %s", google_status)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Google Places API error: {google_status}",
        )

    return PlacesSearchResponse(
        results=[_parse_place_result(p) for p in data.get("results", [])],
        next_page_token=data.get("next_page_token"),
        status=google_status,
    )


def get_place_details(place_id: str, language: str = "en") -> PlaceDetailsResponse:
    """
    Retrieve full details for a single place by its place_id.

    Args:
        place_id: The Google place_id string.
        language: BCP-47 language code for results.

    Returns:
        PlaceDetailsResponse with comprehensive place information.
    """
    api_key = _get_api_key()
    fields = (
        "place_id,name,formatted_address,formatted_phone_number,"
        "international_phone_number,website,geometry,rating,"
        "user_ratings_total,price_level,types,opening_hours,photos,"
        "url,editorial_summary"
    )
    params: dict = {
        "place_id": place_id,
        "fields": fields,
        "language": language,
        "key": api_key,
    }

    try:
        with httpx.Client(timeout=10.0) as client:
            resp = client.get(f"{PLACES_BASE_URL}/details/json", params=params)
            resp.raise_for_status()
            data = resp.json()
    except httpx.HTTPError as exc:
        logger.error("Google Places details request failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Google Places API request failed: {exc}",
        )

    google_status = data.get("status", "UNKNOWN_ERROR")
    if google_status != "OK":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND if google_status == "NOT_FOUND" else status.HTTP_502_BAD_GATEWAY,
            detail=f"Google Places API error: {google_status}",
        )

    place = data.get("result", {})
    geo = place.get("geometry", {}).get("location")
    geometry = PlaceGeometry(lat=geo["lat"], lng=geo["lng"]) if geo else None

    photos = [
        PlacePhoto(
            photo_reference=p["photo_reference"],
            height=p.get("height", 0),
            width=p.get("width", 0),
        )
        for p in place.get("photos", [])
    ]

    editorial = place.get("editorial_summary", {})

    result = PlaceDetailsResult(
        place_id=place.get("place_id", place_id),
        name=place.get("name", ""),
        formatted_address=place.get("formatted_address"),
        formatted_phone_number=place.get("formatted_phone_number"),
        international_phone_number=place.get("international_phone_number"),
        website=place.get("website"),
        geometry=geometry,
        rating=place.get("rating"),
        user_ratings_total=place.get("user_ratings_total"),
        price_level=place.get("price_level"),
        types=place.get("types", []),
        opening_hours=place.get("opening_hours"),
        photos=photos,
        url=place.get("url"),
        editorial_summary=editorial.get("overview") if isinstance(editorial, dict) else None,
    )

    return PlaceDetailsResponse(result=result, status=google_status)


def get_photo_url(photo_reference: str, max_width: int = 800) -> str:
    """
    Build a direct URL to fetch a place photo from Google.

    Args:
        photo_reference: The photo_reference string from a PlacePhoto.
        max_width: Maximum width of the returned image in pixels.

    Returns:
        A URL string that resolves to the photo image.
    """
    api_key = _get_api_key()
    return (
        f"{PLACES_BASE_URL}/photo"
        f"?maxwidth={max_width}"
        f"&photo_reference={photo_reference}"
        f"&key={api_key}"
    )

"""
Google Places Schemas

Pydantic models for Google Places API responses exposed via the /api/places routes.
"""
from pydantic import BaseModel
from typing import List, Optional


class PlaceGeometry(BaseModel):
    lat: float
    lng: float


class PlacePhoto(BaseModel):
    photo_reference: str
    height: int
    width: int


class PlaceOpeningHours(BaseModel):
    open_now: Optional[bool] = None


class PlaceResult(BaseModel):
    place_id: str
    name: str
    formatted_address: Optional[str] = None
    vicinity: Optional[str] = None
    geometry: Optional[PlaceGeometry] = None
    rating: Optional[float] = None
    user_ratings_total: Optional[int] = None
    price_level: Optional[int] = None
    types: List[str] = []
    opening_hours: Optional[PlaceOpeningHours] = None
    photos: List[PlacePhoto] = []
    icon: Optional[str] = None
    business_status: Optional[str] = None


class PlacesSearchResponse(BaseModel):
    results: List[PlaceResult]
    next_page_token: Optional[str] = None
    status: str


class PlaceDetailsResult(BaseModel):
    place_id: str
    name: str
    formatted_address: Optional[str] = None
    formatted_phone_number: Optional[str] = None
    international_phone_number: Optional[str] = None
    website: Optional[str] = None
    geometry: Optional[PlaceGeometry] = None
    rating: Optional[float] = None
    user_ratings_total: Optional[int] = None
    price_level: Optional[int] = None
    types: List[str] = []
    opening_hours: Optional[dict] = None
    photos: List[PlacePhoto] = []
    url: Optional[str] = None
    editorial_summary: Optional[str] = None


class PlaceDetailsResponse(BaseModel):
    result: PlaceDetailsResult
    status: str

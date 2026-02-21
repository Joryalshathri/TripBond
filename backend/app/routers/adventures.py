from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List, Optional
from datetime import date, datetime
from ..database import SupabaseDB

router = APIRouter()


class TripResponse(BaseModel):
    id: str
    created_by: str  # UUID of the user who created the trip
    title: str
    destination: str
    location: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    trip_type: Optional[str] = None  # 'family', 'business', 'relaxing', etc.
    description: Optional[str] = None
    image_url: Optional[str] = None
    is_public: Optional[bool] = True
    created_at: Optional[str] = None


class CreateTripRequest(BaseModel):
    created_by: str  # UUID of the user creating the trip
    title: str
    destination: str
    location: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    trip_type: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    is_public: Optional[bool] = True


class FavoriteResponse(BaseModel):
    id: str
    user_id: str
    trip_id: Optional[str] = None
    destination_name: Optional[str] = None
    destination_type: Optional[str] = None  # 'trip', 'location', 'activity'
    created_at: Optional[str] = None


class AddFavoriteRequest(BaseModel):
    user_id: str
    trip_id: Optional[str] = None
    destination_name: Optional[str] = None
    destination_type: Optional[str] = None


@router.get("/trips/{user_id}", response_model=List[TripResponse])
async def get_user_trips(user_id: str):
    """
    Get all trips for a user (their adventures)
    """
    try:
        db = SupabaseDB()
        
        response = db.client.table("trips").select("*").eq("created_by", user_id).order("created_at", desc=True).execute()
        
        if not response.data:
            return []
        
        trips = []
        for trip in response.data:
            trips.append(TripResponse(
                id=trip["id"],
                created_by=trip["created_by"],
                title=trip.get("title", ""),
                destination=trip.get("destination", ""),
                location=trip.get("location"),
                start_date=trip.get("start_date"),
                end_date=trip.get("end_date"),
                trip_type=trip.get("trip_type"),
                description=trip.get("description"),
                image_url=trip.get("image_url"),
                is_public=trip.get("is_public", True),
                created_at=trip.get("created_at")
            ))
        
        return trips
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get trips: {str(e)}"
        )


@router.get("/trips/detail/{trip_id}", response_model=TripResponse)
async def get_trip_detail(trip_id: str):
    """
    Get detailed information about a specific trip
    """
    try:
        db = SupabaseDB()
        
        response = db.client.table("trips").select("*").eq("id", trip_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found"
            )
        
        trip = response.data[0]
        
        return TripResponse(
            id=trip["id"],
            created_by=trip["created_by"],
            title=trip.get("title", ""),
            destination=trip.get("destination", ""),
            location=trip.get("location"),
            start_date=trip.get("start_date"),
            end_date=trip.get("end_date"),
            trip_type=trip.get("trip_type"),
            description=trip.get("description"),
            image_url=trip.get("image_url"),
            is_public=trip.get("is_public", True),
            created_at=trip.get("created_at")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get trip details: {str(e)}"
        )


@router.post("/trips/create", response_model=TripResponse)
async def create_trip(trip: CreateTripRequest):
    """
    Create a new trip/adventure
    """
    try:
        db = SupabaseDB()
        
        trip_data = {
            "created_by": trip.created_by,
            "title": trip.title,
            "destination": trip.destination,
            "location": trip.location,
            "start_date": trip.start_date.isoformat() if trip.start_date else None,
            "end_date": trip.end_date.isoformat() if trip.end_date else None,
            "trip_type": trip.trip_type,
            "description": trip.description,
            "image_url": trip.image_url,
            "is_public": trip.is_public
        }
        
        # Remove None values
        trip_data = {k: v for k, v in trip_data.items() if v is not None}
        
        response = db.client.table("trips").insert(trip_data).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create trip"
            )
        
        created_trip = response.data[0]
        
        return TripResponse(
            id=created_trip["id"],
            created_by=created_trip["created_by"],
            title=created_trip.get("title", ""),
            destination=created_trip.get("destination", ""),
            location=created_trip.get("location"),
            start_date=created_trip.get("start_date"),
            end_date=created_trip.get("end_date"),
            trip_type=created_trip.get("trip_type"),
            description=created_trip.get("description"),
            image_url=created_trip.get("image_url"),
            is_public=created_trip.get("is_public", True),
            created_at=created_trip.get("created_at")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create trip: {str(e)}"
        )


@router.delete("/trips/delete/{trip_id}")
async def delete_trip(trip_id: str):
    """
    Delete a trip
    """
    try:
        db = SupabaseDB()
        
        db.client.table("trips").delete().eq("id", trip_id).execute()
        
        return {"message": "Trip deleted successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete trip: {str(e)}"
        )


@router.get("/favorites/{user_id}", response_model=List[FavoriteResponse])
async def get_user_favorites(user_id: str):
    """
    Get all favorites for a user
    """
    try:
        db = SupabaseDB()
        
        response = db.client.table("user_favorites").select("*").eq("user_id", user_id).order("created_at", desc=True).execute()
        
        if not response.data:
            return []
        
        favorites = []
        for fav in response.data:
            favorites.append(FavoriteResponse(
                id=fav["id"],
                user_id=fav["user_id"],
                trip_id=fav.get("trip_id"),
                destination_name=fav.get("destination_name"),
                destination_type=fav.get("destination_type"),
                created_at=fav.get("created_at")
            ))
        
        return favorites
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get favorites: {str(e)}"
        )


@router.post("/favorites/add", response_model=FavoriteResponse)
async def add_favorite(favorite: AddFavoriteRequest):
    """
    Add a destination or trip to favorites
    """
    try:
        db = SupabaseDB()
        
        favorite_data = {
            "user_id": favorite.user_id,
            "trip_id": favorite.trip_id,
            "destination_name": favorite.destination_name,
            "destination_type": favorite.destination_type
        }
        
        # Remove None values
        favorite_data = {k: v for k, v in favorite_data.items() if v is not None}
        
        # Check if already favorited
        existing = db.client.table("user_favorites").select("*").eq("user_id", favorite.user_id)
        if favorite.trip_id:
            existing = existing.eq("trip_id", favorite.trip_id)
        existing = existing.execute()
        
        if existing.data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Already in favorites"
            )
        
        response = db.client.table("user_favorites").insert(favorite_data).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to add favorite"
            )
        
        fav = response.data[0]
        
        return FavoriteResponse(
            id=fav["id"],
            user_id=fav["user_id"],
            trip_id=fav.get("trip_id"),
            destination_name=fav.get("destination_name"),
            destination_type=fav.get("destination_type"),
            created_at=fav.get("created_at")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to add favorite: {str(e)}"
        )


@router.delete("/favorites/remove/{favorite_id}")
async def remove_favorite(favorite_id: str):
    """
    Remove a favorite
    """
    try:
        db = SupabaseDB()
        
        db.client.table("user_favorites").delete().eq("id", favorite_id).execute()
        
        return {"message": "Favorite removed successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to remove favorite: {str(e)}"
        )


@router.get("/liked-pages/{user_id}")
async def get_liked_pages(user_id: str):
    """
    Get all pages/posts liked by the user
    Placeholder for social features
    """
    try:
        db = SupabaseDB()
        
        # This would connect to a likes table when implemented
        return {
            "liked_pages": [],
            "total": 0
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get liked pages: {str(e)}"
        )

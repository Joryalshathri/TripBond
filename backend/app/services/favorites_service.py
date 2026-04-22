"""
Favorites Service

Handles user favorites CRUD operations.
"""
from fastapi import HTTPException, status
from typing import List
from ..database import SupabaseDB
from ..schemas.favorites import FavoriteResponse, AddFavoriteRequest
import logging

logger = logging.getLogger(__name__)


def get_user_favorites(user_id: str) -> List[FavoriteResponse]:
    """Retrieve all favorites saved by a user."""
    db = SupabaseDB()
    response = db.client.table("user_favorites").select("*").eq(
        "user_id", user_id
    ).order("created_at", desc=True).execute()

    if not response.data:
        return []

    return [
        FavoriteResponse(
            id=fav["id"],
            user_id=fav["user_id"],
            trip_id=fav.get("trip_id"),
            destination_name=fav.get("destination_name"),
            destination_type=fav.get("destination_type"),
            created_at=fav.get("created_at"),
        )
        for fav in response.data
    ]


def add_favorite(user_id: str, favorite: AddFavoriteRequest) -> FavoriteResponse:
    """Add a destination, trip, or POI to a user's favorites."""
    db = SupabaseDB()
    
    # Debug log what we're receiving
    logger.info(f"Adding favorite for user {user_id}: trip_id={favorite.trip_id}, destination_name={favorite.destination_name}, destination_type={favorite.destination_type}, poi_id={favorite.poi_id}")

    query = db.client.table("user_favorites").select("id").eq("user_id", user_id)
    if favorite.trip_id:
        query = query.eq("trip_id", favorite.trip_id)
    elif favorite.poi_id:
        query = query.eq("poi_id", favorite.poi_id)
    elif favorite.destination_name:
        query = query.eq("destination_name", favorite.destination_name)

    if query.execute().data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Already in favorites")

    # Only include non-null values in the insert data
    favorite_data = {
        "user_id": user_id,
    }
    
    if favorite.trip_id is not None:
        favorite_data["trip_id"] = favorite.trip_id
    if favorite.destination_name is not None:
        favorite_data["destination_name"] = favorite.destination_name
    if favorite.destination_type is not None:
        favorite_data["destination_type"] = favorite.destination_type
    if favorite.poi_id is not None:
        favorite_data["poi_id"] = favorite.poi_id
    
    logger.info(f"Inserting favorite_data: {favorite_data}")

    response = db.client.table("user_favorites").insert(favorite_data).execute()
    if not response.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to add favorite",
        )

    result = response.data[0]
    return FavoriteResponse(
        id=result["id"],
        user_id=result["user_id"],
        trip_id=result.get("trip_id"),
        destination_name=result.get("destination_name"),
        destination_type=result.get("destination_type"),
        created_at=result.get("created_at"),
    )


def remove_favorite(user_id: str, favorite_id: str) -> None:
    """Remove a favorite after verifying ownership."""
    db = SupabaseDB()

    fav = db.client.table("user_favorites").select("id").eq(
        "id", favorite_id
    ).eq("user_id", user_id).execute()

    if not fav.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Favorite not found")

    db.client.table("user_favorites").delete().eq("id", favorite_id).execute()

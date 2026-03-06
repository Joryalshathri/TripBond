from fastapi import APIRouter, HTTPException, status
from typing import List
from ..schemas.favorites import FavoriteResponse, AddFavoriteRequest
from ..services import favorites_service

router = APIRouter()


@router.get("/{user_id}", response_model=List[FavoriteResponse])
async def get_user_favorites(user_id: str):
    """Get all favorites for a user."""
    try:
        return favorites_service.get_user_favorites(user_id)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get favorites: {str(e)}",
        )


@router.post("/{user_id}", response_model=FavoriteResponse)
async def add_favorite(user_id: str, favorite: AddFavoriteRequest):
    """Add a destination, trip, or POI to user's favorites."""
    try:
        return favorites_service.add_favorite(user_id, favorite)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to add favorite: {str(e)}",
        )


@router.delete("/{user_id}/{favorite_id}")
async def remove_favorite(user_id: str, favorite_id: str):
    """Remove a favorite."""
    try:
        favorites_service.remove_favorite(user_id, favorite_id)
        return {"message": "Favorite removed successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to remove favorite: {str(e)}",
        )

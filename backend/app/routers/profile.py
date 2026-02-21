from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import date
from ..database import SupabaseDB

router = APIRouter()


class ProfileResponse(BaseModel):
    id: str
    email: str
    full_name: Optional[str] = None
    username: Optional[str] = None
    phone_number: Optional[str] = None
    date_of_birth: Optional[str] = None
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    current_location: Optional[str] = None
    gender: Optional[str] = None
    is_public: Optional[bool] = True
    # Stats
    past_trips_count: Optional[int] = 0
    liked_pages_count: Optional[int] = 0
    favorites_count: Optional[int] = 0


class UpdateProfileRequest(BaseModel):
    full_name: Optional[str] = None
    username: Optional[str] = None
    phone_number: Optional[str] = None
    date_of_birth: Optional[date] = None
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    current_location: Optional[str] = None
    gender: Optional[str] = None
    is_public: Optional[bool] = None


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


@router.get("/me", response_model=ProfileResponse)
async def get_my_profile(user_id: str):
    """
    Get the current user's profile information with stats
    """
    try:
        db = SupabaseDB()
        
        # Get profile
        profile_response = db.client.table("profiles").select("*").eq("id", user_id).execute()
        
        if not profile_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Profile not found"
            )
        
        profile = profile_response.data[0]
        
        # Get user email from auth
        try:
            user = db.client.auth.admin.get_user_by_id(user_id)
            email = user.user.email if user and user.user else profile.get("email", "")
        except:
            email = profile.get("email", "")
        
        # Get stats
        # Count past trips
        trips_response = db.client.table("trips").select("id", count="exact").eq("user_id", user_id).execute()
        past_trips_count = trips_response.count if trips_response else 0
        
        # Count liked pages (favorites)
        favorites_response = db.client.table("user_favorites").select("id", count="exact").eq("user_id", user_id).execute()
        favorites_count = favorites_response.count if favorites_response else 0
        
        return ProfileResponse(
            id=profile["id"],
            email=email,
            full_name=profile.get("full_name"),
            username=profile.get("username"),
            phone_number=profile.get("phone_number"),
            date_of_birth=profile.get("date_of_birth"),
            bio=profile.get("bio"),
            avatar_url=profile.get("avatar_url"),
            current_location=profile.get("current_location"),
            gender=profile.get("gender"),
            is_public=profile.get("is_public", True),
            past_trips_count=past_trips_count,
            liked_pages_count=0,  # Can be implemented based on your like system
            favorites_count=favorites_count
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get profile: {str(e)}"
        )


@router.get("/{user_id}", response_model=ProfileResponse)
async def get_user_profile(user_id: str):
    """
    Get a user's public profile by user ID
    """
    try:
        db = SupabaseDB()
        
        # Get profile
        profile_response = db.client.table("profiles").select("*").eq("id", user_id).execute()
        
        if not profile_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        profile = profile_response.data[0]
        
        # Check if profile is public
        if not profile.get("is_public", True):
            # Only return basic info for private profiles
            return ProfileResponse(
                id=profile["id"],
                full_name=profile.get("full_name"),
                username=profile.get("username"),
                avatar_url=profile.get("avatar_url"),
                is_public=False
            )
        
        # Get stats for public profile
        trips_response = db.client.table("trips").select("id", count="exact").eq("user_id", user_id).execute()
        past_trips_count = trips_response.count if trips_response else 0
        
        favorites_response = db.client.table("user_favorites").select("id", count="exact").eq("user_id", user_id).execute()
        favorites_count = favorites_response.count if favorites_response else 0
        
        return ProfileResponse(
            id=profile["id"],
            email="",  # Don't expose email for other users
            full_name=profile.get("full_name"),
            username=profile.get("username"),
            phone_number="",  # Don't expose phone for other users
            date_of_birth="",  # Don't expose DOB for other users
            bio=profile.get("bio"),
            avatar_url=profile.get("avatar_url"),
            current_location=profile.get("current_location"),
            is_public=profile.get("is_public", True),
            past_trips_count=past_trips_count,
            liked_pages_count=0,
            favorites_count=favorites_count
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get profile: {str(e)}"
        )


@router.put("/update/{user_id}", response_model=ProfileResponse)
async def update_profile(user_id: str, profile_update: UpdateProfileRequest):
    """
    Update user profile information
    """
    try:
        db = SupabaseDB()
        
        # Build update data
        update_data = {}
        if profile_update.full_name is not None:
            update_data["full_name"] = profile_update.full_name
        if profile_update.username is not None:
            update_data["username"] = profile_update.username
        if profile_update.phone_number is not None:
            update_data["phone_number"] = profile_update.phone_number
        if profile_update.date_of_birth is not None:
            update_data["date_of_birth"] = profile_update.date_of_birth.isoformat()
        if profile_update.bio is not None:
            update_data["bio"] = profile_update.bio
        if profile_update.avatar_url is not None:
            update_data["avatar_url"] = profile_update.avatar_url
        if profile_update.current_location is not None:
            update_data["current_location"] = profile_update.current_location
        if profile_update.gender is not None:
            update_data["gender"] = profile_update.gender
        if profile_update.is_public is not None:
            update_data["is_public"] = profile_update.is_public
        
        if not update_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No update data provided"
            )
        
        # Update profile
        response = db.client.table("profiles").update(update_data).eq("id", user_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Profile not found"
            )
        
        # Return updated profile
        return await get_my_profile(user_id)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update profile: {str(e)}"
        )


@router.post("/change-password/{user_id}")
async def change_password(user_id: str, password_request: ChangePasswordRequest):
    """
    Change user password (requires current password verification)
    """
    try:
        db = SupabaseDB()
        
        # Get user email first
        profile = db.client.table("profiles").select("*").eq("id", user_id).execute()
        if not profile.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Try to get email from auth
        try:
            user = db.client.auth.admin.get_user_by_id(user_id)
            email = user.user.email
        except:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Could not verify user email"
            )
        
        # Verify current password by attempting to sign in
        try:
            db.client.auth.sign_in_with_password({
                "email": email,
                "password": password_request.current_password
            })
        except:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Current password is incorrect"
            )
        
        # Update password
        db.client.auth.update_user({
            "password": password_request.new_password
        })
        
        return {"message": "Password changed successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to change password: {str(e)}"
        )


@router.delete("/delete/{user_id}")
async def delete_account(user_id: str):
    """
    Delete user account permanently
    """
    try:
        db = SupabaseDB()
        
        # Delete profile data
        db.client.table("profiles").delete().eq("id", user_id).execute()
        
        # Delete auth user
        db.client.auth.admin.delete_user(user_id)
        
        return {"message": "Account deleted successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete account: {str(e)}"
        )

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import Optional
from ..database import SupabaseDB

router = APIRouter()


class UserSettingsResponse(BaseModel):
    user_id: str
    # Account settings
    security_enabled: Optional[bool] = True
    notifications_enabled: Optional[bool] = True
    privacy_mode: Optional[str] = "public"  # "public", "friends", "private"
    # Data settings
    data_saver_enabled: Optional[bool] = False
    storage_used_mb: Optional[float] = 0.0


class UpdateSettingsRequest(BaseModel):
    security_enabled: Optional[bool] = None
    notifications_enabled: Optional[bool] = None
    privacy_mode: Optional[str] = None
    data_saver_enabled: Optional[bool] = None


class ClearCacheResponse(BaseModel):
    message: str
    space_freed_mb: float


@router.get("/settings/{user_id}", response_model=UserSettingsResponse)
async def get_user_settings(user_id: str):
    """
    Get user's app settings
    """
    try:
        db = SupabaseDB()
        
        # Get or create settings
        settings_response = db.client.table("user_settings").select("*").eq("user_id", user_id).execute()
        
        if settings_response.data:
            settings = settings_response.data[0]
            return UserSettingsResponse(
                user_id=settings["user_id"],
                security_enabled=settings.get("security_enabled", True),
                notifications_enabled=settings.get("notifications_enabled", True),
                privacy_mode=settings.get("privacy_mode", "public"),
                data_saver_enabled=settings.get("data_saver_enabled", False),
                storage_used_mb=settings.get("storage_used_mb", 0.0)
            )
        else:
            # Return default settings if none exist
            return UserSettingsResponse(
                user_id=user_id,
                security_enabled=True,
                notifications_enabled=True,
                privacy_mode="public",
                data_saver_enabled=False,
                storage_used_mb=0.0
            )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get settings: {str(e)}"
        )


@router.put("/settings/{user_id}", response_model=UserSettingsResponse)
async def update_user_settings(user_id: str, settings_update: UpdateSettingsRequest):
    """
    Update user's app settings
    """
    try:
        db = SupabaseDB()
        
        # Build update data
        update_data = {"user_id": user_id}
        if settings_update.security_enabled is not None:
            update_data["security_enabled"] = settings_update.security_enabled
        if settings_update.notifications_enabled is not None:
            update_data["notifications_enabled"] = settings_update.notifications_enabled
        if settings_update.privacy_mode is not None:
            update_data["privacy_mode"] = settings_update.privacy_mode
        if settings_update.data_saver_enabled is not None:
            update_data["data_saver_enabled"] = settings_update.data_saver_enabled
        
        # Check if settings exist
        existing = db.client.table("user_settings").select("*").eq("user_id", user_id).execute()
        
        if existing.data:
            # Update existing
            response = db.client.table("user_settings").update(update_data).eq("user_id", user_id).execute()
        else:
            # Insert new
            response = db.client.table("user_settings").insert(update_data).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update settings"
            )
        
        settings = response.data[0]
        
        return UserSettingsResponse(
            user_id=settings["user_id"],
            security_enabled=settings.get("security_enabled", True),
            notifications_enabled=settings.get("notifications_enabled", True),
            privacy_mode=settings.get("privacy_mode", "public"),
            data_saver_enabled=settings.get("data_saver_enabled", False),
            storage_used_mb=settings.get("storage_used_mb", 0.0)
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update settings: {str(e)}"
        )


@router.post("/cache/clear/{user_id}", response_model=ClearCacheResponse)
async def clear_cache(user_id: str):
    """
    Clear user's cached data to free up space
    This is a placeholder - implement actual cache clearing logic as needed
    """
    try:
        db = SupabaseDB()
        
        # Get current storage used
        settings_response = db.client.table("user_settings").select("storage_used_mb").eq("user_id", user_id).execute()
        
        storage_used = 0.0
        if settings_response.data:
            storage_used = settings_response.data[0].get("storage_used_mb", 0.0)
        
        # Reset storage to 0 (in real implementation, delete cached files)
        db.client.table("user_settings").update({"storage_used_mb": 0.0}).eq("user_id", user_id).execute()
        
        return ClearCacheResponse(
            message="Cache cleared successfully",
            space_freed_mb=storage_used
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to clear cache: {str(e)}"
        )


@router.get("/storage/{user_id}")
async def get_storage_info(user_id: str):
    """
    Get storage usage information for the user
    """
    try:
        db = SupabaseDB()
        
        settings_response = db.client.table("user_settings").select("storage_used_mb").eq("user_id", user_id).execute()
        
        storage_used = 0.0
        if settings_response.data:
            storage_used = settings_response.data[0].get("storage_used_mb", 0.0)
        
        return {
            "storage_used_mb": storage_used,
            "storage_limit_mb": 500.0,  # Example limit
            "percentage_used": (storage_used / 500.0) * 100
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get storage info: {str(e)}"
        )


@router.get("/support/help")
async def get_help_resources():
    """
    Get help and support resources
    """
    return {
        "faq": [
            {
                "question": "How do I create a trip?",
                "answer": "Navigate to the create trip page and fill in your travel details including destination, dates, and companions."
            },
            {
                "question": "How does the matching algorithm work?",
                "answer": "Our AI analyzes your personality traits, travel preferences, and budget to match you with compatible travel companions."
            },
            {
                "question": "Is my data secure?",
                "answer": "Yes, all your data is encrypted and stored securely. We never share your personal information without your consent."
            }
        ],
        "contact": {
            "email": "support@tripbond.com",
            "phone": "+966-XXX-XXXX"
        }
    }


@router.get("/support/terms")
async def get_terms_and_policies():
    """
    Get terms of service and privacy policy
    """
    return {
        "terms_of_service": {
            "last_updated": "2026-01-01",
            "url": "/legal/terms",
            "version": "1.0"
        },
        "privacy_policy": {
            "last_updated": "2026-01-01",
            "url": "/legal/privacy",
            "version": "1.0"
        },
        "cookie_policy": {
            "last_updated": "2026-01-01",
            "url": "/legal/cookies",
            "version": "1.0"
        }
    }

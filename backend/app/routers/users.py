from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.concurrency import run_in_threadpool
from ..database import SupabaseDB, get_supabase_client_for_user
from ..auth import get_current_user_context
from ..schemas.profile import ProfileResponse, UpdateProfileRequest
from ..schemas.settings import UserSettingsResponse, UpdateSettingsRequest
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


# ==================== Profile ====================

@router.get("/me", response_model=ProfileResponse)
async def get_my_profile(user_context: tuple[str, str] = Depends(get_current_user_context)):
    """Get the current authenticated user's full profile with stats."""
    user_id, token = user_context
    try:
        client = get_supabase_client_for_user(token)
        profile_response = await run_in_threadpool(
            lambda: client.table("profiles").select("*").eq("id", user_id).execute()
        )
        if not profile_response.data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found")
        profile = profile_response.data[0]

        db = SupabaseDB(admin=True)
        trips_response = await run_in_threadpool(
            lambda: db.client.table("trips").select("id", count="exact").eq("user_id", user_id).execute()
        )
        favorites_response = await run_in_threadpool(
            lambda: db.client.table("user_favorites").select("id", count="exact").eq("user_id", user_id).execute()
        )
        return ProfileResponse(
            id=profile["id"],
            email=profile.get("email", ""),
            full_name=profile.get("full_name"),
            username=profile.get("username"),
            phone_number=profile.get("phone_number"),
            date_of_birth=profile.get("date_of_birth"),
            bio=profile.get("bio"),
            avatar_url=profile.get("avatar_url"),
            current_location=profile.get("current_location"),
            gender=profile.get("gender"),
            is_public=profile.get("is_public", True),
            past_trips_count=trips_response.count if trips_response else 0,
            liked_pages_count=0,
            favorites_count=favorites_response.count if favorites_response else 0,
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get profile")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to retrieve profile")


@router.get("/{user_id}/profile", response_model=ProfileResponse)
async def get_user_profile(user_id: str):
    """Get a user's public profile."""
    try:
        db = SupabaseDB(admin=True)
        profile_response = await run_in_threadpool(
            lambda: db.client.table("profiles").select(
                "id,full_name,username,avatar_url,bio,current_location,is_public"
            ).eq("id", user_id).execute()
        )
        if not profile_response.data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        profile = profile_response.data[0]

        if not profile.get("is_public", True):
            return ProfileResponse(
                id=profile["id"],
                full_name=profile.get("full_name"),
                username=profile.get("username"),
                avatar_url=profile.get("avatar_url"),
                is_public=False,
            )

        trips_response = await run_in_threadpool(
            lambda: db.client.table("trips").select("id", count="exact").eq("user_id", user_id).execute()
        )
        favorites_response = await run_in_threadpool(
            lambda: db.client.table("user_favorites").select("id", count="exact").eq("user_id", user_id).execute()
        )
        return ProfileResponse(
            id=profile["id"],
            email="",
            full_name=profile.get("full_name"),
            username=profile.get("username"),
            bio=profile.get("bio"),
            avatar_url=profile.get("avatar_url"),
            current_location=profile.get("current_location"),
            is_public=profile.get("is_public", True),
            past_trips_count=trips_response.count if trips_response else 0,
            liked_pages_count=0,
            favorites_count=favorites_response.count if favorites_response else 0,
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get user profile")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to retrieve user profile")


@router.put("/{user_id}/profile", response_model=ProfileResponse)
async def update_profile(
    user_id: str,
    profile_update: UpdateProfileRequest,
    user_context: tuple[str, str] = Depends(get_current_user_context),
):
    """Update user profile. Users can only update their own profile."""
    current_user_id, token = user_context
    if user_id != current_user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only update your own profile")
    try:
        client = get_supabase_client_for_user(token)
        update_data = {
            k: (v.isoformat() if hasattr(v, "isoformat") else v)
            for k, v in profile_update.model_dump().items()
            if v is not None
        }
        if not update_data:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No update data provided")

        response = await run_in_threadpool(
            lambda: client.table("profiles").update(update_data).eq("id", user_id).execute()
        )
        if not response.data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found")

        db = SupabaseDB(admin=True)
        trips_response = await run_in_threadpool(
            lambda: db.client.table("trips").select("id", count="exact").eq("user_id", user_id).execute()
        )
        favorites_response = await run_in_threadpool(
            lambda: db.client.table("user_favorites").select("id", count="exact").eq("user_id", user_id).execute()
        )
        p = response.data[0]
        return ProfileResponse(
            id=p["id"],
            email=p.get("email", ""),
            full_name=p.get("full_name"),
            username=p.get("username"),
            phone_number=p.get("phone_number"),
            date_of_birth=p.get("date_of_birth"),
            bio=p.get("bio"),
            avatar_url=p.get("avatar_url"),
            current_location=p.get("current_location"),
            gender=p.get("gender"),
            is_public=p.get("is_public", True),
            past_trips_count=trips_response.count if trips_response else 0,
            liked_pages_count=0,
            favorites_count=favorites_response.count if favorites_response else 0,
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to update profile")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to update profile")


@router.delete("/{user_id}")
async def delete_account(
    user_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context),
):
    """Permanently delete a user account."""
    current_user_id, token = user_context
    if user_id != current_user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only delete your own account")
    try:
        client = get_supabase_client_for_user(token)
        await run_in_threadpool(lambda: client.table("profiles").delete().eq("id", user_id).execute())
        try:
            db = SupabaseDB(admin=True)
            await run_in_threadpool(lambda: db.client.auth.admin.delete_user(user_id))
        except Exception:
            logger.exception("Failed to delete auth user (non-critical)")
        return {"message": "Account deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to delete account")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to delete account")


# ==================== Settings ====================

@router.get("/{user_id}/settings", response_model=UserSettingsResponse)
async def get_user_settings(
    user_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context),
):
    """Get user app settings."""
    current_user_id, token = user_context
    if user_id != current_user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only view your own settings")
    try:
        client = get_supabase_client_for_user(token)
        resp = client.table("user_settings").select("*").eq("user_id", user_id).execute()
        if resp.data:
            s = resp.data[0]
            return UserSettingsResponse(
                user_id=s["user_id"],
                security_enabled=s.get("security_enabled", True),
                notifications_enabled=s.get("notifications_enabled", True),
                privacy_mode=s.get("privacy_mode", "public"),
            )
        return UserSettingsResponse(user_id=user_id, security_enabled=True, notifications_enabled=True, privacy_mode="public")
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get settings")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to retrieve settings")


@router.put("/{user_id}/settings", response_model=UserSettingsResponse)
async def update_user_settings(
    user_id: str,
    settings_update: UpdateSettingsRequest,
    user_context: tuple[str, str] = Depends(get_current_user_context),
):
    """Update user app settings."""
    current_user_id, token = user_context
    if user_id != current_user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only update your own settings")
    try:
        client = get_supabase_client_for_user(token)
        update_data: dict = {"user_id": user_id}
        if settings_update.security_enabled is not None:
            update_data["security_enabled"] = settings_update.security_enabled
        if settings_update.notifications_enabled is not None:
            update_data["notifications_enabled"] = settings_update.notifications_enabled
        if settings_update.privacy_mode is not None:
            update_data["privacy_mode"] = settings_update.privacy_mode

        existing = client.table("user_settings").select("*").eq("user_id", user_id).execute()
        if existing.data:
            response = client.table("user_settings").update(update_data).eq("user_id", user_id).execute()
        else:
            response = client.table("user_settings").insert(update_data).execute()

        if not response.data:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to update settings")
        s = response.data[0]
        return UserSettingsResponse(
            user_id=s["user_id"],
            security_enabled=s.get("security_enabled", True),
            notifications_enabled=s.get("notifications_enabled", True),
            privacy_mode=s.get("privacy_mode", "public"),
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to update settings")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to update settings")

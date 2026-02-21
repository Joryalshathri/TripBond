from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List, Optional
from ..database import SupabaseDB

router = APIRouter()


class TripPreferencesRequest(BaseModel):
    trip_id: str
    user_id: str
    activity_tags: Optional[List[str]] = None  # Array of activity preferences
    pace: Optional[str] = None  # 'slow', 'moderate', 'fast'


class TripPreferencesResponse(BaseModel):
    trip_id: str
    user_id: str
    activity_tags: Optional[List[str]] = None
    pace: Optional[str] = None
    updated_at: Optional[str] = None


class UserGeneralPreferences(BaseModel):
    """General user preferences stored in profiles table"""
    user_id: str
    budget_level: Optional[str] = None  # 'low', 'medium', 'high'
    travel_style: Optional[str] = None  # 'adventure', 'relax', 'cultural', 'luxury'
    dietary_preferences: Optional[str] = None
    preferred_accommodation: Optional[str] = None
    preferred_transport: Optional[str] = None


# Questionnaire structure - defines all available options
TRAVEL_QUESTIONNAIRE = {
    "questions": [
        {
            "id": 1,
            "question": "What kind of trip are you planning?",
            "type": "single_choice",
            "field": "trip_type",
            "storage": "trips.trip_type",
            "options": [
                {"value": "relax", "label": "Relax and Recharge"},
                {"value": "culture", "label": "Explore Culture"},
                {"value": "adventure", "label": "Adventure and Nature"},
                {"value": "food", "label": "Food and Cafes"},
                {"value": "family", "label": "Family Fun"},
                {"value": "nightlife", "label": "Nightlife"}
            ]
        },
        {
            "id": 2,
            "question": "What two activities excite you the most?",
            "type": "multiple_choice",
            "field": "activity_tags",
            "storage": "trip_preferences.activity_tags",
            "max_selections": 2,
            "options": [
                {"value": "museums", "label": "Museums"},
                {"value": "dive_fun", "label": "Dive/Fun"},
                {"value": "hiking", "label": "Hiking"},
                {"value": "landmarks", "label": "Landmarks"},
                {"value": "local_dessert", "label": "Local Dessert"},
                {"value": "theme_parks", "label": "Theme Parks"}
            ]
        },
        {
            "id": 3,
            "question": "What is your estimated daily budget (in SAR)?",
            "type": "single_choice",
            "field": "budget_level",
            "storage": "profiles.budget_level",
            "options": [
                {"value": "low", "label": "50 to 100 SAR"},
                {"value": "medium", "label": "200 to 500 SAR"},
                {"value": "high", "label": "500 SAR and above"}
            ]
        },
        {
            "id": 4,
            "question": "Who are you traveling with?",
            "type": "single_choice",
            "field": "travel_companions",
            "storage": "metadata",  # Can be stored in trip metadata
            "options": [
                {"value": "solo", "label": "Solo"},
                {"value": "friends", "label": "Friends"},
                {"value": "family", "label": "Family"},
                {"value": "couple", "label": "Couple"}
            ]
        },
        {
            "id": 5,
            "question": "What is your preferred pace?",
            "type": "single_choice",
            "field": "pace",
            "storage": "trip_preferences.pace",
            "options": [
                {"value": "slow", "label": "Relaxed & Flexible"},
                {"value": "moderate", "label": "Balanced"},
                {"value": "fast", "label": "Packed & Efficient"}
            ]
        },
        {
            "id": 6,
            "question": "Select any options that are important for your comfort",
            "type": "multiple_choice",
            "field": "comfort_tags",
            "storage": "trip_preferences.activity_tags",  # Can be merged with activity tags
            "options": [
                {"value": "luxury", "label": "Luxury Travel"},
                {"value": "prayer_rooms", "label": "Hotels (prayer rooms)"},
                {"value": "accessibility", "label": "Accessibility requests"},
                {"value": "halal_friendly", "label": "Halal Friendly"}
            ]
        }
    ]
}


@router.get("/questionnaire")
async def get_travel_questionnaire():
    """
    Get the complete travel preferences questionnaire structure
    """
    return TRAVEL_QUESTIONNAIRE


@router.post("/trip/submit", response_model=TripPreferencesResponse)
async def submit_trip_preferences(preferences: TripPreferencesRequest):
    """
    Submit or update trip-specific preferences (trip_preferences table)
    This is for preferences specific to a particular trip
    """
    try:
        db = SupabaseDB()
        
        # Prepare data for database
        prefs_data = {
            "trip_id": preferences.trip_id,
            "user_id": preferences.user_id,
            "activity_tags": preferences.activity_tags,
            "pace": preferences.pace
        }
        
        # Remove None values
        prefs_data = {k: v for k, v in prefs_data.items() if v is not None}
        
        # Check if preferences already exist for this trip+user
        existing = db.client.table("trip_preferences").select("*").eq("trip_id", preferences.trip_id).eq("user_id", preferences.user_id).execute()
        
        if existing.data:
            # Update existing preferences
            response = db.client.table("trip_preferences").update(prefs_data).eq("trip_id", preferences.trip_id).eq("user_id", preferences.user_id).execute()
        else:
            # Insert new preferences
            response = db.client.table("trip_preferences").insert(prefs_data).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to save trip preferences"
            )
        
        result = response.data[0]
        
        return TripPreferencesResponse(
            trip_id=result.get("trip_id"),
            user_id=result.get("user_id"),
            activity_tags=result.get("activity_tags"),
            pace=result.get("pace"),
            updated_at=result.get("updated_at")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to submit trip preferences: {str(e)}"
        )


@router.get("/trip/{trip_id}/{user_id}", response_model=TripPreferencesResponse)
async def get_trip_preferences(trip_id: str, user_id: str):
    """
    Get trip preferences for a specific user on a specific trip
    """
    try:
        db = SupabaseDB()
        
        response = db.client.table("trip_preferences").select("*").eq("trip_id", trip_id).eq("user_id", user_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip preferences not found"
            )
        
        result = response.data[0]
        
        return TripPreferencesResponse(
            trip_id=result.get("trip_id"),
            user_id=result.get("user_id"),
            activity_tags=result.get("activity_tags"),
            pace=result.get("pace"),
            updated_at=result.get("updated_at")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get trip preferences: {str(e)}"
        )


@router.get("/trip/{trip_id}/all")
async def get_all_trip_preferences(trip_id: str):
    """
    Get all user preferences for a specific trip (for comparison/matching)
    """
    try:
        db = SupabaseDB()
        
        response = db.client.table("trip_preferences").select("*").eq("trip_id", trip_id).execute()
        
        if not response.data:
            return {"trip_id": trip_id, "preferences": []}
        
        preferences = []
        for pref in response.data:
            preferences.append(TripPreferencesResponse(
                trip_id=pref.get("trip_id"),
                user_id=pref.get("user_id"),
                activity_tags=pref.get("activity_tags"),
                pace=pref.get("pace"),
                updated_at=pref.get("updated_at")
            ))
        
        return {"trip_id": trip_id, "preferences": preferences}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get trip preferences: {str(e)}"
        )


@router.put("/trip/update/{trip_id}/{user_id}", response_model=TripPreferencesResponse)
async def update_trip_preferences(trip_id: str, user_id: str, preferences: TripPreferencesRequest):
    """
    Update trip preferences for a user
    """
    try:
        db = SupabaseDB()
        
        # Build update data
        update_data = {}
        if preferences.activity_tags is not None:
            update_data["activity_tags"] = preferences.activity_tags
        if preferences.pace is not None:
            update_data["pace"] = preferences.pace
        
        if not update_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No preferences provided for update"
            )
        
        # Update preferences
        response = db.client.table("trip_preferences").update(update_data).eq("trip_id", trip_id).eq("user_id", user_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip preferences not found"
            )
        
        result = response.data[0]
        
        return TripPreferencesResponse(
            trip_id=result.get("trip_id"),
            user_id=result.get("user_id"),
            activity_tags=result.get("activity_tags"),
            pace=result.get("pace"),
            updated_at=result.get("updated_at")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update trip preferences: {str(e)}"
        )


@router.post("/user/general", response_model=UserGeneralPreferences)
async def update_user_general_preferences(preferences: UserGeneralPreferences):
    """
    Update general user preferences (stored in profiles table)
    These are user-level preferences that apply across all trips
    """
    try:
        db = SupabaseDB()
        
        # Build update data for profiles table
        update_data = {}
        if preferences.budget_level is not None:
            update_data["budget_level"] = preferences.budget_level
        if preferences.travel_style is not None:
            update_data["travel_style"] = preferences.travel_style
        if preferences.dietary_preferences is not None:
            update_data["dietary_preferences"] = preferences.dietary_preferences
        if preferences.preferred_accommodation is not None:
            update_data["preferred_accommodation"] = preferences.preferred_accommodation
        if preferences.preferred_transport is not None:
            update_data["preferred_transport"] = preferences.preferred_transport
        
        if not update_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No preferences provided for update"
            )
        
        # Update profile
        response = db.client.table("profiles").update(update_data).eq("id", preferences.user_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found"
            )
        
        profile = response.data[0]
        
        return UserGeneralPreferences(
            user_id=profile["id"],
            budget_level=profile.get("budget_level"),
            travel_style=profile.get("travel_style"),
            dietary_preferences=profile.get("dietary_preferences"),
            preferred_accommodation=profile.get("preferred_accommodation"),
            preferred_transport=profile.get("preferred_transport")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update user preferences: {str(e)}"
        )


@router.get("/user/general/{user_id}", response_model=UserGeneralPreferences)
async def get_user_general_preferences(user_id: str):
    """
    Get general user preferences from profile
    """
    try:
        db = SupabaseDB()
        
        response = db.client.table("profiles").select(
            "id, budget_level, travel_style, dietary_preferences, preferred_accommodation, preferred_transport"
        ).eq("id", user_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found"
            )
        
        profile = response.data[0]
        
        return UserGeneralPreferences(
            user_id=profile["id"],
            budget_level=profile.get("budget_level"),
            travel_style=profile.get("travel_style"),
            dietary_preferences=profile.get("dietary_preferences"),
            preferred_accommodation=profile.get("preferred_accommodation"),
            preferred_transport=profile.get("preferred_transport")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get user preferences: {str(e)}"
        )


@router.delete("/trip/delete/{trip_id}/{user_id}")
async def delete_trip_preferences(trip_id: str, user_id: str):
    """
    Delete trip preferences for a user
    """
    try:
        db = SupabaseDB()
        
        response = db.client.table("trip_preferences").delete().eq("trip_id", trip_id).eq("user_id", user_id).execute()
        
        return {"message": "Trip preferences deleted successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete trip preferences: {str(e)}"
        )

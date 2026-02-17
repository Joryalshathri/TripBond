from supabase import create_client, Client
from functools import lru_cache
from .config import get_settings


@lru_cache()
def get_supabase_client() -> Client:
    """Get Supabase client instance"""
    settings = get_settings()
    # Create client with basic parameters only
    return create_client(
        supabase_url=settings.supabase_url,
        supabase_key=settings.supabase_key
    )


class SupabaseDB:
    """Wrapper for Supabase database operations"""
    
    def __init__(self):
        self.client = get_supabase_client()
    
    async def get_user_preferences(self, user_id: str):
        """Get user travel preferences and personality"""
        # Get profile
        profile_response = self.client.table("profiles").select("*").eq("id", user_id).execute()
        profile = profile_response.data[0] if profile_response.data else None
        
        # Get personality answers
        personality_response = self.client.table("personality_answers").select("*").eq("user_id", user_id).execute()
        
        # Get trip preferences
        prefs_response = self.client.table("trip_preferences").select("*").eq("user_id", user_id).execute()
        
        if profile:
            profile["personality_answers"] = personality_response.data
            profile["trip_preferences"] = prefs_response.data
        
        return profile

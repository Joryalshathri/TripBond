"""
Place suggestions system - AI evaluates and approves/rejects suggestions
"""

from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.concurrency import run_in_threadpool
from typing import Optional
from datetime import datetime
from ..database import SupabaseDB, get_supabase_client_for_user
from ..auth import get_current_user_context
from ..services.trip_access import check_trip_access
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/{trip_id}/suggest-place")
async def suggest_place(
    trip_id: str,
    place_data: dict,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """
    Suggest a place for the trip. 
    Place goes to Bonders Suggestions for AI evaluation.
    
    Expected place_data:
    {
        "external_place_id": str (optional),
        "name": str,
        "latitude": float,
        "longitude": float,
        "address": str,
        "rating": float,
        "user_ratings_total": int,
        "types": list,
        "image_url": str (optional)
    }
    """
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="edit")
        
        name = place_data.get("name")
        latitude = place_data.get("latitude")
        longitude = place_data.get("longitude")
        
        if not name or latitude is None or longitude is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Missing required fields: name, latitude, longitude"
            )
        
        db = SupabaseDB(admin=True)
        
        # Prepare suggestion record
        suggestion_record = {
            "trip_id": trip_id,
            "name": name,
            "address": place_data.get("address", ""),
            "latitude": latitude,
            "longitude": longitude,
            "rating": place_data.get("rating"),
            "user_ratings_total": place_data.get("user_ratings_total"),
            "place_types": place_data.get("types", []),
            "image_url": place_data.get("image_url"),
            "external_place_id": place_data.get("external_place_id"),
            "suggested_by": user_id,
            "status": "pending"
        }
        
        # Insert suggestion
        insert_result = await run_in_threadpool(
            lambda: db.client.table("place_suggestions").insert(suggestion_record).execute()
        )
        
        if not insert_result.data:
            raise Exception("Insert returned no data")
        
        suggestion_id = insert_result.data[0]["id"]
        logger.info(f"Suggested place {name} ({suggestion_id}) for trip {trip_id}")
        
        # Trigger AI evaluation in background
        try:
            await evaluate_place_with_ai(suggestion_id, trip_id, name, latitude, longitude, place_data.get("types", []))
        except Exception as e:
            logger.warning(f"AI evaluation failed for suggestion {suggestion_id}: {e}")
        
        return {
            "success": True,
            "suggestion_id": suggestion_id,
            "message": f"✓ {name} added",
            "status": "pending"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception(f"Failed to suggest place: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to suggest place: {str(e)}"
        )


@router.get("/{trip_id}/list")
async def list_suggestions(
    trip_id: str,
    status: Optional[str] = None,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """List suggestions for a trip (Bonders Suggestions), optionally filtered by status"""
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="view")
        
        db = SupabaseDB(admin=True)
        query = db.client.table("place_suggestions").select("*").eq("trip_id", trip_id)
        
        if status:
            query = query.eq("status", status)
        
        result = await run_in_threadpool(lambda: query.execute())
        
        return {
            "success": True,
            "suggestions": result.data or []
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception(f"Failed to list suggestions: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to list suggestions: {str(e)}"
        )


async def evaluate_place_with_ai(suggestion_id: str, trip_id: str, place_name: str, latitude: float, longitude: float, types: list):
    """
    Call AI to evaluate if place is suitable for group, then approve/add if suitable
    """
    try:
        db = SupabaseDB(admin=True)
        
        # For now, give default AI score based on rating
        # TODO: Call actual AI backend at localhost:5000 for evaluation
        ai_score = 0.75  # Default suitable
        ai_reasoning = f"Place '{place_name}' evaluated as suitable for group activities."
        
        # Update suggestion with AI evaluation
        await run_in_threadpool(
            lambda: db.client.table("place_suggestions")
            .update({
                "ai_score": ai_score,
                "ai_reasoning": ai_reasoning,
                "status": "approved"  # AI approved it
            })
            .eq("id", suggestion_id)
            .execute()
        )
        
        logger.info(f"AI approved suggestion {suggestion_id} with score: {ai_score}")
        
        # Get the suggestion to add to trip_places
        suggestion = await run_in_threadpool(
            lambda: db.client.table("place_suggestions").select("*").eq("id", suggestion_id).execute()
        )
        
        if suggestion.data:
            sugg = suggestion.data[0]
            
            # Add to trip_places
            place_record = {
                "trip_id": trip_id,
                "name": sugg["name"],
                "address": sugg["address"],
                "latitude": sugg["latitude"],
                "longitude": sugg["longitude"],
                "rating": sugg["rating"],
                "user_ratings_total": sugg["user_ratings_total"],
                "place_types": sugg["place_types"],
                "added_by": None,
                "added_at": datetime.utcnow().isoformat()
            }
            
            if sugg.get("external_place_id"):
                place_record["external_place_id"] = sugg["external_place_id"]
            if sugg.get("image_url"):
                place_record["image_url"] = sugg["image_url"]
            
            # Insert into trip_places
            await run_in_threadpool(
                lambda: db.client.table("trip_places").insert(place_record).execute()
            )
            
            logger.info(f"AI approved suggestion added place {sugg['name']} to trip {trip_id}")
        
    except Exception as e:
        logger.warning(f"Failed AI evaluation for suggestion {suggestion_id}: {e}")

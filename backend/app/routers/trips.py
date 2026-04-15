from fastapi import APIRouter, HTTPException, status, Query, Depends
from fastapi.concurrency import run_in_threadpool
from typing import List
from datetime import datetime, timedelta
from ..database import SupabaseDB, get_supabase_client_for_user
from ..services.trip_access import check_trip_access
from ..services import trip_service
from ..services.itinerary_service import (
    generate_itinerary,
    create_itinerary,
    get_latest_itinerary,
    list_items,
    insert_items,
    update_item,
    delete_item,
    get_itinerary_with_items,
)
from ..services.recommendation_service import calculate_poi_score
from ..schemas.trips import (
    TripResponse,
    CreateTripRequest,
    UpdateTripRequest,
    TripSummaryResponse,
    AddMemberRequest,
    TripMember,
    ItineraryActivity,
    DayItinerary,
    ItineraryResponse,
    GenerateItineraryRequest,
    POIResponse,
    RecommendationResponse
)
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

# Import auth dependency
from ..auth import get_current_user_context


# ==================== Trip Endpoints ====================

@router.get("/me", response_model=List[TripResponse])
async def get_my_created_trips(user_context: tuple[str, str] = Depends(get_current_user_context)):
    """Get all trips created by authenticated user"""
    user_id, token = user_context
    
    try:
        trips_data = await trip_service.get_user_trips(user_id, token)
        
        return [
            TripResponse(
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
            for trip in trips_data
        ]
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get trips")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve trips"
        )


@router.get("/user/{user_id}", response_model=List[TripResponse])
async def get_trips_by_user(user_id: str):
    """Get all trips created by a specific user (public-facing)."""
    try:
        db = SupabaseDB(admin=True)
        response = await run_in_threadpool(
            lambda: db.client.table("trips").select("*").eq("created_by", user_id).execute()
        )
        return [
            TripResponse(
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
                created_at=trip.get("created_at"),
            )
            for trip in (response.data or [])
            if trip.get("is_public", True)
        ]
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get trips for user %s", user_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve user trips",
        )


@router.get("/public/{trip_id}", response_model=TripResponse)
async def get_public_trip_detail(trip_id: str):
    """Get public trip details (no auth required)"""
    try:
        db = SupabaseDB(admin=True)
        
        trip_response = await run_in_threadpool(
            lambda: db.client.table("trips").select("*").eq("id", trip_id).execute()
        )
        if not trip_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found"
            )
        
        trip = trip_response.data[0]
        
        if not trip.get("is_public", True):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="This trip is private"
            )
        
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
        logger.exception("Failed to get public trip details")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve trip details"
        )


@router.get("/public/{trip_id}/itinerary")
async def get_public_trip_itinerary(trip_id: str):
    """Get public trip itinerary (no auth required)"""
    try:
        db = SupabaseDB(admin=True)
        
        trip_response = await run_in_threadpool(
            lambda: db.client.table("trips").select("*").eq("id", trip_id).execute()
        )
        if not trip_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Trip not found"
            )
        
        trip = trip_response.data[0]
        
        if not trip.get("is_public", True):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="This trip is private"
            )
        
        # Fetch latest itinerary
        itinerary = await run_in_threadpool(
            lambda: get_latest_itinerary(trip_id)
        )
        
        if not itinerary:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No itinerary found for this trip"
            )
        
        # Fetch all items for this itinerary
        items = await run_in_threadpool(
            lambda: list_items(itinerary["id"])
        )
        
        # Build a map of place names/ids to trip_places for enrichment
        places_response = await run_in_threadpool(
            lambda: db.client.table("trip_places").select("*").eq("trip_id", trip_id).execute()
        )
        places_map = {}
        if places_response.data:
            for place in places_response.data:
                # Map by name or external_place_id
                if place.get("name"):
                    places_map[place["name"].lower()] = place
                if place.get("external_place_id"):
                    places_map[place["external_place_id"]] = place
        
        # Group by day_index → days[]
        days_dict = {}
        total_cost = 0.0
        
        for item in items:
            day_idx = int(item.get("day_index") or 1)
            if day_idx not in days_dict:
                days_dict[day_idx] = {"day": day_idx, "activities": []}
            
            # Try to enrich with place data
            item_title = item.get("title", "Activity")
            place_data = places_map.get(item_title.lower()) or places_map.get(item_title)
            
            activity = {
                "id": item["id"],
                "name": item_title,
                "type": item.get("type", "activity"),
                "location": item.get("location") or trip.get("destination", "Unknown"),
                "start_time": item["start_time"],
                "end_time": item["end_time"],
                "description": item.get("notes", ""),
                "cost": place_data.get("cost") if place_data else item.get("cost"),
                "rating": place_data.get("rating") if place_data else item.get("rating"),
                "user_ratings_total": place_data.get("user_ratings_total") if place_data else None,
                "priority": item.get("priority", 1),
                "photo_url": item.get("photo_url") or (place_data.get("image_url") if place_data else None),
                "address": place_data.get("address") if place_data else None,
                "fsq_id": item.get("fsq_id"),
                "external_place_id": item.get("external_place_id") or (place_data.get("external_place_id") if place_data else None),
                "latitude": place_data.get("latitude") if place_data else None,
                "longitude": place_data.get("longitude") if place_data else None,
                "score": item.get("score")
            }
            days_dict[day_idx]["activities"].append(activity)
        
        days = [days_dict[k] for k in sorted(days_dict.keys())]
        
        return ItineraryResponse(
            trip_id=trip_id,
            days=days,
            total_cost=total_cost,
            total_days=len(days),
            optimization_score=itinerary.get("optimization_score"),
            generated_at=itinerary.get("created_at"),
            strategy=itinerary.get("generated_by", "unknown")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get public itinerary")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve itinerary"
        )


@router.get("/{trip_id}", response_model=TripResponse)
async def get_trip_detail(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Get trip details (creator, members, or public)"""
    user_id, token = user_context
    
    try:
        trip = await check_trip_access(trip_id, user_id, token=token, required_role="view")
        
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
        logger.exception("Failed to get trip details")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve trip details"
        )


@router.get("/{trip_id}/summary", response_model=TripSummaryResponse)
async def get_trip_summary(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Get trip summary: member count, itinerary status, user relationship"""
    user_id, token = user_context
    
    try:
        trip = await check_trip_access(trip_id, user_id, token=token, required_role="view")
        client = get_supabase_client_for_user(token)
        
        members_response = await run_in_threadpool(
            lambda: client.table("trip_participants").select("user_id", count="exact")
            .eq("trip_id", trip_id)
            .eq("status", "accepted")
            .execute()
        )
        member_count = members_response.count if members_response.count else 0
        
        db = SupabaseDB(admin=True)
        itinerary_response = await run_in_threadpool(
            lambda: db.client.table("itineraries").select("id")
            .eq("trip_id", trip_id)
            .order("created_at", desc=True)
            .limit(1)
            .execute()
        )
        
        has_itinerary = bool(itinerary_response.data)
        itinerary_days = 0
        if has_itinerary:
            itinerary_id = itinerary_response.data[0]["id"]
            # Count distinct day_index values to get number of days
            items_response = await run_in_threadpool(
                lambda: db.client.table("itinerary_items")
                .select("day_index")
                .eq("itinerary_id", itinerary_id)
                .execute()
            )
            if items_response.data:
                itinerary_days = len(set(item["day_index"] for item in items_response.data))
        
        is_creator = trip["created_by"] == user_id
        
        participant_response = await run_in_threadpool(
            lambda: client.table("trip_participants").select("user_id, status")
            .eq("trip_id", trip_id)
            .eq("user_id", user_id)
            .execute()
        )
        is_member = bool(participant_response.data and participant_response.data[0].get("status") == "accepted")
        
        return TripSummaryResponse(
            trip_id=trip["id"],
            title=trip.get("title", ""),
            destination=trip.get("destination", ""),
            member_count=member_count,
            has_itinerary=has_itinerary,
            itinerary_days=itinerary_days,
            is_creator=is_creator,
            is_member=is_member,
            is_public=trip.get("is_public", True),
            start_date=trip.get("start_date"),
            end_date=trip.get("end_date")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get trip summary")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve trip summary"
        )


@router.post("/", response_model=TripResponse)
async def create_new_trip(
    trip: CreateTripRequest,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Create new trip"""
    user_id, token = user_context
    
    try:
        trip_data = {
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
        
        created_trip = await trip_service.create_trip(user_id, token, trip_data)
        
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
        logger.exception("Failed to create trip")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create trip"
        )


@router.delete("/{trip_id}")
async def delete_trip_endpoint(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Delete trip (creator only)"""
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="creator")
        await trip_service.delete_trip(trip_id, token)
        
        return {"message": "Trip deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to delete trip")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete trip"
        )


@router.patch("/{trip_id}", response_model=TripResponse)
async def update_trip_endpoint(
    trip_id: str,
    updates: UpdateTripRequest,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Update trip details (creator only)"""
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="creator")
        
        update_data = {
            "title": updates.title,
            "destination": updates.destination,
            "location": updates.location,
            "start_date": updates.start_date.isoformat() if updates.start_date else None,
            "end_date": updates.end_date.isoformat() if updates.end_date else None,
            "trip_type": updates.trip_type,
            "description": updates.description,
            "image_url": updates.image_url,
            "is_public": updates.is_public
        }
        
        updated_trip = await trip_service.update_trip(trip_id, token, update_data)
        
        return TripResponse(
            id=updated_trip["id"],
            created_by=updated_trip["created_by"],
            title=updated_trip.get("title", ""),
            destination=updated_trip.get("destination", ""),
            location=updated_trip.get("location"),
            start_date=updated_trip.get("start_date"),
            end_date=updated_trip.get("end_date"),
            trip_type=updated_trip.get("trip_type"),
            description=updated_trip.get("description"),
            image_url=updated_trip.get("image_url"),
            is_public=updated_trip.get("is_public", True),
            created_at=updated_trip.get("created_at")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to update trip")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update trip"
        )


# ==================== Member Endpoints ====================

@router.get("/{trip_id}/members", response_model=List[TripMember])
async def get_trip_members(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Get accepted trip members (creator/members only)"""
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="member")
        members_data = await trip_service.get_trip_members(trip_id, token, status_filter="accepted")
        
        return [
            TripMember(
                id=member.get("id"),
                user_id=member["user_id"],
                status=member.get("status", "accepted"),
                invited_by=member.get("invited_by"),
                invited_at=member.get("invited_at"),
                responded_at=member.get("responded_at"),
                joined_at=member.get("joined_at")
            )
            for member in members_data
        ]
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get trip members")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve trip members"
        )


@router.get("/{trip_id}/members/pending", response_model=List[TripMember])
async def get_pending_invites(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Get pending invites for trip (creator only)"""
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="creator")
        members_data = await trip_service.get_trip_members(trip_id, token, status_filter="pending")
        
        return [
            TripMember(
                id=member.get("id"),
                user_id=member["user_id"],
                status=member.get("status", "pending"),
                invited_by=member.get("invited_by"),
                invited_at=member.get("invited_at"),
                responded_at=member.get("responded_at"),
                joined_at=member.get("joined_at")
            )
            for member in members_data
        ]
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get pending invites")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve pending invites"
        )


@router.get("/{trip_id}/members/all", response_model=List[TripMember])
async def get_all_trip_members(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Get all trip members (accepted + pending + declined) (creator only)"""
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="creator")
        members_data = await trip_service.get_trip_members(trip_id, token, status_filter=None)
        
        return [
            TripMember(
                id=member.get("id"),
                user_id=member["user_id"],
                status=member.get("status", "accepted"),
                invited_by=member.get("invited_by"),
                invited_at=member.get("invited_at"),
                responded_at=member.get("responded_at"),
                joined_at=member.get("joined_at")
            )
            for member in members_data
        ]
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get all trip members")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve all trip members"
        )


@router.post("/{trip_id}/leave")
async def leave_trip_endpoint(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Leave trip (members only, creator must delete)"""
    user_id, token = user_context
    
    try:
        await trip_service.leave_trip(trip_id, user_id, token)
        return {"message": "Successfully left the trip"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to leave trip")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to leave trip"
        )


@router.post("/{trip_id}/members", response_model=TripMember)
async def invite_trip_member(
    trip_id: str,
    member: AddMemberRequest,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Invite member (creates pending invite)"""
    inviter_id, token = user_context
    
    try:
        await check_trip_access(trip_id, inviter_id, token=token, required_role="creator")
        
        row = await trip_service.invite_member(trip_id, inviter_id, member.user_id, token)
        
        return TripMember(
            id=row.get("id"),
            user_id=row["user_id"],
            status=row["status"],
            invited_by=row.get("invited_by"),
            invited_at=row.get("invited_at"),
            responded_at=row.get("responded_at"),
            joined_at=row.get("joined_at")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to invite member")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to invite member"
        )


@router.delete("/{trip_id}/members/{user_id}")
async def remove_trip_member(
    trip_id: str,
    user_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Remove member or cancel invite (creator only)"""
    current_user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, current_user_id, token=token, required_role="creator")
        await trip_service.remove_member(trip_id, user_id, token)
        
        return {"message": "Member/invite removed successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to remove member")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to remove member"
        )


@router.get("/invites", response_model=List[dict])
async def get_my_pending_invites(
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Get user's pending trip invites"""
    user_id, token = user_context
    
    try:
        invites = await trip_service.get_user_pending_invites(user_id, token)
        return invites
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get pending invites")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve pending invites"
        )


@router.post("/{trip_id}/invites/accept", response_model=TripMember)
async def accept_trip_invite(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Accept pending trip invite"""
    user_id, token = user_context
    
    try:
        row = await trip_service.accept_invite(trip_id, user_id, token)
        
        return TripMember(
            id=row.get("id"),
            user_id=row["user_id"],
            status=row["status"],
            invited_by=row.get("invited_by"),
            invited_at=row.get("invited_at"),
            responded_at=row.get("responded_at"),
            joined_at=row.get("joined_at")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to accept invite")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to accept invite"
        )


@router.post("/{trip_id}/invites/decline")
async def decline_trip_invite(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Decline pending trip invite"""
    user_id, token = user_context
    
    try:
        await trip_service.decline_invite(trip_id, user_id, token)
        return {"message": "Invite declined successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to decline invite")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to decline invite"
        )


# ==================== Itinerary Endpoints ====================

@router.post("/{trip_id}/generate-itinerary", response_model=ItineraryResponse)
async def generate_trip_itinerary(
    trip_id: str,
    request: GenerateItineraryRequest,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Generate optimized itinerary using GA (creator only)"""
    user_id, token = user_context
    
    try:
        trip = await check_trip_access(trip_id, user_id, token=token, required_role="creator")
        
        db = SupabaseDB(admin=True)
        group_prefs_response = await run_in_threadpool(
            lambda: db.client.table("group_models").select("*").eq("trip_id", trip_id).execute()
        )
        
        group_prefs = group_prefs_response.data[0] if group_prefs_response.data else None
        
        # Service layer handles strategy selection
        itinerary_data, strategy = generate_itinerary(
            trip=trip,
            group_preferences=group_prefs.get("aggregated_preferences") if group_prefs else None,
            use_ga=request.use_ga,
            max_budget=request.max_budget,
            pace=request.pace,
            preferences=request.preferences
        )
        
        # Insert itinerary record using helper function
        itinerary_row = await run_in_threadpool(
            lambda: create_itinerary(
                trip_id=trip_id,
                generated_by=user_id,
                status="active",
                optimization_score=itinerary_data.get("fitness_score", 0.0),
                version=1
            )
        )
        itinerary_id = itinerary_row["id"]
        
        # Bulk insert itinerary items using helper function
        # Convert days structure to flat items list
        items_to_insert = []
        for day in itinerary_data.get("days", []):
            for activity in day.get("activities", []):
                item = {
                    "day_index": day.get("day"),
                    "start_time": activity.get("start_time"),
                    "end_time": activity.get("end_time"),
                    "title": activity.get("name"),
                    "notes": activity.get("description"),
                    "score": activity.get("score", 0.0),
                }
                    
                items_to_insert.append(item)
        
        await run_in_threadpool(
            lambda: insert_items(itinerary_id, items_to_insert)
        )
        
        return ItineraryResponse(
            trip_id=trip_id,
            days=itinerary_data["days"],
            total_cost=itinerary_data["total_cost"],
            total_days=len(itinerary_data["days"]),
            optimization_score=itinerary_data.get("fitness_score"),
            generated_at=datetime.now().isoformat(),
            strategy=strategy
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to generate itinerary")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate itinerary"
        )


@router.get("/{trip_id}/itinerary", response_model=ItineraryResponse)
async def get_itinerary(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Get trip itinerary"""
    user_id, token = user_context
    
    try:
        trip = await check_trip_access(trip_id, user_id, token=token, required_role="view")
        
        # Fetch latest itinerary
        itinerary = await run_in_threadpool(
            lambda: get_latest_itinerary(trip_id)
        )
        
        if not itinerary:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No itinerary found for this trip. Please generate one first."
            )
        
        # Fetch all items for this itinerary
        items = await run_in_threadpool(
            lambda: list_items(itinerary["id"])
        )
        
        # Group by day_index → days[]
        days_dict = {}
        total_cost = 0.0

        start_date_raw = trip.get("start_date") if isinstance(trip, dict) else None
        start_date_obj = None
        if start_date_raw:
            try:
                start_date_obj = datetime.fromisoformat(str(start_date_raw)).date()
            except ValueError:
                start_date_obj = None
        
        # Build a map of place names/ids to trip_places for enrichment
        places_response = await run_in_threadpool(
            lambda: db.client.table("trip_places").select("*").eq("trip_id", trip_id).execute()
        )
        places_map = {}
        if places_response.data:
            for place in places_response.data:
                # Map by name or external_place_id
                if place.get("name"):
                    places_map[place["name"].lower()] = place
                if place.get("external_place_id"):
                    places_map[place["external_place_id"]] = place
        
        for item in items:
            day_idx = item["day_index"]
            if day_idx not in days_dict:
                day_date = (
                    (start_date_obj + timedelta(days=max(day_idx - 1, 0))).isoformat()
                    if start_date_obj
                    else f"Day {day_idx}"
                )
                days_dict[day_idx] = {
                    "day": day_idx,
                    "date": day_date,
                    "activities": [],
                    "total_cost": 0.0,
                    "total_duration_minutes": 0,
                }
            
            # Try to enrich with place data
            item_title = item.get("title", "Activity")
            place_data = places_map.get(item_title.lower()) or places_map.get(item_title)
            
            # If not found by name, try by external_place_id
            if not place_data and item.get("external_place_id"):
                place_data = places_map.get(item["external_place_id"])
            
            activity = {
                "id": item["id"],
                "name": item.get("name") or item_title,
                "title": item_title,
                "type": item.get("type", "activity"),
                "location": item.get("location") or item.get("notes") or trip.get("destination", "Unknown"),
                "start_time": item["start_time"],
                "end_time": item["end_time"],
                "description": item.get("notes", ""),
                "priority": item.get("priority", 1),
                "rating": place_data.get("rating") if place_data else item.get("rating", 4.0),
                "user_ratings_total": place_data.get("user_ratings_total") if place_data else None,
                "cost": place_data.get("cost") if place_data else item.get("cost", 0),
                "photo_url": item.get("photo_url") or (place_data.get("image_url") if place_data else None),
                "address": place_data.get("address") if place_data else None,
                # Place data fields
                "external_place_id": item.get("external_place_id") or (place_data.get("external_place_id") if place_data else None),
                "place_id": item.get("place_id"),
                "fsq_id": item.get("fsq_id"),
                "latitude": place_data.get("latitude") if place_data else item.get("latitude"),
                "longitude": place_data.get("longitude") if place_data else item.get("longitude"),
            }
            days_dict[day_idx]["activities"].append(activity)
        
        days = [days_dict[k] for k in sorted(days_dict.keys())]
        
        return ItineraryResponse(
            trip_id=trip_id,
            days=days,
            total_cost=total_cost,
            total_days=len(days),
            optimization_score=itinerary.get("optimization_score"),
            generated_at=itinerary.get("created_at"),
            strategy=itinerary.get("generated_by", "unknown")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get itinerary")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve itinerary"
        )


@router.put("/{trip_id}/recalculate", response_model=ItineraryResponse)
async def recalculate_itinerary(
    trip_id: str,
    request: GenerateItineraryRequest,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Recalculate itinerary with updated preferences"""
    return await generate_trip_itinerary(trip_id, request, user_context)


@router.put("/{trip_id}/itinerary/items/{item_id}")
async def update_itinerary_item(
    trip_id: str,
    item_id: str,
    activity: ItineraryActivity,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Update itinerary activity (creator only)"""
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="creator")
        
        # Verify itinerary exists for this trip
        itinerary = await run_in_threadpool(
            lambda: get_latest_itinerary(trip_id)
        )
        
        if not itinerary:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No itinerary found for this trip"
            )
        
        # Update the specific itinerary item using helper
        patch = {
            "title": activity.name,
            "start_time": activity.start_time,
            "end_time": activity.end_time,
            "notes": activity.description,
            "score": activity.priority if activity.priority else 1
        }
        
        try:
            updated_item = await run_in_threadpool(
                lambda: update_item(item_id, patch)
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Activity item not found in itinerary"
            )
        
        return {
            "message": "Itinerary item updated successfully", 
            "activity": updated_item
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to update itinerary item")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update itinerary item"
        )



@router.post("/{trip_id}/itinerary/items")
async def add_itinerary_item(
    trip_id: str,
    day: int,
    activity: ItineraryActivity,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Add activity to itinerary day (creator only)"""
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="creator")
        
        # Get itinerary for this trip
        itinerary = await run_in_threadpool(
            lambda: get_latest_itinerary(trip_id)
        )
        
        if not itinerary:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No itinerary found for this trip"
            )
        
        itinerary_id = itinerary["id"]
        
        # Insert new activity item using helper
        new_item = {
            "day_index": day,
            "start_time": activity.start_time,
            "end_time": activity.end_time,
            "title": activity.name,
            "notes": activity.description,
            "score": activity.priority if activity.priority else 0.0
        }
        
        await run_in_threadpool(
            lambda: insert_items(itinerary_id, [new_item])
        )
        
        return {
            "message": "Activity added successfully", 
            "activity": new_item
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to add itinerary item")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to add itinerary item"
        )



@router.delete("/{trip_id}/itinerary/items/{item_id}")
async def delete_itinerary_item(
    trip_id: str,
    item_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Remove activity from itinerary (creator only)"""
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="creator")
        
        # Verify itinerary exists for this trip
        itinerary = await run_in_threadpool(
            lambda: get_latest_itinerary(trip_id)
        )
        
        if not itinerary:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No itinerary found for this trip"
            )
        
        # Delete the specific itinerary item using helper
        try:
            await run_in_threadpool(
                lambda: delete_item(item_id)
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Activity item not found in itinerary"
            )
        
        return {"message": "Activity removed successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to delete itinerary item")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete itinerary item"
        )


# ==================== POI Recommendations ====================

@router.get("/{trip_id}/recommendations", response_model=List[RecommendationResponse])
async def get_trip_recommendations(
    trip_id: str,
    user_context: tuple[str, str] = Depends(get_current_user_context),
    limit: int = Query(20, description="Number of recommendations to return")
):
    """Get personalized POI recommendations"""
    user_id, token = user_context
    
    try:
        trip = await check_trip_access(trip_id, user_id, token=token, required_role="view")
        
        db = SupabaseDB(admin=True)
        destination = trip.get("destination", "")
        
        group_prefs_response = await run_in_threadpool(
            lambda: db.client.table("group_models").select("*")
            .eq("trip_id", trip_id)
            .order("created_at", desc=True)
            .limit(1)
            .execute()
        )
        
        group_prefs = group_prefs_response.data[0] if group_prefs_response.data else None
        
        try:
            pois_response = await run_in_threadpool(
                lambda: db.client.table("pois").select("*")
                .ilike("location", f"%{destination}%")
                .order("rating", desc=True)
                .limit(100)
                .execute()
            )
        except Exception:
            pois_response = await run_in_threadpool(
                lambda: db.client.table("pois").select("*")
                .order("rating", desc=True)
                .limit(100)
                .execute()
            )
        
        if not pois_response.data:
            return []
        
        recommendations = []
        for poi in pois_response.data[:limit]:
            score, reason = calculate_poi_score(
                poi,
                group_prefs.get("aggregated_preferences") if group_prefs else {},
                trip
            )
            
            recommendations.append(RecommendationResponse(
                poi=POIResponse(
                    id=poi["id"],
                    name=poi.get("name", ""),
                    type=poi.get("poi_type", ""),
                    location=poi.get("location") or poi.get("formatted_address") or poi.get("city") or destination,
                    description=poi.get("description"),
                    rating=poi.get("rating"),
                    price_level=poi.get("price_level"),
                    image_url=poi.get("image_url"),
                    coordinates=poi.get("coordinates"),
                    tags=poi.get("tags", []),
                    opening_hours=poi.get("opening_hours"),
                    contact=poi.get("contact"),
                    created_at=poi.get("created_at")
                ),
                score=score,
                reason=reason
            ))
        
        recommendations.sort(key=lambda x: x.score, reverse=True)
        
        return recommendations
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to get recommendations")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve recommendations"
        )


@router.post("/{trip_id}/recommendations/selected")
async def mark_recommendations_selected(
    trip_id: str,
    poi_ids: List[str],
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """Mark selected POIs for CF learning"""
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="view")
        
        db = SupabaseDB(admin=True)
        
        for poi_id in poi_ids:
            selection_data = {
                "trip_id": trip_id,
                "poi_id": poi_id,
                "selected": True,
                "selection_type": "user_choice"
            }
            
            await run_in_threadpool(
                lambda: db.client.table("poi_selections").insert(selection_data).execute()
            )
        
        return {
            "message": f"Recorded {len(poi_ids)} POI selections",
            "trip_id": trip_id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to record selections")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to record selections"
        )


# ==================== Place Endpoints ====================

@router.post("/{trip_id}/places/check-duplicate")
async def check_place_duplicate(
    trip_id: str,
    place_data: dict,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """
    Check if a place already exists in the trip.
    
    Duplicate detection rules:
    1. Prefer external_place_id for matching
    2. Fallback to (name + latitude + longitude)
    3. Include trip_id in check
    
    Returns:
    {
        "already_exists": bool,
        "message": str,
        "place_id": str (if exists)
    }
    """
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="view")
        
        external_place_id = place_data.get("external_place_id")
        name = place_data.get("name")
        latitude = place_data.get("latitude")
        longitude = place_data.get("longitude")
        
        db = SupabaseDB(admin=True)
        
        # Try to find by external_place_id first
        if external_place_id:
            result = await run_in_threadpool(
                lambda: db.client.table("trip_places").select("id").eq("trip_id", trip_id).eq("external_place_id", external_place_id).execute()
            )
            
            if result.data:
                return {
                    "already_exists": True,
                    "message": f"This place is already in your trip",
                    "place_id": result.data[0]["id"]
                }
        
        # Fallback to name + lat/lng if no external_place_id
        if name and latitude is not None and longitude is not None:
            result = await run_in_threadpool(
                lambda: db.client.table("trip_places").select("id").eq("trip_id", trip_id).eq("name", name).eq("latitude", latitude).eq("longitude", longitude).execute()
            )
            
            if result.data:
                return {
                    "already_exists": True,
                    "message": f"{name} is already in your trip",
                    "place_id": result.data[0]["id"]
                }
        
        return {
            "already_exists": False,
            "message": "Place is not in trip"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception(f"Failed to check place duplicate: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to check place duplicate"
        )


@router.post("/{trip_id}/places/add")
async def add_place_to_trip(
    trip_id: str,
    place_data: dict,
    user_context: tuple[str, str] = Depends(get_current_user_context)
):
    """
    Add a place to the trip with duplicate detection.
    
    Expected place_data:
    {
        "external_place_id": str,
        "name": str,
        "latitude": float,
        "longitude": float,
        "address": str,
        "rating": float,
        "user_ratings_total": int,
        "types": list,
        "image_url": str (optional)
    }
    
    Returns:
    {
        "success": bool,
        "id": str (place id),
        "already_exists": bool,
        "message": str
    }
    """
    user_id, token = user_context
    
    try:
        await check_trip_access(trip_id, user_id, token=token, required_role="edit")
        
        external_place_id = place_data.get("external_place_id")
        name = place_data.get("name")
        latitude = place_data.get("latitude")
        longitude = place_data.get("longitude")
        address = place_data.get("address", "")
        rating = place_data.get("rating")
        user_ratings_total = place_data.get("user_ratings_total")
        types = place_data.get("types", [])
        image_url = place_data.get("image_url")
        
        if not name or latitude is None or longitude is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Missing required fields: name, latitude, longitude"
            )
        
        db = SupabaseDB(admin=True)
        
        # Check for duplicates first
        # Try external_place_id
        if external_place_id:
            result = await run_in_threadpool(
                lambda: db.client.table("trip_places").select("id").eq("trip_id", trip_id).eq("external_place_id", external_place_id).execute()
            )
            
            if result.data:
                return {
                    "success": False,
                    "already_exists": True,
                    "id": result.data[0]["id"],
                    "message": f"{name} is already in your trip"
                }
        
        # Fallback to name + lat/lng
        result = await run_in_threadpool(
            lambda: db.client.table("trip_places").select("id").eq("trip_id", trip_id).eq("name", name).eq("latitude", latitude).eq("longitude", longitude).execute()
        )
        
        if result.data:
            return {
                "success": False,
                "already_exists": True,
                "id": result.data[0]["id"],
                "message": f"{name} is already in your trip"
            }
        
        # Place doesn't exist, insert it
        place_record = {
            "trip_id": trip_id,
            "name": name,
            "address": address,
            "latitude": latitude,
            "longitude": longitude,
            "rating": rating,
            "user_ratings_total": user_ratings_total,
            "place_types": types,
            "added_by": None,
            "added_at": datetime.utcnow().isoformat()
        }
        
        # Add optional fields only if they have values
        if external_place_id:
            place_record["external_place_id"] = external_place_id
        if image_url:
            place_record["image_url"] = image_url
        
        insert_result = await run_in_threadpool(
            lambda: db.client.table("trip_places").insert(place_record).execute()
        )
        
        if insert_result.data:
            place_id = insert_result.data[0]["id"]
            logger.info(f"Added place {name} ({place_id}) to trip {trip_id}")
            return {
                "success": True,
                "already_exists": False,
                "id": place_id,
                "message": f"✓ {name} added to your trip"
            }
        else:
            raise Exception("Insert returned no data")
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception(f"Failed to add place to trip: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to add place to trip: {str(e)}"
        )


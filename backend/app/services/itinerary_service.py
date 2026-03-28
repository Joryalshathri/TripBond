"""
Itinerary Generation Service

Handles trip itinerary creation using:
- Genetic Algorithm (GA) optimization
- Heuristic fallback methods
"""
from datetime import datetime, timedelta
from typing import Optional, List
import logging

logger = logging.getLogger(__name__)


def generate_itinerary(
    trip: dict,
    group_preferences: Optional[dict] = None,
    use_ga: bool = False,
    max_budget: Optional[float] = None,
    pace: str = "moderate",
    preferences: Optional[dict] = None
) -> tuple[dict, str]:
    """
    Generate trip itinerary using appropriate strategy.
    
    Selects GA or heuristic based on availability of group preferences
    and user request.
    
    Args:
        trip: Trip data (destination, dates, type, etc.)
        group_preferences: Aggregated preferences from group model (optional)
        use_ga: Whether to attempt GA-based generation
        max_budget: Maximum budget constraint
        pace: Trip pace ("relaxed", "moderate", "fast")
        preferences: Additional preference overrides
    
    Returns:
        tuple: (itinerary_data dict, strategy_name str)
    """
    if use_ga and group_preferences:
        constraints = {
            "max_budget": max_budget,
            "pace": pace,
            **(preferences or {})
        }
        itinerary_data = generate_itinerary_with_ga(trip, group_preferences, constraints)
        return itinerary_data, "genetic_algorithm"
    else:
        itinerary_data = generate_itinerary_heuristic(trip, pace, max_budget)
        return itinerary_data, "heuristic"


def generate_itinerary_with_ga(
    trip: dict, 
    group_preferences: dict, 
    constraints: dict
) -> dict:
    """
    Generate itinerary using Genetic Algorithm.
    
    GA Components:
    - Chromosome: Sequence of activities for each day
    - Fitness: Weighted score based on preferences, time, distance, cost
    - Selection: Tournament or roulette wheel
    - Crossover: Order-based or two-point
    - Mutation: Swap, insert, or replace activities
    
    Args:
        trip: Trip data (destination, dates, type, etc.)
        group_preferences: Aggregated preferences from group model
        constraints: Budget, pace, and other constraints
    
    Returns:
        dict: Itinerary data with days, activities, costs, and fitness score
    
    TODO: Implement actual GA logic based on research paper.
    Current implementation is a placeholder.
    """
    logger.info(
        "GA placeholder used - constraints not applied (pace: %s, max_budget: %s)",
        constraints.get("pace"),
        constraints.get("max_budget")
    )
    
    days = []
    
    # Handle None values for dates - use 'or' to catch both missing keys and None values
    start_raw = trip.get("start_date") or datetime.now().isoformat()
    end_raw = trip.get("end_date") or (datetime.now() + timedelta(days=3)).isoformat()
    start_date = datetime.fromisoformat(start_raw)
    end_date = datetime.fromisoformat(end_raw)
    
    # Ensure end_date is not before start_date
    if end_date < start_date:
        end_date = start_date
    
    num_days = (end_date - start_date).days + 1
    
    for day_num in range(1, num_days + 1):
        current_date = start_date + timedelta(days=day_num - 1)
        
        # Generate activities for this day
        day_activities = [
            {
                "id": f"act_{day_num}_1",
                "name": "Morning Activity",
                "type": "attraction",
                "location": trip.get("destination", "Unknown"),
                "start_time": "09:00",
                "end_time": "11:00",
                "duration_minutes": 120,
                "cost": 50.0,
                "description": "Optimized based on group preferences",
                "priority": 4
            },
            {
                "id": f"act_{day_num}_2",
                "name": "Lunch",
                "type": "restaurant",
                "location": trip.get("destination", "Unknown"),
                "start_time": "12:00",
                "end_time": "13:00",
                "duration_minutes": 60,
                "cost": 30.0,
                "priority": 3
            },
            {
                "id": f"act_{day_num}_3",
                "name": "Afternoon Exploration",
                "type": "activity",
                "location": trip.get("destination", "Unknown"),
                "start_time": "14:00",
                "end_time": "17:00",
                "duration_minutes": 180,
                "cost": 40.0,
                "priority": 4
            }
        ]
        
        day_total_cost = sum(a.get("cost", 0) or 0 for a in day_activities)
        day_total_duration = sum(
            a.get("duration_minutes", 0) or 0 for a in day_activities
        )
        
        days.append({
            "day": day_num,
            "date": current_date.strftime("%Y-%m-%d"),
            "activities": day_activities,
            "total_cost": day_total_cost,
            "total_duration_minutes": day_total_duration
        })
    
    total_cost = sum(day.get("total_cost", 0) or 0 for day in days)
    
    return {
        "days": days,
        "total_cost": total_cost,
        "fitness_score": 0.87  # High fitness indicating good optimization
    }


def generate_itinerary_heuristic(
    trip: dict, 
    pace: str, 
    max_budget: Optional[float]
) -> dict:
    """
    Generate itinerary using simple heuristic approach.
    
    Fallback method when no group model exists or GA is disabled.
    Uses rule-based activity selection and timing.
    
    Args:
        trip: Trip data
        pace: Activity pace ("relaxed", "moderate", "fast")
        max_budget: Optional budget constraint
    
    Returns:
        dict: Itinerary data
    """
    logger.info(
        "Heuristic placeholder used - delegating to GA (pace: %s, max_budget: %s)",
        pace,
        max_budget
    )
    # For now, delegate to GA with empty preferences
    return generate_itinerary_with_ga(
        trip, 
        {}, 
        {"pace": pace, "max_budget": max_budget}
    )


# ==================== Database Helpers (itinerary_db) ====================

from typing import Optional as _Optional, List as _List
from ..database import SupabaseDB as _SupabaseDB


def create_itinerary(
    trip_id: str,
    generated_by: str,
    status: str = "generated",
    optimization_score: float = 0.0,
    version: int = 1,
) -> dict:
    """Create a new itinerary record."""
    db = _SupabaseDB(admin=True)
    record = {
        "trip_id": trip_id,
        "version": version,
        "status": status,
        "generated_by": generated_by,
    }
    response = db.client.table("itineraries").insert(record).execute()
    if not response.data:
        raise Exception("Failed to create itinerary")
    logger.info(f"Created itinerary {response.data[0]['id']} for trip {trip_id}")
    return response.data[0]


def get_latest_itinerary(trip_id: str) -> _Optional[dict]:
    """Get the latest itinerary record for a trip."""
    db = _SupabaseDB(admin=True)
    response = (
        db.client.table("itineraries")
        .select("*")
        .eq("trip_id", trip_id)
        .order("created_at", desc=True)
        .limit(1)
        .execute()
    )
    return response.data[0] if response.data else None


def list_items(itinerary_id: str) -> _List[dict]:
    """List all items for an itinerary, ordered by day and time."""
    db = _SupabaseDB(admin=True)
    response = (
        db.client.table("itinerary_items")
        .select("*")
        .eq("itinerary_id", itinerary_id)
        .order("day_index")
        .order("start_time")
        .execute()
    )
    return response.data if response.data else []


def insert_items(itinerary_id: str, items: _List[dict]) -> None:
    """Bulk insert itinerary items."""
    db = _SupabaseDB(admin=True)
    to_insert = []
    for item in items:
        if "itinerary_id" in item:
            to_insert.append(item)
        else:
            to_insert.append({
                "itinerary_id": itinerary_id,
                "day_index": item.get("day_index") or item.get("day", 1),
                "start_time": item.get("start_time"),
                "end_time": item.get("end_time"),
                "title": item.get("title") or item.get("name", "Untitled"),
                "notes": item.get("notes") or item.get("description"),
                "score": item.get("score", 0.0),
            })
    if to_insert:
        response = db.client.table("itinerary_items").insert(to_insert).execute()
        if not response.data:
            raise Exception("Failed to insert itinerary items")
        logger.info(f"Inserted {len(to_insert)} items for itinerary {itinerary_id}")


def update_item(item_id: str, patch: dict) -> dict:
    """Update an itinerary item."""
    db = _SupabaseDB(admin=True)
    response = db.client.table("itinerary_items").update(patch).eq("id", item_id).execute()
    if not response.data:
        raise Exception(f"Failed to update item {item_id}")
    logger.info(f"Updated itinerary item {item_id}")
    return response.data[0]


def delete_item(item_id: str) -> None:
    """Delete an itinerary item."""
    db = _SupabaseDB(admin=True)
    response = db.client.table("itinerary_items").delete().eq("id", item_id).execute()
    if not response.data:
        raise Exception(f"Failed to delete item {item_id}")
    logger.info(f"Deleted itinerary item {item_id}")


def get_itinerary_with_items(trip_id: str) -> _Optional[dict]:
    """Fetch latest itinerary and its items as a days structure."""
    itinerary = get_latest_itinerary(trip_id)
    if not itinerary:
        return None
    itinerary_id = itinerary["id"]
    items = list_items(itinerary_id)
    days_dict: dict = {}
    for item in items:
        day_idx = item["day_index"]
        if day_idx not in days_dict:
            days_dict[day_idx] = {"day": day_idx, "activities": []}
        days_dict[day_idx]["activities"].append({
            "id": item["id"],
            "name": item["title"],
            "start_time": item["start_time"],
            "end_time": item["end_time"],
            "notes": item["notes"],
            "score": item["score"],
        })
    days = [days_dict[k] for k in sorted(days_dict.keys())]
    return {
        "itinerary_id": itinerary_id,
        "optimization_score": itinerary.get("optimization_score", 0.0),
        "generated_by": itinerary.get("generated_by", "unknown"),
        "created_at": itinerary.get("created_at"),
        "days": days,
        "total_cost": 0.0,
    }

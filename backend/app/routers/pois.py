from fastapi import APIRouter, HTTPException, status, Query
from typing import List, Optional
from ..schemas.pois import POIResponse
from ..services import poi_service, ai_poi_service

router = APIRouter()


@router.get("/", response_model=List)
async def search_pois(
    location: Optional[str] = Query(None, description="Filter by location"),
    type: Optional[str] = Query(None, description="Filter by type (attraction, restaurant, etc.)"),
    min_rating: Optional[float] = Query(None, description="Minimum rating (0-5)"),
    max_price_level: Optional[int] = Query(None, description="Maximum price level (1-4)"),
    tags: Optional[str] = Query(None, description="Comma-separated tags to filter by"),
    limit: int = Query(50, description="Maximum number of results"),
):
    """Search and filter Points of Interest (POIs) using AI backend dataset."""
    try:
        # Use AI POI service if location is provided, otherwise query database
        if location:
            pois = ai_poi_service.get_pois_for_destination(location, limit=limit)
            # Filter by type if provided
            if type and pois:
                pois = [p for p in pois if p.get('category', '').lower() == type.lower()]
            return pois
        
        # Fallback to database query if no location provided
        return poi_service.search_pois(
            location=location,
            poi_type=type,
            min_rating=min_rating,
            max_price_level=max_price_level,
            tags=tags,
            limit=limit,
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to search POIs: {str(e)}",
        )


@router.get("/{poi_id}", response_model=POIResponse)
async def get_poi_detail(poi_id: str):
    """Get detailed information about a specific POI."""
    try:
        return poi_service.get_poi_by_id(poi_id)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get POI details: {str(e)}",
        )

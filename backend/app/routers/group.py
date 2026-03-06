from fastapi import APIRouter, HTTPException, status
from ..schemas.group import (
    GroupAggregationRequest,
    GAOptimizationRequest,
    GroupPreferenceModel,
    OptimizationResult,
)
from ..services import group_service

router = APIRouter()


@router.post("/{trip_id}/aggregate", response_model=GroupPreferenceModel)
async def aggregate_group_preferences(trip_id: str, request: GroupAggregationRequest):
    """
    Aggregate preferences from multiple group members using specified strategy.

    Strategies: least_misery, average, majority_rule, weighted_average, most_pleasure
    """
    try:
        return group_service.aggregate_group_preferences(trip_id, request)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to aggregate group preferences: {str(e)}",
        )


@router.post("/{trip_id}/optimize", response_model=OptimizationResult)
async def optimize_group_recommendations(trip_id: str, request: GAOptimizationRequest):
    """Use Genetic Algorithm to optimize recommendations for the group."""
    try:
        return group_service.optimize_group_recommendations(trip_id, request)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to optimize recommendations: {str(e)}",
        )

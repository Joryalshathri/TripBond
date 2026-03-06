"""
Authentication Dependencies

FastAPI dependencies for user authentication and authorization.
Prevents circular imports between routers by centralizing auth logic.
"""
from fastapi import Depends, HTTPException, status
from fastapi.concurrency import run_in_threadpool
from .database import get_current_user_token, get_supabase_client_for_user
import logging

logger = logging.getLogger(__name__)


async def get_current_user_context(token: str = Depends(get_current_user_token)) -> tuple[str, str]:
    """
    FastAPI dependency to extract user ID and token from authenticated JWT
    
    Validates the token with Supabase to prevent forgery.
    
    Returns:
        Tuple of (user_id, token) for endpoints that need both RLS client and user validation
    
    Raises:
        HTTPException: If token is invalid or user cannot be retrieved
    """
    try:
        client = get_supabase_client_for_user(token)
        # Wrap sync Supabase call in threadpool to avoid blocking
        user = await run_in_threadpool(lambda: client.auth.get_user(token))
        
        if not user or not user.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication token"
            )
        
        return user.user.id, token
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to extract user from token")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed"
        )

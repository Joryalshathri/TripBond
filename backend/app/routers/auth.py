from fastapi import APIRouter, HTTPException, status, Depends
from ..database import SupabaseDB, get_current_user_token, get_supabase_client_for_user
from ..config import get_settings
from ..schemas.auth import (
    SignUpRequest,
    SignInRequest,
    AuthResponse,
    PasswordResetRequest,
    UpdatePasswordRequest,
    VerifyEmailRequest,
    ResendVerificationRequest,
)
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/signup", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
async def sign_up(request: SignUpRequest):
    """
    Register a new user with email and password
    """
    try:
        db = SupabaseDB()
        config = get_settings()
        
        # Create user with Supabase Auth
        response = db.client.auth.sign_up(
            credentials={
                "email": request.email,
                "password": request.password,
                "options": {
                    "data": {
                        "full_name": request.full_name
                    },
                    "email_redirect_to": f"{config.frontend_url}/verify-email"
                }
            }
        )
        
        if not response.user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create user. Email may already be in use."
            )
        
        # Create profile in profiles table
        profile_data = {
            "id": response.user.id,  # Foreign key to auth.users
            "email": response.user.email,  # Store email for easy access
            "full_name": request.full_name,
            "date_of_birth": request.date_of_birth.isoformat() if request.date_of_birth else None,
            "phone_number": request.phone_number,
            "gender": request.gender,
            "openness": request.openness,
            "conscientiousness": request.conscientiousness,
            "extraversion": request.extraversion,
            "agreeableness": request.agreeableness,
            "neuroticism": request.neuroticism,
            "budget_level": request.budget_level,
            "travel_style": request.travel_style,
            "dietary_preferences": request.dietary_preferences,
            "preferred_accommodation": request.preferred_accommodation,
            "preferred_transport": request.preferred_transport
        }
        
        # Insert profile (ignore None values)
        profile_data = {k: v for k, v in profile_data.items() if v is not None}
        db.client.table("profiles").insert(profile_data).execute()
        
        # Note: access_token may be empty if email confirmation is required
        return AuthResponse(
            access_token=response.session.access_token if response.session else "",
            user={
                "id": response.user.id,
                "email": response.user.email,
                "full_name": request.full_name
            },
            message="Account created successfully! Please check your email to verify your account."
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Signup failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Signup failed. Please try again."
        )


@router.post("/signin", response_model=AuthResponse)
async def sign_in(request: SignInRequest):
    """
    Sign in user with email and password
    """
    try:
        db = SupabaseDB()
        
        # Sign in with Supabase Auth
        response = db.client.auth.sign_in_with_password(
            credentials={
                "email": request.email,
                "password": request.password
            }
        )
        
        if not response.user or not response.session:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Get user profile
        # TODO: Refactor to use get_supabase_client_for_user(response.session.access_token)
        profile = db.get_user_preferences(response.user.id)
        if hasattr(profile, '__await__'):
            profile = await profile
        
        return AuthResponse(
            access_token=response.session.access_token,
            user={
                "id": response.user.id,
                "email": response.user.email,
                "full_name": profile.get("full_name") if profile else None,
                "username": profile.get("username") if profile else None,
                "avatar_url": profile.get("avatar_url") if profile else None
            },
            message="Signed in successfully!"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Sign in failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Sign in failed. Please check your credentials."
        )


@router.post("/signout")
async def sign_out(token: str = Depends(get_current_user_token)):
    """
    Sign out the current user
    
    Requires: Authorization header with Bearer token
    
    Note: In Supabase architecture, signout is typically handled client-side
    by clearing the local session. This endpoint provides server-side revocation
    if needed, but frontend should still clear local storage.
    """
    try:
        # Use user-authenticated client to sign out the specific session
        client = get_supabase_client_for_user(token)
        client.auth.sign_out()
        
        return {"message": "Signed out successfully. Please clear your local session."}
        
    except Exception as e:
        logger.exception("Sign out failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Sign out failed. Please try again."
        )


@router.post("/reset-password")
async def reset_password(request: PasswordResetRequest):
    """
    Send password reset email to user
    """
    try:
        db = SupabaseDB()
        config = get_settings()
        
        db.client.auth.reset_password_for_email(
            request.email,
            options={
                "redirect_to": f"{config.frontend_url}/reset-password"
            }
        )
        
        return {
            "message": f"If an account exists with {request.email}, you will receive a password reset email."
        }
        
    except Exception as e:
        logger.exception("Password reset request failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Password reset request failed. Please try again."
        )


@router.post("/update-password")
async def update_password(
    request: UpdatePasswordRequest,
    token: str = Depends(get_current_user_token)
):
    """
    Update password for authenticated user
    
    Requires: Authorization header with valid JWT access token.
    
    Flow:
    1. User requests password reset via /reset-password
    2. Receives email with reset link (format depends on Supabase config)
    3. Frontend handles the reset link and extracts/exchanges for access token
    4. Frontend calls this endpoint with Authorization: Bearer <access_token>
    5. Password is updated for the authenticated user
    
    Note: Supabase password reset links may contain access_token directly,
    or may require an additional exchange step depending on your configuration.
    Frontend must provide a valid JWT access token in the Authorization header.
    
    Alternative: Use Supabase client-side updateUser() directly from frontend
    for simpler flow and better cross-version compatibility.
    """
    try:
        # Use user-authenticated client so Supabase knows which user to update
        client = get_supabase_client_for_user(token)
        
        # Update the user's password using their authenticated session
        response = client.auth.update_user({
            "password": request.new_password
        })
        
        if not response.user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to update password. Please try again or request a new reset link."
            )
        
        return {
            "message": "Password updated successfully! You can now sign in with your new password."
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Password update failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Password update failed. Please try again."
        )


@router.post("/verify-email")
async def verify_email(request: VerifyEmailRequest):
    """
    Verify user email with token hash from verification email
    Token hash is received from the verification email link
    """
    try:
        db = SupabaseDB()
        
        # Verify the OTP/token
        response = db.client.auth.verify_otp({
            "token_hash": request.token_hash,
            "type": request.type
        })
        
        if not response.user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired verification token"
            )
        
        return {
            "message": "Email verified successfully! You can now sign in.",
            "user": {
                "id": response.user.id,
                "email": response.user.email,
                "email_confirmed_at": response.user.email_confirmed_at
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Email verification failed")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email verification failed. The link may be invalid or expired."
        )


@router.post("/resend-verification")
async def resend_verification_email(request: ResendVerificationRequest):
    """
    Resend verification email to user
    """
    try:
        db = SupabaseDB()
        
        # Resend verification email
        db.client.auth.resend({
            "type": "signup",
            "email": request.email
        })
        
        return {
            "message": f"Verification email sent to {request.email}. Please check your inbox."
        }
        
    except Exception as e:
        logger.exception("Failed to resend verification email")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to resend verification email. Please try again."
        )

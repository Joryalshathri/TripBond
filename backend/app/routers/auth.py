from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import date
from ..database import SupabaseDB
from supabase import Client

router = APIRouter()


class SignUpRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: Optional[str] = None
    date_of_birth: Optional[date] = None
    phone_number: Optional[str] = None
    gender: Optional[str] = None  # 'male', 'female', 'other'
    # Personality traits (Big Five)
    openness: Optional[float] = None
    conscientiousness: Optional[float] = None
    extraversion: Optional[float] = None
    agreeableness: Optional[float] = None
    neuroticism: Optional[float] = None
    # Travel preferences
    budget_level: Optional[str] = None  # 'low', 'medium', 'high'
    travel_style: Optional[str] = None  # 'adventure', 'relax', 'cultural', 'luxury'
    dietary_preferences: Optional[str] = None
    preferred_accommodation: Optional[str] = None
    preferred_transport: Optional[str] = None


class SignInRequest(BaseModel):
    email: EmailStr
    password: str


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: dict
    message: str


class PasswordResetRequest(BaseModel):
    email: EmailStr


class UpdatePasswordRequest(BaseModel):
    access_token: str
    new_password: str


@router.post("/signup", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
async def sign_up(request: SignUpRequest):
    """
    Register a new user with email and password
    """
    try:
        db = SupabaseDB()
        
        # Create user with Supabase Auth
        response = db.client.auth.sign_up(
            credentials={
                "email": request.email,
                "password": request.password,
                "options": {
                    "data": {
                        "full_name": request.full_name
                    }
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
        
        return AuthResponse(
            access_token=response.session.access_token if response.session else "",
            user={
                "id": response.user.id,
                "email": response.user.email,
                "full_name": request.full_name
            },
            message="Account created successfully! Please check your email to verify your account."
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Signup failed: {str(e)}"
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
        profile = await db.get_user_preferences(response.user.id)
        
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
        # Log the detailed error for debugging
        import traceback
        print(f"Sign in error: {str(e)}")
        print(traceback.format_exc())
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Sign in failed: {str(e)}"
        )


@router.post("/signout")
async def sign_out():
    """
    Sign out the current user
    """
    try:
        db = SupabaseDB()
        db.client.auth.sign_out()
        
        return {"message": "Signed out successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Sign out failed: {str(e)}"
        )


@router.post("/reset-password")
async def reset_password(request: PasswordResetRequest):
    """
    Send password reset email to user
    """
    try:
        db = SupabaseDB()
        
        db.client.auth.reset_password_for_email(request.email)
        
        return {
            "message": f"If an account exists with {request.email}, you will receive a password reset email."
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Password reset failed: {str(e)}"
        )


@router.post("/update-password")
async def update_password(request: UpdatePasswordRequest):
    """
    Update password using access token from reset email
    User receives access_token from password reset email link
    """
    try:
        db = SupabaseDB()
        
        # Set the session with the access token from the reset email
        db.client.auth.set_session(request.access_token, request.access_token)
        
        # Update the user's password
        response = db.client.auth.update_user({
            "password": request.new_password
        })
        
        if not response.user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to update password. Token may be invalid or expired."
            )
        
        return {
            "message": "Password updated successfully! You can now sign in with your new password."
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Password update failed: {str(e)}"
        )


@router.get("/me")
async def get_current_user():
    """
    Get current authenticated user information
    Requires valid auth token in Authorization header
    """
    try:
        db = SupabaseDB()
        user = db.client.auth.get_user()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Not authenticated"
            )
        
        # Get user profile
        profile = await db.get_user_preferences(user.user.id)
        
        return {
            "id": user.user.id,
            "email": user.user.email,
            "profile": profile
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get user: {str(e)}"
        )


@router.post("/verify-email")
async def verify_email(token: str):
    """
    Verify user email with token from email
    """
    try:
        db = SupabaseDB()
        
        response = db.client.auth.verify_otp({
            "token": token,
            "type": "email"
        })
        
        return {
            "message": "Email verified successfully!",
            "user": response.user
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Email verification failed: {str(e)}"
        )

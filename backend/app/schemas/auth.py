"""
Authentication Schemas

Pydantic models for request/response validation in auth endpoints.
"""
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import date


class SignUpRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: Optional[str] = None
    date_of_birth: Optional[date] = None
    phone_number: Optional[str] = None
    gender: Optional[str] = None  # 'male', 'female'
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
    new_password: str


class VerifyEmailRequest(BaseModel):
    token_hash: str
    type: str = "email"  # 'email', 'signup'


class ResendVerificationRequest(BaseModel):
    email: EmailStr

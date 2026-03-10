"""
Authentication Schemas

Pydantic models for request/response validation in auth endpoints.
"""
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import date


class SignUpRequest(BaseModel):
    # Basic registration info only
    email: EmailStr
    password: str
    full_name: str
    date_of_birth: Optional[date] = None
    phone_number: Optional[str] = None
    gender: Optional[str] = None  # 'male', 'female'


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

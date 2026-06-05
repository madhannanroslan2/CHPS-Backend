from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    role: Optional[str] = "user"
    full_name: Optional[str] = None

class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None
    is_active: Optional[bool] = None
    role: Optional[str] = None
    full_name: Optional[str] = None
    position: Optional[str] = None
    municipality: Optional[str] = None
    barangay: Optional[str] = None
    onboarding_complete: Optional[bool] = None

class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    is_active: bool
    role: str
    full_name: Optional[str] = None
    position: Optional[str] = None
    municipality: Optional[str] = None
    barangay: Optional[str] = None
    onboarding_complete: bool = False
    status: str = "pending"
    approved_by: Optional[int] = None
    approved_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True

class LoginResponse(BaseModel):
    access_token: str
    token_type: str
    role: str
    user_id: int
    full_name: Optional[str] = None
    status: str = "pending"
    onboarding_complete: bool = False

class UpdateCredentialsRequest(BaseModel):
    email: str
    password: str
    username: Optional[str] = None
    position: Optional[str] = None

class UpdateProfileRequest(BaseModel):
    username: Optional[str] = None
    position: Optional[str] = None

class OnboardingUpdate(BaseModel):
    position: str
    municipality: str
    barangay: str
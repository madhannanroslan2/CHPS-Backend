import os
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from app.database.connection import get_db
from app.models.user_model import UserModel
from app.schemas.user_schema import UserCreate, UserUpdate, UserResponse, LoginResponse, UpdateCredentialsRequest, UpdateProfileRequest, OnboardingUpdate
from app.security import hash_password, verify_password, create_access_token, get_current_user, require_admin
from typing import List
from pydantic import BaseModel

router = APIRouter(prefix="/users", tags=["Users"])

GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")

class GoogleAuthRequest(BaseModel):
    id_token: str

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    if db.query(UserModel).filter(UserModel.email == user.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    new_user = UserModel(
        username=user.username,
        email=user.email,
        hashed_password=hash_password(user.password),
        role=user.role or "user",
        full_name=user.full_name,
        status="pending"
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.post("/login", response_model=LoginResponse)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(UserModel).filter(UserModel.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect email or password")
    token = create_access_token(data={"sub": user.email, "role": user.role, "user_id": user.id, "full_name": user.full_name, "status": user.status, "onboarding_complete": user.onboarding_complete, "position": user.position, "username": user.username})
    return {"access_token": token, "token_type": "bearer", "role": user.role, "user_id": user.id, "full_name": user.full_name, "status": user.status, "onboarding_complete": user.onboarding_complete, "position": user.position, "username": user.username}

@router.post("/auth/google")
def google_auth(req: GoogleAuthRequest, db: Session = Depends(get_db)):
    if not GOOGLE_CLIENT_ID:
        raise HTTPException(status_code=501, detail="Google sign-in is not configured. Set GOOGLE_CLIENT_ID in the backend .env file.")
    try:
        info = id_token.verify_oauth2_token(req.id_token, google_requests.Request(), GOOGLE_CLIENT_ID)
        email = info.get("email")
        if not email:
            raise HTTPException(status_code=400, detail="No email from Google")
        user = db.query(UserModel).filter(UserModel.email == email).first()
        if not user:
            username = info.get("name", email.split("@")[0])
            user = UserModel(
                username=username,
                email=email,
                hashed_password=hash_password("google_oauth_user"),
                role="user",
                full_name=info.get("name"),
                status="pending"
            )
            db.add(user)
            db.commit()
            db.refresh(user)
        token = create_access_token(data={"sub": user.email, "role": user.role, "user_id": user.id, "full_name": user.full_name, "status": user.status, "onboarding_complete": user.onboarding_complete, "position": user.position, "username": user.username})
        return {"access_token": token, "token_type": "bearer", "role": user.role, "user_id": user.id, "full_name": user.full_name, "status": user.status, "onboarding_complete": user.onboarding_complete, "position": user.position, "username": user.username}
    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid Google token")

@router.post("/seed-admin", status_code=status.HTTP_200_OK)
def seed_admin(db: Session = Depends(get_db)):
    admin_email = "admin@chps.com"
    existing = db.query(UserModel).filter(UserModel.email == admin_email).first()
    if existing:
        if existing.role != "admin":
            existing.role = "admin"
            existing.status = "approved"
            db.commit()
            db.refresh(existing)
            return {"message": "Existing user promoted to admin", "email": existing.email}
        raise HTTPException(status_code=400, detail="Admin already exists")
    existing_username = db.query(UserModel).filter(UserModel.username == "admin").first()
    username = "chps_admin" if existing_username else "admin"
    admin = UserModel(
        username=username,
        email=admin_email,
        hashed_password=hash_password("admin123"),
        role="admin",
        status="approved"
    )
    db.add(admin)
    db.commit()
    db.refresh(admin)
    return {"message": "Admin created", "email": admin.email, "password": "admin123", "username": username}

@router.get("/pending", response_model=List[UserResponse])
def get_pending_users(db: Session = Depends(get_db), current_user: UserModel = Depends(require_admin)):
    return db.query(UserModel).filter(UserModel.status == "pending").all()

@router.put("/{id}/approve", response_model=UserResponse)
def approve_user(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(require_admin)):
    user = db.query(UserModel).filter(UserModel.id == id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.status = "approved"
    user.approved_by = current_user.id
    user.approved_at = datetime.utcnow()
    db.commit()
    db.refresh(user)
    return user

@router.put("/{id}/reject", response_model=UserResponse)
def reject_user(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(require_admin)):
    user = db.query(UserModel).filter(UserModel.id == id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.status = "rejected"
    user.approved_by = current_user.id
    user.approved_at = datetime.utcnow()
    db.commit()
    db.refresh(user)
    return user

@router.get("", response_model=List[UserResponse])
def get_users(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return db.query(UserModel).all()

@router.get("/{id}", response_model=UserResponse)
def get_user_by_id(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    user = db.query(UserModel).filter(UserModel.id == id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.put("/me/credentials")
def update_my_credentials(data: UpdateCredentialsRequest, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    if data.email != current_user.email:
        if db.query(UserModel).filter(UserModel.email == data.email).first():
            raise HTTPException(status_code=400, detail="Email already taken")
    if len(data.password) < 6:
        raise HTTPException(status_code=400, detail="Password must be at least 6 characters")
    current_user.email = data.email
    current_user.hashed_password = hash_password(data.password)
    if data.username is not None and data.username != current_user.username:
        if db.query(UserModel).filter(UserModel.username == data.username).first():
            raise HTTPException(status_code=400, detail="Username already taken")
        current_user.username = data.username
    if data.position is not None:
        current_user.position = data.position
    db.commit()
    return {"message": "Credentials updated. Please log in with your new credentials."}

@router.get("/me/profile", response_model=UserResponse)
def get_my_profile(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return current_user

@router.put("/me/profile", response_model=UserResponse)
def update_my_profile(data: UpdateProfileRequest, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    if data.username is not None and data.username != current_user.username:
        if db.query(UserModel).filter(UserModel.username == data.username).first():
            raise HTTPException(status_code=400, detail="Username already taken")
        current_user.username = data.username
    if data.position is not None:
        current_user.position = data.position
    db.commit()
    db.refresh(current_user)
    return current_user

@router.put("/me/onboarding", response_model=UserResponse)
def update_onboarding(data: OnboardingUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    current_user.position = data.position
    current_user.municipality = data.municipality
    current_user.barangay = data.barangay
    current_user.onboarding_complete = True
    db.commit()
    db.refresh(current_user)
    return current_user

@router.put("/{id}", response_model=UserResponse)
def update_user(id: int, data: UserUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    user = db.query(UserModel).filter(UserModel.id == id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if data.email and data.email != user.email:
        if db.query(UserModel).filter(UserModel.email == data.email).first():
            raise HTTPException(status_code=400, detail="Email already taken")
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(user, key, val)
    db.commit()
    db.refresh(user)
    return user

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    user = db.query(UserModel).filter(UserModel.id == id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(user)
    db.commit()
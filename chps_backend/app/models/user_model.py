from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database.connection import Base

class UserModel(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    role = Column(String, default="user")  # "admin" or "user"
    full_name = Column(String, nullable=True)
    position = Column(String, nullable=True)
    municipality = Column(String, nullable=True)
    barangay = Column(String, nullable=True)
    onboarding_complete = Column(Boolean, default=False)
    status = Column(String, default="pending", nullable=False)
    approved_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    approved_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    approver = relationship("UserModel", foreign_keys=[approved_by], remote_side=[id])
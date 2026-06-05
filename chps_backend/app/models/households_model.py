from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database.connection import Base

class HouseholdModel(Base):
    __tablename__ = "households"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    household_number = Column(String, unique=True, index=True, nullable=False)
    head_of_family = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("UserModel", foreign_keys=[user_id])
    residents = relationship("ResidentModel", back_populates="household", cascade="all, delete-orphan")
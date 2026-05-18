from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database.connection import Base

class HouseholdModel(Base):
    __tablename__ = "households"

    id = Column(Integer, primary_key=True, index=True)
    household_number = Column(String, unique=True, index=True, nullable=False)
    purok = Column(String, nullable=False)
    head_of_family = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    residents = relationship("ResidentModel", back_populates="household", cascade="all, delete-orphan")
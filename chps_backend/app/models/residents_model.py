from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database.connection import Base

class ResidentModel(Base):
    __tablename__ = "residents"

    id = Column(Integer, primary_key=True, index=True)
    household_id = Column(Integer, ForeignKey("households.id", ondelete="CASCADE"), nullable=False)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    gender = Column(String, nullable=False)
    birth_date = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    household = relationship("HouseholdModel", back_populates="residents")
    immunizations = relationship("ImmunizationModel", back_populates="resident", cascade="all, delete-orphan")
    medical_histories = relationship("MedicalHistoryModel", back_populates="resident", cascade="all, delete-orphan")
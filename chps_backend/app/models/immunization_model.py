from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database.connection import Base

class ImmunizationModel(Base):
    __tablename__ = "immunizations"

    id = Column(Integer, primary_key=True, index=True)
    resident_id = Column(Integer, ForeignKey("residents.id", ondelete="CASCADE"), nullable=False)
    vaccine_name = Column(String, nullable=False)
    dose_number = Column(Integer, nullable=False)
    administered_by = Column(String, nullable=False)
    date_given = Column(DateTime, default=datetime.utcnow)

    resident = relationship("ResidentModel", back_populates="immunizations")
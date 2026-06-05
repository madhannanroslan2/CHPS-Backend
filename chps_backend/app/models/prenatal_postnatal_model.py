from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database.connection import Base

class PrenatalPostnatalModel(Base):
    __tablename__ = "prenatal_postnatal"

    id = Column(Integer, primary_key=True, index=True)
    resident_id = Column(Integer, ForeignKey("residents.id", ondelete="CASCADE"), nullable=False)
    care_type = Column(String, nullable=False)
    date_given = Column(DateTime, default=datetime.utcnow)
    administered_by = Column(String, nullable=False)
    notes = Column(String, nullable=True)

    resident = relationship("ResidentModel", back_populates="prenatal_postnatal")

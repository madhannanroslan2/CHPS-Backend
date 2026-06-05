from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database.connection import Base

class MedicalHistoryModel(Base):
    __tablename__ = "medical_histories"

    id = Column(Integer, primary_key=True, index=True)
    resident_id = Column(Integer, ForeignKey("residents.id", ondelete="CASCADE"), nullable=False)
    diagnosis = Column(String, nullable=False)
    treatment = Column(String, nullable=True)
    remarks = Column(String, nullable=True)
    checkup_date = Column(DateTime, default=datetime.utcnow)
    disease_type = Column(String, nullable=True)

    resident = relationship("ResidentModel", back_populates="medical_histories")
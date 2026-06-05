from sqlalchemy import Column, Integer, String, DateTime, Date, Text
from datetime import datetime
from app.database.connection import Base

class ReportModel(Base):
    __tablename__ = "reports"

    id = Column(Integer, primary_key=True, index=True)
    report_title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    generated_by = Column(String, nullable=False)
    municipality = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    report_type = Column(String, nullable=True)
    date_generated = Column(Date, nullable=True)
    reporting_period_start = Column(Date, nullable=True)
    reporting_period_end = Column(Date, nullable=True)
    barangay = Column(String, nullable=True)

    disease_dengue = Column(Integer, nullable=True, default=0)
    disease_cough_cold = Column(Integer, nullable=True, default=0)
    disease_hypertension = Column(Integer, nullable=True, default=0)
    disease_diabetes = Column(Integer, nullable=True, default=0)
    disease_other = Column(Integer, nullable=True, default=0)

    total_patients_served = Column(Integer, nullable=True, default=0)
    total_consultations = Column(Integer, nullable=True, default=0)
    total_vaccinations = Column(Integer, nullable=True, default=0)
    prenatal_visits = Column(Integer, nullable=True, default=0)
    postnatal_visits = Column(Integer, nullable=True, default=0)
    health_education_activities = Column(Integer, nullable=True, default=0)

    medicine_available = Column(String, nullable=True)
    medicine_low_stock = Column(String, nullable=True)
    medicine_out_of_stock = Column(String, nullable=True)

    remarks = Column(Text, nullable=True)
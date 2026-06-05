from pydantic import BaseModel
from datetime import datetime, date
from typing import Optional

class ReportCreate(BaseModel):
    report_title: str
    description: Optional[str] = None
    generated_by: str
    report_type: Optional[str] = None
    date_generated: Optional[date] = None
    reporting_period_start: Optional[date] = None
    reporting_period_end: Optional[date] = None
    municipality: Optional[str] = None
    barangay: Optional[str] = None
    disease_dengue: Optional[int] = 0
    disease_cough_cold: Optional[int] = 0
    disease_hypertension: Optional[int] = 0
    disease_diabetes: Optional[int] = 0
    disease_other: Optional[int] = 0
    total_patients_served: Optional[int] = 0
    total_consultations: Optional[int] = 0
    total_vaccinations: Optional[int] = 0
    prenatal_visits: Optional[int] = 0
    postnatal_visits: Optional[int] = 0
    health_education_activities: Optional[int] = 0
    medicine_available: Optional[str] = None
    medicine_low_stock: Optional[str] = None
    medicine_out_of_stock: Optional[str] = None
    remarks: Optional[str] = None

class ReportUpdate(BaseModel):
    report_title: Optional[str] = None
    description: Optional[str] = None
    generated_by: Optional[str] = None
    report_type: Optional[str] = None
    date_generated: Optional[date] = None
    reporting_period_start: Optional[date] = None
    reporting_period_end: Optional[date] = None
    municipality: Optional[str] = None
    barangay: Optional[str] = None
    disease_dengue: Optional[int] = None
    disease_cough_cold: Optional[int] = None
    disease_hypertension: Optional[int] = None
    disease_diabetes: Optional[int] = None
    disease_other: Optional[int] = None
    total_patients_served: Optional[int] = None
    total_consultations: Optional[int] = None
    total_vaccinations: Optional[int] = None
    prenatal_visits: Optional[int] = None
    postnatal_visits: Optional[int] = None
    health_education_activities: Optional[int] = None
    medicine_available: Optional[str] = None
    medicine_low_stock: Optional[str] = None
    medicine_out_of_stock: Optional[str] = None
    remarks: Optional[str] = None

class ReportResponse(BaseModel):
    id: int
    report_title: str
    description: Optional[str] = None
    generated_by: str
    municipality: Optional[str] = None
    created_at: datetime
    report_type: Optional[str] = None
    date_generated: Optional[date] = None
    reporting_period_start: Optional[date] = None
    reporting_period_end: Optional[date] = None
    barangay: Optional[str] = None
    disease_dengue: Optional[int] = None
    disease_cough_cold: Optional[int] = None
    disease_hypertension: Optional[int] = None
    disease_diabetes: Optional[int] = None
    disease_other: Optional[int] = None
    total_patients_served: Optional[int] = None
    total_consultations: Optional[int] = None
    total_vaccinations: Optional[int] = None
    prenatal_visits: Optional[int] = None
    postnatal_visits: Optional[int] = None
    health_education_activities: Optional[int] = None
    medicine_available: Optional[str] = None
    medicine_low_stock: Optional[str] = None
    medicine_out_of_stock: Optional[str] = None
    remarks: Optional[str] = None

    class Config:
        from_attributes = True
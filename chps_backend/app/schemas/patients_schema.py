from pydantic import BaseModel
from typing import Optional

class ImmunizationItem(BaseModel):
    vaccine_name: str
    dose_number: int
    administered_by: str
    date_given: Optional[str] = None

class MedicalHistoryItem(BaseModel):
    diagnosis: str
    treatment: Optional[str] = None
    remarks: Optional[str] = None
    checkup_date: Optional[str] = None
    disease_type: Optional[str] = None

class PrenatalPostnatalItem(BaseModel):
    care_type: str
    date_given: Optional[str] = None
    administered_by: str
    notes: Optional[str] = None

class PatientResponse(BaseModel):
    id: int
    household_id: int
    first_name: str
    last_name: str
    gender: str
    birth_date: str
    age: Optional[int] = None
    contact_number: Optional[str] = None
    household_number: Optional[str] = None
    head_of_family: Optional[str] = None
    municipality: Optional[str] = None
    barangay: Optional[str] = None
    purok: Optional[str] = None
    immunizations: list[ImmunizationItem] = []
    medical_histories: list[MedicalHistoryItem] = []
    prenatal_postnatal: list[PrenatalPostnatalItem] = []

    class Config:
        from_attributes = True

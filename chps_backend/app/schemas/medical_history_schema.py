from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class MedicalHistoryCreate(BaseModel):
    resident_id: int
    diagnosis: str
    treatment: Optional[str] = None
    remarks: Optional[str] = None
    disease_type: Optional[str] = None

class MedicalHistoryUpdate(BaseModel):
    diagnosis: Optional[str] = None
    treatment: Optional[str] = None
    remarks: Optional[str] = None
    disease_type: Optional[str] = None

class MedicalHistoryResponse(BaseModel):
    id: int
    resident_id: int
    diagnosis: str
    treatment: Optional[str]
    remarks: Optional[str]
    checkup_date: datetime
    disease_type: Optional[str] = None

    class Config:
        from_attributes = True
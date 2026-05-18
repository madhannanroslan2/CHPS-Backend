from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class ImmunizationCreate(BaseModel):
    resident_id: int
    vaccine_name: str
    dose_number: int
    administered_by: str

class ImmunizationUpdate(BaseModel):
    vaccine_name: Optional[str] = None
    dose_number: Optional[int] = None
    administered_by: Optional[str] = None

class ImmunizationResponse(BaseModel):
    id: int
    resident_id: int
    vaccine_name: str
    dose_number: int
    administered_by: str
    date_given: datetime

    class Config:
        from_attributes = True
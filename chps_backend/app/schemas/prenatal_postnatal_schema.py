from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class PrenatalPostnatalCreate(BaseModel):
    resident_id: int
    care_type: str
    administered_by: str
    notes: Optional[str] = None

class PrenatalPostnatalUpdate(BaseModel):
    care_type: Optional[str] = None
    administered_by: Optional[str] = None
    notes: Optional[str] = None

class PrenatalPostnatalResponse(BaseModel):
    id: int
    resident_id: int
    care_type: str
    date_given: datetime
    administered_by: str
    notes: Optional[str] = None

    class Config:
        from_attributes = True

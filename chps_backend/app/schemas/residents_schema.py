from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class ResidentCreate(BaseModel):
    household_id: int
    first_name: str
    last_name: str
    gender: str
    birth_date: str
    age: Optional[int] = None
    contact_number: Optional[str] = None

class ResidentUpdate(BaseModel):
    household_id: Optional[int] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    gender: Optional[str] = None
    birth_date: Optional[str] = None
    age: Optional[int] = None
    contact_number: Optional[str] = None

class ResidentResponse(BaseModel):
    id: int
    household_id: int
    first_name: str
    last_name: str
    gender: str
    birth_date: str
    age: Optional[int] = None
    contact_number: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
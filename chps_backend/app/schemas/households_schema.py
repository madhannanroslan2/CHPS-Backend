from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class HouseholdCreate(BaseModel):
    household_number: str
    head_of_family: str

class HouseholdUpdate(BaseModel):
    head_of_family: Optional[str] = None

class HouseholdResponse(BaseModel):
    id: int
    user_id: int
    household_number: str
    head_of_family: str
    created_at: datetime

    class Config:
        from_attributes = True
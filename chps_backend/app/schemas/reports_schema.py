from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class ReportCreate(BaseModel):
    report_title: str
    description: str
    generated_by: str

class ReportUpdate(BaseModel):
    report_title: Optional[str] = None
    description: Optional[str] = None

class ReportResponse(BaseModel):
    id: int
    report_title: str
    description: str
    generated_by: str
    created_at: datetime

    class Config:
        from_attributes = True
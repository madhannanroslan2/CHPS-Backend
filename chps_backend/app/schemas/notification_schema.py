from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class NotificationResponse(BaseModel):
    id: int
    message: str
    resource_type: str
    resource_id: Optional[int] = None
    created_by: Optional[int] = None
    created_at: datetime
    is_read: bool

    class Config:
        from_attributes = True

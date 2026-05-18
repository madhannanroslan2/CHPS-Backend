from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime
from app.database.connection import Base

class ReportModel(Base):
    __tablename__ = "reports"

    id = Column(Integer, primary_key=True, index=True)
    report_title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    generated_by = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
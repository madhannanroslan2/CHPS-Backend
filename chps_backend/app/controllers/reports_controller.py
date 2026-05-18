from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database.connection import get_db
from app.models.reports_model import ReportModel
from app.models.user_model import UserModel
from app.models.residents_model import ResidentModel
from app.models.households_model import HouseholdModel
from app.schemas.reports_schema import ReportCreate, ReportUpdate, ReportResponse
from app.security import get_current_user
from typing import List

router = APIRouter(prefix="/reports", tags=["Reports"])

@router.get("/dashboard-stats")
def get_dashboard_stats(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return {
        "total_residents": db.query(ResidentModel).count(),
        "total_households": db.query(HouseholdModel).count()
    }

@router.post("/", response_model=ReportResponse, status_code=status.HTTP_201_CREATED)
def create_report(report: ReportCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    new_rep = ReportModel(**report.model_dump())
    db.add(new_rep)
    db.commit()
    db.refresh(new_rep)
    return new_rep

@router.get("/", response_model=List[ReportResponse])
def get_reports(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return db.query(ReportModel).all()

@router.put("/{id}", response_model=ReportResponse)
def update_report(id: int, data: ReportUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    rep = db.query(ReportModel).filter(ReportModel.id == id).first()
    if not rep:
        raise HTTPException(status_code=404, detail="Report not found")
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(rep, key, val)
    db.commit()
    db.refresh(rep)
    return rep

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_report(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    rep = db.query(ReportModel).filter(ReportModel.id == id).first()
    if not rep:
        raise HTTPException(status_code=404, detail="Report not found")
    db.delete(rep)
    db.commit()
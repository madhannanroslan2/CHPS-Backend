from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.database.connection import get_db
from app.models.reports_model import ReportModel
from app.models.user_model import UserModel
from app.models.residents_model import ResidentModel
from app.models.households_model import HouseholdModel
from app.models.immunization_model import ImmunizationModel
from app.models.medical_history_model import MedicalHistoryModel
from app.models.prenatal_postnatal_model import PrenatalPostnatalModel
from app.schemas.reports_schema import ReportCreate, ReportUpdate, ReportResponse
from app.security import get_current_user
from app.services.notification_service import notify_resource_created
from typing import List

router = APIRouter(prefix="/reports", tags=["Reports"])

@router.get("/dashboard-stats")
def get_dashboard_stats(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    base_hh = db.query(HouseholdModel)
    base_res = db.query(ResidentModel)
    base_imm = db.query(ImmunizationModel)
    base_med = db.query(MedicalHistoryModel)
    base_pp = db.query(PrenatalPostnatalModel)

    if current_user.role != "admin":
        base_hh = base_hh.filter(HouseholdModel.user_id == current_user.id)
        user_hh_ids = [h.id for h in base_hh.all()]
        base_res = base_res.filter(ResidentModel.household_id.in_(user_hh_ids))
        base_imm = base_imm.join(ResidentModel, ImmunizationModel.resident_id == ResidentModel.id).filter(ResidentModel.household_id.in_(user_hh_ids))
        base_med = base_med.join(ResidentModel, MedicalHistoryModel.resident_id == ResidentModel.id).filter(ResidentModel.household_id.in_(user_hh_ids))
        base_pp = base_pp.join(ResidentModel, PrenatalPostnatalModel.resident_id == ResidentModel.id).filter(ResidentModel.household_id.in_(user_hh_ids))

    def _disease_count(query, disease):
        return query.filter(MedicalHistoryModel.disease_type == disease).count()

    return {
        "total_residents": base_res.count(),
        "total_patients": base_res.count(),
        "total_households": base_hh.count(),
        "total_immunizations": base_imm.count(),
        "total_medical_histories": base_med.count(),
        "total_prenatal_postnatal": base_pp.count(),
        "total_reports": db.query(ReportModel).count(),
        "disease_stats": {
            "dengue": _disease_count(base_med, "Dengue"),
            "cough_cold": _disease_count(base_med, "Cough and Cold"),
            "hypertension": _disease_count(base_med, "Hypertension"),
            "diabetes": _disease_count(base_med, "Diabetes"),
            "other": _disease_count(base_med, "Other"),
        }
    }

@router.get("/disease-stats")
def get_disease_stats(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    base = db.query(MedicalHistoryModel)
    if current_user.role != "admin":
        base = base.join(ResidentModel, MedicalHistoryModel.resident_id == ResidentModel.id)
        base = base.join(HouseholdModel, ResidentModel.household_id == HouseholdModel.id)
        base = base.filter(HouseholdModel.user_id == current_user.id)
    stats = base.with_entities(
        MedicalHistoryModel.disease_type, func.count(MedicalHistoryModel.id)
    ).filter(MedicalHistoryModel.disease_type.isnot(None)).group_by(MedicalHistoryModel.disease_type).all()
    return {row[0] or "Unspecified": row[1] for row in stats}

@router.post("", response_model=ReportResponse, status_code=status.HTTP_201_CREATED)
def create_report(report: ReportCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    new_rep = ReportModel(**report.model_dump())
    db.add(new_rep)
    db.commit()
    db.refresh(new_rep)
    if current_user.role != "admin":
        notify_resource_created(db, "Report", new_rep.id, current_user.id, new_rep.report_title or f"RPT-{new_rep.id}")
    return new_rep

@router.get("", response_model=List[ReportResponse])
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
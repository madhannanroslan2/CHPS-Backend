from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from app.database.connection import get_db
from app.models.residents_model import ResidentModel
from app.models.households_model import HouseholdModel
from app.models.user_model import UserModel
from app.models.prenatal_postnatal_model import PrenatalPostnatalModel
from app.schemas.patients_schema import PatientResponse, ImmunizationItem, MedicalHistoryItem, PrenatalPostnatalItem
from app.security import get_current_user
from typing import List

router = APIRouter(prefix="/patients", tags=["Patients"])

def _fmt_date(dt: datetime | None) -> str | None:
    if dt is None:
        return None
    return dt.strftime("%Y-%m-%d")

def _filter_by_user(query, current_user):
    if current_user.role != "admin":
        query = query.join(HouseholdModel, ResidentModel.household_id == HouseholdModel.id).filter(HouseholdModel.user_id == current_user.id)
    return query

def _build_patient_response(r):
    imm = r.immunizations or []
    med = r.medical_histories or []
    pp = r.prenatal_postnatal or []
    return PatientResponse(
        id=r.id,
        household_id=r.household_id,
        first_name=r.first_name,
        last_name=r.last_name,
        gender=r.gender,
        birth_date=r.birth_date,
        age=r.age,
        contact_number=r.contact_number,
        household_number=r.household.household_number if r.household else None,
        head_of_family=r.household.head_of_family if r.household else None,
        municipality=r.municipality,
        barangay=r.barangay,
        purok=r.purok,
        immunizations=[ImmunizationItem(
            vaccine_name=i.vaccine_name,
            dose_number=i.dose_number,
            administered_by=i.administered_by,
            date_given=_fmt_date(i.date_given),
        ) for i in imm],
        medical_histories=[MedicalHistoryItem(
            diagnosis=m.diagnosis,
            treatment=m.treatment,
            remarks=m.remarks,
            checkup_date=_fmt_date(m.checkup_date),
            disease_type=m.disease_type,
        ) for m in med],
        prenatal_postnatal=[PrenatalPostnatalItem(
            care_type=p.care_type,
            date_given=_fmt_date(p.date_given),
            administered_by=p.administered_by,
            notes=p.notes,
        ) for p in pp],
    )

@router.get("/{id}", response_model=PatientResponse)
def get_patient(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = (
        db.query(ResidentModel)
        .options(joinedload(ResidentModel.household), joinedload(ResidentModel.immunizations), joinedload(ResidentModel.medical_histories), joinedload(ResidentModel.prenatal_postnatal))
        .filter(ResidentModel.id == id)
    )
    query = _filter_by_user(query, current_user)
    r = query.first()
    if not r:
        raise HTTPException(status_code=404, detail="Patient not found")
    return _build_patient_response(r)

@router.get("", response_model=List[PatientResponse])
def get_patients(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = (
        db.query(ResidentModel)
        .options(joinedload(ResidentModel.household), joinedload(ResidentModel.immunizations), joinedload(ResidentModel.medical_histories), joinedload(ResidentModel.prenatal_postnatal))
    )
    query = _filter_by_user(query, current_user)
    residents = query.all()
    return [_build_patient_response(r) for r in residents]

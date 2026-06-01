from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from app.database.connection import get_db
from app.models.residents_model import ResidentModel
from app.models.user_model import UserModel
from app.schemas.patients_schema import PatientResponse, ImmunizationItem, MedicalHistoryItem
from app.security import get_current_user
from typing import List

router = APIRouter(prefix="/patients", tags=["Patients"])

def _fmt_date(dt: datetime | None) -> str | None:
    if dt is None:
        return None
    return dt.strftime("%Y-%m-%d")

@router.get("/{id}", response_model=PatientResponse)
def get_patient(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    r = (
        db.query(ResidentModel)
        .options(joinedload(ResidentModel.household), joinedload(ResidentModel.immunizations), joinedload(ResidentModel.medical_histories))
        .filter(ResidentModel.id == id)
        .first()
    )
    if not r:
        raise HTTPException(status_code=404, detail="Patient not found")
    imm = r.immunizations or []
    med = r.medical_histories or []
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
        purok=r.household.purok if r.household else None,
        head_of_family=r.household.head_of_family if r.household else None,
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
        ) for m in med],
    )

@router.get("", response_model=List[PatientResponse])
def get_patients(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    residents = (
        db.query(ResidentModel)
        .options(joinedload(ResidentModel.household), joinedload(ResidentModel.immunizations), joinedload(ResidentModel.medical_histories))
        .all()
    )
    result = []
    for r in residents:
        imm = r.immunizations or []
        med = r.medical_histories or []

        result.append(PatientResponse(
            id=r.id,
            household_id=r.household_id,
            first_name=r.first_name,
            last_name=r.last_name,
            gender=r.gender,
            birth_date=r.birth_date,
            age=r.age,
            contact_number=r.contact_number,
            household_number=r.household.household_number if r.household else None,
            purok=r.household.purok if r.household else None,
            head_of_family=r.household.head_of_family if r.household else None,
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
            ) for m in med],
        ))
    return result

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.database.connection import get_db
from app.models.medical_history_model import MedicalHistoryModel
from app.models.residents_model import ResidentModel
from app.models.households_model import HouseholdModel
from app.models.user_model import UserModel
from app.schemas.medical_history_schema import MedicalHistoryCreate, MedicalHistoryUpdate, MedicalHistoryResponse
from app.security import get_current_user
from app.services.notification_service import notify_resource_created
from typing import List

router = APIRouter(prefix="/medical-histories", tags=["Medical History"])

def _filter_by_user(query, current_user):
    if current_user.role != "admin":
        query = query.join(ResidentModel, MedicalHistoryModel.resident_id == ResidentModel.id)
        query = query.join(HouseholdModel, ResidentModel.household_id == HouseholdModel.id)
        query = query.filter(HouseholdModel.user_id == current_user.id)
    return query

@router.post("", response_model=MedicalHistoryResponse, status_code=status.HTTP_201_CREATED)
def add_medical_history(data: MedicalHistoryCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    resident = db.query(ResidentModel).options(joinedload(ResidentModel.household)).filter(ResidentModel.id == data.resident_id).first()
    if not resident:
        raise HTTPException(status_code=404, detail="Resident not found")
    if current_user.role != "admin" and resident.household.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    new_med = MedicalHistoryModel(**data.model_dump())
    db.add(new_med)
    db.commit()
    db.refresh(new_med)
    if current_user.role != "admin":
        notify_resource_created(db, "Medical Record", new_med.id, current_user.id, new_med.diagnosis)
    return new_med

@router.get("", response_model=List[MedicalHistoryResponse])
def get_medical_histories(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(MedicalHistoryModel)
    query = _filter_by_user(query, current_user)
    return query.all()

@router.get("/{id}", response_model=MedicalHistoryResponse)
def get_medical_history(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(MedicalHistoryModel).filter(MedicalHistoryModel.id == id)
    query = _filter_by_user(query, current_user)
    med = query.first()
    if not med:
        raise HTTPException(status_code=404, detail="Medical record not found")
    return med

@router.put("/{id}", response_model=MedicalHistoryResponse)
def update_medical_history(id: int, data: MedicalHistoryUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(MedicalHistoryModel).filter(MedicalHistoryModel.id == id)
    query = _filter_by_user(query, current_user)
    med = query.first()
    if not med:
        raise HTTPException(status_code=404, detail="Medical record not found")
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(med, key, val)
    db.commit()
    db.refresh(med)
    return med

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_medical_history(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(MedicalHistoryModel).filter(MedicalHistoryModel.id == id)
    query = _filter_by_user(query, current_user)
    med = query.first()
    if not med:
        raise HTTPException(status_code=404, detail="Medical record not found")
    db.delete(med)
    db.commit()
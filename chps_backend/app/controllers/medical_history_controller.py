from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database.connection import get_db
from app.models.medical_history_model import MedicalHistoryModel
from app.models.user_model import UserModel
from app.schemas.medical_history_schema import MedicalHistoryCreate, MedicalHistoryUpdate, MedicalHistoryResponse
from app.security import get_current_user
from typing import List

router = APIRouter(prefix="/medical-histories", tags=["Medical History"])

@router.post("", response_model=MedicalHistoryResponse, status_code=status.HTTP_201_CREATED)
def add_medical_history(data: MedicalHistoryCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    new_med = MedicalHistoryModel(**data.model_dump())
    db.add(new_med)
    db.commit()
    db.refresh(new_med)
    return new_med

@router.get("", response_model=List[MedicalHistoryResponse])
def get_medical_histories(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return db.query(MedicalHistoryModel).all()

@router.get("/{id}", response_model=MedicalHistoryResponse)
def get_medical_history(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    med = db.query(MedicalHistoryModel).filter(MedicalHistoryModel.id == id).first()
    if not med:
        raise HTTPException(status_code=404, detail="Medical record not found")
    return med

@router.put("/{id}", response_model=MedicalHistoryResponse)
def update_medical_history(id: int, data: MedicalHistoryUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    med = db.query(MedicalHistoryModel).filter(MedicalHistoryModel.id == id).first()
    if not med:
        raise HTTPException(status_code=404, detail="Medical record not found")
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(med, key, val)
    db.commit()
    db.refresh(med)
    return med

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_medical_history(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    med = db.query(MedicalHistoryModel).filter(MedicalHistoryModel.id == id).first()
    if not med:
        raise HTTPException(status_code=404, detail="Medical record not found")
    db.delete(med)
    db.commit()
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database.connection import get_db
from app.models.immunization_model import ImmunizationModel
from app.models.user_model import UserModel
from app.schemas.immunization_schema import ImmunizationCreate, ImmunizationUpdate, ImmunizationResponse
from app.security import get_current_user
from typing import List

router = APIRouter(prefix="/immunizations", tags=["Immunizations"])

@router.post("", response_model=ImmunizationResponse, status_code=status.HTTP_201_CREATED)
def add_immunization(data: ImmunizationCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    new_imm = ImmunizationModel(**data.model_dump())
    db.add(new_imm)
    db.commit()
    db.refresh(new_imm)
    return new_imm

@router.get("", response_model=List[ImmunizationResponse])
def get_immunizations(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return db.query(ImmunizationModel).all()

@router.get("/{id}", response_model=ImmunizationResponse)
def get_immunization(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    imm = db.query(ImmunizationModel).filter(ImmunizationModel.id == id).first()
    if not imm:
        raise HTTPException(status_code=404, detail="Record not found")
    return imm

@router.put("/{id}", response_model=ImmunizationResponse)
def update_immunization(id: int, data: ImmunizationUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    imm = db.query(ImmunizationModel).filter(ImmunizationModel.id == id).first()
    if not imm:
        raise HTTPException(status_code=404, detail="Record not found")
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(imm, key, val)
    db.commit()
    db.refresh(imm)
    return imm

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_immunization(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    imm = db.query(ImmunizationModel).filter(ImmunizationModel.id == id).first()
    if not imm:
        raise HTTPException(status_code=404, detail="Record not found")
    db.delete(imm)
    db.commit()
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database.connection import get_db
from app.models.residents_model import ResidentModel
from app.models.user_model import UserModel
from app.schemas.residents_schema import ResidentCreate, ResidentUpdate, ResidentResponse
from app.security import get_current_user
from typing import List

router = APIRouter(prefix="/residents", tags=["Residents"])

@router.post("", response_model=ResidentResponse, status_code=status.HTTP_201_CREATED)
def create_resident(resident: ResidentCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    new_resident = ResidentModel(**resident.model_dump())
    db.add(new_resident)
    db.commit()
    db.refresh(new_resident)
    return new_resident

@router.get("", response_model=List[ResidentResponse])
def get_residents(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return db.query(ResidentModel).all()

@router.get("/{id}", response_model=ResidentResponse)
def get_resident(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    res = db.query(ResidentModel).filter(ResidentModel.id == id).first()
    if not res:
        raise HTTPException(status_code=404, detail="Resident not found")
    return res

@router.put("/{id}", response_model=ResidentResponse)
def update_resident(id: int, data: ResidentUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    res = db.query(ResidentModel).filter(ResidentModel.id == id).first()
    if not res:
        raise HTTPException(status_code=404, detail="Resident not found")
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(res, key, val)
    db.commit()
    db.refresh(res)
    return res

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_resident(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    res = db.query(ResidentModel).filter(ResidentModel.id == id).first()
    if not res:
        raise HTTPException(status_code=404, detail="Resident not found")
    db.delete(res)
    db.commit()
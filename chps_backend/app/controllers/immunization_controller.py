from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.database.connection import get_db
from app.models.immunization_model import ImmunizationModel
from app.models.residents_model import ResidentModel
from app.models.households_model import HouseholdModel
from app.models.user_model import UserModel
from app.schemas.immunization_schema import ImmunizationCreate, ImmunizationUpdate, ImmunizationResponse
from app.security import get_current_user
from app.services.notification_service import notify_resource_created
from typing import List

router = APIRouter(prefix="/immunizations", tags=["Immunizations"])

def _filter_by_user(query, current_user):
    if current_user.role != "admin":
        query = query.join(ResidentModel, ImmunizationModel.resident_id == ResidentModel.id)
        query = query.join(HouseholdModel, ResidentModel.household_id == HouseholdModel.id)
        query = query.filter(HouseholdModel.user_id == current_user.id)
    return query

@router.post("", response_model=ImmunizationResponse, status_code=status.HTTP_201_CREATED)
def add_immunization(data: ImmunizationCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    resident = db.query(ResidentModel).options(joinedload(ResidentModel.household)).filter(ResidentModel.id == data.resident_id).first()
    if not resident:
        raise HTTPException(status_code=404, detail="Resident not found")
    if current_user.role != "admin" and resident.household.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    new_imm = ImmunizationModel(**data.model_dump())
    db.add(new_imm)
    db.commit()
    db.refresh(new_imm)
    if current_user.role != "admin":
        notify_resource_created(db, "Vaccination", new_imm.id, current_user.id, new_imm.vaccine_name)
    return new_imm

@router.get("", response_model=List[ImmunizationResponse])
def get_immunizations(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(ImmunizationModel)
    query = _filter_by_user(query, current_user)
    return query.all()

@router.get("/{id}", response_model=ImmunizationResponse)
def get_immunization(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(ImmunizationModel).filter(ImmunizationModel.id == id)
    query = _filter_by_user(query, current_user)
    imm = query.first()
    if not imm:
        raise HTTPException(status_code=404, detail="Record not found")
    return imm

@router.put("/{id}", response_model=ImmunizationResponse)
def update_immunization(id: int, data: ImmunizationUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(ImmunizationModel).filter(ImmunizationModel.id == id)
    query = _filter_by_user(query, current_user)
    imm = query.first()
    if not imm:
        raise HTTPException(status_code=404, detail="Record not found")
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(imm, key, val)
    db.commit()
    db.refresh(imm)
    return imm

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_immunization(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(ImmunizationModel).filter(ImmunizationModel.id == id)
    query = _filter_by_user(query, current_user)
    imm = query.first()
    if not imm:
        raise HTTPException(status_code=404, detail="Record not found")
    db.delete(imm)
    db.commit()
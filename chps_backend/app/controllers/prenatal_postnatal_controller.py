from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.database.connection import get_db
from app.models.prenatal_postnatal_model import PrenatalPostnatalModel
from app.models.residents_model import ResidentModel
from app.models.households_model import HouseholdModel
from app.models.user_model import UserModel
from app.schemas.prenatal_postnatal_schema import PrenatalPostnatalCreate, PrenatalPostnatalUpdate, PrenatalPostnatalResponse
from app.security import get_current_user
from app.services.notification_service import notify_resource_created
from typing import List

router = APIRouter(prefix="/prenatal-postnatal", tags=["Prenatal Postnatal"])

def _filter_by_user(query, current_user):
    if current_user.role != "admin":
        query = query.join(ResidentModel, PrenatalPostnatalModel.resident_id == ResidentModel.id)
        query = query.join(HouseholdModel, ResidentModel.household_id == HouseholdModel.id)
        query = query.filter(HouseholdModel.user_id == current_user.id)
    return query

@router.post("", response_model=PrenatalPostnatalResponse, status_code=status.HTTP_201_CREATED)
def add_prenatal_postnatal(data: PrenatalPostnatalCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    resident = db.query(ResidentModel).options(joinedload(ResidentModel.household)).filter(ResidentModel.id == data.resident_id).first()
    if not resident:
        raise HTTPException(status_code=404, detail="Resident not found")
    if current_user.role != "admin" and resident.household.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    new_rec = PrenatalPostnatalModel(**data.model_dump())
    db.add(new_rec)
    db.commit()
    db.refresh(new_rec)
    if current_user.role != "admin":
        notify_resource_created(db, "Immunization", new_rec.id, current_user.id, new_rec.care_type)
    return new_rec

@router.get("", response_model=List[PrenatalPostnatalResponse])
def get_prenatal_postnatal_list(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(PrenatalPostnatalModel)
    query = _filter_by_user(query, current_user)
    return query.all()

@router.get("/{id}", response_model=PrenatalPostnatalResponse)
def get_prenatal_postnatal(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(PrenatalPostnatalModel).filter(PrenatalPostnatalModel.id == id)
    query = _filter_by_user(query, current_user)
    rec = query.first()
    if not rec:
        raise HTTPException(status_code=404, detail="Record not found")
    return rec

@router.put("/{id}", response_model=PrenatalPostnatalResponse)
def update_prenatal_postnatal(id: int, data: PrenatalPostnatalUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(PrenatalPostnatalModel).filter(PrenatalPostnatalModel.id == id)
    query = _filter_by_user(query, current_user)
    rec = query.first()
    if not rec:
        raise HTTPException(status_code=404, detail="Record not found")
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(rec, key, val)
    db.commit()
    db.refresh(rec)
    return rec

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_prenatal_postnatal(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(PrenatalPostnatalModel).filter(PrenatalPostnatalModel.id == id)
    query = _filter_by_user(query, current_user)
    rec = query.first()
    if not rec:
        raise HTTPException(status_code=404, detail="Record not found")
    db.delete(rec)
    db.commit()

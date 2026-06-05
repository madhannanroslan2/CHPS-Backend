from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.database.connection import get_db
from app.models.residents_model import ResidentModel
from app.models.households_model import HouseholdModel
from app.models.user_model import UserModel
from app.schemas.residents_schema import ResidentCreate, ResidentUpdate, ResidentResponse
from app.security import get_current_user
from app.services.notification_service import notify_resource_created
from typing import List

router = APIRouter(prefix="/residents", tags=["Residents"])

def _filter_by_user(query, current_user):
    if current_user.role != "admin":
        query = query.join(HouseholdModel, ResidentModel.household_id == HouseholdModel.id).filter(HouseholdModel.user_id == current_user.id)
    return query

@router.post("", response_model=ResidentResponse, status_code=status.HTTP_201_CREATED)
def create_resident(resident: ResidentCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    household = db.query(HouseholdModel).filter(HouseholdModel.id == resident.household_id).first()
    if not household:
        raise HTTPException(status_code=404, detail="Household not found")
    if current_user.role != "admin" and household.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    new_resident = ResidentModel(**resident.model_dump())
    db.add(new_resident)
    db.commit()
    db.refresh(new_resident)
    if current_user.role != "admin":
        notify_resource_created(db, "Resident", new_resident.id, current_user.id, f"{new_resident.first_name} {new_resident.last_name}")
    return new_resident

@router.get("", response_model=List[ResidentResponse])
def get_residents(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(ResidentModel).options(joinedload(ResidentModel.household))
    query = _filter_by_user(query, current_user)
    residents = query.all()
    result = []
    for r in residents:
        data = {
            "id": r.id,
            "household_id": r.household_id,
            "first_name": r.first_name,
            "last_name": r.last_name,
            "gender": r.gender,
            "birth_date": r.birth_date,
            "age": r.age,
            "contact_number": r.contact_number,
            "municipality": r.municipality,
            "barangay": r.barangay,
            "purok": r.purok,
            "household_number": r.household.household_number if r.household else None,
            "head_of_family": r.household.head_of_family if r.household else None,
            "created_at": r.created_at,
        }
        result.append(data)
    return result

@router.get("/{id}", response_model=ResidentResponse)
def get_resident(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(ResidentModel).options(joinedload(ResidentModel.household)).filter(ResidentModel.id == id)
    query = _filter_by_user(query, current_user)
    r = query.first()
    if not r:
        raise HTTPException(status_code=404, detail="Resident not found")
    return {
        "id": r.id,
        "household_id": r.household_id,
        "first_name": r.first_name,
        "last_name": r.last_name,
        "gender": r.gender,
        "birth_date": r.birth_date,
        "age": r.age,
        "contact_number": r.contact_number,
        "municipality": r.municipality,
        "barangay": r.barangay,
        "purok": r.purok,
        "household_number": r.household.household_number if r.household else None,
        "head_of_family": r.household.head_of_family if r.household else None,
        "created_at": r.created_at,
    }

@router.put("/{id}", response_model=ResidentResponse)
def update_resident(id: int, data: ResidentUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(ResidentModel).filter(ResidentModel.id == id)
    query = _filter_by_user(query, current_user)
    res = query.first()
    if not res:
        raise HTTPException(status_code=404, detail="Resident not found")
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(res, key, val)
    db.commit()
    db.refresh(res)
    return res

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_resident(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(ResidentModel).filter(ResidentModel.id == id)
    query = _filter_by_user(query, current_user)
    res = query.first()
    if not res:
        raise HTTPException(status_code=404, detail="Resident not found")
    db.delete(res)
    db.commit()
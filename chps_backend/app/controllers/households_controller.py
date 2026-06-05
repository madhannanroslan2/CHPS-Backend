from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database.connection import get_db
from app.models.households_model import HouseholdModel
from app.models.user_model import UserModel
from app.schemas.households_schema import HouseholdCreate, HouseholdUpdate, HouseholdResponse
from app.security import get_current_user
from app.services.notification_service import notify_resource_created
from typing import List

router = APIRouter(prefix="/households", tags=["Households"])

def _filter_by_user(query, current_user):
    if current_user.role != "admin":
        query = query.filter(HouseholdModel.user_id == current_user.id)
    return query

@router.post("", response_model=HouseholdResponse, status_code=status.HTTP_201_CREATED)
def create_household(household: HouseholdCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    if db.query(HouseholdModel).filter(HouseholdModel.household_number == household.household_number).first():
        raise HTTPException(status_code=400, detail="Household number already exists")
    new_house = HouseholdModel(**household.model_dump(), user_id=current_user.id)
    db.add(new_house)
    db.commit()
    db.refresh(new_house)
    if current_user.role != "admin":
        notify_resource_created(db, "Household", new_house.id, current_user.id, new_house.household_number)
    return new_house

@router.get("", response_model=List[HouseholdResponse])
def get_households(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(HouseholdModel)
    query = _filter_by_user(query, current_user)
    return query.all()

@router.get("/{id}", response_model=HouseholdResponse)
def get_household(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(HouseholdModel).filter(HouseholdModel.id == id)
    query = _filter_by_user(query, current_user)
    house = query.first()
    if not house:
        raise HTTPException(status_code=404, detail="Household not found")
    return house

@router.put("/{id}", response_model=HouseholdResponse)
def update_household(id: int, data: HouseholdUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(HouseholdModel).filter(HouseholdModel.id == id)
    query = _filter_by_user(query, current_user)
    house = query.first()
    if not house:
        raise HTTPException(status_code=404, detail="Household not found")
    for key, val in data.model_dump(exclude_unset=True).items():
        setattr(house, key, val)
    db.commit()
    db.refresh(house)
    return house

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_household(id: int, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(HouseholdModel).filter(HouseholdModel.id == id)
    query = _filter_by_user(query, current_user)
    house = query.first()
    if not house:
        raise HTTPException(status_code=404, detail="Household not found")
    db.delete(house)
    db.commit()
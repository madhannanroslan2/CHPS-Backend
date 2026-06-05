from datetime import datetime
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session, joinedload
from app.database.connection import get_db
from app.models.residents_model import ResidentModel
from app.models.households_model import HouseholdModel
from app.models.user_model import UserModel
from app.security import get_current_user
from typing import Optional, List
from pydantic import BaseModel

router = APIRouter(prefix="/municipalities", tags=["Municipalities"])

class BarangayResponse(BaseModel):
    municipality: str
    barangays: List[str]

@router.get("/barangays", response_model=List[BarangayResponse])
def get_all_barangays(current_user: UserModel = Depends(get_current_user)):
    result = []
    for muni, brgys in BARANGAYS_BY_MUNICIPALITY.items():
        result.append({"municipality": muni, "barangays": brgys})
    return result

@router.get("/barangays/{municipality}", response_model=BarangayResponse)
def get_barangays_for_municipality(municipality: str, current_user: UserModel = Depends(get_current_user)):
    muni_normalized = municipality.strip().title()
    for muni, brgys in BARANGAYS_BY_MUNICIPALITY.items():
        if muni.lower() == muni_normalized.lower():
            return {"municipality": muni, "barangays": brgys}
    return {"municipality": municipality, "barangays": []}

TAWI_TAWI_MUNICIPALITIES = [
    "Bongao",
    "Languyan",
    "Mapun",
    "Panglima Sugala",
    "Sapa-Sapa",
    "Sibutu",
    "Simunul",
    "Sitangkay",
    "South Ubian",
    "Tandubas",
    "Turtle Island",
]

BARANGAYS_BY_MUNICIPALITY = {
    "Bongao": [
        "Ipil", "Kumalarang", "Lapid", "Lato", "Luuk Pandan",
        "Malassa", "Mandal", "Nalil", "Pag-asa", "Pahut",
        "Poblacion", "Sanga-Sanga", "Silubog", "Simuag", "Tagum",
    ],
    "Languyan": [
        "Adjid", "Bakong", "Bas-bas", "Datu Damdam", "Gus",
        "Lakas", "Lamion", "Languyan Proper", "Mantabuan", "Parangan",
        "Sibutu", "Simalak", "Tandubas", "Tubig-basag", "Tubig-sallang",
    ],
    "Mapun": [
        "Boki", "Duhul Batu", "Iku", "Kawit", "Li-awan",
        "Lupa Pula", "Mahalu", "Pandanan", "Poblacion", "Sapa",
    ],
    "Panglima Sugala": [
        "Balimbing", "Batu-batu", "Buhangin", "Kawas", "Lahi",
        "Ligayan", "Malacca", "Pallan", "Pantar", "Sapa",
        "Silag", "Sulut", "Tanduan", "Tinondoran",
    ],
    "Sapa-Sapa": [
        "Baldatal Islam", "Kohec", "Look Natuh", "Malanta", "Palate Gadjamina",
        "Sapaat", "Tangngah", "Tonggusong Banaran", "Buton", "Lakit-Lakit",
        "Lookan Banaran", "Mantabuan Tambunan", "Pamasan", "Sukah-sukah",
        "Tapian Boheh North", "Tup-Tup Banaran", "Mantabuan Dalo-Dalo",
        "Latuan", "Lookan Latuan", "Nunuk Likud Sikubung", "Sapa-sapa (Pob.)",
        "Tabunan Likud Sikubung", "Tapian Boheh South",
    ],
    "Sibutu": [
        "Ambutun", "Hadji Haidi", "Lombong", "Pandan", "Pisak-pisak",
        "Sibutu Proper", "Silangkob", "Tanduan",
    ],
    "Simunul": [
        "Bagid", "Batuan", "Bung-bung", "Duhul", "Manuk Mangkaw",
        "Mongkay", "Poblacion", "Tampakan", "Tubig Indangan", "Tubig Sallang",
    ],
    "Sitangkay": [
        "Datu", "Kawilan", "Ligayan", "Malibong", "Pandan",
        "Poblacion", "Sipangkot", "Tanduan",
    ],
    "South Ubian": [
        "Babagan", "Bangal", "Bawab", "Bi", "Bong",
        "Ibus", "Lahad", "Likit", "Magsaysay", "Nuang",
        "Poblacion", "Sangay", "Taban", "Tuk", "Ubal",
    ],
    "Tandubas": [
        "Bail", "Balimbing", "Ballak", "Butun", "Dungon",
        "Kalakuhan", "Kanduli", "Lanting", "Latian", "Leon",
        "Likud", "Luukbog", "Magsaysay", "Mintabun", "Pandanan",
        "Pasiagan", "Silantup", "Tapian", "Taruk",
    ],
    "Turtle Island": [
        "Lihunu", "Taganak", "Sibutu",
    ],
}

def _fmt_date(dt: datetime | None) -> str | None:
    if dt is None:
        return None
    return dt.strftime("%Y-%m-%d")

def _serialize_resident(r):
    imm = r.immunizations or []
    med = r.medical_histories or []
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
        "immunizations": [{
            "vaccine_name": i.vaccine_name,
            "dose_number": i.dose_number,
            "administered_by": i.administered_by,
            "date_given": _fmt_date(i.date_given),
        } for i in imm],
        "medical_histories": [{
            "diagnosis": m.diagnosis,
            "treatment": m.treatment,
            "remarks": m.remarks,
            "checkup_date": _fmt_date(m.checkup_date),
        } for m in med],
    }

@router.get("/{name}/detail")
def get_municipality_detail(name: str, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = (
        db.query(ResidentModel)
        .options(
            joinedload(ResidentModel.household),
            joinedload(ResidentModel.immunizations),
            joinedload(ResidentModel.medical_histories),
        )
    )
    name_normalized = name.strip().title()
    query = query.filter(ResidentModel.municipality.ilike(name_normalized))

    residents = query.all()
    total_count = len(residents)

    barangay_groups = {}
    for r in residents:
        brgy = r.barangay.strip() if r.barangay and r.barangay.strip() else None
        if brgy is None:
            continue
        if brgy not in barangay_groups:
            barangay_groups[brgy] = {"residents": [], "household_ids": set()}
        barangay_groups[brgy]["residents"].append(_serialize_resident(r))
        barangay_groups[brgy]["household_ids"].add(r.household_id)

    brgy_list = BARANGAYS_BY_MUNICIPALITY.get(name_normalized, [])
    result_barangays = []
    for brgy in brgy_list:
        group = barangay_groups.get(brgy, {"residents": [], "household_ids": set()})
        result_barangays.append({
            "name": brgy,
            "resident_count": len(group["residents"]),
            "household_count": len(group["household_ids"]),
            "residents": group["residents"],
        })

    return {
        "name": name_normalized,
        "total_residents": total_count,
        "total_barangays": len(result_barangays),
        "barangays": result_barangays,
    }

@router.get("/data")
def get_municipality_data(search: Optional[str] = Query(None), db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = (
        db.query(ResidentModel)
        .options(
            joinedload(ResidentModel.household),
            joinedload(ResidentModel.immunizations),
            joinedload(ResidentModel.medical_histories),
        )
    )
    if current_user.role != "admin":
        query = query.join(HouseholdModel, ResidentModel.household_id == HouseholdModel.id).filter(HouseholdModel.user_id == current_user.id)

    residents = query.all()

    groups = {}
    for r in residents:
        muni = r.municipality.strip() if r.municipality and r.municipality.strip() else None
        if muni is None:
            continue
        if muni not in groups:
            groups[muni] = []
        groups[muni].append(_serialize_resident(r))

    for muni in TAWI_TAWI_MUNICIPALITIES:
        if muni not in groups:
            groups[muni] = []

    result = [{"name": m, "residents": residents, "count": len(residents)} for m, residents in groups.items()]
    result.sort(key=lambda x: x["name"])

    if search:
        search_lower = search.strip().lower()
        result = [g for g in result if search_lower in g["name"].lower()]

    return result

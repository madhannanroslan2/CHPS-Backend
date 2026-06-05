from app.controllers import ai_controller
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database.connection import Base, engine
from sqlalchemy import text
from app.controllers import (
    user_controller, households_controller, residents_controller,
    immunization_controller, medical_history_controller, reports_controller,
    patients_controller, municipalities_controller, prenatal_postnatal_controller,
    notifications_controller
)

# Automatically create secure tables in your Neon cloud database
Base.metadata.create_all(bind=engine)

# Auto-migrate: prenatal_postnatal table, drop disease_type from immunizations, add to medical_histories
with engine.connect() as conn:
    result = conn.execute(text(
        "SELECT column_name FROM information_schema.columns WHERE table_name='prenatal_postnatal' AND column_name='id'"
    ))
    if not result.first():
        conn.execute(text("""
            CREATE TABLE prenatal_postnatal (
                id SERIAL PRIMARY KEY,
                resident_id INTEGER REFERENCES residents(id) ON DELETE CASCADE NOT NULL,
                care_type VARCHAR NOT NULL,
                date_given TIMESTAMP DEFAULT NOW(),
                administered_by VARCHAR NOT NULL,
                notes VARCHAR
            )
        """))
        conn.commit()
    result = conn.execute(text(
        "SELECT column_name FROM information_schema.columns WHERE table_name='notifications' AND column_name='id'"
    ))
    if not result.first():
        conn.execute(text("""
            CREATE TABLE notifications (
                id SERIAL PRIMARY KEY,
                message VARCHAR NOT NULL,
                resource_type VARCHAR NOT NULL,
                resource_id INTEGER,
                created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
                created_at TIMESTAMP DEFAULT NOW(),
                is_read BOOLEAN DEFAULT FALSE
            )
        """))
        conn.commit()
    conn.execute(text(
        "SELECT column_name FROM information_schema.columns WHERE table_name='immunizations' AND column_name='disease_type'"
    ))
    result = conn.execute(text(
        "SELECT column_name FROM information_schema.columns WHERE table_name='immunizations' AND column_name='disease_type'"
    ))
    if result.first():
        conn.execute(text("ALTER TABLE immunizations DROP COLUMN disease_type"))
        conn.commit()
    result = conn.execute(text(
        "SELECT column_name FROM information_schema.columns WHERE table_name='medical_histories' AND column_name='disease_type'"
    ))
    if not result.first():
        conn.execute(text("ALTER TABLE medical_histories ADD COLUMN disease_type VARCHAR"))
        conn.commit()

app = FastAPI(
    title="CHPS Backend API",
    description="Authorized & Secure Community Health Post System Backend Service with Neon PostgreSQL",
    version="1.2.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Route definitions
app.include_router(ai_controller.router)
app.include_router(user_controller.router)
app.include_router(households_controller.router)
app.include_router(residents_controller.router)
app.include_router(immunization_controller.router)
app.include_router(medical_history_controller.router)
app.include_router(reports_controller.router)
app.include_router(patients_controller.router)
app.include_router(municipalities_controller.router)
app.include_router(prenatal_postnatal_controller.router)
app.include_router(notifications_controller.router)

@app.get("/")
def root():
    return {
        "status": "Online",
        "system": "Community Health Post System (CHPS) Secured Hub",
        "environment": "Production Venv"
    }
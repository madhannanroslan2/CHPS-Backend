from app.controllers import ai_controller
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database.connection import Base, engine
from app.controllers import (
    user_controller, households_controller, residents_controller,
    immunization_controller, medical_history_controller, reports_controller
)

# Automatically create secure tables in your Neon cloud database
Base.metadata.create_all(bind=engine)

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

@app.get("/")
def root():
    return {
        "status": "Online",
        "system": "Community Health Post System (CHPS) Secured Hub",
        "environment": "Production Venv"
    }
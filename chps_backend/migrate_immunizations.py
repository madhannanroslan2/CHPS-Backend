from dotenv import load_dotenv
from sqlalchemy import text
from app.database.connection import engine

load_dotenv()

def run_migration():
    with engine.connect() as conn:
        result = conn.execute(text(
            "SELECT column_name FROM information_schema.columns WHERE table_name='immunizations' AND column_name='disease_type'"
        ))
        if result.first():
            conn.execute(text("ALTER TABLE immunizations DROP COLUMN disease_type"))
            conn.commit()
            print("Dropped 'disease_type' from 'immunizations' table.")
        else:
            print("Column 'disease_type' already removed from 'immunizations'.")

        result = conn.execute(text(
            "SELECT column_name FROM information_schema.columns WHERE table_name='medical_histories' AND column_name='disease_type'"
        ))
        if not result.first():
            conn.execute(text("ALTER TABLE medical_histories ADD COLUMN disease_type VARCHAR"))
            conn.commit()
            print("Added 'disease_type' column to 'medical_histories' table.")
        else:
            print("Column 'disease_type' already exists in 'medical_histories'.")

if __name__ == "__main__":
    run_migration()

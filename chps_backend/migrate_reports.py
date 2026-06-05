import sys
sys.path.insert(0, ".")
from dotenv import load_dotenv
load_dotenv()

from app.database.connection import engine
from sqlalchemy import text

with engine.connect() as conn:
    trans = conn.begin()
    try:
        conn.execute(text("""
            DO $$
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reports' AND column_name='municipality') THEN
                    ALTER TABLE reports ADD COLUMN municipality VARCHAR;
                END IF;
            END $$;
        """))
        trans.commit()
        print("Migration complete: reports.municipality column added")
    except Exception as e:
        trans.rollback()
        print(f"Error: {e}")

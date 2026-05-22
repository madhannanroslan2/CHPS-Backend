from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
import google.generativeai as genai

router = APIRouter(prefix="/ai", tags=["AI Assistant"])

# Configure Gemini API Key
GEMINI_API_KEY = "AIzaSyApqs5ECx8vuPJmRP48Aar377AStshjYyM"
genai.configure(api_key=GEMINI_API_KEY)

# Create a Schema for the User request
class ChatRequest(BaseModel):
    prompt: str

# Create an Endpoint for the Chat AI
@router.post("/chat")
def ask_ai(request: ChatRequest):
    try:
        model = genai.GenerativeModel(
        model_name="gemini-flash-latest",
            system_instruction="You are a helpful medical and community health assistant for the CHPS (Community Health Profiling System) application. Provide clear, empathetic, and concise health-related or system-related answers in Tagalog or English."
        )
        
        response = model.generate_content(request.prompt)
        
        return {
            "status": "success",
            "reply": response.text
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI Error: {str(e)}")
import os
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from groq import Groq

router = APIRouter(prefix="/ai", tags=["AI Assistant"])

client = Groq(api_key=os.getenv("GROQ_API_KEY", "YOUR_GROQ_API_KEY"))

# Create a Schema for the User request
class ChatRequest(BaseModel):
    prompt: str

# Create an Endpoint for the Chat AI
@router.post("/chat")
def ask_ai(request: ChatRequest):
    try:
        completion = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {
                    "role": "system",
                    "content": "You are a helpful medical and community health assistant for the CHPS (Community Health Profiling System) application. Provide clear, empathetic, and concise health-related or system-related answers in Tagalog or English."
                },
                {
                    "role": "user",
                    "content": request.prompt
                }
            ],
            temperature=1,
            max_tokens=1024,
            top_p=1,
            stream=False,
        )

        return {
            "status": "success",
            "reply": completion.choices[0].message.content
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI Error: {str(e)}")
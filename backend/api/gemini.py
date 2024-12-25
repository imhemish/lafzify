from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from .auth import verify_token
from ..gemini.gemini import GeminiSource, GeminiResponse, GeminiRequest
from .secret_store import Secrets, get_secrets_from_db

router = APIRouter()

@router.get("/gemini", response_model=GeminiResponse)
def get_response_from_gemini(
    gemRequest: GeminiRequest,
    username: str = Depends(verify_token),
    secrets: Secrets= Depends(get_secrets_from_db),
    ):
    
    gem_key = secrets.gemini
    if gem_key is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="No gemini key found")
    gem = GeminiSource(key=gem_key)
    res = gem.get_contents(gemRequest)
    return res

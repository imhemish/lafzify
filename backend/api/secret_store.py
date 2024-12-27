from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from .db import db
from .auth import verify_token
from .supported_platforms import SupportedPlatformID

secrets_collection = db["secrets"]

class PlatformSecrets(BaseModel):
    platform_id: SupportedPlatformID
    api_key: str
    api_secret: str
    access_token: str
    access_secret: str

class Secrets(BaseModel):
    gemini: str | None = None
    platforms: list[PlatformSecrets] = []
    
class SecretsInDB(Secrets):
    username: str
    
class SecretsResponse(BaseModel):
    msg: str
    
router = APIRouter()

@router.put("/secrets", response_model=SecretsResponse)
def put_secrets(secrets: Secrets, username: str = Depends(verify_token)):
    # upsert = True tells to create new document if not exists
    secrets_collection.update_one({"username": username}, {"$set": secrets.model_dump(exclude_unset=True)}, upsert=True)
    return {"msg": "Secrets added successfully"}

# Fastapi dependency
def get_secrets_from_db(username: Annotated[str, Depends(verify_token)]) -> Secrets:
    document = secrets_collection.find_one({"username": username})
    if document == None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No secrets found")
    return Secrets(**document)
    
@router.get("/secrets")
def get_secrets(username: str = Depends(verify_token)) -> Secrets | None:
    return get_secrets_from_db(username)
    
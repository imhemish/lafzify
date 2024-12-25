from fastapi import FastAPI
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import MongoDsn, AnyHttpUrl
from dotenv import load_dotenv
from typing import Optional

load_dotenv("/home/hemish/projects/lafzify/.env")

class Settings(BaseSettings):
    google_genai_key:Optional[str]
    mongo_url: str
    mongo_db_name: str
    x_access_token: Optional[str]
    x_access_secret: Optional[str]
    x_api_key: Optional[str]
    x_api_secret: Optional[str]
    x_bearer_token: Optional[str]
    threads_app_id: Optional[str]
    threads_api_secret: Optional[str]
    threads_access_token: Optional[str]

settings = Settings()
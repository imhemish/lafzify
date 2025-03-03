from fastapi import FastAPI
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import MongoDsn, AnyHttpUrl
from dotenv import load_dotenv
from typing import Optional

load_dotenv("/home/hemish/projects/lafzify/.env")

class Settings(BaseSettings):
    mongo_url: str
    mongo_db_name: str

settings = Settings()
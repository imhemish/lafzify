from fastapi import FastAPI, Depends
from fastapi.staticfiles import StaticFiles
from .auth import router as auth_router
from .secret_store import router as secret_store_router
from .post import router as post_router
from .gemini import router as gemini_router
import os
app = FastAPI()

app.include_router(auth_router)
app.include_router(secret_store_router)
app.include_router(post_router)
app.include_router(gemini_router)
static_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "static")
app.mount("/static", StaticFiles(directory=static_dir), name="static")
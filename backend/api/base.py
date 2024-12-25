from fastapi import FastAPI, Depends
from .auth import router as auth_router
from .secret_store import router as secret_store_router
from .post import router as post_router
from .gemini import router as gemini_router
app = FastAPI()

app.include_router(auth_router)
app.include_router(secret_store_router)
app.include_router(post_router)
app.include_router(gemini_router)
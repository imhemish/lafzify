from enum import Enum
from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from pydantic import BaseModel, BeforeValidator, ConfigDict, Field
from typing import Annotated, Literal, List, Dict, Optional
from .auth import verify_token
from ..platforms import x
from ..platforms.platform import Platform
from .db import db
import datetime
from bson.objectid import ObjectId
from .secret_store import Secrets, get_secrets_from_db

PyObjectId = Annotated[str, BeforeValidator(str)]
SupportedPlatformID = Literal['x']
platform_lookup: Dict[SupportedPlatformID, Platform] = {
    'x': x.XPlatform,
}
class JobStatus(str, Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"

class Job(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    platform_id: SupportedPlatformID
    text: str
    time: datetime.datetime
    status: JobStatus = JobStatus.PENDING
    failed_reason: str | None = None
    post_url: str | None = None
    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
    )

class JobInDB(Job):
    username: str

def add_job(username: str, platform_id: SupportedPlatformID, text: str) -> JobInDB:
    
    job = JobInDB(username=username, platform_id=platform_id, text=text, time=datetime.datetime.utcnow())
    
    # check duplicate job with same text
    job_duplicate = db["jobs"].find_one({"text": text, "platform_id": platform_id})
    if job_duplicate:
        job.status = JobStatus.FAILED
        job.failed_reason = "Duplicate text"
        
    
    # exclude id field as it would be set by db as '_id'
    job_id = db["jobs"].insert_one(job.model_dump(exclude=["id"])).inserted_id
    job = db["jobs"].find_one({"_id": ObjectId(job_id)})
    return JobInDB(**job)

router = APIRouter()

class PlatformPostTextRequest(BaseModel):
    platform_id: SupportedPlatformID
    text: str

class PostTextRequest(BaseModel):
    platforms: List[PlatformPostTextRequest] = Field(min_length=1)


class PostTextResponse(BaseModel):
    jobs: List[Job]
    
def job_wrapper(job: JobInDB, secrets: Secrets):
    platform = platform_lookup[job.platform_id]
    secrets = get_secrets_from_db(job.username)
    plt_secrets = secrets.__getattribute__(job.platform_id)
    
    # no secrets for current platform
    if plt_secrets == None:
        job.status = JobStatus.FAILED
        job.failed_reason = "Platform secrets not found"
        db["jobs"].update_one({"_id": ObjectId(job.id)}, {"$set": job.model_dump(exclude=["id"])})
        return

    # each platform has constructor that takes its secrets
    platform_instance = platform(plt_secrets)
    try:
        url = platform_instance.post_text(job.text)
        print(url)
        job.post_url = url
        job.status = JobStatus.COMPLETED
    except Exception as e:
        job.status = JobStatus.FAILED
        job.failed_reason = str(e)
    db["jobs"].update_one({"_id": ObjectId(job.id)}, {"$set": job.model_dump(exclude=["id"])})
    print(job)
    print("updated")
    

@router.post("/post-text", response_model=PostTextResponse, response_model_by_alias=False)
def post_text(data: PostTextRequest, background_tasks: BackgroundTasks, username: str = Depends(verify_token), secrets: Secrets = Depends(get_secrets_from_db),):
    
    jobs: List[Job] = []
    for plt in data.platforms:
        job_db = add_job(username, plt.platform_id, plt.text)
        # a job might be outright rejected and failed if it is duplicate
        if job_db.status == JobStatus.PENDING:
            background_tasks.add_task(job_wrapper, job_db, secrets)
        
        jobs.append(Job(**job_db.model_dump()))
    return PostTextResponse(jobs=jobs)

@router.get("/jobs", response_model=List[Job])
def get_jobs(username: str = Depends(verify_token)):
    jobs = db["jobs"].find({"username": username})
    return [Job(**job) for job in jobs]

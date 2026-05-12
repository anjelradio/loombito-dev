from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.modules.academic.router import router as academic_router
from app.modules.attendance.router import router as attendance_router
from app.modules.auth.router import router as auth_router
from app.modules.evaluations.router import router as evaluations_router
from app.modules.intelligence.router import router as intelligence_router
from app.modules.reports.router import router as reports_router
from app.modules.schools.router import router as school_router
from app.modules.students.router import router as student_router
from app.modules.subscriptions.router import router as subscriptions_router
from app.modules.system.router import router as system_router

load_dotenv()


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(
    title=settings.PROJECT_NAME,
    lifespan=lifespan,
    swagger_ui_parameters={
        "persistAuthorization": True,
    },
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(auth_router, prefix="/api")

app.include_router(school_router, prefix="/api")

app.include_router(academic_router, prefix="/api")

app.include_router(student_router, prefix="/api")

app.include_router(evaluations_router, prefix="/api")

app.include_router(attendance_router, prefix="/api")

app.include_router(intelligence_router, prefix="/api")

app.include_router(subscriptions_router, prefix="/api")

app.include_router(reports_router, prefix="/api")

app.include_router(system_router, prefix="/api")

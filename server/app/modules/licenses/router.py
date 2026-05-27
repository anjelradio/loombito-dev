from uuid import UUID

from fastapi import APIRouter

from app.dependencies.auth import CurrentActor, DBSession
from app.modules.licenses.schemas import StudentLicenseCreate, StudentLicenseRead
from app.modules.licenses.services import LicenseService

router = APIRouter(prefix="/licenses", tags=["Licencias"])


@router.post("/schools/{school_id}/students/{student_id}", response_model=StudentLicenseRead)
def create_student_license(
    school_id: UUID,
    student_id: UUID,
    payload: StudentLicenseCreate,
    db: DBSession,
    actor: CurrentActor,
):
    return LicenseService(db).create_student_license(school_id, student_id, payload, actor)


@router.get("/schools/{school_id}/students/{student_id}", response_model=list[StudentLicenseRead])
def list_student_licenses(
    school_id: UUID,
    student_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    return LicenseService(db).list_student_licenses(school_id, student_id, actor)

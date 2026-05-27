from datetime import datetime
from uuid import UUID

from sqlmodel import Session, select

from app.modules.licenses.models import StudentLicense


class StudentLicenseRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, row: StudentLicense) -> StudentLicense:
        self.db.add(row)
        return row

    def list_active_by_student(self, school_id: UUID, student_id: UUID) -> list[StudentLicense]:
        query = (
            select(StudentLicense)
            .where(
                StudentLicense.school_id == school_id,
                StudentLicense.student_id == student_id,
                StudentLicense.state == True,
            )
            .order_by(StudentLicense.created_date.desc())
        )
        return self.db.exec(query).all()

    def count_active_in_month_by_student(
        self,
        school_id: UUID,
        student_id: UUID,
        month_start: datetime,
        month_end: datetime,
    ) -> int:
        query = select(StudentLicense).where(
            StudentLicense.school_id == school_id,
            StudentLicense.student_id == student_id,
            StudentLicense.state == True,
            StudentLicense.created_date >= month_start,
            StudentLicense.created_date < month_end,
        )
        return len(self.db.exec(query).all())

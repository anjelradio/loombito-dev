from datetime import datetime, timezone
from io import BytesIO
from secrets import choice
from string import ascii_uppercase, digits
from uuid import UUID

from fastapi import HTTPException
from openpyxl import Workbook
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.dependencies.auth import CurrentActorContext
from app.modules.academic.models import Course
from app.modules.academic.permissions import ensure_admin_or_owner
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.students.models import StudentParentInvite
from app.modules.students.models import StudentParent
from app.modules.students.repositories import (
    CourseStudentRepository,
    StudentParentInviteRepository,
    StudentParentRepository,
    StudentRepository,
)
from app.modules.students.schemas import (
    StudentInviteBulkExportRequest,
    StudentLinkedByUserRead,
    StudentJoinByCode,
    StudentLinkedRead,
)
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


class StudentParentInviteService:
    def __init__(self, db: Session):
        self.db = db
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.course_student = CourseStudentRepository(db)
        self.invite = StudentParentInviteRepository(db)
        self.student_parent = StudentParentRepository(db)
        self.student = StudentRepository(db)
        self.audit_logger = AuditLogger(db)

    def _is_expired(self, expires_at: datetime) -> bool:
        normalized_expires_at = (
            expires_at.replace(tzinfo=timezone.utc)
            if expires_at.tzinfo is None
            else expires_at.astimezone(timezone.utc)
        )
        return normalized_expires_at <= datetime.now(timezone.utc)

    def _ensure_context(self, school_id: UUID, course_id: UUID, actor: CurrentActorContext) -> Course:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_owner(self.school_user, actor.user.id, school_id)

        course = self.db.get(Course, course_id)
        if not course or not course.state or course.school_id != school_id:
            raise HTTPException(status_code=404, detail="Curso no encontrado en esta escuela")

        return course

    def _build_code_base(self, first_name: str, last_name: str, birth_date) -> str:
        first_initial = first_name.strip()[:1].upper() if first_name.strip() else "X"
        last_initial = last_name.strip()[:1].upper() if last_name.strip() else "X"
        year_suffix = str(birth_date.year)[-2:]
        return f"{year_suffix}{first_initial}{last_initial}"

    def _generate_unique_code(self, first_name: str, last_name: str, birth_date) -> str:
        base = self._build_code_base(first_name, last_name, birth_date)
        alphabet = ascii_uppercase + digits

        for _ in range(40):
            suffix = "".join(choice(alphabet) for _ in range(2))
            code = f"{base}{suffix}"
            if not self.invite.get_active_by_code(code):
                return code

        raise HTTPException(status_code=500, detail="No se pudo generar un codigo unico")

    def _build_xlsx_bytes(
        self,
        course_name: str,
        expires_at: datetime,
        max_uses: int,
        rows: list[dict],
    ) -> bytes:
        workbook = Workbook()
        sheet = workbook.active
        sheet.title = "Codigos"

        sheet.append(["Course", course_name])
        sheet.append(["Expires At", expires_at.isoformat()])
        sheet.append(["Max Uses", max_uses])
        sheet.append([])
        sheet.append(["N", "First Name", "Last Name", "Code"])

        for row in rows:
            sheet.append([row["n"], row["first_name"], row["last_name"], row["code"]])

        buffer = BytesIO()
        workbook.save(buffer)
        buffer.seek(0)
        return buffer.getvalue()

    def export_course_student_invites(
        self,
        school_id: UUID,
        course_id: UUID,
        payload: StudentInviteBulkExportRequest,
        actor: CurrentActorContext,
    ) -> tuple[bytes, str, str]:
        course = self._ensure_context(school_id, course_id, actor)
        if self._is_expired(payload.expires_at):
            raise HTTPException(status_code=400, detail="expires_at must be in the future")

        students = self.course_student.list_active_students_by_course_without_pagination(
            school_id,
            course_id,
        )
        if not students:
            raise HTTPException(status_code=404, detail="No hay estudiantes activos en el curso")

        try:
            student_ids = [student.id for student in students]
            self.invite.delete_active_by_student_ids(student_ids)
            self.db.flush()

            export_rows: list[dict] = []
            for index, student in enumerate(students, start=1):
                invite = StudentParentInvite(
                    code=self._generate_unique_code(student.first_name, student.last_name, student.birth_date),
                    expires_at=payload.expires_at,
                    max_uses=payload.max_uses,
                    used_count=0,
                    student_id=student.id,
                )
                self.invite.create(invite)

                export_rows.append(
                    {
                        "n": index,
                        "first_name": student.first_name,
                        "last_name": student.last_name,
                        "code": invite.code,
                    }
                )

            self.db.commit()
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="No se pudo generar codigos para el curso")
        except Exception:
            self.db.rollback()
            raise

        self.audit_logger.safe_log_school_success(
            action=AuditAction.CREATE,
            description="Generacion masiva de codigos de vinculacion para estudiantes exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

        file_name = (
            f"{course.name}_student_invite_codes.xlsx".replace(" ", "_").replace("/", "-").lower()
        )
        media_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        content = self._build_xlsx_bytes(course.name, payload.expires_at, payload.max_uses, export_rows)
        return content, file_name, media_type

    def join_student_by_code(self, payload: StudentJoinByCode, actor: CurrentActorContext) -> StudentLinkedRead:
        invite = self.invite.get_active_by_code(payload.code)
        if not invite:
            raise HTTPException(status_code=404, detail="El codigo no existe o expiro")

        if self._is_expired(invite.expires_at):
            raise HTTPException(status_code=404, detail="El codigo no existe o expiro")

        if invite.used_count >= invite.max_uses:
            raise HTTPException(status_code=409, detail="El codigo alcanzo su limite de usos")

        student = self.student.get_active_by_id_in_school_for_any_school(invite.student_id)
        if not student:
            raise HTTPException(status_code=404, detail="Estudiante no encontrado")

        existing_link = self.student_parent.get_active_by_user_and_student(actor.user.id, student.id)
        if existing_link:
            raise HTTPException(status_code=409, detail="Ya te encuentras vinculado a este estudiante")

        try:
            self.student_parent.create(StudentParent(user_id=actor.user.id, student_id=student.id))
            invite.used_count += 1
            self.invite.update(invite)
            if invite.used_count >= invite.max_uses:
                self.invite.delete(invite)

            self.db.commit()
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="Ya te encuentras vinculado a este estudiante")

        self.audit_logger.safe_log_school_success(
            action=AuditAction.JOIN,
            description="Union a estudiante por codigo exitosa",
            ip=actor.ip,
            school_id=student.school_id,
            actor_user_id=actor.user.id,
        )

        school = self.school.get(student.school_id)
        school_name = school.name if school else ""
        course_name = self.student_parent.get_latest_active_course_name_by_student(student.id)
        return StudentLinkedRead(
            id=student.id,
            first_name=student.first_name,
            last_name=student.last_name,
            school_id=student.school_id,
            school_name=school_name,
            course_name=course_name,
        )

    def list_linked_students_by_user(self, actor: CurrentActorContext) -> list[StudentLinkedByUserRead]:
        rows = self.student_parent.list_active_students_by_user(actor.user.id)
        return [
            StudentLinkedByUserRead(
                id=student.id,
                first_name=student.first_name,
                last_name=student.last_name,
                school_id=student.school_id,
                school_name=school_name,
                course_name=self.student_parent.get_latest_active_course_name_by_student(student.id),
            )
            for student, school_name in rows
        ]

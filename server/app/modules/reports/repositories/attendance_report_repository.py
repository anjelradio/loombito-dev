from datetime import date
from uuid import UUID

from sqlalchemy import func
from sqlmodel import Session, select

from app.modules.academic.models import Assignment, Course, CourseSubject, Subject
from app.modules.attendance.models import AttendanceRecord, AttendanceSession, AttendanceStatus
from app.modules.students.models import Student


class AttendanceReportRepository:
    def __init__(self, db: Session):
        self.db = db

    # Obtiene metadatos de asignacion con curso y materia para encabezado del reporte.
    def get_assignment_metadata(self, school_id: UUID, assignment_id: UUID):
        query = (
            select(Assignment.id, Course.name, Subject.name)
            .join(CourseSubject, CourseSubject.id == Assignment.course_subject_id)
            .join(Course, Course.id == CourseSubject.course_id)
            .join(Subject, Subject.id == CourseSubject.subject_id)
            .where(
                Assignment.school_id == school_id,
                Assignment.id == assignment_id,
                Assignment.state == True,
                CourseSubject.state == True,
                Course.state == True,
                Subject.state == True,
            )
        )
        return self.db.exec(query).first()

    # Lista registros de asistencia por asignacion y rango de fechas.
    def list_rows_by_assignment_and_date_range(
        self,
        school_id: UUID,
        assignment_id: UUID,
        from_date: date | None = None,
        to_date: date | None = None,
        student_id: UUID | None = None,
        student_last_name: str | None = None,
        student_first_name: str | None = None,
        attendance_status_filter: str | None = None,
    ):
        query = (
            select(
                AttendanceSession.attendance_date,
                AttendanceSession.name,
                Student.last_name,
                Student.first_name,
                AttendanceStatus.name,
                AttendanceRecord.observation,
            )
            .join(AttendanceRecord, AttendanceRecord.attendance_session_id == AttendanceSession.id)
            .join(Student, Student.id == AttendanceRecord.student_id)
            .join(AttendanceStatus, AttendanceStatus.id == AttendanceRecord.status_id)
            .where(
                AttendanceSession.school_id == school_id,
                AttendanceSession.assignment_id == assignment_id,
                AttendanceSession.state == True,
                AttendanceRecord.state == True,
                AttendanceStatus.state == True,
                Student.state == True,
                Student.school_id == school_id,
            )
            .order_by(
                AttendanceSession.attendance_date.asc(),
                Student.last_name.asc(),
                Student.first_name.asc(),
            )
        )
        if student_id:
            query = query.where(Student.id == student_id)
        if from_date:
            query = query.where(AttendanceSession.attendance_date >= from_date)
        if to_date:
            query = query.where(AttendanceSession.attendance_date <= to_date)
        if student_last_name and student_last_name.strip():
            query = query.where(func.lower(Student.last_name).like(f"%{student_last_name.strip().lower()}%"))
        if student_first_name and student_first_name.strip():
            query = query.where(func.lower(Student.first_name).like(f"%{student_first_name.strip().lower()}%"))
        if attendance_status_filter and attendance_status_filter.strip().lower() != "all":
            query = query.where(func.lower(AttendanceStatus.name) == attendance_status_filter.strip().lower())
        return self.db.exec(query).all()

    # Lista registros para resumen general por estudiante en un rango de fechas.
    def list_rows_for_general_summary(
        self,
        school_id: UUID,
        assignment_id: UUID,
        from_date: date | None = None,
        to_date: date | None = None,
    ):
        query = (
            select(
                Student.id,
                Student.last_name,
                Student.first_name,
                AttendanceStatus.name,
            )
            .join(AttendanceRecord, AttendanceRecord.student_id == Student.id)
            .join(AttendanceSession, AttendanceSession.id == AttendanceRecord.attendance_session_id)
            .join(AttendanceStatus, AttendanceStatus.id == AttendanceRecord.status_id)
            .where(
                AttendanceSession.school_id == school_id,
                AttendanceSession.assignment_id == assignment_id,
                AttendanceSession.state == True,
                AttendanceRecord.state == True,
                AttendanceStatus.state == True,
                Student.state == True,
                Student.school_id == school_id,
            )
            .order_by(Student.last_name.asc(), Student.first_name.asc())
        )
        if from_date:
            query = query.where(AttendanceSession.attendance_date >= from_date)
        if to_date:
            query = query.where(AttendanceSession.attendance_date <= to_date)
        return self.db.exec(query).all()

    # Obtiene primera y ultima fecha de asistencia para una asignacion.
    def get_assignment_attendance_date_bounds(self, school_id: UUID, assignment_id: UUID):
        query = (
            select(func.min(AttendanceSession.attendance_date), func.max(AttendanceSession.attendance_date))
            .where(
                AttendanceSession.school_id == school_id,
                AttendanceSession.assignment_id == assignment_id,
                AttendanceSession.state == True,
            )
        )
        return self.db.exec(query).first()

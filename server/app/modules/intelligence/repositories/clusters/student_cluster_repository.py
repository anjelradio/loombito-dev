from uuid import UUID

from sqlmodel import Session, select

from app.modules.academic.models import Assignment, Term
from app.modules.attendance.models import AttendanceRecord, AttendanceSession, AttendanceStatus
from app.modules.evaluations.models import TermSubjectAverage
from app.modules.intelligence.models import StudentClusterResult, StudentClusterRun
from app.modules.schools.models import School
from app.modules.students.models import Student


class StudentClusterRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_school(self, school_id: UUID) -> School | None:
        return self.db.get(School, school_id)

    def get_active_assignment_in_school(self, school_id: UUID, assignment_id: UUID) -> Assignment | None:
        query = select(Assignment).where(
            Assignment.id == assignment_id,
            Assignment.school_id == school_id,
            Assignment.state == True,
        )
        return self.db.exec(query).first()

    def get_active_term_in_school(self, school_id: UUID, term_id: UUID) -> Term | None:
        query = select(Term).where(
            Term.id == term_id,
            Term.school_id == school_id,
            Term.state == True,
        )
        return self.db.exec(query).first()

    def get_active_run(self, school_id: UUID, assignment_id: UUID, term_id: UUID) -> StudentClusterRun | None:
        query = select(StudentClusterRun).where(
            StudentClusterRun.school_id == school_id,
            StudentClusterRun.assignment_id == assignment_id,
            StudentClusterRun.term_id == term_id,
            StudentClusterRun.is_active == True,
            StudentClusterRun.state == True,
        )
        return self.db.exec(query).first()

    def list_active_results_by_run(self, run_id: UUID) -> list[StudentClusterResult]:
        query = select(StudentClusterResult).where(
            StudentClusterResult.run_id == run_id,
            StudentClusterResult.state == True,
        )
        return self.db.exec(query).all()

    def list_students_by_ids_in_school(self, school_id: UUID, student_ids: list[UUID]) -> list[Student]:
        if not student_ids:
            return []
        query = select(Student).where(
            Student.school_id == school_id,
            Student.id.in_(student_ids),
            Student.state == True,
        )
        return self.db.exec(query).all()

    def list_final_scores(self, school_id: UUID, assignment_id: UUID, term_id: UUID):
        query = select(TermSubjectAverage.student_id, TermSubjectAverage.final_score).where(
            TermSubjectAverage.school_id == school_id,
            TermSubjectAverage.assignment_id == assignment_id,
            TermSubjectAverage.term_id == term_id,
            TermSubjectAverage.state == True,
        )
        return self.db.exec(query).all()

    def get_attendance_status_ids_by_name(self) -> dict[str, UUID]:
        query = select(AttendanceStatus.id, AttendanceStatus.name).where(AttendanceStatus.state == True)
        rows = self.db.exec(query).all()
        return {name.lower(): status_id for status_id, name in rows}

    def list_attendance_records_by_assignment_and_term(self, school_id: UUID, assignment_id: UUID, term_id: UUID):
        query = (
            select(AttendanceRecord.student_id, AttendanceRecord.status_id)
            .join(AttendanceSession, AttendanceSession.id == AttendanceRecord.attendance_session_id)
            .where(
                AttendanceRecord.school_id == school_id,
                AttendanceRecord.state == True,
                AttendanceSession.school_id == school_id,
                AttendanceSession.assignment_id == assignment_id,
                AttendanceSession.term_id == term_id,
                AttendanceSession.state == True,
            )
        )
        return self.db.exec(query).all()

    def deactivate_active_runs(self, school_id: UUID, assignment_id: UUID, term_id: UUID) -> None:
        query = select(StudentClusterRun).where(
            StudentClusterRun.school_id == school_id,
            StudentClusterRun.assignment_id == assignment_id,
            StudentClusterRun.term_id == term_id,
            StudentClusterRun.is_active == True,
            StudentClusterRun.state == True,
        )
        rows = self.db.exec(query).all()
        for row in rows:
            row.is_active = False
            self.db.add(row)

    def create_run(self, run: StudentClusterRun) -> StudentClusterRun:
        self.db.add(run)
        return run

    def create_result(self, result: StudentClusterResult) -> StudentClusterResult:
        self.db.add(result)
        return result

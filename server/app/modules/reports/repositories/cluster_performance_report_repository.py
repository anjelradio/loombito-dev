from uuid import UUID

from sqlalchemy import case, func
from sqlmodel import Session, select

from app.modules.academic.models import Assignment, Course, CourseSubject, Subject
from app.modules.attendance.models import AttendanceRecord, AttendanceSession, AttendanceStatus
from app.modules.evaluations.models import TermSubjectAverage
from app.modules.intelligence.models import StudentClusterResult, StudentClusterRun
from app.modules.students.models import Student


class ClusterPerformanceReportRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_assignment_metadata(self, school_id: UUID, assignment_id: UUID):
        query = (
            select(Assignment.id, Course.name, Subject.name)
            .join(CourseSubject, CourseSubject.id == Assignment.course_subject_id)
            .join(Course, Course.id == CourseSubject.course_id)
            .join(Subject, Subject.id == CourseSubject.subject_id)
            .where(
                Assignment.id == assignment_id,
                Assignment.school_id == school_id,
                Assignment.state == True,
                CourseSubject.state == True,
                Course.state == True,
                Subject.state == True,
            )
        )
        return self.db.exec(query).first()

    def get_active_cluster_run(self, school_id: UUID, assignment_id: UUID, term_id: UUID):
        query = select(StudentClusterRun).where(
            StudentClusterRun.school_id == school_id,
            StudentClusterRun.assignment_id == assignment_id,
            StudentClusterRun.term_id == term_id,
            StudentClusterRun.is_active == True,
            StudentClusterRun.state == True,
        )
        return self.db.exec(query).first()

    def list_rows_by_run_and_cluster(
        self,
        school_id: UUID,
        assignment_id: UUID,
        term_id: UUID,
        run_id: UUID,
        cluster_label: str,
    ):
        present_count = func.sum(case((func.lower(AttendanceStatus.name) == "presente", 1), else_=0))
        absence_count = func.sum(case((func.lower(AttendanceStatus.name) == "falta", 1), else_=0))
        license_count = func.sum(case((func.lower(AttendanceStatus.name) == "licencia", 1), else_=0))
        total_sessions = func.count(AttendanceRecord.id)

        query = (
            select(
                Student.id,
                Student.last_name,
                Student.first_name,
                StudentClusterResult.cluster_label,
                TermSubjectAverage.final_score,
                StudentClusterResult.attendance_rate,
                present_count.label("present_count"),
                absence_count.label("absence_count"),
                license_count.label("license_count"),
                total_sessions.label("total_sessions"),
            )
            .join(Student, Student.id == StudentClusterResult.student_id)
            .join(
                TermSubjectAverage,
                (
                    (TermSubjectAverage.student_id == StudentClusterResult.student_id)
                    & (TermSubjectAverage.school_id == school_id)
                    & (TermSubjectAverage.assignment_id == assignment_id)
                    & (TermSubjectAverage.term_id == term_id)
                    & (TermSubjectAverage.state == True)
                ),
            )
            .outerjoin(
                AttendanceSession,
                (
                    (AttendanceSession.school_id == school_id)
                    & (AttendanceSession.assignment_id == assignment_id)
                    & (AttendanceSession.term_id == term_id)
                    & (AttendanceSession.state == True)
                ),
            )
            .outerjoin(
                AttendanceRecord,
                (
                    (AttendanceRecord.attendance_session_id == AttendanceSession.id)
                    & (AttendanceRecord.student_id == Student.id)
                    & (AttendanceRecord.school_id == school_id)
                    & (AttendanceRecord.state == True)
                ),
            )
            .outerjoin(
                AttendanceStatus,
                (
                    (AttendanceStatus.id == AttendanceRecord.status_id)
                    & (AttendanceStatus.state == True)
                ),
            )
            .where(
                StudentClusterResult.run_id == run_id,
                StudentClusterResult.school_id == school_id,
                StudentClusterResult.state == True,
                Student.state == True,
                Student.school_id == school_id,
            )
            .group_by(
                Student.id,
                Student.last_name,
                Student.first_name,
                StudentClusterResult.cluster_label,
                TermSubjectAverage.final_score,
                StudentClusterResult.attendance_rate,
            )
            .order_by(TermSubjectAverage.final_score.desc(), Student.last_name.asc(), Student.first_name.asc())
        )

        if cluster_label != "all":
            query = query.where(StudentClusterResult.cluster_label == cluster_label)

        return self.db.exec(query).all()

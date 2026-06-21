from uuid import UUID

from sqlmodel import Session, select

from app.modules.academic.models import Assignment, Course, CourseSubject, Subject, Term
from app.modules.schools.models import Level, SchoolLevel, School
from app.modules.evaluations.models import TermSubjectAverage
from app.modules.students.models import Student


class BoletinReportRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_school_name(self, school_id: UUID) -> str:
        query = select(School.name).where(School.id == school_id)
        return self.db.exec(query).first() or "Unidad Educativa"

    def get_course_metadata(self, school_id: UUID, course_id: UUID):
        query = (
            select(Course.name, Level.name)
            .join(SchoolLevel, SchoolLevel.id == Course.school_level_id)
            .join(Level, Level.id == SchoolLevel.level_id)
            .where(
                Course.id == course_id,
                Course.school_id == school_id,
                Course.state == True,
                SchoolLevel.state == True,
                Level.state == True
            )
        )
        return self.db.exec(query).first()

    def get_student_metadata(self, school_id: UUID, student_id: UUID):
        query = select(Student.first_name, Student.last_name, Student.birth_date).where(
            Student.id == student_id,
            Student.school_id == school_id,
            Student.state == True
        )
        return self.db.exec(query).first()

    def list_active_terms(self, school_id: UUID):
        query = select(Term.id, Term.name).where(
            Term.school_id == school_id,
            Term.state == True
        ).order_by(Term.start_date.asc())
        return self.db.exec(query).all()

    def list_assignments_by_course(self, school_id: UUID, course_id: UUID):
        query = (
            select(Assignment.id, Subject.name)
            .join(CourseSubject, CourseSubject.id == Assignment.course_subject_id)
            .join(Subject, Subject.id == CourseSubject.subject_id)
            .where(
                CourseSubject.course_id == course_id,
                Assignment.school_id == school_id,
                Assignment.state == True,
                CourseSubject.state == True,
                Subject.state == True
            )
        )
        return self.db.exec(query).all()

    def list_student_averages_by_course(self, school_id: UUID, course_id: UUID, student_id: UUID):
        query = (
            select(
                TermSubjectAverage.assignment_id,
                TermSubjectAverage.term_id,
                TermSubjectAverage.final_score
            )
            .join(Assignment, Assignment.id == TermSubjectAverage.assignment_id)
            .join(CourseSubject, CourseSubject.id == Assignment.course_subject_id)
            .where(
                TermSubjectAverage.school_id == school_id,
                TermSubjectAverage.student_id == student_id,
                CourseSubject.course_id == course_id,
                TermSubjectAverage.state == True,
                Assignment.state == True,
                CourseSubject.state == True
            )
        )
        return self.db.exec(query).all()

from uuid import UUID

from sqlmodel import Session, select

from app.modules.academic.models import Assignment, Course, CourseSubject, Subject, Term
from app.modules.evaluations.models import TermSubjectAverage
from app.modules.students.models import CourseStudent, Student


class TermAverageReportRepository:
    def __init__(self, db: Session):
        self.db = db

    # Obtiene metadatos de asignacion para encabezado de reporte de promedios.
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

    # Obtiene nombre del trimestre activo objetivo del reporte.
    def get_term_name(self, school_id: UUID, term_id: UUID):
        query = select(Term.name).where(
            Term.id == term_id,
            Term.school_id == school_id,
            Term.state == True,
        )
        return self.db.exec(query).first()

    # Lista estudiantes activos de una asignacion para incluir calculados y sin calcular.
    def list_active_students_by_assignment(self, school_id: UUID, assignment_id: UUID):
        query = (
            select(Student.id, Student.last_name, Student.first_name)
            .join(CourseStudent, CourseStudent.student_id == Student.id)
            .join(Course, Course.id == CourseStudent.course_id)
            .join(CourseSubject, CourseSubject.course_id == Course.id)
            .join(Assignment, Assignment.course_subject_id == CourseSubject.id)
            .where(
                Assignment.id == assignment_id,
                Assignment.school_id == school_id,
                Assignment.state == True,
                CourseSubject.state == True,
                Course.state == True,
                CourseStudent.state == True,
                Student.state == True,
                Student.school_id == school_id,
            )
            .order_by(Student.last_name.asc(), Student.first_name.asc())
        )
        return self.db.exec(query).all()

    # Lista promedios trimestrales ya calculados para una asignacion y trimestre.
    def list_active_averages_by_assignment_and_term(self, school_id: UUID, assignment_id: UUID, term_id: UUID):
        query = select(
            TermSubjectAverage.student_id,
            TermSubjectAverage.saber_score,
            TermSubjectAverage.hacer_score,
            TermSubjectAverage.ser_score,
            TermSubjectAverage.autoevaluacion_score,
            TermSubjectAverage.final_score,
        ).where(
            TermSubjectAverage.school_id == school_id,
            TermSubjectAverage.assignment_id == assignment_id,
            TermSubjectAverage.term_id == term_id,
            TermSubjectAverage.state == True,
        )
        return self.db.exec(query).all()

from uuid import UUID

from sqlmodel import Session, select

from app.modules.academic.models import Assignment, Course, CourseSubject, Subject, Term
from app.modules.evaluations.models import Evaluation, EvaluationGrade
from app.modules.students.models import CourseStudent, Student


class EvaluationReportRepository:
    def __init__(self, db: Session):
        self.db = db

    # Obtiene metadatos de evaluacion con curso, materia y trimestre.
    def get_evaluation_metadata(self, school_id: UUID, evaluation_id: UUID):
        query = (
            select(Evaluation.id, Evaluation.name, Evaluation.term_id, Term.name, Assignment.id, Course.name, Subject.name)
            .join(Assignment, Assignment.id == Evaluation.assignment_id)
            .join(CourseSubject, CourseSubject.id == Assignment.course_subject_id)
            .join(Course, Course.id == CourseSubject.course_id)
            .join(Subject, Subject.id == CourseSubject.subject_id)
            .join(Term, Term.id == Evaluation.term_id)
            .where(
                Evaluation.id == evaluation_id,
                Evaluation.school_id == school_id,
                Evaluation.state == True,
                Assignment.state == True,
                CourseSubject.state == True,
                Course.state == True,
                Subject.state == True,
                Term.state == True,
            )
        )
        return self.db.exec(query).first()

    # Obtiene metadatos de asignacion para curso y materia.
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

    # Lista evaluaciones activas de una asignacion ordenadas por fecha.
    def list_active_evaluations_by_assignment(self, school_id: UUID, assignment_id: UUID):
        query = (
            select(Evaluation.id, Evaluation.name, Term.id, Term.name)
            .join(Term, Term.id == Evaluation.term_id)
            .where(
                Evaluation.assignment_id == assignment_id,
                Evaluation.school_id == school_id,
                Evaluation.state == True,
                Term.state == True,
            )
            .order_by(Evaluation.presentation_date.asc(), Evaluation.created_date.asc())
        )
        return self.db.exec(query).all()

    # Lista estudiantes activos de una asignacion para armar gradebook completo.
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

    # Lista calificaciones activas para una evaluacion.
    def list_active_grades_by_evaluation(self, school_id: UUID, evaluation_id: UUID):
        query = select(EvaluationGrade.student_id, EvaluationGrade.score).where(
            EvaluationGrade.school_id == school_id,
            EvaluationGrade.evaluation_id == evaluation_id,
            EvaluationGrade.state == True,
        )
        return self.db.exec(query).all()

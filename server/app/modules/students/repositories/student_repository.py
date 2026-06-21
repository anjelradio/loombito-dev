from uuid import UUID

from sqlmodel import Session, func, select

from app.modules.academic.models import Course
from app.modules.evaluations.models import EvaluationGrade
from app.modules.students.models import CourseStudent, Student


class StudentRepository:
    def __init__(self, db: Session):
        self.db = db

    # Persiste un nuevo estudiante en la sesion actual.
    def create(self, student: Student) -> Student:
        self.db.add(student)
        return student

    # Persiste cambios sobre un estudiante existente.
    def update(self, student: Student) -> Student:
        self.db.add(student)
        return student

    # Desactiva un estudiante (borrado logico).
    def delete(self, student: Student) -> Student:
        student.state = False
        self.db.add(student)
        return student

    # Busca un estudiante activo por ID dentro de una escuela.
    def get_active_by_id_in_school(self, school_id: UUID, student_id: UUID) -> Student | None:
        query = select(Student).where(
            Student.id == student_id,
            Student.school_id == school_id,
            Student.state == True,
        )
        return self.db.exec(query).first()

    def get_active_by_id_in_school_for_any_school(self, student_id: UUID) -> Student | None:
        query = select(Student).where(
            Student.id == student_id,
            Student.state == True,
        )
        return self.db.exec(query).first()

    def list_active_by_school(self, school_id: UUID) -> list[Student]:
        query = select(Student).where(
            Student.school_id == school_id,
            Student.state == True,
        )
        return self.db.exec(query).all()

    # Busca un estudiante activo por identidad (nombre, apellido y fecha de nacimiento) en la escuela.
    def get_by_identity_in_school(
        self,
        school_id: UUID,
        first_name: str,
        last_name: str,
        birth_date,
    ) -> Student | None:
        query = select(Student).where(
            Student.school_id == school_id,
            func.lower(Student.first_name) == first_name.lower(),
            func.lower(Student.last_name) == last_name.lower(),
            Student.birth_date == birth_date,
            Student.state == True,
        )
        return self.db.exec(query).first()


class CourseStudentRepository:
    def __init__(self, db: Session):
        self.db = db

    # Persiste una nueva vinculacion curso-estudiante en la sesion actual.
    def create(self, link: CourseStudent) -> CourseStudent:
        self.db.add(link)
        return link

    # Busca una vinculacion activa entre curso y estudiante.
    def get_active_link(self, course_id: UUID, student_id: UUID) -> CourseStudent | None:
        query = select(CourseStudent).where(
            CourseStudent.course_id == course_id,
            CourseStudent.student_id == student_id,
            CourseStudent.state == True,
        )
        return self.db.exec(query).first()

    # Desactiva una vinculacion curso-estudiante (borrado logico).
    def delete(self, link: CourseStudent) -> CourseStudent:
        link.state = False
        self.db.add(link)
        return link

    # Desactiva todas las vinculaciones activas de un estudiante.
    def delete_active_links_by_student(self, student_id: UUID) -> None:
        query = select(CourseStudent).where(
            CourseStudent.student_id == student_id,
            CourseStudent.state == True,
        )
        links = self.db.exec(query).all()
        for link in links:
            link.state = False
            self.db.add(link)

    # Cuenta estudiantes activos vinculados a un curso dentro de la escuela.
    def count_active_students_by_course(self, school_id: UUID, course_id: UUID) -> int:
        query = (
            select(func.count())
            .select_from(CourseStudent)
            .join(Student, Student.id == CourseStudent.student_id)
            .join(Course, Course.id == CourseStudent.course_id)
            .where(
                CourseStudent.course_id == course_id,
                CourseStudent.state == True,
                Student.state == True,
                Student.school_id == school_id,
                Course.state == True,
                Course.school_id == school_id,
            )
        )
        return self.db.exec(query).one()

    # Cuenta estudiantes activos de un curso con filtro opcional por nombre o apellido.
    def count_active_students_by_course_with_search(
        self, school_id: UUID, course_id: UUID, search: str | None = None
    ) -> int:
        query = (
            select(func.count())
            .select_from(CourseStudent)
            .join(Student, Student.id == CourseStudent.student_id)
            .join(Course, Course.id == CourseStudent.course_id)
            .where(
                CourseStudent.course_id == course_id,
                CourseStudent.state == True,
                Student.state == True,
                Student.school_id == school_id,
                Course.state == True,
                Course.school_id == school_id,
            )
        )
        if search:
            query = query.where(
                (func.lower(Student.first_name).contains(search.lower()))
                | (func.lower(Student.last_name).contains(search.lower()))
            )
        return self.db.exec(query).one()

    # Lista estudiantes activos de un curso de forma paginada con filtro opcional.
    def list_active_students_by_course(
        self,
        school_id: UUID,
        course_id: UUID,
        search: str | None = None,
        *,
        per_page: int,
        page: int,
    ) -> list[Student]:
        query = (
            select(Student)
            .join(CourseStudent, CourseStudent.student_id == Student.id)
            .join(Course, Course.id == CourseStudent.course_id)
            .where(
                CourseStudent.course_id == course_id,
                CourseStudent.state == True,
                Student.state == True,
                Student.school_id == school_id,
                Course.state == True,
                Course.school_id == school_id,
            )
            .order_by(Student.created_date.desc())
        )
        if search:
            query = query.where(
                (func.lower(Student.first_name).contains(search.lower()))
                | (func.lower(Student.last_name).contains(search.lower()))
            )
        offset = (page - 1) * per_page
        return self.db.exec(query.offset(offset).limit(per_page)).all()

    # Lista estudiantes activos de un curso sin paginacion.
    def list_active_students_by_course_without_pagination(
        self,
        school_id: UUID,
        course_id: UUID,
    ) -> list[Student]:
        query = (
            select(Student)
            .join(CourseStudent, CourseStudent.student_id == Student.id)
            .join(Course, Course.id == CourseStudent.course_id)
            .where(
                CourseStudent.course_id == course_id,
                CourseStudent.state == True,
                Student.state == True,
                Student.school_id == school_id,
                Course.state == True,
                Course.school_id == school_id,
            )
            .order_by(Student.last_name.asc(), Student.first_name.asc())
        )
        return self.db.exec(query).all()


class EvaluationGradeRepository:
    def __init__(self, db: Session):
        self.db = db

    # Busca una calificacion activa por evaluacion y estudiante.
    def get_active_by_evaluation_and_student(
        self,
        school_id: UUID,
        evaluation_id: UUID,
        student_id: UUID,
    ) -> EvaluationGrade | None:
        query = select(EvaluationGrade).where(
            EvaluationGrade.school_id == school_id,
            EvaluationGrade.evaluation_id == evaluation_id,
            EvaluationGrade.student_id == student_id,
            EvaluationGrade.state == True,
        )
        return self.db.exec(query).first()

    # Persiste una nueva calificacion en la sesion actual.
    def create(self, grade: EvaluationGrade) -> EvaluationGrade:
        self.db.add(grade)
        return grade

    # Persiste cambios sobre una calificacion existente.
    def update(self, grade: EvaluationGrade) -> EvaluationGrade:
        self.db.add(grade)
        return grade

    # Lista calificaciones activas de una evaluacion.
    def list_active_by_evaluation(self, school_id: UUID, evaluation_id: UUID) -> list[EvaluationGrade]:
        query = select(EvaluationGrade).where(
            EvaluationGrade.school_id == school_id,
            EvaluationGrade.evaluation_id == evaluation_id,
            EvaluationGrade.state == True,
        )
        return self.db.exec(query).all()

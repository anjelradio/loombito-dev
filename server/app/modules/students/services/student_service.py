from math import ceil
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.dependencies.auth import CurrentActorContext
from app.modules.academic.models import Assignment, Course, CourseSubject
from app.modules.evaluations.models import Evaluation, EvaluationGrade
from app.modules.schools.models import SchoolRole
from app.modules.academic.permissions import ensure_admin_or_owner
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.students.models import CourseStudent, Student
from app.modules.students.repositories import (
    CourseStudentRepository,
    EvaluationGradeRepository,
    StudentRepository,
)
from app.modules.students.schemas import (
    EvaluationFinalizeSummaryRead,
    PaginatedStudent,
    StudentCreate,
    StudentEvaluationGradeRowRead,
    StudentEvaluationGradeUpsert,
    StudentRead,
    StudentUpdate,
)
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


class StudentService:
    def __init__(self, db: Session):
        self.db = db
        self.student = StudentRepository(db)
        self.course_student = CourseStudentRepository(db)
        self.evaluation_grade = EvaluationGradeRepository(db)
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.audit_logger = AuditLogger(db)

    # Verifica existencia de la escuela y permisos administrativos del usuario.
    def _ensure_school_and_permissions(self, school_id: UUID, user_id: UUID) -> None:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")
        ensure_admin_or_owner(self.school_user, user_id, school_id)

    # Verifica que el curso pertenezca a la escuela y se encuentre activo.
    def _ensure_course_in_school(self, school_id: UUID, course_id: UUID) -> None:
        course = self.db.get(Course, course_id)
        if not course or not course.state or course.school_id != school_id:
            raise HTTPException(status_code=404, detail="Curso no encontrado en esta escuela")

    # Verifica membresia activa del docente en la escuela.
    def _ensure_teacher_membership(self, school_id: UUID, user_id: UUID):
        membership = self.school_user.get_by_user_school_and_role(
            user_id,
            school_id,
            SchoolRole.TEACHER,
        )
        if not membership:
            raise HTTPException(
                status_code=403,
                detail="Solo un docente de la escuela puede consultar este recurso",
            )
        return membership

    # Lista estudiantes activos de un curso con paginacion y busqueda opcional.
    def list_by_course(
        self,
        school_id: UUID,
        course_id: UUID,
        user_id: UUID,
        per_page: int,
        page: int,
        search: str | None = None,
    ) -> PaginatedStudent:
        self._ensure_school_and_permissions(school_id, user_id)
        self._ensure_course_in_school(school_id, course_id)

        total = self.course_student.count_active_students_by_course_with_search(
            school_id, course_id, search
        )
        total_pages = ceil(total / per_page) if total > 0 else 0
        current_page = 1 if total_pages == 0 else min(page, total_pages)

        students = (
            self.course_student.list_active_students_by_course(
                school_id,
                course_id,
                search,
                per_page=per_page,
                page=current_page,
            )
            if total_pages > 0
            else []
        )

        return PaginatedStudent(
            students=[StudentRead.model_validate(student) for student in students],
            page=current_page,
            per_page=per_page,
            total_pages=total_pages,
            has_prev=current_page > 1,
            has_next=current_page < total_pages if total_pages > 0 else False,
        )

    # Crea un estudiante nuevo o vincula uno existente al curso.
    def create_in_course(
        self,
        school_id: UUID,
        course_id: UUID,
        payload: StudentCreate,
        actor: CurrentActorContext,
    ) -> StudentRead:
        self._ensure_school_and_permissions(school_id, actor.user.id)
        self._ensure_course_in_school(school_id, course_id)

        existing = self.student.get_by_identity_in_school(
            school_id, payload.first_name, payload.last_name, payload.birth_date
        )
        if existing:
            if self.course_student.get_active_link(course_id, existing.id):
                raise HTTPException(status_code=409, detail="El estudiante ya esta vinculado al curso")

            try:
                self.course_student.create(CourseStudent(course_id=course_id, student_id=existing.id))
                self.db.commit()
                self.audit_logger.safe_log_school_success(
                    action=AuditAction.CREATE,
                    description="Vinculacion de estudiante a curso exitosa",
                    ip=actor.ip,
                    school_id=school_id,
                    actor_user_id=actor.user.id,
                )
                return StudentRead.model_validate(existing)
            except IntegrityError:
                self.db.rollback()
                raise HTTPException(status_code=409, detail="No se pudo vincular el estudiante")

        try:
            student = Student(
                first_name=payload.first_name,
                last_name=payload.last_name,
                birth_date=payload.birth_date,
                school_id=school_id,
            )
            self.student.create(student)
            self.db.flush()
            self.course_student.create(CourseStudent(course_id=course_id, student_id=student.id))
            self.db.commit()
            self.db.refresh(student)
            self.audit_logger.safe_log_school_success(
                action=AuditAction.CREATE,
                description="Creacion de estudiante en curso exitosa",
                ip=actor.ip,
                school_id=school_id,
                actor_user_id=actor.user.id,
            )
            return StudentRead.model_validate(student)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="No se pudo crear el estudiante")
        except Exception:
            self.db.rollback()
            raise

    # Actualiza los datos de un estudiante activo.
    def update(
        self,
        school_id: UUID,
        student_id: UUID,
        payload: StudentUpdate,
        actor: CurrentActorContext,
    ) -> StudentRead:
        self._ensure_school_and_permissions(school_id, actor.user.id)

        student = self.student.get_active_by_id_in_school(school_id, student_id)
        if not student:
            raise HTTPException(status_code=404, detail="Estudiante no encontrado")

        existing = self.student.get_by_identity_in_school(
            school_id, payload.first_name, payload.last_name, payload.birth_date
        )
        if existing and existing.id != student_id:
            raise HTTPException(status_code=409, detail="Ya existe un estudiante con esos datos")

        try:
            student.first_name = payload.first_name
            student.last_name = payload.last_name
            student.birth_date = payload.birth_date
            self.student.update(student)
            self.db.commit()
            self.db.refresh(student)
            self.audit_logger.safe_log_school_success(
                action=AuditAction.UPDATE,
                description="Actualizacion de estudiante exitosa",
                ip=actor.ip,
                school_id=school_id,
                actor_user_id=actor.user.id,
            )
            return StudentRead.model_validate(student)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(status_code=409, detail="No se pudo actualizar el estudiante")
        except Exception:
            self.db.rollback()
            raise

    # Desvincula un estudiante del curso y desactiva sus vinculaciones activas.
    def unlink_from_course(
        self,
        school_id: UUID,
        course_id: UUID,
        student_id: UUID,
        actor: CurrentActorContext,
    ) -> None:
        self._ensure_school_and_permissions(school_id, actor.user.id)
        self._ensure_course_in_school(school_id, course_id)

        student = self.student.get_active_by_id_in_school(school_id, student_id)
        if not student:
            raise HTTPException(status_code=404, detail="Estudiante no encontrado")

        link = self.course_student.get_active_link(course_id, student_id)
        if not link:
            raise HTTPException(status_code=404, detail="Vinculo curso-estudiante no encontrado")

        self.course_student.delete_active_links_by_student(student_id)
        self.student.delete(student)
        self.db.commit()
        self.audit_logger.safe_log_school_success(
            action=AuditAction.DELETE,
            description="Eliminacion de estudiante de curso exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

    # Lista estudiantes del curso asociado a una evaluacion para un docente.
    def list_by_evaluation_for_teacher(
        self,
        school_id: UUID,
        evaluation_id: UUID,
        user_id: UUID,
    ) -> list[StudentRead]:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        teacher_membership = self._ensure_teacher_membership(school_id, user_id)

        evaluation = self.db.get(Evaluation, evaluation_id)
        if not evaluation or not evaluation.state or evaluation.school_id != school_id:
            raise HTTPException(status_code=404, detail="Evaluacion no encontrada")

        assignment = self.db.get(Assignment, evaluation.assignment_id)
        if not assignment or not assignment.state or assignment.school_id != school_id:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")

        if assignment.teacher_id != teacher_membership.id:
            raise HTTPException(status_code=403, detail="No puedes consultar estudiantes de esta evaluacion")

        course_subject = self.db.get(CourseSubject, assignment.course_subject_id)
        if not course_subject or not course_subject.state:
            raise HTTPException(status_code=404, detail="Materia del curso no encontrada")

        self._ensure_course_in_school(school_id, course_subject.course_id)

        students = self.course_student.list_active_students_by_course_without_pagination(
            school_id,
            course_subject.course_id,
        )
        return [StudentRead.model_validate(student) for student in students]

    # Obtiene evaluacion y curso validando pertenencia del docente.
    def _get_evaluation_and_course_for_teacher(
        self,
        school_id: UUID,
        evaluation_id: UUID,
        user_id: UUID,
    ):
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        teacher_membership = self._ensure_teacher_membership(school_id, user_id)

        evaluation = self.db.get(Evaluation, evaluation_id)
        if not evaluation or not evaluation.state or evaluation.school_id != school_id:
            raise HTTPException(status_code=404, detail="Evaluacion no encontrada")

        assignment = self.db.get(Assignment, evaluation.assignment_id)
        if not assignment or not assignment.state or assignment.school_id != school_id:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")

        if assignment.teacher_id != teacher_membership.id:
            raise HTTPException(status_code=403, detail="No puedes consultar estudiantes de esta evaluacion")

        course_subject = self.db.get(CourseSubject, assignment.course_subject_id)
        if not course_subject or not course_subject.state:
            raise HTTPException(status_code=404, detail="Materia del curso no encontrada")

        self._ensure_course_in_school(school_id, course_subject.course_id)
        return evaluation, course_subject.course_id

    # Construye el gradebook de una evaluacion para el docente.
    def list_gradebook_by_evaluation_for_teacher(
        self,
        school_id: UUID,
        evaluation_id: UUID,
        user_id: UUID,
    ) -> list[StudentEvaluationGradeRowRead]:
        evaluation, course_id = self._get_evaluation_and_course_for_teacher(
            school_id,
            evaluation_id,
            user_id,
        )

        students = self.course_student.list_active_students_by_course_without_pagination(
            school_id,
            course_id,
        )
        grades = self.evaluation_grade.list_active_by_evaluation(school_id, evaluation.id)
        grades_by_student = {grade.student_id: grade for grade in grades}

        return [
            StudentEvaluationGradeRowRead(
                student_id=student.id,
                first_name=student.first_name,
                last_name=student.last_name,
                score=grades_by_student[student.id].score if student.id in grades_by_student else None,
                observation=grades_by_student[student.id].observation
                if student.id in grades_by_student
                else None,
                evaluation_grade_id=grades_by_student[student.id].id
                if student.id in grades_by_student
                else None,
                status="calificado" if student.id in grades_by_student else "sin_calificar",
            )
            for student in students
        ]

    # Crea o actualiza la calificacion de un estudiante en una evaluacion.
    def upsert_evaluation_grade_for_teacher(
        self,
        school_id: UUID,
        evaluation_id: UUID,
        student_id: UUID,
        payload: StudentEvaluationGradeUpsert,
        actor: CurrentActorContext,
    ) -> StudentEvaluationGradeRowRead:
        evaluation, course_id = self._get_evaluation_and_course_for_teacher(
            school_id,
            evaluation_id,
            actor.user.id,
        )

        student = self.student.get_active_by_id_in_school(school_id, student_id)
        if not student:
            raise HTTPException(status_code=404, detail="Estudiante no encontrado")

        link = self.course_student.get_active_link(course_id, student_id)
        if not link:
            raise HTTPException(status_code=403, detail="El estudiante no pertenece al curso de esta evaluacion")

        grade = self.evaluation_grade.get_active_by_evaluation_and_student(
            school_id,
            evaluation.id,
            student_id,
        )

        if grade:
            grade.score = payload.score
            grade.observation = payload.observation
            self.evaluation_grade.update(grade)
        else:
            grade = EvaluationGrade(
                score=payload.score,
                observation=payload.observation,
                evaluation_id=evaluation.id,
                student_id=student_id,
                school_id=school_id,
            )
            self.evaluation_grade.create(grade)

        self.db.commit()
        self.db.refresh(grade)

        self.audit_logger.safe_log_school_success(
            action=AuditAction.UPDATE,
            description="Calificacion de evaluacion actualizada exitosamente",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

        return StudentEvaluationGradeRowRead(
            student_id=student.id,
            first_name=student.first_name,
            last_name=student.last_name,
            score=grade.score,
            observation=grade.observation,
            evaluation_grade_id=grade.id,
            status="calificado",
        )

    # Finaliza una evaluacion completando con cero estudiantes faltantes.
    def finalize_evaluation_for_teacher(
        self,
        school_id: UUID,
        evaluation_id: UUID,
        actor: CurrentActorContext,
    ) -> EvaluationFinalizeSummaryRead:
        evaluation, course_id = self._get_evaluation_and_course_for_teacher(
            school_id,
            evaluation_id,
            actor.user.id,
        )

        students = self.course_student.list_active_students_by_course_without_pagination(
            school_id,
            course_id,
        )
        grades = self.evaluation_grade.list_active_by_evaluation(school_id, evaluation.id)
        grade_student_ids = {grade.student_id for grade in grades}

        created_missing = 0
        for student in students:
            if student.id in grade_student_ids:
                continue
            self.evaluation_grade.create(
                EvaluationGrade(
                    score=0,
                    observation=None,
                    evaluation_id=evaluation.id,
                    student_id=student.id,
                    school_id=school_id,
                )
            )
            created_missing += 1

        evaluation.is_closed = True
        self.db.add(evaluation)
        self.db.commit()

        self.audit_logger.safe_log_school_success(
            action=AuditAction.UPDATE,
            description="Finalizacion de evaluacion exitosa",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

        return EvaluationFinalizeSummaryRead(
            created_missing=created_missing,
            total_students=len(students),
        )

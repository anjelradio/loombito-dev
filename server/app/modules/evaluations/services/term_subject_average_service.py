from collections import defaultdict
from statistics import mean
from uuid import UUID

from fastapi import HTTPException
from sqlmodel import Session

from app.dependencies.auth import CurrentActorContext
from app.modules.evaluations.models import TermSubjectAverage
from app.modules.evaluations.permissions import ensure_admin_or_teacher_in_school
from app.modules.evaluations.repositories import TermSubjectAverageRepository
from app.modules.evaluations.schemas import (
    CalculateTermAverageSummaryRead,
    StudentTermAverageRowRead,
    TermAverageTermOptionRead,
)
from app.modules.schools.models import SchoolRole
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository
from app.modules.system.models import AuditAction
from app.modules.system.services import AuditLogger


class TermSubjectAverageService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = TermSubjectAverageRepository(db)
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.audit_logger = AuditLogger(db)

    # Verifica que la escuela exista.
    def _ensure_school_exists(self, school_id: UUID) -> None:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

    # Verifica que el usuario pueda consultar/cacular promedios en la escuela.
    def _ensure_user_access(self, school_id: UUID, user_id: UUID):
        return ensure_admin_or_teacher_in_school(self.school_user, user_id, school_id)

    # Valida asignacion y acceso del docente si corresponde.
    def _validate_assignment_access(self, school_id: UUID, assignment_id: UUID, membership) -> None:
        assignment = self.repo.get_active_assignment_by_id_in_school(school_id, assignment_id)
        if not assignment:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")

        if membership.role == SchoolRole.TEACHER and assignment.teacher_id != membership.id:
            raise HTTPException(status_code=403, detail="No puedes consultar promedios de esta asignacion")

    # Valida que el trimestre pertenezca a la escuela y este activo.
    def _validate_term(self, school_id: UUID, term_id: UUID) -> None:
        term = self.repo.get_active_term_by_id_in_school(school_id, term_id)
        if not term:
            raise HTTPException(status_code=400, detail="Trimestre no valido")

    # Redondea un numero a 2 decimales para respuestas consistentes.
    def _round(self, value: float) -> float:
        return round(value, 2)

    # Lista trimestres activos para selector de la pantalla de promedios.
    def list_term_average_options(self, school_id: UUID, user_id: UUID) -> list[TermAverageTermOptionRead]:
        from datetime import date

        self._ensure_school_exists(school_id)
        self._ensure_user_access(school_id, user_id)

        rows = self.repo.list_active_terms_with_active_flag(school_id, date.today())
        return [
            TermAverageTermOptionRead(
                id=term.id,
                name=term.name,
                start_date=term.start_date,
                end_date=term.end_date,
                is_active=is_active,
            )
            for term, is_active in rows
        ]

    # Lista estudiantes con promedio calculado o estado sin_calcular.
    def list_by_assignment_and_term(
        self,
        school_id: UUID,
        assignment_id: UUID,
        term_id: UUID,
        user_id: UUID,
    ) -> list[StudentTermAverageRowRead]:
        self._ensure_school_exists(school_id)
        membership = self._ensure_user_access(school_id, user_id)
        self._validate_assignment_access(school_id, assignment_id, membership)
        self._validate_term(school_id, term_id)

        students = self.repo.list_active_students_by_assignment(school_id, assignment_id)
        average_rows = self.repo.list_active_by_assignment_and_term(school_id, assignment_id, term_id)
        averages_by_student = {item.student_id: item for item in average_rows}

        rows: list[StudentTermAverageRowRead] = []
        for student in students:
            average = averages_by_student.get(student.id)
            rows.append(
                StudentTermAverageRowRead(
                    student_id=student.id,
                    first_name=student.first_name,
                    last_name=student.last_name,
                    saber_score=self._round(average.saber_score) if average else None,
                    hacer_score=self._round(average.hacer_score) if average else None,
                    ser_score=self._round(average.ser_score) if average else None,
                    autoevaluacion_score=self._round(average.autoevaluacion_score) if average else None,
                    final_score=self._round(average.final_score) if average else None,
                    status="calculado" if average else "sin_calcular",
                )
            )
        return rows

    # Calcula y reemplaza promedios trimestrales para todos los estudiantes de la asignacion.
    def calculate_by_assignment_and_term(
        self,
        school_id: UUID,
        assignment_id: UUID,
        term_id: UUID,
        actor: CurrentActorContext,
    ) -> CalculateTermAverageSummaryRead:
        self._ensure_school_exists(school_id)
        membership = self._ensure_user_access(school_id, actor.user.id)
        self._validate_assignment_access(school_id, assignment_id, membership)
        self._validate_term(school_id, term_id)

        course_and_level = self.repo.get_course_and_level_by_assignment(assignment_id)
        if not course_and_level:
            raise HTTPException(status_code=404, detail="No se pudo resolver el curso de la asignacion")
        _, school_level_id = course_and_level

        weight = self.repo.get_active_weight_by_school_and_level(school_id, school_level_id)
        if not weight:
            raise HTTPException(status_code=400, detail="No hay ponderacion configurada para el nivel del curso")

        students = self.repo.list_active_students_by_assignment(school_id, assignment_id)
        evaluations = self.repo.list_active_evaluations_by_assignment_and_term(school_id, assignment_id, term_id)
        evaluation_ids = [evaluation_id for evaluation_id, _ in evaluations]
        evaluation_type_by_id = {evaluation_id: type_name.lower() for evaluation_id, type_name in evaluations}

        grades = self.repo.list_active_grades_by_evaluation_ids(school_id, evaluation_ids)
        grades_by_student_dimension = defaultdict(lambda: defaultdict(list))

        for grade in grades:
            type_name = evaluation_type_by_id.get(grade.evaluation_id, "")
            if type_name == "examen":
                dimension = "saber"
            elif type_name == "autoevaluacion":
                dimension = "autoevaluacion"
            else:
                dimension = "hacer"
            grades_by_student_dimension[grade.student_id][dimension].append(float(grade.score))

        status_ids = self.repo.get_attendance_status_ids_by_name()
        attendance_records = self.repo.list_attendance_records_by_assignment_and_term(
            school_id,
            assignment_id,
            term_id,
        )
        attendance_map = {
            status_ids.get("presente"): 100.0,
            status_ids.get("licencia"): 50.0,
            status_ids.get("falta"): 0.0,
        }
        for student_id, status_id in attendance_records:
            value = attendance_map.get(status_id)
            if value is None:
                continue
            grades_by_student_dimension[student_id]["ser"].append(value)

        w_saber = weight.saber / 100
        w_hacer = weight.hacer / 100
        w_ser = weight.ser / 100
        w_auto = weight.autoevaluacion / 100

        self.repo.soft_delete_by_assignment_and_term(school_id, assignment_id, term_id)

        for student in students:
            student_dimensions = grades_by_student_dimension.get(student.id, {})
            saber_score = mean(student_dimensions.get("saber", [0.0]))
            hacer_score = mean(student_dimensions.get("hacer", [0.0]))
            ser_score = mean(student_dimensions.get("ser", [0.0]))
            auto_score = mean(student_dimensions.get("autoevaluacion", [0.0]))
            final_score = (saber_score * w_saber) + (hacer_score * w_hacer) + (ser_score * w_ser) + (auto_score * w_auto)

            self.repo.create(
                TermSubjectAverage(
                    assignment_id=assignment_id,
                    term_id=term_id,
                    student_id=student.id,
                    school_id=school_id,
                    saber_score=self._round(saber_score),
                    hacer_score=self._round(hacer_score),
                    ser_score=self._round(ser_score),
                    autoevaluacion_score=self._round(auto_score),
                    final_score=self._round(final_score),
                )
            )

        self.db.commit()

        self.audit_logger.safe_log_school_success(
            action=AuditAction.UPDATE,
            description="Calculo de promedios trimestrales exitoso",
            ip=actor.ip,
            school_id=school_id,
            actor_user_id=actor.user.id,
        )

        return CalculateTermAverageSummaryRead(
            processed_students=len(students),
            assignment_id=assignment_id,
            term_id=term_id,
        )

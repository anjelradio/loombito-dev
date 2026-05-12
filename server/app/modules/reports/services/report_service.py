from io import BytesIO
from datetime import date
from uuid import UUID

from fastapi import HTTPException
from openpyxl import Workbook
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle
from sqlmodel import Session

from app.modules.reports.catalog import REPORT_CATALOG
from app.modules.reports.models import ReportRun, ReportType
from app.modules.reports.permissions import ensure_admin_or_owner_in_school
from app.modules.reports.repositories import (
    AttendanceReportRepository,
    EvaluationReportRepository,
    ReportRunRepository,
    TermAverageReportRepository,
)
from app.modules.reports.schemas import (
    AttendanceReportGenerate,
    AttendanceReportGenerateRead,
    AttendanceReportPreviewRow,
    EvaluationReportGenerate,
    ReportCatalogItemRead,
    ReportRunRead,
    TermAverageReportGenerate,
)
from app.modules.schools.repositories import SchoolRepository, SchoolUserRepository


class ReportService:
    def __init__(self, db: Session):
        self.db = db
        self.school = SchoolRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.report_run = ReportRunRepository(db)
        self.attendance_report = AttendanceReportRepository(db)
        self.evaluation_report = EvaluationReportRepository(db)
        self.term_average_report = TermAverageReportRepository(db)

    # Resuelve rango de fechas efectivo para asistencia segun reglas de negocio.
    def _resolve_attendance_date_range(
        self,
        school_id: UUID,
        assignment_id: UUID,
        from_date: date | None,
        to_date: date | None,
    ) -> tuple[date | None, date | None]:
        min_date, max_date = self.attendance_report.get_assignment_attendance_date_bounds(school_id, assignment_id)
        today = date.today()

        resolved_from = from_date
        resolved_to = to_date

        if from_date and not to_date:
            resolved_to = today
        elif to_date and not from_date:
            resolved_from = min_date
        elif not from_date and not to_date:
            resolved_from = min_date
            resolved_to = max_date

        if resolved_from and resolved_to and resolved_from > resolved_to:
            raise HTTPException(status_code=400, detail="Rango de fechas invalido")

        return resolved_from, resolved_to

    # Valida que escuela exista y el usuario tenga permisos administrativos.
    def _ensure_context(self, school_id: UUID, user_id: UUID) -> None:
        school = self.school.get(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")
        ensure_admin_or_owner_in_school(self.school_user, user_id, school_id)

    # Devuelve catalogo estatico de tipos de reporte con filtros y columnas permitidas.
    def get_catalog(self, school_id: UUID, user_id: UUID) -> list[ReportCatalogItemRead]:
        self._ensure_context(school_id, user_id)
        return [ReportCatalogItemRead(**item) for item in REPORT_CATALOG]

    # Obtiene item de catalogo por tipo de reporte para validar filtros y columnas.
    def _get_catalog_item(self, report_type: ReportType):
        for item in REPORT_CATALOG:
            if item["report_type"] == report_type:
                return item
        return None

    # Valida columnas permitidas de acuerdo al tipo de reporte.
    def _validate_columns(self, report_type: ReportType, columns: list[str]) -> None:
        catalog_item = self._get_catalog_item(report_type)
        if not catalog_item:
            raise HTTPException(status_code=500, detail="Catalogo de reporte no configurado")
        invalid_columns = [col for col in columns if col not in catalog_item["allowed_columns"]]
        if invalid_columns:
            raise HTTPException(status_code=400, detail=f"Columnas no permitidas: {', '.join(invalid_columns)}")

    # Valida que el formato solicitado este habilitado para el tipo de reporte.
    def _validate_format(self, report_type: ReportType, report_format) -> None:
        catalog_item = self._get_catalog_item(report_type)
        if not catalog_item:
            raise HTTPException(status_code=500, detail="Catalogo de reporte no configurado")
        if report_format not in catalog_item["allowed_formats"]:
            raise HTTPException(status_code=400, detail="Formato no permitido para este reporte")

    # Genera bytes de archivo XLSX en memoria usando filas ya normalizadas.
    def _build_xlsx_bytes(self, columns: list[str], rows: list[dict]):
        workbook = Workbook()
        sheet = workbook.active
        sheet.title = "Reporte"

        sheet.append(columns)
        for row in rows:
            sheet.append([row.get(column) for column in columns])

        buffer = BytesIO()
        workbook.save(buffer)
        buffer.seek(0)
        return buffer.getvalue()

    # Genera bytes de archivo PDF en memoria con tabla de datos normalizados.
    def _build_pdf_bytes(self, columns: list[str], rows: list[dict], title: str, summary: str | None = None):
        buffer = BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=landscape(letter),
            leftMargin=24,
            rightMargin=24,
            topMargin=24,
            bottomMargin=24,
        )

        styles = getSampleStyleSheet()
        story = [Paragraph(title, styles["Heading2"]), Spacer(1, 8)]
        if summary:
            story.extend([Paragraph(summary, styles["BodyText"]), Spacer(1, 8)])

        table_rows = [columns]
        for row in rows:
            table_rows.append(["" if row.get(column) is None else str(row.get(column)) for column in columns])

        table = Table(table_rows, repeatRows=1)
        table.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1E3A5F")),
                    ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                    ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                    ("FONTSIZE", (0, 0), (-1, -1), 8),
                    ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#A9BDD4")),
                    ("BACKGROUND", (0, 1), (-1, -1), colors.HexColor("#F8FBFF")),
                    ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ]
            )
        )
        story.append(table)
        doc.build(story)
        buffer.seek(0)
        return buffer.getvalue()

    # Registra en historial una ejecucion de reporte con filtros y columnas.
    def _register_run(
        self,
        school_id: UUID,
        report_type: ReportType,
        filters_json: dict,
        columns_json: list[str],
        report_format,
        summary: str | None,
    ) -> None:
        run = ReportRun(
            school_id=school_id,
            report_type=report_type,
            filters_json=filters_json,
            columns_json=columns_json,
            format=report_format,
            summary=summary,
        )
        self.report_run.create(run)
        self.db.commit()

    # Genera preview de reporte de asistencia y guarda el historial de ejecucion.
    def generate_attendance_report(
        self,
        school_id: UUID,
        payload: AttendanceReportGenerate,
        user_id: UUID,
    ) -> AttendanceReportGenerateRead:
        self._ensure_context(school_id, user_id)

        if not payload.from_date or not payload.to_date:
            raise HTTPException(status_code=400, detail="Debes enviar desde y hasta para la vista previa")
        if payload.from_date > payload.to_date:
            raise HTTPException(status_code=400, detail="Rango de fechas invalido")

        self._validate_columns(ReportType.ATTENDANCE, payload.columns)
        self._validate_format(ReportType.ATTENDANCE, payload.format)

        assignment_meta = self.attendance_report.get_assignment_metadata(school_id, payload.assignment_id)
        if not assignment_meta:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")

        assignment_id, course_name, subject_name = assignment_meta
        rows = self.attendance_report.list_rows_by_assignment_and_date_range(
            school_id=school_id,
            assignment_id=payload.assignment_id,
            from_date=payload.from_date,
            to_date=payload.to_date,
            student_id=payload.student_id,
        )

        preview_rows: list[AttendanceReportPreviewRow] = []
        for attendance_date, session_name, student_last_name, student_first_name, status_name, observation in rows:
            data = {
                "attendance_date": attendance_date.isoformat(),
                "session_name": session_name,
                "course_name": course_name,
                "subject_name": subject_name,
                "student_last_name": student_last_name,
                "student_first_name": student_first_name,
                "status_name": status_name,
                "observation": observation,
            }
            filtered_data = {column: data.get(column) for column in payload.columns}
            preview_rows.append(AttendanceReportPreviewRow(**filtered_data))

        filters_json = {
            "assignment_id": str(payload.assignment_id),
            "from_date": payload.from_date.isoformat(),
            "to_date": payload.to_date.isoformat(),
            "student_id": str(payload.student_id) if payload.student_id else None,
        }
        run = ReportRun(
            school_id=school_id,
            report_type=ReportType.ATTENDANCE,
            filters_json=filters_json,
            columns_json=payload.columns,
            format=payload.format,
            summary=payload.summary,
        )
        self.report_run.create(run)
        self.db.commit()
        self.db.refresh(run)

        run_read = ReportRunRead(
            id=run.id,
            school_id=run.school_id,
            report_type=run.report_type,
            filters_json=run.filters_json,
            columns_json=run.columns_json,
            format=run.format,
            summary=run.summary,
            created_date=run.created_date,
        )
        return AttendanceReportGenerateRead(run=run_read, rows=preview_rows)

    # Exporta reporte de asistencia en XLSX/PDF y registra la ejecucion.
    def export_attendance_report_xlsx(
        self,
        school_id: UUID,
        payload: AttendanceReportGenerate,
        user_id: UUID,
    ) -> tuple[bytes, str, str]:
        self._ensure_context(school_id, user_id)
        if payload.mode not in ["general", "student_specific"]:
            raise HTTPException(status_code=400, detail="Modo de reporte de asistencia no valido")

        general_columns = [
            "student_last_name",
            "student_first_name",
            "total_sessions",
            "present_count",
            "absence_count",
            "license_count",
            "attendance_percentage",
            "absence_percentage",
        ]

        columns_to_use = general_columns if payload.mode == "general" else payload.columns
        if payload.mode == "student_specific":
            self._validate_columns(ReportType.ATTENDANCE, columns_to_use)
        self._validate_format(ReportType.ATTENDANCE, payload.format)

        assignment_meta = self.attendance_report.get_assignment_metadata(school_id, payload.assignment_id)
        if not assignment_meta:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")
        _, course_name, subject_name = assignment_meta

        resolved_from_date, resolved_to_date = self._resolve_attendance_date_range(
            school_id,
            payload.assignment_id,
            payload.from_date,
            payload.to_date,
        )

        dataset = []
        if payload.mode == "general":
            rows = self.attendance_report.list_rows_for_general_summary(
                school_id=school_id,
                assignment_id=payload.assignment_id,
                from_date=resolved_from_date,
                to_date=resolved_to_date,
            )
            bucket: dict[str, dict] = {}
            for student_id, student_last_name, student_first_name, status_name in rows:
                key = str(student_id)
                if key not in bucket:
                    bucket[key] = {
                        "student_last_name": student_last_name,
                        "student_first_name": student_first_name,
                        "present_count": 0,
                        "absence_count": 0,
                        "license_count": 0,
                        "total_sessions": 0,
                    }
                bucket[key]["total_sessions"] += 1
                normalized = (status_name or "").strip().lower()
                if normalized == "presente":
                    bucket[key]["present_count"] += 1
                elif normalized == "falta":
                    bucket[key]["absence_count"] += 1
                elif normalized == "licencia":
                    bucket[key]["license_count"] += 1

            for row in bucket.values():
                total = row["total_sessions"]
                row["attendance_percentage"] = round((row["present_count"] / total) * 100, 2) if total else 0
                row["absence_percentage"] = round((row["absence_count"] / total) * 100, 2) if total else 0
                dataset.append(row)
        else:
            if not (payload.student_last_name or payload.student_first_name or payload.student_id):
                raise HTTPException(status_code=400, detail="Para modo especifico debes indicar apellido y/o nombre")
            rows = self.attendance_report.list_rows_by_assignment_and_date_range(
                school_id=school_id,
                assignment_id=payload.assignment_id,
                from_date=resolved_from_date,
                to_date=resolved_to_date,
                student_id=payload.student_id,
                student_last_name=payload.student_last_name,
                student_first_name=payload.student_first_name,
                attendance_status_filter=payload.attendance_status_filter,
            )
            for attendance_date, session_name, student_last_name, student_first_name, status_name, observation in rows:
                dataset.append(
                    {
                        "attendance_date": attendance_date.isoformat(),
                        "session_name": session_name,
                        "course_name": course_name,
                        "subject_name": subject_name,
                        "student_last_name": student_last_name,
                        "student_first_name": student_first_name,
                        "status_name": status_name,
                        "observation": observation,
                    }
                )

        self._register_run(
            school_id=school_id,
            report_type=ReportType.ATTENDANCE,
            filters_json={
                "assignment_id": str(payload.assignment_id),
                "from_date": resolved_from_date.isoformat() if resolved_from_date else None,
                "to_date": resolved_to_date.isoformat() if resolved_to_date else None,
                "mode": payload.mode,
                "student_id": str(payload.student_id) if payload.student_id else None,
                "student_last_name": payload.student_last_name,
                "student_first_name": payload.student_first_name,
                "attendance_status_filter": payload.attendance_status_filter or "all",
            },
            columns_json=columns_to_use,
            report_format=payload.format,
            summary=payload.summary,
        )

        suffix = "general" if payload.mode == "general" else "estudiante"
        if payload.format.value == "pdf":
            file_name = f"reporte_asistencia_{suffix}_{course_name}_{subject_name}.pdf".replace(" ", "_").lower()
            return (
                self._build_pdf_bytes(columns_to_use, dataset, "Reporte de asistencias", payload.summary),
                file_name,
                "application/pdf",
            )

        file_name = f"reporte_asistencia_{suffix}_{course_name}_{subject_name}.xlsx".replace(" ", "_").lower()
        return (
            self._build_xlsx_bytes(columns_to_use, dataset),
            file_name,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        )

    # Exporta reporte de calificaciones por evaluacion en XLSX y registra la ejecucion.
    def export_evaluation_report_xlsx(
        self,
        school_id: UUID,
        payload: EvaluationReportGenerate,
        user_id: UUID,
    ) -> tuple[bytes, str, str]:
        self._ensure_context(school_id, user_id)
        self._validate_columns(ReportType.EVALUATION_GRADEBOOK, payload.columns)
        self._validate_format(ReportType.EVALUATION_GRADEBOOK, payload.format)

        if not payload.evaluation_id and not payload.assignment_id:
            raise HTTPException(status_code=400, detail="Debe enviar evaluation_id o assignment_id")

        dataset = []

        if payload.evaluation_id:
            evaluation_meta = self.evaluation_report.get_evaluation_metadata(school_id, payload.evaluation_id)
            if not evaluation_meta:
                raise HTTPException(status_code=404, detail="Evaluacion no encontrada")

            _, evaluation_name, term_id, term_name, assignment_id, course_name, subject_name = evaluation_meta
            students = self.evaluation_report.list_active_students_by_assignment(school_id, assignment_id)
            grades = self.evaluation_report.list_active_grades_by_evaluation(school_id, payload.evaluation_id)
            grades_by_student = {student_id: score for student_id, score in grades}

            for student_id, last_name, first_name in students:
                score = grades_by_student.get(student_id)
                dataset.append(
                    {
                        "student_last_name": last_name,
                        "student_first_name": first_name,
                        "score": score,
                        "status": "calificado" if score is not None else "sin_calificar",
                        "evaluation_name": evaluation_name,
                        "term_name": term_name,
                        "course_name": course_name,
                        "subject_name": subject_name,
                    }
                )

            self._register_run(
                school_id=school_id,
                report_type=ReportType.EVALUATION_GRADEBOOK,
                filters_json={
                    "assignment_id": str(assignment_id),
                    "evaluation_id": str(payload.evaluation_id),
                    "term_id": str(term_id),
                },
                columns_json=payload.columns,
                report_format=payload.format,
                summary=payload.summary,
            )

            file_name = f"reporte_evaluacion_{evaluation_name}.xlsx".replace(" ", "_").lower()
            if payload.format.value == "pdf":
                file_name = f"reporte_evaluacion_{evaluation_name}.pdf".replace(" ", "_").lower()
                return (
                    self._build_pdf_bytes(payload.columns, dataset, "Reporte de evaluacion", payload.summary),
                    file_name,
                    "application/pdf",
                )

            file_name = f"reporte_evaluacion_{evaluation_name}.xlsx".replace(" ", "_").lower()
            return (
                self._build_xlsx_bytes(payload.columns, dataset),
                file_name,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            )

        assignment_meta = self.evaluation_report.get_assignment_metadata(school_id, payload.assignment_id)
        if not assignment_meta:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")

        assignment_id, course_name, subject_name = assignment_meta
        students = self.evaluation_report.list_active_students_by_assignment(school_id, assignment_id)
        evaluations = self.evaluation_report.list_active_evaluations_by_assignment(school_id, assignment_id)
        if not evaluations:
            raise HTTPException(status_code=404, detail="No hay evaluaciones activas para esta asignacion")

        for evaluation_id, evaluation_name, term_id, term_name in evaluations:
            grades = self.evaluation_report.list_active_grades_by_evaluation(school_id, evaluation_id)
            grades_by_student = {student_id: score for student_id, score in grades}

            for student_id, last_name, first_name in students:
                score = grades_by_student.get(student_id)
                dataset.append(
                    {
                        "student_last_name": last_name,
                        "student_first_name": first_name,
                        "score": score,
                        "status": "calificado" if score is not None else "sin_calificar",
                        "evaluation_name": evaluation_name,
                        "term_name": term_name,
                        "course_name": course_name,
                        "subject_name": subject_name,
                    }
                )

        self._register_run(
            school_id=school_id,
            report_type=ReportType.EVALUATION_GRADEBOOK,
            filters_json={
                "assignment_id": str(assignment_id),
                "evaluation_id": None,
                "evaluation_count": len(evaluations),
            },
            columns_json=payload.columns,
            report_format=payload.format,
            summary=payload.summary,
        )

        if payload.format.value == "pdf":
            file_name = f"reporte_evaluaciones_{course_name}_{subject_name}.pdf".replace(" ", "_").lower()
            return (
                self._build_pdf_bytes(payload.columns, dataset, "Reporte de evaluaciones", payload.summary),
                file_name,
                "application/pdf",
            )

        file_name = f"reporte_evaluaciones_{course_name}_{subject_name}.xlsx".replace(" ", "_").lower()
        return (
            self._build_xlsx_bytes(payload.columns, dataset),
            file_name,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        )

    # Exporta reporte de promedios trimestrales en XLSX y registra la ejecucion.
    def export_term_average_report_xlsx(
        self,
        school_id: UUID,
        payload: TermAverageReportGenerate,
        user_id: UUID,
    ) -> tuple[bytes, str]:
        self._ensure_context(school_id, user_id)
        self._validate_columns(ReportType.TERM_AVERAGE, payload.columns)
        self._validate_format(ReportType.TERM_AVERAGE, payload.format)

        assignment_meta = self.term_average_report.get_assignment_metadata(school_id, payload.assignment_id)
        if not assignment_meta:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")
        _, course_name, subject_name = assignment_meta

        term_name = self.term_average_report.get_term_name(school_id, payload.term_id)
        if not term_name:
            raise HTTPException(status_code=404, detail="Trimestre no encontrado")

        students = self.term_average_report.list_active_students_by_assignment(school_id, payload.assignment_id)
        averages = self.term_average_report.list_active_averages_by_assignment_and_term(
            school_id,
            payload.assignment_id,
            payload.term_id,
        )
        averages_by_student = {
            student_id: {
                "saber_score": saber_score,
                "hacer_score": hacer_score,
                "ser_score": ser_score,
                "autoevaluacion_score": autoevaluacion_score,
                "final_score": final_score,
            }
            for student_id, saber_score, hacer_score, ser_score, autoevaluacion_score, final_score in averages
        }

        dataset = []
        for student_id, last_name, first_name in students:
            item = averages_by_student.get(student_id)
            dataset.append(
                {
                    "student_last_name": last_name,
                    "student_first_name": first_name,
                    "saber_score": item["saber_score"] if item else None,
                    "hacer_score": item["hacer_score"] if item else None,
                    "ser_score": item["ser_score"] if item else None,
                    "autoevaluacion_score": item["autoevaluacion_score"] if item else None,
                    "final_score": item["final_score"] if item else None,
                    "status": "calculado" if item else "sin_calcular",
                    "term_name": term_name,
                    "course_name": course_name,
                    "subject_name": subject_name,
                }
            )

        self._register_run(
            school_id=school_id,
            report_type=ReportType.TERM_AVERAGE,
            filters_json={
                "assignment_id": str(payload.assignment_id),
                "term_id": str(payload.term_id),
            },
            columns_json=payload.columns,
            report_format=payload.format,
            summary=payload.summary,
        )

        file_name = f"reporte_promedios_{course_name}_{subject_name}_{term_name}.xlsx".replace(" ", "_").lower()
        return self._build_xlsx_bytes(payload.columns, dataset), file_name

    # Lista historial de ejecuciones de reportes guardadas para una escuela.
    def list_runs(self, school_id: UUID, user_id: UUID, report_type: ReportType | None = None) -> list[ReportRunRead]:
        self._ensure_context(school_id, user_id)
        rows = self.report_run.list_active_by_school_id(school_id, report_type)
        return [
            ReportRunRead(
                id=row.id,
                school_id=row.school_id,
                report_type=row.report_type,
                filters_json=row.filters_json,
                columns_json=row.columns_json,
                format=row.format,
                summary=row.summary,
                created_date=row.created_date,
            )
            for row in rows
        ]

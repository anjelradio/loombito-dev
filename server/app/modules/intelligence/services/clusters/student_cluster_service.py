from collections import defaultdict
from datetime import datetime
from statistics import mean
from uuid import UUID

import numpy as np
from fastapi import HTTPException
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from sklearn.preprocessing import StandardScaler
from sqlmodel import Session

from app.modules.intelligence.models import StudentClusterResult, StudentClusterRun
from app.modules.intelligence.permissions import ensure_admin_or_teacher_in_school
from app.modules.intelligence.repositories import StudentClusterRepository
from app.modules.intelligence.schemas import (
    StudentClusterRecalculateSummaryRead,
    StudentClusterRowRead,
    StudentClusterSnapshotRead,
)
from app.modules.schools.repositories import SchoolUserRepository


class StudentClusterService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = StudentClusterRepository(db)
        self.school_user = SchoolUserRepository(db)

    def _ensure_context_and_access(self, school_id: UUID, assignment_id: UUID, term_id: UUID, user_id: UUID):
        school = self.repo.get_school(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        ensure_admin_or_teacher_in_school(self.school_user, user_id, school_id)

        assignment = self.repo.get_active_assignment_in_school(school_id, assignment_id)
        if not assignment:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")

        term = self.repo.get_active_term_in_school(school_id, term_id)
        if not term:
            raise HTTPException(status_code=400, detail="Trimestre no valido")

    def _build_student_feature_rows(self, school_id: UUID, assignment_id: UUID, term_id: UUID):
        final_scores_rows = self.repo.list_final_scores(school_id, assignment_id, term_id)
        final_scores_by_student = {student_id: float(final_score) for student_id, final_score in final_scores_rows}

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

        attendance_values_by_student = defaultdict(list)
        for student_id, status_id in attendance_records:
            value = attendance_map.get(status_id)
            if value is None:
                continue
            attendance_values_by_student[student_id].append(value)

        student_rows = []
        for student_id, final_score in final_scores_by_student.items():
            attendance_values = attendance_values_by_student.get(student_id)
            if not attendance_values:
                continue
            student_rows.append(
                {
                    "student_id": student_id,
                    "final_score": float(round(final_score, 2)),
                    "attendance_rate": float(round(mean(attendance_values), 2)),
                }
            )

        return student_rows

    def _build_labels_by_cluster(self, kmeans: KMeans, scaler: StandardScaler, k_value: int) -> dict[int, str]:
        centroids_scaled = kmeans.cluster_centers_
        centroids_original = scaler.inverse_transform(centroids_scaled)
        ranked = sorted(
            [(idx, centroid[0]) for idx, centroid in enumerate(centroids_original)],
            key=lambda item: item[1],
            reverse=True,
        )

        if k_value == 2:
            return {
                ranked[0][0]: "alto_rendimiento",
                ranked[1][0]: "en_riesgo",
            }

        labels_by_cluster: dict[int, str] = {}
        labels_by_cluster[ranked[0][0]] = "alto_rendimiento"
        labels_by_cluster[ranked[-1][0]] = "en_riesgo"
        for cluster_id, _ in ranked[1:-1]:
            labels_by_cluster[cluster_id] = "rendimiento_medio"
        return labels_by_cluster

    def _choose_best_k(self, x_scaled: np.ndarray) -> tuple[int, KMeans, float | None]:
        n_samples = x_scaled.shape[0]
        if n_samples < 2:
            raise HTTPException(status_code=400, detail="No hay suficientes estudiantes para clustering")

        max_k = min(4, n_samples)
        if max_k < 2:
            raise HTTPException(status_code=400, detail="No hay suficientes estudiantes para clustering")

        best_model = None
        best_k = 2
        best_silhouette = None

        for k in range(2, max_k + 1):
            model = KMeans(n_clusters=k, init="k-means++", random_state=42, n_init="auto")
            labels = model.fit_predict(x_scaled)

            silhouette = None
            unique_labels = np.unique(labels)
            if len(unique_labels) > 1 and n_samples > k:
                silhouette = float(silhouette_score(x_scaled, labels))

            if best_model is None:
                best_model = model
                best_k = k
                best_silhouette = silhouette
                continue

            current_score = silhouette if silhouette is not None else -1.0
            best_score = best_silhouette if best_silhouette is not None else -1.0
            if current_score > best_score:
                best_model = model
                best_k = k
                best_silhouette = silhouette

        if best_model is None:
            raise HTTPException(status_code=400, detail="No se pudo entrenar el modelo de clustering")
        return best_k, best_model, best_silhouette

    def recalculate(
        self,
        school_id: UUID,
        assignment_id: UUID,
        term_id: UUID,
        user_id: UUID,
    ) -> StudentClusterRecalculateSummaryRead:
        self._ensure_context_and_access(school_id, assignment_id, term_id, user_id)

        rows = self._build_student_feature_rows(school_id, assignment_id, term_id)
        if len(rows) < 2:
            raise HTTPException(
                status_code=400,
                detail="Se necesitan al menos 2 estudiantes con promedio y asistencia para clasificar",
            )

        x = np.array([[row["final_score"], row["attendance_rate"]] for row in rows], dtype=float)
        scaler = StandardScaler()
        x_scaled = scaler.fit_transform(x)

        k_value, kmeans, best_silhouette = self._choose_best_k(x_scaled)
        predicted_clusters = kmeans.predict(x_scaled)
        labels_by_cluster = self._build_labels_by_cluster(kmeans, scaler, k_value)

        self.repo.deactivate_active_runs(school_id, assignment_id, term_id)
        run = StudentClusterRun(
            school_id=school_id,
            assignment_id=assignment_id,
            term_id=term_id,
            trained_by_user_id=user_id,
            status="completed",
            features_version="v1_2d_final_attendance",
            is_active=True,
            k_value=k_value,
            inertia=float(kmeans.inertia_),
            silhouette_score=best_silhouette,
            trained_at=datetime.utcnow(),
        )
        self.repo.create_run(run)
        self.db.flush()

        for idx, row in enumerate(rows):
            cluster_id = int(predicted_clusters[idx])
            self.repo.create_result(
                StudentClusterResult(
                    run_id=run.id,
                    student_id=row["student_id"],
                    school_id=school_id,
                    cluster_id=cluster_id,
                    cluster_label=labels_by_cluster.get(cluster_id, "rendimiento_medio"),
                    final_score=row["final_score"],
                    attendance_rate=row["attendance_rate"],
                )
            )

        self.db.commit()

        return StudentClusterRecalculateSummaryRead(
            assignment_id=assignment_id,
            term_id=term_id,
            school_id=school_id,
            run_id=run.id,
            processed_students=len(rows),
            k_value=k_value,
            inertia=float(kmeans.inertia_),
            silhouette_score=best_silhouette,
            trained_at=run.trained_at,
        )

    def get_snapshot(
        self,
        school_id: UUID,
        assignment_id: UUID,
        term_id: UUID,
        user_id: UUID,
    ) -> StudentClusterSnapshotRead:
        self._ensure_context_and_access(school_id, assignment_id, term_id, user_id)

        run = self.repo.get_active_run(school_id, assignment_id, term_id)
        if not run:
            return StudentClusterSnapshotRead(
                assignment_id=assignment_id,
                term_id=term_id,
                school_id=school_id,
                features_version=None,
                k_value=None,
                inertia=None,
                silhouette_score=None,
                trained_at=None,
                students=[],
            )

        results = self.repo.list_active_results_by_run(run.id)
        students = self.repo.list_students_by_ids_in_school(
            school_id,
            [result.student_id for result in results],
        )
        student_map = {student.id: student for student in students}

        rows: list[StudentClusterRowRead] = []
        for result in results:
            student = student_map.get(result.student_id)
            if not student:
                continue
            rows.append(
                StudentClusterRowRead(
                    student_id=student.id,
                    first_name=student.first_name,
                    last_name=student.last_name,
                    cluster_id=result.cluster_id,
                    cluster_label=result.cluster_label,
                    final_score=round(float(result.final_score), 2),
                    attendance_rate=round(float(result.attendance_rate), 2),
                )
            )

        rows.sort(key=lambda item: (item.cluster_id, item.last_name, item.first_name))

        return StudentClusterSnapshotRead(
            assignment_id=assignment_id,
            term_id=term_id,
            school_id=school_id,
            features_version=run.features_version,
            k_value=run.k_value,
            inertia=round(float(run.inertia), 4),
            silhouette_score=round(float(run.silhouette_score), 4) if run.silhouette_score is not None else None,
            trained_at=run.trained_at,
            students=rows,
        )

import os
import joblib
from uuid import UUID
import numpy as np
from fastapi import HTTPException
from sqlmodel import Session

from app.modules.intelligence.models.regressions.student_risk_prediction import StudentRiskPrediction
from app.modules.intelligence.repositories import StudentClusterRepository
from app.modules.intelligence.repositories.student_risk_repository import StudentRiskRepository
from app.modules.schools.repositories import SchoolUserRepository
from app.modules.intelligence.permissions import ensure_admin_or_teacher_in_school

ARTIFACTS_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "models", "artifacts")

class StudentRiskService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = StudentRiskRepository(db)
        self.cluster_repo = StudentClusterRepository(db) # Reuse for building student features
        self.school_user = SchoolUserRepository(db)
        
        # Load pre-trained models
        self.scaler = joblib.load(os.path.join(ARTIFACTS_DIR, "base_scaler.pkl"))
        self.lin_reg = joblib.load(os.path.join(ARTIFACTS_DIR, "base_linear_model.pkl"))
        self.log_reg = joblib.load(os.path.join(ARTIFACTS_DIR, "base_logistic_model.pkl"))

    def _ensure_context_and_access(self, school_id: UUID, assignment_id: UUID, term_id: UUID, user_id: UUID | None = None):
        school = self.cluster_repo.get_school(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")

        if user_id:
            ensure_admin_or_teacher_in_school(self.school_user, user_id, school_id)

        assignment = self.cluster_repo.get_active_assignment_in_school(school_id, assignment_id)
        if not assignment:
            raise HTTPException(status_code=404, detail="Asignacion no encontrada")

        term = self.cluster_repo.get_active_term_in_school(school_id, term_id)
        if not term:
            raise HTTPException(status_code=400, detail="Trimestre no valido")

    def recalculate_risk_predictions(self, school_id: UUID, assignment_id: UUID, term_id: UUID, user_id: UUID | None = None) -> int:
        self._ensure_context_and_access(school_id, assignment_id, term_id, user_id)

        # 1. Build features (same logic as clustering: final_score and attendance_rate)
        # Note: The cluster repo already has logic to get these values for all students
        from app.modules.intelligence.services.clusters.student_cluster_service import StudentClusterService
        cluster_service = StudentClusterService(self.db)
        rows = cluster_service._build_student_feature_rows(school_id, assignment_id, term_id)
        
        if not rows:
            return 0

        self.repo.deactivate_active_predictions(school_id, assignment_id, term_id)

        # 2. Predict and save
        processed = 0
        for row in rows:
            student_id = row["student_id"]
            attendance = row["attendance_rate"]
            partial_score = row["final_score"] # Using current final_score as partial_score for the projection
            
            # Prepare feature array: [attendance_rate, partial_score]
            X = np.array([[attendance, partial_score]])
            X_scaled = self.scaler.transform(X)

            # Predict Linear Regression (Projected Final Score)
            proj_score = float(self.lin_reg.predict(X_scaled)[0])
            proj_score = max(0.0, min(100.0, proj_score))

            # Predict Logistic Regression (Failure Probability)
            # log_reg predicts "passed" (1). The probability of failure is proba for class 0.
            proba_fail = float(self.log_reg.predict_proba(X_scaled)[0][0])

            # Save
            prediction = StudentRiskPrediction(
                school_id=school_id,
                assignment_id=assignment_id,
                term_id=term_id,
                student_id=student_id,
                projected_final_score=round(proj_score, 2),
                failure_probability=round(proba_fail, 4),
                is_active=True
            )
            self.repo.create_prediction(prediction)
            processed += 1

        self.db.commit()
        return processed

    def recalculate_all_global(self) -> dict:
        from app.modules.academic.models.assignments import Assignment
        from app.modules.academic.models.terms import Term
        from sqlmodel import select
        import datetime

        assignments = self.db.exec(select(Assignment).where(Assignment.state == True)).all()
        terms = self.db.exec(select(Term).where(Term.state == True)).all()

        today = datetime.date.today()
        active_terms = [t for t in terms if t.start_date <= today <= t.end_date]

        total_processed = 0
        total_assignments = 0

        for term in active_terms:
            school_assignments = [a for a in assignments if a.school_id == term.school_id]
            for assignment in school_assignments:
                try:
                    processed = self.recalculate_risk_predictions(
                        school_id=term.school_id,
                        assignment_id=assignment.id,
                        term_id=term.id,
                        user_id=None
                    )
                    if processed > 0:
                        total_processed += processed
                        total_assignments += 1
                except Exception:
                    continue

        return {"processed_students": total_processed, "processed_assignments": total_assignments}

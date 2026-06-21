from uuid import UUID
from sqlmodel import Session, select, and_

from app.modules.intelligence.models.regressions.student_risk_prediction import StudentRiskPrediction

class StudentRiskRepository:
    def __init__(self, db: Session):
        self.db = db

    def deactivate_active_predictions(self, school_id: UUID, assignment_id: UUID, term_id: UUID):
        stmt = select(StudentRiskPrediction).where(
            and_(
                StudentRiskPrediction.school_id == school_id,
                StudentRiskPrediction.assignment_id == assignment_id,
                StudentRiskPrediction.term_id == term_id,
                StudentRiskPrediction.is_active == True,
            )
        )
        predictions = self.db.exec(stmt).all()
        for p in predictions:
            p.is_active = False
        self.db.add_all(predictions)

    def create_prediction(self, prediction: StudentRiskPrediction) -> StudentRiskPrediction:
        self.db.add(prediction)
        return prediction

    def get_active_prediction_by_student(self, school_id: UUID, assignment_id: UUID, term_id: UUID, student_id: UUID) -> StudentRiskPrediction | None:
        query = select(StudentRiskPrediction).where(
            StudentRiskPrediction.school_id == school_id,
            StudentRiskPrediction.assignment_id == assignment_id,
            StudentRiskPrediction.term_id == term_id,
            StudentRiskPrediction.student_id == student_id,
            StudentRiskPrediction.is_active == True,
            StudentRiskPrediction.state == True,
        )
        return self.db.exec(query).first()

    def get_all_active_predictions_for_student(self, school_id: UUID, student_id: UUID) -> list[StudentRiskPrediction]:
        query = select(StudentRiskPrediction).where(
            StudentRiskPrediction.school_id == school_id,
            StudentRiskPrediction.student_id == student_id,
            StudentRiskPrediction.is_active == True,
            StudentRiskPrediction.state == True,
        )
        return self.db.exec(query).all()

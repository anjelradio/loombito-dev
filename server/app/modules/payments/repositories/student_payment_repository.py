from uuid import UUID
from sqlmodel import Session
from app.modules.payments.models.student_payment import StudentPayment

class StudentPaymentRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, payment: StudentPayment) -> StudentPayment:
        self.db.add(payment)
        return payment

    def list_by_student(self, student_id: UUID) -> list[tuple[StudentPayment, str]]:
        from app.modules.payments.models.student_debt import StudentDebt
        from app.modules.payments.models.payment_concept import PaymentConcept
        from sqlmodel import select
        
        query = select(StudentPayment, PaymentConcept.name).join(
            StudentDebt, StudentDebt.id == StudentPayment.student_debt_id
        ).join(
            PaymentConcept, PaymentConcept.id == StudentDebt.concept_id
        ).where(
            StudentDebt.student_id == student_id,
            StudentPayment.state == True
        ).order_by(StudentPayment.payment_date.desc())
        
        return self.db.exec(query).all()

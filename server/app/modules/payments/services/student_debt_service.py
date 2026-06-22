from uuid import UUID

from fastapi import HTTPException
from sqlmodel import Session

from app.modules.payments.permissions import ensure_admin_or_owner
from app.modules.payments.repositories.student_debt_repository import StudentDebtRepository
from app.modules.payments.schemas.student_debt_schema import StudentDebtRead
from app.modules.schools.repositories import SchoolUserRepository
from app.modules.students.repositories.student_repository import StudentRepository


class StudentDebtService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = StudentDebtRepository(db)
        self.school_user_repo = SchoolUserRepository(db)
        self.student_repo = StudentRepository(db)

    # Verifica que el usuario sea padre del estudiante o administrador del colegio
    def _ensure_can_manage(self, school_id: UUID, user_id: UUID, student_id: UUID) -> None:
        from app.modules.students.repositories.student_parent_repository import StudentParentRepository
        parent_repo = StudentParentRepository(self.db)
        if parent_repo.get_active_by_user_and_student(user_id, student_id):
            return  # Parent is allowed
        ensure_admin_or_owner(self.school_user_repo, user_id, school_id)

    # Lista las deudas de un estudiante con el nombre del concepto
    def list_student_debts(
        self, school_id: UUID, student_id: UUID, user_id: UUID, status: str | None = None
    ) -> list[StudentDebtRead]:
        self._ensure_can_manage(school_id, user_id, student_id)
        
        # Verify student belongs to school
        student = self.student_repo.get_active_by_id_in_school(school_id, student_id)
        if not student:
            raise HTTPException(status_code=404, detail="Estudiante no encontrado en este colegio")
            
        debts_with_concept = self.repo.list_by_student(student_id, status)
        
        return [
            StudentDebtRead(
                id=debt.id,
                student_id=debt.student_id,
                concept_id=debt.concept_id,
                concept_name=concept_name,
                amount=debt.amount,
                status=debt.status,
                due_date=debt.due_date,
                billing_month=debt.billing_month,
                billing_year=debt.billing_year,
                state=debt.state,
            )
            for debt, concept_name in debts_with_concept
        ]

    # Procesa el pago de una deuda y registra la transacción
    def pay_debt(self, school_id: UUID, student_id: UUID, debt_id: UUID, user_id: UUID) -> StudentDebtRead:
        self._ensure_can_manage(school_id, user_id, student_id)
        
        debt = self.repo.get(debt_id)
        if not debt or debt.student_id != student_id:
            raise HTTPException(status_code=404, detail="Deuda no encontrada")
            
        if debt.status == "PAID":
            raise HTTPException(status_code=400, detail="Esta deuda ya está pagada")
            
        # Update debt status
        debt.status = "PAID"
        self.db.add(debt)
        
        # Register payment
        from app.modules.payments.models.student_payment import StudentPayment
        from app.modules.payments.repositories.student_payment_repository import StudentPaymentRepository
        payment_repo = StudentPaymentRepository(self.db)
        
        payment = StudentPayment(
            student_debt_id=debt.id,
            amount_paid=debt.amount,
        )
        payment_repo.create(payment)
        self.db.commit()
        self.db.refresh(debt)
        
        return self.list_student_debts(school_id, student_id, user_id)[0] # Just a simple return, though it might be better to return a basic object. We return success.

    # Lista los pagos realizados por un estudiante
    def list_student_payments(
        self, school_id: UUID, student_id: UUID, user_id: UUID
    ):
        self._ensure_can_manage(school_id, user_id, student_id)
        
        # Verify student belongs to school
        student = self.student_repo.get_active_by_id_in_school(school_id, student_id)
        if not student:
            from fastapi import HTTPException
            raise HTTPException(status_code=404, detail="Estudiante no encontrado en este colegio")
            
        from app.modules.payments.repositories.student_payment_repository import StudentPaymentRepository
        from app.modules.payments.schemas.student_payment_schema import StudentPaymentRead
        payment_repo = StudentPaymentRepository(self.db)
        
        payments_with_concept = payment_repo.list_by_student(student_id)
        
        return [
            StudentPaymentRead(
                id=payment.id,
                student_debt_id=payment.student_debt_id,
                concept_name=concept_name,
                amount_paid=payment.amount_paid,
                transaction_id=payment.transaction_id,
                payment_date=payment.payment_date,
            )
            for payment, concept_name in payments_with_concept
        ]

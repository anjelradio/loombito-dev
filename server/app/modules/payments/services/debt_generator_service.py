import logging
from datetime import datetime
from uuid import UUID

from sqlmodel import Session

from app.modules.payments.models.payment_concept import PaymentConcept
from app.modules.payments.models.student_debt import StudentDebt
from app.modules.payments.repositories.payment_concept_repository import PaymentConceptRepository
from app.modules.payments.repositories.student_debt_repository import StudentDebtRepository
from app.modules.students.repositories.student_repository import StudentRepository


logger = logging.getLogger(__name__)


class DebtGeneratorService:
    def __init__(self, db: Session):
        self.db = db
        self.concept_repo = PaymentConceptRepository(db)
        self.debt_repo = StudentDebtRepository(db)
        self.student_repo = StudentRepository(db)

    # Genera deudas para todos los estudiantes activos de un concepto específico
    def generate_debts_for_concept(
        self,
        school_id: UUID,
        concept_id: UUID,
        billing_month: int | None = None,
        billing_year: int | None = None,
    ) -> int:
        """
        Generates debts for all active students in a school for a specific payment concept.
        Returns the number of debts created.
        """
        concept = self.concept_repo.get(school_id, concept_id)
        if not concept or not concept.state:
            logger.warning(f"Concept {concept_id} not found or inactive.")
            return 0

        now = datetime.now()
        month = billing_month or now.month
        year = billing_year or now.year

        students = self.student_repo.list_active_by_school(school_id)
        if not students:
            return 0

        debts_to_create = []
        for student in students:
            # Check idempotency
            existing_debt = self.debt_repo.get_by_unique_fields(
                student_id=student.id,
                concept_id=concept.id,
                billing_month=month,
                billing_year=year,
            )
            if not existing_debt:
                new_debt = StudentDebt(
                    student_id=student.id,
                    concept_id=concept.id,
                    amount=concept.amount,
                    status="PENDING",
                    billing_month=month,
                    billing_year=year,
                    due_date=now.date(), # Set due date as today or configure differently
                    state=True,
                )
                debts_to_create.append(new_debt)

        if debts_to_create:
            self.debt_repo.bulk_create(debts_to_create)
            logger.info(f"Created {len(debts_to_create)} debts for concept {concept.name}.")
        
        return len(debts_to_create)

    # Genera deudas para todos los conceptos recurrentes activos (cron)
    def generate_all_recurring_debts(self) -> dict:
        """
        Triggered by a cron job. Generates debts for ALL recurring concepts across ALL schools.
        """
        now = datetime.now()
        month = now.month
        year = now.year

        all_concepts = self.concept_repo.get_all_recurring_active()
        
        results = {"concepts_processed": len(all_concepts), "debts_created": 0}
        
        for concept in all_concepts:
            created_count = self.generate_debts_for_concept(
                school_id=concept.school_id,
                concept_id=concept.id,
                billing_month=month,
                billing_year=year,
            )
            results["debts_created"] += created_count

        return results

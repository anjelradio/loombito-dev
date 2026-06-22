from uuid import UUID

from sqlmodel import Session, select, update

from app.modules.payments.models.student_debt import StudentDebt


class StudentDebtRepository:
    def __init__(self, db: Session):
        self.db = db

    # Crea un nuevo registro de deuda
    def create(self, debt: StudentDebt) -> StudentDebt:
        self.db.add(debt)
        return debt

    # Obtiene una deuda activa por su ID
    def get(self, id: UUID) -> StudentDebt | None:
        query = select(StudentDebt).where(StudentDebt.id == id, StudentDebt.state == True)
        return self.db.exec(query).first()

    # Crea varios registros de deuda en lote
    def bulk_create(self, debts: list[StudentDebt]) -> None:
        self.db.add_all(debts)
        self.db.commit()

    # Busca una deuda por estudiante, concepto, mes y año
    def get_by_unique_fields(
        self,
        student_id: UUID,
        concept_id: UUID,
        billing_month: int,
        billing_year: int,
    ) -> StudentDebt | None:
        query = select(StudentDebt).where(
            StudentDebt.student_id == student_id,
            StudentDebt.concept_id == concept_id,
            StudentDebt.billing_month == billing_month,
            StudentDebt.billing_year == billing_year,
            StudentDebt.state
        )
        return self.db.exec(query).first()

    # Desactiva deudas pendientes de un concepto (borrado lógico)
    def deactivate_pending_by_concept(self, concept_id: UUID) -> None:
        statement = (
            update(StudentDebt)
            .where(
                StudentDebt.concept_id == concept_id,
                StudentDebt.status == "PENDING",
                StudentDebt.state
            )
            .values(state=False)
        )
        self.db.exec(statement)
        self.db.commit()

    # Lista las deudas de un estudiante, opcionalmente filtradas por estado
    def list_by_student(self, student_id: UUID, status: str | None = None) -> list[tuple[StudentDebt, str]]:
        from app.modules.payments.models.payment_concept import PaymentConcept
        query = select(StudentDebt, PaymentConcept.name).join(
            PaymentConcept, PaymentConcept.id == StudentDebt.concept_id
        ).where(
            StudentDebt.student_id == student_id,
            StudentDebt.state
        )
        if status:
            query = query.where(StudentDebt.status == status)
        
        query = query.order_by(StudentDebt.created_date.desc())
        return self.db.exec(query).all()

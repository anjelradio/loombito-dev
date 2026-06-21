from uuid import UUID

from sqlmodel import Session, select

from app.modules.payments.models import PaymentConcept
from app.modules.payments.schemas.payment_concept_schema import PaymentConceptCreate, PaymentConceptUpdate


class PaymentConceptRepository:
    def __init__(self, db: Session):
        self.db = db

    def get(self, school_id: UUID, concept_id: UUID) -> PaymentConcept | None:
        query = select(PaymentConcept).where(
            PaymentConcept.id == concept_id,
            PaymentConcept.school_id == school_id,
            PaymentConcept.state == True
        )
        return self.db.exec(query).first()

    def get_all_recurring_active(self) -> list[PaymentConcept]:
        query = select(PaymentConcept).where(
            PaymentConcept.is_recurring == True,
            PaymentConcept.state == True,
        )
        return list(self.db.exec(query).all())

    def get_by_name(self, school_id: UUID, name: str) -> PaymentConcept | None:
        query = select(PaymentConcept).where(
            PaymentConcept.name == name,
            PaymentConcept.school_id == school_id,
            PaymentConcept.state == True
        )
        return self.db.exec(query).first()

    def list_by_school(self, school_id: UUID) -> list[PaymentConcept]:
        query = select(PaymentConcept).where(
            PaymentConcept.school_id == school_id,
            PaymentConcept.state == True
        ).order_by(PaymentConcept.created_date.desc())
        return list(self.db.exec(query).all())

    def create(self, school_id: UUID, payload: PaymentConceptCreate) -> PaymentConcept:
        concept = PaymentConcept(**payload.model_dump(), school_id=school_id)
        self.db.add(concept)
        self.db.commit()
        self.db.refresh(concept)
        return concept

    def update(self, concept: PaymentConcept, payload: PaymentConceptUpdate) -> PaymentConcept:
        update_data = payload.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(concept, key, value)
        self.db.add(concept)
        self.db.commit()
        self.db.refresh(concept)
        return concept

    def delete(self, concept: PaymentConcept) -> None:
        concept.state = False
        self.db.add(concept)
        self.db.commit()

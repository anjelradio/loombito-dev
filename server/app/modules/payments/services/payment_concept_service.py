from uuid import UUID

from fastapi import HTTPException
from sqlmodel import Session

from app.modules.payments.models import PaymentConcept
from app.modules.payments.permissions import ensure_admin_or_owner
from app.modules.payments.repositories.payment_concept_repository import PaymentConceptRepository
from app.modules.payments.schemas.payment_concept_schema import PaymentConceptCreate, PaymentConceptUpdate
from app.modules.schools.repositories import SchoolUserRepository


class PaymentConceptService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = PaymentConceptRepository(db)
        self.school_user_repo = SchoolUserRepository(db)

    # Verifica que el usuario sea administrador del colegio
    def _ensure_can_manage(self, school_id: UUID, user_id: UUID) -> None:
        ensure_admin_or_owner(self.school_user_repo, user_id, school_id)

    # Lista los conceptos de pago de un colegio
    def list_concepts(self, school_id: UUID, user_id: UUID) -> list[PaymentConcept]:
        self._ensure_can_manage(school_id, user_id)
        return self.repo.list_by_school(school_id)

    # Obtiene un concepto de pago por ID
    def get_concept(self, school_id: UUID, concept_id: UUID, user_id: UUID) -> PaymentConcept:
        self._ensure_can_manage(school_id, user_id)
        concept = self.repo.get(school_id, concept_id)
        if not concept:
            raise HTTPException(status_code=404, detail="Concepto de pago no encontrado")
        return concept

    # Crea un nuevo concepto de pago validando nombre único
    def create_concept(self, school_id: UUID, user_id: UUID, payload: PaymentConceptCreate) -> PaymentConcept:
        self._ensure_can_manage(school_id, user_id)
        existing = self.repo.get_by_name(school_id, payload.name)
        if existing:
            raise HTTPException(status_code=400, detail="Ya existe un concepto de pago con este nombre")
        return self.repo.create(school_id, payload)

    # Actualiza un concepto de pago existente
    def update_concept(self, school_id: UUID, concept_id: UUID, user_id: UUID, payload: PaymentConceptUpdate) -> PaymentConcept:
        concept = self.get_concept(school_id, concept_id, user_id)
        if payload.name and payload.name != concept.name:
            existing = self.repo.get_by_name(school_id, payload.name)
            if existing:
                raise HTTPException(status_code=400, detail="Ya existe un concepto de pago con este nombre")
        return self.repo.update(concept, payload)

    # Desactiva un concepto de pago (borrado lógico)
    def delete_concept(self, school_id: UUID, concept_id: UUID, user_id: UUID) -> None:
        concept = self.get_concept(school_id, concept_id, user_id)
        self.repo.delete(concept)

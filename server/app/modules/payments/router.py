from uuid import UUID

from fastapi import APIRouter, BackgroundTasks, HTTPException, Header, status
from sqlmodel import Session

from app.core.config import settings
from app.core.db import engine
from app.dependencies.auth import CurrentActor, DBSession
from app.modules.payments.schemas.payment_concept_schema import (
    PaymentConceptCreate,
    PaymentConceptRead,
    PaymentConceptUpdate,
)
from app.modules.payments.services.payment_concept_service import PaymentConceptService
from app.modules.payments.services.debt_generator_service import DebtGeneratorService

router = APIRouter(prefix="/payments", tags=["Pagos"])

import logging

logger = logging.getLogger(__name__)

def background_generate_debts_for_concept(school_id: UUID, concept_id: UUID):
    try:
        logger.info(f"Starting background debt generation for concept {concept_id} in school {school_id}")
        with Session(engine) as db:
            service = DebtGeneratorService(db)
            count = service.generate_debts_for_concept(school_id, concept_id)
            logger.info(f"Successfully generated {count} debts for concept {concept_id}")
    except Exception as e:
        logger.error(f"Error generating debts in background for concept {concept_id}: {str(e)}", exc_info=True)

def background_delete_debts_for_concept(concept_id: UUID):
    try:
        logger.info(f"Starting background debt deletion for concept {concept_id}")
        with Session(engine) as db:
            service = DebtGeneratorService(db)
            service.debt_repo.deactivate_pending_by_concept(concept_id)
            logger.info(f"Successfully deactivated pending debts for concept {concept_id}")
    except Exception as e:
        logger.error(f"Error deleting debts in background for concept {concept_id}: {str(e)}", exc_info=True)



@router.get(
    "/schools/{school_id}/concepts",
    response_model=list[PaymentConceptRead],
)
def list_payment_concepts(school_id: UUID, db: DBSession, actor: CurrentActor):
    return PaymentConceptService(db).list_concepts(school_id, actor.user.id)

@router.post(
    "/schools/{school_id}/concepts",
    response_model=PaymentConceptRead,
    status_code=status.HTTP_201_CREATED,
)
def create_payment_concept(school_id: UUID, payload: PaymentConceptCreate, db: DBSession, actor: CurrentActor, background_tasks: BackgroundTasks):
    concept = PaymentConceptService(db).create_concept(school_id, actor.user.id, payload)
    
    # If not recurring, generate debts for all students immediately in background
    if not concept.is_recurring:
        background_tasks.add_task(background_generate_debts_for_concept, school_id, concept.id)
        
    return concept

@router.put(
    "/schools/{school_id}/concepts/{concept_id}",
    response_model=PaymentConceptRead,
)
def update_payment_concept(
    school_id: UUID, concept_id: UUID, payload: PaymentConceptUpdate, db: DBSession, actor: CurrentActor
):
    return PaymentConceptService(db).update_concept(school_id, concept_id, actor.user.id, payload)

@router.delete(
    "/schools/{school_id}/concepts/{concept_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_payment_concept(school_id: UUID, concept_id: UUID, db: DBSession, actor: CurrentActor, background_tasks: BackgroundTasks):
    PaymentConceptService(db).delete_concept(school_id, concept_id, actor.user.id)
    background_tasks.add_task(background_delete_debts_for_concept, concept_id)

@router.post(
    "/cron/generate-recurring-debts",
    status_code=status.HTTP_200_OK,
    tags=["Cron Jobs"],
)
def cron_generate_recurring_debts(db: DBSession, authorization: str | None = Header(None)):
    """
    Endpoint intended to be called by a CRON job (e.g. Render Cron Jobs).
    Validates a secret token.
    """
    secret = settings.JWT_SECRET # Using JWT_SECRET as a simple token for now
    expected_token = f"Bearer {secret}"
    
    if authorization != expected_token:
        # Also allow local dev to test easily if needed, but standard is token
        raise HTTPException(status_code=401, detail="Unauthorized CRON caller")
    
    service = DebtGeneratorService(db)
    result = service.generate_all_recurring_debts()
    return {"message": "Recurring debts generation completed", "data": result}

from app.modules.payments.schemas.student_debt_schema import StudentDebtRead
from app.modules.payments.services.student_debt_service import StudentDebtService
from typing import Optional

@router.get(
    "/schools/{school_id}/students/{student_id}/debts",
    response_model=list[StudentDebtRead],
)
def list_student_debts(
    school_id: UUID, 
    student_id: UUID, 
    db: DBSession, 
    actor: CurrentActor,
    status: Optional[str] = None
):
    return StudentDebtService(db).list_student_debts(school_id, student_id, actor.user.id, status)

@router.post(
    "/schools/{school_id}/students/{student_id}/debts/{debt_id}/pay",
    status_code=status.HTTP_200_OK,
)
def pay_student_debt(
    school_id: UUID,
    student_id: UUID,
    debt_id: UUID,
    db: DBSession,
    actor: CurrentActor,
):
    StudentDebtService(db).pay_debt(school_id, student_id, debt_id, actor.user.id)
    return {"message": "Pago registrado exitosamente"}

from app.modules.payments.schemas.student_payment_schema import StudentPaymentRead

@router.get(
    "/schools/{school_id}/students/{student_id}/payments",
    response_model=list[StudentPaymentRead],
)
def list_student_payments(
    school_id: UUID, 
    student_id: UUID, 
    db: DBSession, 
    actor: CurrentActor,
):
    return StudentDebtService(db).list_student_payments(school_id, student_id, actor.user.id)

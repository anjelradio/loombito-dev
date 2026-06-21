from datetime import date
from typing import Optional
from uuid import UUID

from pydantic import BaseModel

from app.modules.payments.models.student_debt import DebtStatus

class StudentDebtRead(BaseModel):
    id: UUID
    student_id: UUID
    concept_id: UUID
    concept_name: str
    amount: float
    status: DebtStatus
    due_date: Optional[date] = None
    billing_month: Optional[int] = None
    billing_year: Optional[int] = None
    state: bool

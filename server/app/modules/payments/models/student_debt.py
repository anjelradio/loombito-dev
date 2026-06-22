from datetime import date
from enum import Enum
from typing import Optional
from uuid import UUID

from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class DebtStatus(str, Enum):
    PENDING = "PENDING" #PENDIENTE
    PAID = "PAID" #PAGADO
    OVERDUE = "OVERDUE" #EXPIRADO
    CANCELLED = "CANCELLED" #CANCELADO


class StudentDebt(UUIDBaseModel, table=True):
    __tablename__ = "student_debts"

    student_id: UUID = Field(foreign_key="students.id", index=True)
    concept_id: UUID = Field(foreign_key="payment_concepts.id", index=True)
    amount: float = Field(default=0.0)
    status: DebtStatus = Field(default=DebtStatus.PENDING)
    due_date: Optional[date] = Field(default=None)
    billing_month: Optional[int] = Field(default=None)
    billing_year: Optional[int] = Field(default=None)

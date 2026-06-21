from datetime import datetime
from typing import Optional
from uuid import UUID

from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


class StudentPayment(UUIDBaseModel, table=True):
    __tablename__ = "student_payments"

    student_debt_id: UUID = Field(foreign_key="student_debts.id", index=True)
    amount_paid: float = Field(default=0.0)
    transaction_id: Optional[str] = Field(default=None, index=True)
    payment_date: datetime = Field(default_factory=datetime.utcnow)

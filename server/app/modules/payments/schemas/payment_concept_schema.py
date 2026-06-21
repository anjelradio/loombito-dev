from typing import Optional
from uuid import UUID

from sqlmodel import SQLModel


class PaymentConceptBase(SQLModel):
    name: str
    amount: float
    is_recurring: bool = True


class PaymentConceptCreate(PaymentConceptBase):
    pass


class PaymentConceptUpdate(SQLModel):
    name: Optional[str] = None
    amount: Optional[float] = None
    is_recurring: Optional[bool] = None
    state: Optional[bool] = None


class PaymentConceptRead(PaymentConceptBase):
    id: UUID
    school_id: UUID
    state: bool

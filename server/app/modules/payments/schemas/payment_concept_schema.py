from typing import Optional
from uuid import UUID

from sqlmodel import SQLModel


# Campos base de un concepto de pago
class PaymentConceptBase(SQLModel):
    name: str
    amount: float
    is_recurring: bool = True


# Esquema para crear un concepto de pago
class PaymentConceptCreate(PaymentConceptBase):
    pass


# Esquema para actualizar un concepto de pago
class PaymentConceptUpdate(SQLModel):
    name: Optional[str] = None
    amount: Optional[float] = None
    is_recurring: Optional[bool] = None
    state: Optional[bool] = None


# Lectura para concepto de pago
class PaymentConceptRead(PaymentConceptBase):
    id: UUID
    school_id: UUID
    state: bool

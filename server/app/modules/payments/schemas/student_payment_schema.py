from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

# Esquema de lectura para pago estudiantil
class StudentPaymentRead(BaseModel):
    id: UUID
    student_debt_id: UUID
    concept_name: str
    amount_paid: float
    transaction_id: str | None = None
    payment_date: datetime

from datetime import time
from typing import Optional
from uuid import UUID

from sqlalchemy import Index, text
from sqlmodel import Field

from app.core.base_model import UUIDBaseModel


# Modelo de concepto de pago (ej. cuota)
class PaymentConcept(UUIDBaseModel, table=True):
    __tablename__ = "payment_concepts"
    __table_args__ = (
        Index(
            "uq_payment_concepts_school_name_active",
            "school_id",
            "name",
            unique=True,
            sqlite_where=text("state = 1"),
            postgresql_where=text("state = true"),
        ),
    )

    school_id: UUID = Field(foreign_key="school.id", index=True)
    name: str = Field(index=True, max_length=100)
    amount: float = Field(default=0.0)
    is_recurring: bool = Field(default=True)

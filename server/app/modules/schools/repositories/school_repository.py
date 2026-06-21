from uuid import UUID

from sqlmodel import Session, func, select

from app.modules.schools.models import School, SchoolUser


class SchoolRepository:
    def __init__(self, db: Session):
        self.db = db

    # Cuenta escuelas activas para calcular paginacion.
    def count_active(self) -> int:
        query = select(func.count()).select_from(School).where(School.state == True)
        return self.db.exec(query).one()

    # Lista escuelas activas ordenadas por fecha de creacion descendente.
    def list_paginated(
        self,
        *,
        per_page: int,
        page: int,
    ) -> list[School]:
        query = select(School).where(School.state == True)
        query = query.order_by(School.created_date.desc())

        offset = (page - 1) * per_page
        query = query.offset(offset).limit(per_page)

        return self.db.exec(query).all()

    # Busca una escuela activa por su identificador.
    def get(self, school_id: UUID) -> School | None:
        query = select(School).where(School.id == school_id, School.state == True)
        return self.db.exec(query).first()

    # Busca coincidencia por nombre normalizado en escuelas activas.
    def get_by_name(self, name: str) -> School | None:
        query = select(School).where(
            func.lower(func.trim(School.name)) == name.lower(), School.state == True
        )
        return self.db.exec(query).first()

    # Busca una escuela activa por telefono.
    def get_by_phone(self, phone: str) -> School | None:
        query = select(School).where(School.phone == phone, School.state == True)
        return self.db.exec(query).first()

    # Persiste una nueva escuela en la sesion actual.
    def create(self, school: School) -> School:
        self.db.add(school)
        return school

    # Persiste cambios sobre una escuela existente.
    def update(self, school: School) -> School:
        self.db.add(school)
        return school

    # Desactiva una escuela (borrado logico).
    def delete(self, school: School) -> School:
        school.state = False
        self.db.add(school)
        return school

    # Lista todas las escuelas activas del sistema (uso exclusivo de cron jobs / tareas internas).
    def list_all_active(self) -> list[School]:
        query = select(School).where(School.state == True).order_by(School.created_date.asc())
        return self.db.exec(query).all()

    # Lista escuelas activas asociadas al usuario junto con su rol.
    def list_by_user_id(self, user_id: UUID):
        query = (
            select(School, SchoolUser.role)
            .join(SchoolUser, School.id == SchoolUser.school_id)
            .where(
                SchoolUser.user_id == user_id,
                School.state == True,
                SchoolUser.state == True,
            )
        )
        return self.db.exec(query).all()

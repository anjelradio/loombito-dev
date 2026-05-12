from uuid import UUID

from sqlmodel import Session, select

from app.modules.system.models import SchoolBackup


class BackupRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, backup: SchoolBackup) -> SchoolBackup:
        self.db.add(backup)
        return backup

    def get_active_by_id_and_school(self, backup_id: UUID, school_id: UUID) -> SchoolBackup | None:
        query = select(SchoolBackup).where(
            SchoolBackup.id == backup_id,
            SchoolBackup.school_id == school_id,
            SchoolBackup.state == True,
        )
        return self.db.exec(query).first()

    def list_active_by_school(self, school_id: UUID) -> list[SchoolBackup]:
        query = (
            select(SchoolBackup)
            .where(
                SchoolBackup.school_id == school_id,
                SchoolBackup.state == True,
            )
            .order_by(SchoolBackup.created_date.desc())
        )
        return self.db.exec(query).all()

    def update(self, backup: SchoolBackup) -> SchoolBackup:
        self.db.add(backup)
        return backup

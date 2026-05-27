from uuid import UUID

from sqlmodel import Session, select

from app.modules.students.models import StudentParentInvite


class StudentParentInviteRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_active_by_code(self, code: str) -> StudentParentInvite | None:
        query = select(StudentParentInvite).where(
            StudentParentInvite.code == code,
            StudentParentInvite.state == True,
        )
        return self.db.exec(query).first()

    def get_active_by_student_id(self, student_id: UUID) -> StudentParentInvite | None:
        query = select(StudentParentInvite).where(
            StudentParentInvite.student_id == student_id,
            StudentParentInvite.state == True,
        )
        return self.db.exec(query).first()

    def create(self, invite: StudentParentInvite) -> StudentParentInvite:
        self.db.add(invite)
        return invite

    def update(self, invite: StudentParentInvite) -> StudentParentInvite:
        self.db.add(invite)
        return invite

    def delete(self, invite: StudentParentInvite) -> StudentParentInvite:
        invite.state = False
        self.db.add(invite)
        return invite

    def delete_active_by_student_ids(self, student_ids: list[UUID]) -> None:
        if not student_ids:
            return

        query = select(StudentParentInvite).where(
            StudentParentInvite.student_id.in_(student_ids),
            StudentParentInvite.state == True,
        )
        invites = self.db.exec(query).all()
        for invite in invites:
            invite.state = False
            self.db.add(invite)

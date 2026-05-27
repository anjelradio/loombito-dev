from uuid import UUID

from sqlmodel import Session, select

from app.modules.communications.models import StudentCommunication


class StudentCommunicationRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, communication: StudentCommunication) -> StudentCommunication:
        self.db.add(communication)
        return communication

    def update(self, communication: StudentCommunication) -> StudentCommunication:
        self.db.add(communication)
        return communication

    def delete(self, communication: StudentCommunication) -> StudentCommunication:
        communication.state = False
        self.db.add(communication)
        return communication

    def get_active_by_id(self, communication_id: UUID) -> StudentCommunication | None:
        query = select(StudentCommunication).where(
            StudentCommunication.id == communication_id,
            StudentCommunication.state == True,
        )
        return self.db.exec(query).first()

    def list_active_by_student(self, school_id: UUID, student_id: UUID) -> list[StudentCommunication]:
        query = (
            select(StudentCommunication)
            .where(
                StudentCommunication.school_id == school_id,
                StudentCommunication.student_id == student_id,
                StudentCommunication.state == True,
            )
            .order_by(StudentCommunication.created_date.desc())
        )
        return self.db.exec(query).all()

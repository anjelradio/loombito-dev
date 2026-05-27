from uuid import UUID

from sqlmodel import Session, select

from app.modules.academic.models import Course
from app.modules.students.models import CourseStudent
from app.modules.schools.models import School
from app.modules.students.models import Student
from app.modules.students.models import StudentParent


class StudentParentRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_active_by_user_and_student(self, user_id: UUID, student_id: UUID) -> StudentParent | None:
        query = select(StudentParent).where(
            StudentParent.user_id == user_id,
            StudentParent.student_id == student_id,
            StudentParent.state == True,
        )
        return self.db.exec(query).first()

    def create(self, link: StudentParent) -> StudentParent:
        self.db.add(link)
        return link

    def update(self, link: StudentParent) -> StudentParent:
        self.db.add(link)
        return link

    def list_active_students_by_user(self, user_id: UUID):
        query = (
            select(Student, School.name)
            .select_from(StudentParent)
            .join(Student, Student.id == StudentParent.student_id)
            .join(School, School.id == Student.school_id)
            .where(
                StudentParent.user_id == user_id,
                StudentParent.state == True,
                Student.state == True,
                School.state == True,
            )
            .order_by(Student.last_name.asc(), Student.first_name.asc())
        )
        return self.db.exec(query).all()

    def get_latest_active_course_name_by_student(self, student_id: UUID) -> str | None:
        query = (
            select(Course.name)
            .join(CourseStudent, CourseStudent.course_id == Course.id)
            .where(
                CourseStudent.student_id == student_id,
                CourseStudent.state == True,
                Course.state == True,
            )
            .order_by(CourseStudent.created_date.desc())
        )
        return self.db.exec(query).first()

    def list_active_parent_user_ids_by_student(self, student_id: UUID) -> list[UUID]:
        query = select(StudentParent.user_id).where(
            StudentParent.student_id == student_id,
            StudentParent.state == True,
        )
        return list(self.db.exec(query).all())

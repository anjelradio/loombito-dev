import type {
  StudentCommunication,
  TeacherCommunicationCourse,
  TeacherCommunicationStudent,
} from "@/features/communications/domain/entities/student-communication";

export function toTeacherCommunicationCourseEntity(dto: {
  id: string;
  name: string;
}): TeacherCommunicationCourse {
  return {
    id: dto.id,
    name: dto.name,
  };
}

export function toTeacherCommunicationStudentEntity(dto: {
  id: string;
  first_name: string;
  last_name: string;
}): TeacherCommunicationStudent {
  return {
    id: dto.id,
    firstName: dto.first_name,
    lastName: dto.last_name,
  };
}

export function toStudentCommunicationEntity(dto: {
  id: string;
  school_id: string;
  student_id: string;
  author_user_id: string;
  title: string;
  body: string;
  created_date: string;
}): StudentCommunication {
  return {
    id: dto.id,
    schoolId: dto.school_id,
    studentId: dto.student_id,
    authorUserId: dto.author_user_id,
    title: dto.title,
    body: dto.body,
    createdDate: dto.created_date,
  };
}

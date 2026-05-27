import type {
  TeacherCommunicationCourse,
  TeacherCommunicationStudent,
} from "@/features/students/domain/entities/teacher-communication-target";

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

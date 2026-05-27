import { z } from "zod";

export const TeacherCommunicationCourseResponseSchema = z.object({
  id: z.string(),
  name: z.string(),
});

export const TeacherCommunicationStudentResponseSchema = z.object({
  id: z.string(),
  first_name: z.string(),
  last_name: z.string(),
});

export const StudentCommunicationResponseSchema = z.object({
  id: z.string(),
  school_id: z.string(),
  student_id: z.string(),
  author_user_id: z.string(),
  title: z.string(),
  body: z.string(),
  created_date: z.string(),
});

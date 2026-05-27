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

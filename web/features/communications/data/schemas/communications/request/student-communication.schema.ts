import { z } from "zod";

export const StudentCommunicationCreateSchema = z.object({
  title: z.string().min(1, "Debes ingresar un titulo"),
  body: z.string().min(1, "Debes ingresar una descripcion"),
});

export const StudentCommunicationUpdateSchema = StudentCommunicationCreateSchema;

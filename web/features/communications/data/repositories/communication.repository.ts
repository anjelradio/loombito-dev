import { communicationApi } from "../api";

export const communicationRepository = {
  getTeacherCommunicationCourses(schoolId: string) {
    return communicationApi.getTeacherCommunicationCourses(schoolId);
  },

  getTeacherCommunicationStudentsByCourse(schoolId: string, courseId: string) {
    return communicationApi.getTeacherCommunicationStudentsByCourse(schoolId, courseId);
  },

  getStudentCommunications(schoolId: string, studentId: string) {
    return communicationApi.getStudentCommunications(schoolId, studentId);
  },

  createStudentCommunication(schoolId: string, studentId: string, data: unknown) {
    return communicationApi.createStudentCommunication(schoolId, studentId, data);
  },

  updateStudentCommunication(schoolId: string, communicationId: string, data: unknown) {
    return communicationApi.updateStudentCommunication(schoolId, communicationId, data);
  },

  deleteStudentCommunication(schoolId: string, communicationId: string) {
    return communicationApi.deleteStudentCommunication(schoolId, communicationId);
  },
};

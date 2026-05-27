export type TeacherCommunicationCourse = {
  id: string;
  name: string;
};

export type TeacherCommunicationStudent = {
  id: string;
  firstName: string;
  lastName: string;
};

export type StudentCommunication = {
  id: string;
  schoolId: string;
  studentId: string;
  authorUserId: string;
  title: string;
  body: string;
  createdDate: string;
};

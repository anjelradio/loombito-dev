import { schoolApi } from "../api/school-api";

export const schoolRepository = {
  getSchools(page?: number, perPage?: number) {
    return schoolApi.getSchools(page, perPage);
  },

  getSchoolsByUser() {
    return schoolApi.getSchoolsByUser();
  },

  getLevels() {
    return schoolApi.getLevels();
  },

  createSchool(data: unknown) {
    return schoolApi.createSchool(data);
  },

  joinSchoolByCode(data: unknown) {
    return schoolApi.joinSchoolByCode(data);
  },
};

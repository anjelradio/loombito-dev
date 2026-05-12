import { reportApi } from "../api/report-api";
import type { ReportType } from "../../domain/entities/report";

export const reportRepository = {
  getRunsBySchool(schoolId: string, reportType?: ReportType) {
    return reportApi.getRunsBySchool(schoolId, reportType);
  },
};

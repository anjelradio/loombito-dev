import { reportBrowserApi } from "../api/report-browser-api";
import type {
  ExportAttendanceReportInput,
  ExportEvaluationReportInput,
} from "../../domain/entities/report";

export const reportBrowserRepository = {
  getEvaluationOptionsByAssignment(schoolId: string, assignmentId: string) {
    return reportBrowserApi.getEvaluationOptionsByAssignment(schoolId, assignmentId);
  },

  exportEvaluationReport(input: ExportEvaluationReportInput) {
    return reportBrowserApi.exportEvaluationReport(input);
  },

  exportAttendanceReport(input: ExportAttendanceReportInput) {
    return reportBrowserApi.exportAttendanceReport(input);
  },
};

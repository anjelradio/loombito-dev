export type ReportType =
  | "attendance_report"
  | "evaluation_gradebook_report"
  | "term_average_report";

export type ReportRun = {
  id: string;
  schoolId: string;
  reportType: ReportType;
  filtersJson: Record<string, unknown>;
  columnsJson: string[];
  format: "xlsx" | "pdf";
  summary: string | null;
  createdDate: string;
};

export type ReportEvaluationOption = {
  id: string;
  name: string;
};

export type ReportExportFormat = "xlsx" | "pdf";

export type ExportEvaluationReportInput = {
  schoolId: string;
  assignmentId?: string;
  evaluationId?: string;
  columns: string[];
  format: ReportExportFormat;
  summary?: string | null;
};

export type ExportedReportFile = {
  fileName: string;
  contentType: string;
  blob: Blob;
};

export type AttendanceReportMode = "general" | "student_specific";

export type ExportAttendanceReportInput = {
  schoolId: string;
  assignmentId: string;
  fromDate?: string;
  toDate?: string;
  mode: AttendanceReportMode;
  studentLastName?: string;
  studentFirstName?: string;
  attendanceStatusFilter?: "all" | "presente" | "falta" | "licencia";
  columns: string[];
  format: ReportExportFormat;
  summary?: string | null;
};

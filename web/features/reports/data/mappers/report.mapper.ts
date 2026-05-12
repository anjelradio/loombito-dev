import type {
  ReportEvaluationOption,
  ReportRun,
} from "@/features/reports/domain/entities/report";

import type {
  ReportEvaluationOptionResponseDto,
  ReportRunResponseDto,
} from "../schemas/report-response.schema";

export function toReportRunEntity(dto: ReportRunResponseDto): ReportRun {
  return {
    id: dto.id,
    schoolId: dto.school_id,
    reportType: dto.report_type,
    filtersJson: dto.filters_json,
    columnsJson: dto.columns_json,
    format: dto.format,
    summary: dto.summary,
    createdDate: dto.created_date,
  };
}

export function toReportEvaluationOptionEntity(
  dto: ReportEvaluationOptionResponseDto,
): ReportEvaluationOption {
  return {
    id: dto.id,
    name: dto.name,
  };
}

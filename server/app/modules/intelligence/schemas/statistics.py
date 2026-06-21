from datetime import datetime
from pydantic import BaseModel

class SubjectPerformance(BaseModel):
    subject_name: str
    average: float

class StudentStatisticsData(BaseModel):
    total_presences: int
    total_absences: int
    total_licenses: int
    attendance_percentage: float
    current_average: float
    strengths: list[SubjectPerformance] = []
    weaknesses: list[SubjectPerformance] = []

class StudentPredictionsData(BaseModel):
    cluster_label: str | None
    projected_final_score: float | None
    failure_probability: float | None
    calculated_at: datetime | None

class StudentStatisticsResponse(BaseModel):
    statistics: StudentStatisticsData
    predictions: StudentPredictionsData

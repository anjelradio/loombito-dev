from uuid import UUID
from sqlmodel import Session
from fastapi import HTTPException

from app.modules.intelligence.repositories import StudentClusterRepository, StudentRiskRepository
from app.modules.schools.repositories import SchoolUserRepository
from app.modules.students.repositories.student_parent_repository import StudentParentRepository
from app.modules.intelligence.schemas.statistics import StudentStatisticsResponse, StudentStatisticsData, StudentPredictionsData
from app.modules.intelligence.permissions import ensure_admin_or_teacher_in_school

class StudentStatisticsService:
    def __init__(self, db: Session):
        self.db = db
        self.cluster_repo = StudentClusterRepository(db)
        self.risk_repo = StudentRiskRepository(db)
        self.school_user = SchoolUserRepository(db)
        self.parent_repo = StudentParentRepository(db)
        
    def get_student_statistics(self, school_id: UUID, student_id: UUID, user_id: UUID) -> StudentStatisticsResponse:
        school = self.cluster_repo.get_school(school_id)
        if not school:
            raise HTTPException(status_code=404, detail="Escuela no encontrada")
            
        parent_link = self.parent_repo.get_active_by_user_and_student(user_id, student_id)
        if not parent_link:
            try:
                ensure_admin_or_teacher_in_school(self.school_user, user_id, school_id)
            except HTTPException:
                raise HTTPException(status_code=403, detail="No tienes permisos para ver las estadísticas de este estudiante")

        # 1. Calculate General Statistics (SQL Based)
        attendance_status_ids = self.cluster_repo.list_all_attendance_records_for_student(school_id, student_id)
        status_ids = self.cluster_repo.get_attendance_status_ids_by_name()
        
        presences = len([s for s in attendance_status_ids if s == status_ids.get("presente")])
        absences = len([s for s in attendance_status_ids if s == status_ids.get("falta")])
        licenses = len([s for s in attendance_status_ids if s == status_ids.get("licencia")])
        
        total_classes = presences + absences + licenses
        if total_classes > 0:
            att_percentage = round(((presences * 100.0) + (licenses * 50.0)) / total_classes, 2)
        else:
            att_percentage = 0.0
            
        scores = self.cluster_repo.list_all_final_scores_for_student(school_id, student_id)
        current_score = sum(float(s) for s in scores) / len(scores) if scores else 0.0
        
        stats_data = StudentStatisticsData(
            total_presences=presences,
            total_absences=absences,
            total_licenses=licenses,
            attendance_percentage=att_percentage,
            current_average=round(current_score, 2),
            strengths=[],
            weaknesses=[]
        )
        
        # 1.5 Subject Strengths and Weaknesses
        subject_perf = self.cluster_repo.get_subject_performance_for_student(school_id, student_id)
        if subject_perf:
            # Sort by average descending
            sorted_subjects = sorted(subject_perf, key=lambda x: x[1], reverse=True)
            
            top_3 = sorted_subjects[:3]
            bottom_3 = sorted_subjects[-3:] if len(sorted_subjects) > 3 else sorted_subjects[len(top_3):]
            bottom_3 = sorted(bottom_3, key=lambda x: x[1]) # weakest first
            
            stats_data.strengths = [{"subject_name": s[0], "average": round(s[1], 2)} for s in top_3]
            stats_data.weaknesses = [{"subject_name": s[0], "average": round(s[1], 2)} for s in bottom_3]
        
        # 2. Get Machine Learning Predictions (General)
        predictions = self.risk_repo.get_all_active_predictions_for_student(school_id, student_id)
        
        cluster_label = self.cluster_repo.get_latest_cluster_label_for_student(school_id, student_id)
        
        if predictions:
            avg_proj_score = sum(p.projected_final_score for p in predictions) / len(predictions)
            avg_fail_prob = sum(p.failure_probability for p in predictions) / len(predictions)
            calc_at = max((p.calculated_at for p in predictions if p.calculated_at), default=None)
        else:
            avg_proj_score = None
            avg_fail_prob = None
            calc_at = None
            
        pred_data = StudentPredictionsData(
            cluster_label=cluster_label,
            projected_final_score=round(avg_proj_score, 2) if avg_proj_score is not None else None,
            failure_probability=round(avg_fail_prob, 2) if avg_fail_prob is not None else None,
            calculated_at=calc_at
        )
        
        return StudentStatisticsResponse(statistics=stats_data, predictions=pred_data)

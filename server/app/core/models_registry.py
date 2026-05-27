"""Registro central de modelos SQLModel.

Importar este modulo garantiza que todos los modelos queden cargados en
SQLModel.metadata para Alembic y utilidades de base de datos.
"""

from app.modules.academic.models import (  # noqa: F401
    Assignment,
    Course,
    CourseSubject,
    EvaluationWeight,
    Subject,
    Term,
)
from app.modules.attendance.models import AttendanceRecord, AttendanceSession, AttendanceStatus  # noqa: F401
from app.modules.auth.models import User  # noqa: F401
from app.modules.communications.models import Notification, StudentCommunication  # noqa: F401
from app.modules.evaluations.models import (  # noqa: F401
    Evaluation,
    EvaluationGrade,
    EvaluationType,
    TermSubjectAverage,
)
from app.modules.intelligence.models import StudentClusterResult, StudentClusterRun  # noqa: F401
from app.modules.licenses.models import StudentLicense  # noqa: F401
from app.modules.schools.models import (  # noqa: F401
    Level,
    School,
    SchoolInvite,
    SchoolLevel,
    SchoolUser,
)
from app.modules.reports.models import ReportRun  # noqa: F401
from app.modules.students.models import (  # noqa: F401
    CourseStudent,
    Student,
    StudentParent,
    StudentParentInvite,
)
from app.modules.subscriptions.models import Plan, SchoolSubscription, SubscriptionPayment  # noqa: F401
from app.modules.system.models import AuditLog, SchoolBackup  # noqa: F401

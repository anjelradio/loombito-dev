class Evaluation {
  final String id;
  final String name;
  final String? description;
  final String presentationDate;
  final String termId;
  final String termName;
  final String assignmentId;
  final String evaluationTypeId;
  final String evaluationTypeName;
  final String schoolId;
  final bool isClosed;

  Evaluation({
    required this.id,
    required this.name,
    required this.description,
    required this.presentationDate,
    required this.termId,
    required this.termName,
    required this.assignmentId,
    required this.evaluationTypeId,
    required this.evaluationTypeName,
    required this.schoolId,
    required this.isClosed,
  });
}

class EvaluationList {
  final List<Evaluation> evaluations;
  final int page;
  final int perPage;
  final int totalPages;
  final bool hasPrev;
  final bool hasNext;

  EvaluationList({
    required this.evaluations,
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.hasPrev,
    required this.hasNext,
  });
}

class EvaluationTypeOption {
  final String id;
  final String name;

  EvaluationTypeOption({required this.id, required this.name});
}

class EvaluationTermOption {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final bool isActive;

  EvaluationTermOption({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });
}

class TermAverageOption {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final bool isActive;

  TermAverageOption({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });
}

class StudentTermAverageRow {
  final String studentId;
  final String firstName;
  final String lastName;
  final double? saberScore;
  final double? hacerScore;
  final double? serScore;
  final double? autoevaluacionScore;
  final double? finalScore;
  final String status;

  StudentTermAverageRow({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.saberScore,
    required this.hacerScore,
    required this.serScore,
    required this.autoevaluacionScore,
    required this.finalScore,
    required this.status,
  });
}

class CalculateTermAverageSummary {
  final int processedStudents;
  final String assignmentId;
  final String termId;

  CalculateTermAverageSummary({
    required this.processedStudents,
    required this.assignmentId,
    required this.termId,
  });
}

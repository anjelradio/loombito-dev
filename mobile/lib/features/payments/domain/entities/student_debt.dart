class StudentDebt {
  final String id;
  final String studentId;
  final String conceptId;
  final String conceptName;
  final double amount;
  final String status;
  final String dueDate;
  final int? billingMonth;
  final int? billingYear;

  StudentDebt({
    required this.id,
    required this.studentId,
    required this.conceptId,
    required this.conceptName,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.billingMonth,
    this.billingYear,
  });

  factory StudentDebt.fromJson(Map<String, dynamic> json) {
    return StudentDebt(
      id: json['id'],
      studentId: json['student_id'],
      conceptId: json['concept_id'],
      conceptName: json['concept_name'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      dueDate: json['due_date'],
      billingMonth: json['billing_month'],
      billingYear: json['billing_year'],
    );
  }
}

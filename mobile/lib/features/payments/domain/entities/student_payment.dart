class StudentPayment {
  final String id;
  final String studentDebtId;
  final String conceptName;
  final double amountPaid;
  final String? transactionId;
  final DateTime paymentDate;

  StudentPayment({
    required this.id,
    required this.studentDebtId,
    required this.conceptName,
    required this.amountPaid,
    this.transactionId,
    required this.paymentDate,
  });

  factory StudentPayment.fromJson(Map<String, dynamic> json) => StudentPayment(
        id: json["id"],
        studentDebtId: json["student_debt_id"],
        conceptName: json["concept_name"],
        amountPaid: (json["amount_paid"] as num).toDouble(),
        transactionId: json["transaction_id"],
        paymentDate: DateTime.parse(json["payment_date"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "student_debt_id": studentDebtId,
        "concept_name": conceptName,
        "amount_paid": amountPaid,
        "transaction_id": transactionId,
        "payment_date": paymentDate.toIso8601String(),
      };
}

import 'package:mobile/features/payments/domain/entities/student_debt.dart';

abstract class StudentDebtRepository {
  Future<List<StudentDebt>> getPendingDebts(String schoolId, String studentId);
  Future<void> payDebt(String schoolId, String studentId, String debtId);
}

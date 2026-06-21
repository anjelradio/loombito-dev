import 'package:mobile/features/payments/domain/entities/student_debt.dart';
import 'package:mobile/features/payments/domain/repositories/student_debt_repository.dart';
import 'package:mobile/features/payments/data/api/student_debt_api.dart';

class StudentDebtRepositoryImpl implements StudentDebtRepository {
  final StudentDebtApi _api;

  StudentDebtRepositoryImpl({required StudentDebtApi api}) : _api = api;

  @override
  Future<List<StudentDebt>> getPendingDebts(String schoolId, String studentId) async {
    return await _api.getPendingDebts(schoolId, studentId);
  }

  @override
  Future<void> payDebt(String schoolId, String studentId, String debtId) async {
    await _api.payDebt(schoolId, studentId, debtId);
  }
}

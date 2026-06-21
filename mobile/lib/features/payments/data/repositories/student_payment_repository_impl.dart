import 'package:mobile/features/payments/data/api/student_payment_api.dart';
import 'package:mobile/features/payments/domain/entities/student_payment.dart';
import 'package:mobile/features/payments/domain/repositories/student_payment_repository.dart';

class StudentPaymentRepositoryImpl implements StudentPaymentRepository {
  final StudentPaymentApi api;

  StudentPaymentRepositoryImpl(this.api);

  @override
  Future<List<StudentPayment>> getStudentPayments(String schoolId, String studentId) {
    return api.getStudentPayments(schoolId, studentId);
  }
}

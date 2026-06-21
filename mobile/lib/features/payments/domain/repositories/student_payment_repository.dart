import 'package:mobile/features/payments/domain/entities/student_payment.dart';

abstract class StudentPaymentRepository {
  Future<List<StudentPayment>> getStudentPayments(String schoolId, String studentId);
}

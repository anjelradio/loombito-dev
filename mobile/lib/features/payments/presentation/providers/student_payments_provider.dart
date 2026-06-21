import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/payments/data/data.dart';
import 'package:mobile/features/payments/domain/domain.dart';

final studentPaymentRepositoryProvider = Provider<StudentPaymentRepositoryImpl>((ref) {
  final authState = ref.watch(authProvider);
  final accessToken = authState.user?.token ?? '';
  
  return StudentPaymentRepositoryImpl(
    StudentPaymentApi(accessToken: accessToken),
  );
});

typedef _StudentArgs = ({String schoolId, String studentId});

final studentPaymentsProvider = FutureProvider.family<List<StudentPayment>, _StudentArgs>((ref, args) {
  final repository = ref.watch(studentPaymentRepositoryProvider);
  return repository.getStudentPayments(args.schoolId, args.studentId);
});

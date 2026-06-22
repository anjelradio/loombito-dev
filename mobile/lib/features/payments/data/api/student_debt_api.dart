import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/payments/domain/entities/student_debt.dart';

class StudentDebtApi {
  late final Dio dio;
  final String accessToken;

  StudentDebtApi({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  // Obtiene las deudas pendientes de un estudiante
  Future<List<StudentDebt>> getPendingDebts(String schoolId, String studentId) async {
    final response = await dio.get(
      '/payments/schools/$schoolId/students/$studentId/debts?status=PENDING',
    );

    final data = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return data.map((json) => StudentDebt.fromJson(json)).toList();
  }

  // Envía la solicitud de pago de una deuda al backend
  Future<void> payDebt(String schoolId, String studentId, String debtId) async {
    await dio.post(
      '/payments/schools/$schoolId/students/$studentId/debts/$debtId/pay',
    );
  }
}

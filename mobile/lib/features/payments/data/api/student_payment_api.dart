import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/payments/domain/entities/student_payment.dart';

class StudentPaymentApi {
  late final Dio dio;
  final String accessToken;

  StudentPaymentApi({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

  // Obtiene el historial de pagos de un estudiante
  Future<List<StudentPayment>> getStudentPayments(String schoolId, String studentId) async {
    try {
      final response = await dio.get('/payments/schools/$schoolId/students/$studentId/payments');
      final data = (response.data as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>().toList();
      return data.map((json) => StudentPayment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error al obtener los pagos');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}

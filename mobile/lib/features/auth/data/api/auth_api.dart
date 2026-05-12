import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/auth/data/data.dart';
import 'package:mobile/features/auth/domain/domain.dart';
import 'package:mobile/features/shared/shared.dart';

class AuthApi {
  AuthApi({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: Environment.apiUrl));

  final Dio _dio;

  Never _throwParsedDioError(DioException error, String fallbackMessage) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      throw CustomError('Revisa tu conexion a internet');
    }

    final messages = parseApiErrors(error.response?.data);
    if (messages.isNotEmpty) {
      throw CustomError.multiple(messages);
    }

    throw CustomError(fallbackMessage);
  }

  Future<User> checkAuthStatus(String token) async {
    try {
      final response = await _dio.post(
        '/auth/check-status',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return UserMapper.userJsonToEntity(response.data);
    } on DioException catch (e) {
      _throwParsedDioError(e, 'No fue posible validar la sesion');
    } catch (_) {
      throw CustomError('No fue posible validar la sesion');
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'auth/login',
        data: AuthRequestMapper.toLoginRequest(email, password),
      );
      return UserMapper.userJsonToEntity(response.data);
    } on DioException catch (e) {
      _throwParsedDioError(e, 'No fue posible iniciar sesion');
    } catch (_) {
      throw CustomError('No fue posible iniciar sesion');
    }
  }

  Future<User> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        'auth/register',
        data: AuthRequestMapper.toRegisterRequest(
          firstName,
          lastName,
          email,
          password,
        ),
      );
      return UserMapper.userJsonToEntity(response.data);
    } on DioException catch (e) {
      _throwParsedDioError(e, 'No fue posible registrarse');
    } catch (_) {
      throw CustomError('No fue posible registrarse');
    }
  }
}

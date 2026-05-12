import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/features/auth/data/data.dart';
import 'package:mobile/features/auth/domain/domain.dart';
import 'package:mobile/features/shared/shared.dart';

class AccountApi {
  AccountApi({Dio? dio})
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

  Future<User> updatePersonalInfo(
    String token,
    String firstName,
    String lastName,
  ) async {
    try {
      final response = await _dio.patch(
        '/users/me/profile',
        data: AccountRequestMapper.toUpdatePersonalInfoRequest(
          firstName,
          lastName,
        ),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return UserMapper.userJsonWithoutTokenToEntity(
        Map<String, dynamic>.from(response.data),
        token: token,
      );
    } on DioException catch (e) {
      _throwParsedDioError(e, 'No fue posible actualizar los datos');
    } catch (_) {
      throw CustomError('No fue posible actualizar los datos');
    }
  }

  Future<void> requestEmailOtp(String token) async {
    try {
      await _dio.post(
        '/users/me/email/request-otp',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      _throwParsedDioError(e, 'No fue posible enviar el codigo OTP');
    } catch (_) {
      throw CustomError('No fue posible enviar el codigo OTP');
    }
  }

  Future<String> verifyEmailOtp(String token, String otp) async {
    try {
      final response = await _dio.post(
        '/users/me/email/verify-otp',
        data: AccountRequestMapper.toVerifyEmailOtpRequest(otp),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return EmailChangeMapper.emailChangeTokenFromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      _throwParsedDioError(e, 'No fue posible verificar el codigo OTP');
    } catch (_) {
      throw CustomError('No fue posible verificar el codigo OTP');
    }
  }

  Future<User> updateEmail(
    String token,
    String newEmail,
    String emailChangeToken,
  ) async {
    try {
      final response = await _dio.patch(
        '/users/me/email',
        data: AccountRequestMapper.toUpdateEmailRequest(
          newEmail,
          emailChangeToken,
        ),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return UserMapper.userJsonWithoutTokenToEntity(
        Map<String, dynamic>.from(response.data),
        token: token,
      );
    } on DioException catch (e) {
      _throwParsedDioError(e, 'No fue posible actualizar el correo');
    } catch (_) {
      throw CustomError('No fue posible actualizar el correo');
    }
  }

  Future<void> updatePassword(
    String token,
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    try {
      await _dio.patch(
        '/users/me/password',
        data: AccountRequestMapper.toUpdatePasswordRequest(
          currentPassword,
          newPassword,
          confirmNewPassword,
        ),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      _throwParsedDioError(e, 'No fue posible actualizar la contraseña');
    } catch (_) {
      throw CustomError('No fue posible actualizar la contraseña');
    }
  }
}

import 'package:mobile/features/auth/data/data.dart';
import 'package:mobile/features/auth/domain/domain.dart';

class AccountRepository {
  AccountRepository({required AccountApi accountApi})
    : _accountApi = accountApi;
  final AccountApi _accountApi;

  Future<User> updatePersonalInfo(
    String token,
    String firstName,
    String lastName,
  ) {
    return _accountApi.updatePersonalInfo(token, firstName, lastName);
  }

  Future<void> requestEmailOtp(String token) {
    return _accountApi.requestEmailOtp(token);
  }

  Future<String> verifyEmailOtp(String token, String otp) {
    return _accountApi.verifyEmailOtp(token, otp);
  }

  Future<User> updateEmail(
    String token,
    String newEmail,
    String emailChangeToken,
  ) {
    return _accountApi.updateEmail(token, newEmail, emailChangeToken);
  }

  Future<void> updatePassword(
    String token,
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) {
    return _accountApi.updatePassword(
      token,
      currentPassword,
      newPassword,
      confirmNewPassword,
    );
  }
}

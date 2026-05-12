import 'package:mobile/features/auth/auth.dart';

class AuthRepository {
  AuthRepository({required AuthApi authApi}) : _authApi = authApi;
  final AuthApi _authApi;

  Future<User> login(String email, String password) {
    return _authApi.login(email, password);
  }

  Future<User> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) {
    return _authApi.register(firstName, lastName, email, password);
  }

  Future<User> checkAuthStatus(String token) {
    return _authApi.checkAuthStatus(token);
  }
}

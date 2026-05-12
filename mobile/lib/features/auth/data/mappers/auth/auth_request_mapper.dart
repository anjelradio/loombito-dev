class AuthRequestMapper {
  static Map<String, dynamic> toLoginRequest(String email, String password) {
    return {'email': email, 'password': password};
  }

  static Map<String, dynamic> toRegisterRequest(
    String firstName,
    String lastName,
    String email,
    String password,
  ) {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
    };
  }
}

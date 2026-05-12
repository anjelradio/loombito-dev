class EmailChangeMapper {
  static String emailChangeTokenFromJson(Map<String, dynamic> json) {
    final token = json['email_change_token'];
    if (token is String && token.isNotEmpty) return token;

    throw FormatException('email_change_token invalido');
  }
}

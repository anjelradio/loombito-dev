class AccountRequestMapper {
  static Map<String, dynamic> toUpdatePersonalInfoRequest(
    String firstName,
    String lastName,
  ) {
    return {'first_name': firstName, 'last_name': lastName};
  }

  static Map<String, dynamic> toVerifyEmailOtpRequest(String otp) {
    return {'otp': otp};
  }

  static Map<String, dynamic> toUpdateEmailRequest(
    String newEmail,
    String emailChangeToken,
  ) {
    return {'new_email': newEmail, 'email_change_token': emailChangeToken};
  }

  static Map<String, dynamic> toUpdatePasswordRequest(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_new_password': confirmNewPassword,
    };
  }
}

import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:mobile/features/auth/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';

final emailChangeFormProvider =
    StateNotifierProvider.autoDispose<
      EmailChangeFormNotifier,
      EmailChangeFormState
    >((ref) {
      final requestEmailOtpCallback = ref
          .read(authProvider.notifier)
          .requestEmailOtp;
      final verifyEmailOtpCallback = ref
          .read(authProvider.notifier)
          .verifyEmailOtp;
      final updateEmailCallback = ref.read(authProvider.notifier).updateEmail;

      return EmailChangeFormNotifier(
        requestEmailOtpCallback: requestEmailOtpCallback,
        verifyEmailOtpCallback: verifyEmailOtpCallback,
        updateEmailCallback: updateEmailCallback,
      );
    });

class EmailChangeFormNotifier extends StateNotifier<EmailChangeFormState> {
  final Future<bool> Function() requestEmailOtpCallback;
  final Future<String?> Function(String otp) verifyEmailOtpCallback;
  final Future<bool> Function(String newEmail, String emailChangeToken)
  updateEmailCallback;

  EmailChangeFormNotifier({
    required this.requestEmailOtpCallback,
    required this.verifyEmailOtpCallback,
    required this.updateEmailCallback,
  }) : super(EmailChangeFormState());

  void onOtpChange(String value) {
    final newOtp = Otp.dirty(value);
    state = state.copyWith(otp: newOtp, isOtpValid: Formz.validate([newOtp]));
  }

  void onNewEmailChange(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      newEmail: newEmail,
      isNewEmailValid: Formz.validate([newEmail]),
    );
  }

  Future<bool> requestOtp() async {
    state = state.copyWith(isPosting: true);
    final success = await requestEmailOtpCallback();
    if (!mounted) return success;
    state = state.copyWith(isPosting: false);
    return success;
  }

  Future<bool> verifyOtp() async {
    _touchOtpField();
    if (!state.isOtpValid) return false;

    state = state.copyWith(isPosting: true);
    final token = await verifyEmailOtpCallback(state.otp.value.trim());
    if (!mounted) return false;
    if (token == null) {
      state = state.copyWith(isPosting: false);
      return false;
    }

    state = state.copyWith(
      isPosting: false,
      isOtpFormPosted: false,
      otp: const Otp.pure(),
      isOtpValid: false,
      emailChangeToken: token,
    );
    return true;
  }

  Future<bool> submitNewEmail() async {
    _touchEmailField();
    if (!state.isNewEmailValid || state.emailChangeToken.isEmpty) return false;

    state = state.copyWith(isPosting: true);
    final wasUpdated = await updateEmailCallback(
      state.newEmail.value.trim(),
      state.emailChangeToken,
    );
    if (!mounted) return false;

    state = state.copyWith(isPosting: false);
    if (!wasUpdated) return false;

    reset();
    return true;
  }

  void reset() {
    state = EmailChangeFormState();
  }

  void _touchOtpField() {
    final otp = Otp.dirty(state.otp.value);
    state = state.copyWith(
      otp: otp,
      isOtpFormPosted: true,
      isOtpValid: Formz.validate([otp]),
    );
  }

  void _touchEmailField() {
    final email = Email.dirty(state.newEmail.value);
    state = state.copyWith(
      newEmail: email,
      isNewEmailFormPosted: true,
      isNewEmailValid: Formz.validate([email]),
    );
  }
}

class EmailChangeFormState {
  final bool isPosting;
  final bool isOtpFormPosted;
  final bool isNewEmailFormPosted;
  final Otp otp;
  final Email newEmail;
  final bool isOtpValid;
  final bool isNewEmailValid;
  final String emailChangeToken;

  bool get canVerifyOtp => !isPosting && isOtpValid;

  bool get canSubmitNewEmail {
    return !isPosting && isNewEmailValid && emailChangeToken.isNotEmpty;
  }

  EmailChangeFormState({
    this.isPosting = false,
    this.isOtpFormPosted = false,
    this.isNewEmailFormPosted = false,
    this.otp = const Otp.pure(),
    this.newEmail = const Email.pure(),
    this.isOtpValid = false,
    this.isNewEmailValid = false,
    this.emailChangeToken = '',
  });

  EmailChangeFormState copyWith({
    bool? isPosting,
    bool? isOtpFormPosted,
    bool? isNewEmailFormPosted,
    Otp? otp,
    Email? newEmail,
    bool? isOtpValid,
    bool? isNewEmailValid,
    String? emailChangeToken,
  }) => EmailChangeFormState(
    isPosting: isPosting ?? this.isPosting,
    isOtpFormPosted: isOtpFormPosted ?? this.isOtpFormPosted,
    isNewEmailFormPosted: isNewEmailFormPosted ?? this.isNewEmailFormPosted,
    otp: otp ?? this.otp,
    newEmail: newEmail ?? this.newEmail,
    isOtpValid: isOtpValid ?? this.isOtpValid,
    isNewEmailValid: isNewEmailValid ?? this.isNewEmailValid,
    emailChangeToken: emailChangeToken ?? this.emailChangeToken,
  );
}

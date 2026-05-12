import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/auth/presentation/providers/providers.dart';

final passwordChangeFormProvider =
    StateNotifierProvider.autoDispose<
      PasswordChangeFormNotifier,
      PasswordChangeFormState
    >((ref) {
      final updatePasswordCallback = ref
          .read(authProvider.notifier)
          .updatePassword;
      return PasswordChangeFormNotifier(
        updatePasswordCallback: updatePasswordCallback,
      );
    });

class PasswordChangeFormNotifier
    extends StateNotifier<PasswordChangeFormState> {
  final Future<bool> Function(String, String, String) updatePasswordCallback;

  PasswordChangeFormNotifier({required this.updatePasswordCallback})
    : super(PasswordChangeFormState());

  void onCurrentPasswordChange(String value) {
    state = state.copyWith(currentPassword: value);
  }

  void onNewPasswordChange(String value) {
    state = state.copyWith(newPassword: value);
  }

  void onConfirmNewPasswordChange(String value) {
    state = state.copyWith(confirmNewPassword: value);
  }

  Future<bool> onFormSubmit() async {
    state = state.copyWith(isFormPosted: true);
    if (!state.isValid) return false;

    state = state.copyWith(isPosting: true);
    final wasUpdated = await updatePasswordCallback(
      state.currentPassword.trim(),
      state.newPassword.trim(),
      state.confirmNewPassword.trim(),
    );
    if (!mounted) return false;

    state = state.copyWith(isPosting: false);
    if (!wasUpdated) {
      return false;
    }

    reset();
    return true;
  }

  void reset() {
    state = PasswordChangeFormState();
  }
}

class PasswordChangeFormState {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;
  final bool isFormPosted;
  final bool isPosting;

  bool get isValid {
    final hasCurrentPassword = currentPassword.trim().isNotEmpty;
    final hasNewPassword = newPassword.trim().isNotEmpty;
    final hasConfirmPassword = confirmNewPassword.trim().isNotEmpty;
    final passwordsMatch = newPassword.trim() == confirmNewPassword.trim();

    return hasCurrentPassword &&
        hasNewPassword &&
        hasConfirmPassword &&
        passwordsMatch;
  }

  bool get canSubmit => isValid && !isPosting;

  String? get currentPasswordError {
    if (!isFormPosted) return null;
    if (currentPassword.trim().isEmpty) {
      return 'La contraseña actual es requerida';
    }
    return null;
  }

  String? get newPasswordError {
    if (!isFormPosted) return null;
    if (newPassword.trim().isEmpty) return 'La nueva contraseña es requerida';
    return null;
  }

  String? get confirmNewPasswordError {
    if (!isFormPosted) return null;
    if (confirmNewPassword.trim().isEmpty) {
      return 'La confirmación de contraseña es requerida';
    }
    if (newPassword.trim() != confirmNewPassword.trim()) {
      return 'La confirmación de contraseña no coincide';
    }
    return null;
  }

  PasswordChangeFormState({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmNewPassword = '',
    this.isFormPosted = false,
    this.isPosting = false,
  });

  PasswordChangeFormState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmNewPassword,
    bool? isFormPosted,
    bool? isPosting,
  }) => PasswordChangeFormState(
    currentPassword: currentPassword ?? this.currentPassword,
    newPassword: newPassword ?? this.newPassword,
    confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isPosting: isPosting ?? this.isPosting,
  );
}

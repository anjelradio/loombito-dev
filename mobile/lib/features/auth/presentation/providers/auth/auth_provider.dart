import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/shared/shared.dart';

final keyValueStorageProvider = Provider<KeyValueStorageService>((ref) {
  return KeyValueStorageServiceImpl();
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi();
});

final accountApiProvider = Provider<AccountApi>((ref) {
  return AccountApi();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApi = ref.watch(authApiProvider);
  return AuthRepository(authApi: authApi);
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final accountApi = ref.watch(accountApiProvider);
  return AccountRepository(accountApi: accountApi);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final accountRepository = ref.watch(accountRepositoryProvider);
  final keyValueStorageService = ref.watch(keyValueStorageProvider);
  return AuthNotifier(
    authRepository: authRepository,
    accountRepository: accountRepository,
    keyValueStorageService: keyValueStorageService,
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final AccountRepository accountRepository;
  final KeyValueStorageService keyValueStorageService;
  AuthNotifier({
    required this.authRepository,
    required this.accountRepository,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> loginUser(String email, String password) async {
    try {
      final user = await authRepository.login(email, password);
      _setLoggedUser(user);
    } on CustomError catch (e) {
      logoutWithErrors(e.messages);
    } catch (e) {
      logout('Error al iniciar sesion');
    }
  }

  Future<void> registerUser(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = await authRepository.register(
        firstName,
        lastName,
        email,
        password,
      );
      _setLoggedUser(user);
    } on CustomError catch (e) {
      logoutWithErrors(e.messages);
    } catch (e) {
      logout('Error al registrarse');
    }
  }

  Future<bool> updatePersonalInfo(String firstName, String lastName) async {
    final currentUser = state.user;
    if (currentUser == null) return false;

    state = state.copyWith(errorMessages: const []);

    try {
      final updatedUser = await accountRepository.updatePersonalInfo(
        currentUser.token,
        firstName,
        lastName,
      );

      state = state.copyWith(user: updatedUser, errorMessages: const []);
      return true;
    } on CustomError catch (e) {
      state = state.copyWith(errorMessages: e.messages);
      return false;
    } catch (_) {
      state = state.copyWith(
        errorMessages: const ['Error al actualizar datos personales'],
      );
      return false;
    }
  }

  Future<bool> requestEmailOtp() async {
    final currentUser = state.user;
    if (currentUser == null) return false;

    state = state.copyWith(errorMessages: const []);

    try {
      await accountRepository.requestEmailOtp(currentUser.token);
      return true;
    } on CustomError catch (e) {
      state = state.copyWith(errorMessages: e.messages);
      return false;
    } catch (_) {
      state = state.copyWith(
        errorMessages: const ['Error al enviar el codigo OTP'],
      );
      return false;
    }
  }

  Future<String?> verifyEmailOtp(String otp) async {
    final currentUser = state.user;
    if (currentUser == null) return null;

    state = state.copyWith(errorMessages: const []);

    try {
      return await accountRepository.verifyEmailOtp(currentUser.token, otp);
    } on CustomError catch (e) {
      state = state.copyWith(errorMessages: e.messages);
      return null;
    } catch (_) {
      state = state.copyWith(
        errorMessages: const ['Error al verificar el codigo OTP'],
      );
      return null;
    }
  }

  Future<bool> updateEmail(String newEmail, String emailChangeToken) async {
    final currentUser = state.user;
    if (currentUser == null) return false;

    state = state.copyWith(errorMessages: const []);

    try {
      final updatedUser = await accountRepository.updateEmail(
        currentUser.token,
        newEmail,
        emailChangeToken,
      );
      state = state.copyWith(user: updatedUser, errorMessages: const []);
      return true;
    } on CustomError catch (e) {
      state = state.copyWith(errorMessages: e.messages);
      return false;
    } catch (_) {
      state = state.copyWith(
        errorMessages: const ['Error al actualizar el correo'],
      );
      return false;
    }
  }

  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    final currentUser = state.user;
    if (currentUser == null) return false;

    state = state.copyWith(errorMessages: const []);

    try {
      await accountRepository.updatePassword(
        currentUser.token,
        currentPassword,
        newPassword,
        confirmNewPassword,
      );
      state = state.copyWith(errorMessages: const []);
      return true;
    } on CustomError catch (e) {
      state = state.copyWith(errorMessages: e.messages);
      return false;
    } catch (_) {
      state = state.copyWith(
        errorMessages: const ['Error al actualizar la contraseña'],
      );
      return false;
    }
  }

  void checkAuthStatus() async {
    final token = await keyValueStorageService.getValue<String>('token');

    if (token == null) return logout();

    try {
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user);
    } catch (e) {
      logout();
    }
  }

  void _setLoggedUser(User user) async {
    await keyValueStorageService.setKeyValue('token', user.token);
    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessages: const [],
    );
  }

  Future<void> logoutWithErrors(List<String> errorMessages) async {
    await keyValueStorageService.removeKey('token');
    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessages: errorMessages,
    );
  }

  Future<void> logout([String? errorMessage]) async {
    await keyValueStorageService.removeKey('token');
    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessages: errorMessage == null ? const [] : [errorMessage],
    );
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final List<String> errorMessages;

  String get errorMessage =>
      errorMessages.isNotEmpty ? errorMessages.first : '';

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessages = const [],
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    List<String>? errorMessages,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}

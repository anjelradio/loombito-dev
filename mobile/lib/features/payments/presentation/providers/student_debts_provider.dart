import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/payments/domain/domain.dart';
import 'package:mobile/features/payments/data/data.dart';

class StudentDebtsState {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<StudentDebt> debts;

  StudentDebtsState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.debts = const [],
  });

  StudentDebtsState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<StudentDebt>? debts,
  }) {
    return StudentDebtsState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      debts: debts ?? this.debts,
    );
  }
}

class StudentDebtsNotifier extends StateNotifier<StudentDebtsState> {
  final StudentDebtRepositoryImpl repository;

  StudentDebtsNotifier({required this.repository}) : super(StudentDebtsState());

  Future<void> loadDebts(String schoolId, String studentId) async {
    state = state.copyWith(isLoading: true, hasError: false);
    
    try {
      final debts = await repository.getPendingDebts(schoolId, studentId);
      state = state.copyWith(
        isLoading: false,
        debts: debts,
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al obtener las deudas del estudiante.',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error inesperado al cargar las deudas.',
      );
    }
  }

  Future<bool> payDebt(String schoolId, String studentId, String debtId) async {
    try {
      await repository.payDebt(schoolId, studentId, debtId);
      state = state.copyWith(
        debts: state.debts.where((debt) => debt.id != debtId).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final studentDebtRepositoryProvider = Provider<StudentDebtRepositoryImpl>((ref) {
  final authState = ref.watch(authProvider);
  final accessToken = authState.user?.token ?? '';
  
  return StudentDebtRepositoryImpl(
    api: StudentDebtApi(accessToken: accessToken),
  );
});

final studentDebtsProvider = StateNotifierProvider.family<StudentDebtsNotifier, StudentDebtsState, String>((ref, id) {
  final repository = ref.watch(studentDebtRepositoryProvider);
  return StudentDebtsNotifier(repository: repository);
});

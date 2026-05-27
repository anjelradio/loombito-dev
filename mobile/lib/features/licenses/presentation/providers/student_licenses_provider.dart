import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/licenses/data/repositories/repositories.dart';
import 'package:mobile/features/licenses/domain/domain.dart';
import 'package:mobile/features/licenses/presentation/providers/license_repository_provider.dart';

final studentLicensesProvider =
    StateNotifierProvider<StudentLicensesNotifier, StudentLicensesState>((ref) {
      final repository = ref.watch(licenseRepositoryProvider);
      return StudentLicensesNotifier(repository: repository);
    });

class StudentLicensesNotifier extends StateNotifier<StudentLicensesState> {
  final LicenseRepository repository;

  StudentLicensesNotifier({required this.repository}) : super(StudentLicensesState());

  Future<void> load(String schoolId, String studentId, {bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (!forceRefresh && state.hasLoaded && state.schoolId == schoolId && state.studentId == studentId) return;

    state = state.copyWith(
      isLoading: true,
      schoolId: schoolId,
      studentId: studentId,
      errorMessages: const [],
    );

    try {
      final licenses = await repository.getStudentLicenses(schoolId, studentId);
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        licenses: licenses,
        errorMessages: const [],
      );
    } on DioException catch (error) {
      state = state.copyWith(isLoading: false, hasLoaded: true, errorMessages: [_resolveError(error)]);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['Error de conexion. Intentalo nuevamente.'],
      );
    }
  }

  String _resolveError(DioException error) {
    final detail = error.response?.data;
    if (detail is Map<String, dynamic> && detail['detail'] is String) {
      return detail['detail'] as String;
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Error de conexion. Intentalo nuevamente.';
    }
    return 'No fue posible cargar las licencias.';
  }
}

class StudentLicensesState {
  final bool isLoading;
  final bool hasLoaded;
  final String schoolId;
  final String studentId;
  final List<StudentLicense> licenses;
  final List<String> errorMessages;

  StudentLicensesState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schoolId = '',
    this.studentId = '',
    this.licenses = const [],
    this.errorMessages = const [],
  });

  StudentLicensesState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? schoolId,
    String? studentId,
    List<StudentLicense>? licenses,
    List<String>? errorMessages,
  }) => StudentLicensesState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    licenses: licenses ?? this.licenses,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/schools/data/repositories/repositories.dart';
import 'package:mobile/features/schools/domain/domain.dart';
import 'package:mobile/features/schools/presentation/providers/school_repository_provider.dart';

final schoolsProvider = StateNotifierProvider<SchoolsNotifier, SchoolsState>((
  ref,
) {
  final schoolRepository = ref.watch(schoolRepositoryProvider);
  return SchoolsNotifier(schoolRepository: schoolRepository);
});

class SchoolsNotifier extends StateNotifier<SchoolsState> {
  final SchoolRepository schoolRepository;
  SchoolsNotifier({required this.schoolRepository}) : super(SchoolsState());

  Future<void> loadSchools() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessages: const []);

    try {
      final schools = await schoolRepository.getSchoolsByUser();
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        schools: schools,
        errorMessages: const [],
      );
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: [_resolveDioError(error)],
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessages: const ['Error de conexión. Inténtalo nuevamente.'],
      );
    }
  }

  String _resolveDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Error de conexión. Inténtalo nuevamente.';
    }

    return 'No fue posible cargar tus colegios.';
  }

  void addOrUpdateSchool(School school) {
    final currentSchools = [...state.schools];
    final schoolIndex = currentSchools.indexWhere(
      (item) => item.id == school.id,
    );

    if (schoolIndex >= 0) {
      currentSchools[schoolIndex] = school;
    } else {
      currentSchools.insert(0, school);
    }

    state = state.copyWith(
      schools: currentSchools,
      hasLoaded: true,
      errorMessages: const [],
    );
  }
}

class SchoolsState {
  final bool isLoading;
  final bool hasLoaded;
  final List<School> schools;
  final List<String> errorMessages;

  SchoolsState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.schools = const [],
    this.errorMessages = const [],
  });

  SchoolsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    List<School>? schools,
    List<String>? errorMessages,
  }) => SchoolsState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    schools: schools ?? this.schools,
    errorMessages: errorMessages ?? this.errorMessages,
  );
}

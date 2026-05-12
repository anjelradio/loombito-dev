import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/academic/data/data.dart';
import 'package:mobile/features/auth/auth.dart';

final academicApiProvider = Provider<AcademicApi>((ref) {
  final accessToken = ref.watch(
    authProvider.select((state) => state.user?.token ?? ''),
  );

  return AcademicApi(accessToken: accessToken);
});

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  final academicApi = ref.watch(academicApiProvider);
  return AcademicRepository(academicApi: academicApi);
});

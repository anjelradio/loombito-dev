import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/students/data/data.dart';

final studentApiProvider = Provider<StudentApi>((ref) {
  final accessToken = ref.watch(
    authProvider.select((state) => state.user?.token ?? ''),
  );
  return StudentApi(accessToken: accessToken);
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final api = ref.watch(studentApiProvider);
  return StudentRepository(studentApi: api);
});

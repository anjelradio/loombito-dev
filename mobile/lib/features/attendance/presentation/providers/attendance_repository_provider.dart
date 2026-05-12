import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/attendance/data/data.dart';
import 'package:mobile/features/auth/auth.dart';

final attendanceApiProvider = Provider<AttendanceApi>((ref) {
  final accessToken = ref.watch(
    authProvider.select((state) => state.user?.token ?? ''),
  );

  return AttendanceApi(accessToken: accessToken);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final api = ref.watch(attendanceApiProvider);
  return AttendanceRepository(attendanceApi: api);
});

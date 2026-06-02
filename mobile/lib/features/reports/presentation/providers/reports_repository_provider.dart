import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/reports/data/data.dart';

final reportsApiProvider = Provider<ReportsApi>((ref) {
  final accessToken = ref.watch(
    authProvider.select((state) => state.user?.token ?? ''),
  );
  return ReportsApi(accessToken: accessToken);
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final api = ref.watch(reportsApiProvider);
  return ReportsRepository(api: api);
});

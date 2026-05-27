import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/licenses/data/data.dart';

final licenseApiProvider = Provider<LicenseApi>((ref) {
  final accessToken = ref.watch(authProvider.select((state) => state.user?.token ?? ''));
  return LicenseApi(accessToken: accessToken);
});

final licenseRepositoryProvider = Provider<LicenseRepository>((ref) {
  final licenseApi = ref.watch(licenseApiProvider);
  return LicenseRepository(licenseApi: licenseApi);
});

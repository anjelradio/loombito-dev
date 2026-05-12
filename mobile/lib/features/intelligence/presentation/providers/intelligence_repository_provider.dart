import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/intelligence/data/data.dart';

final intelligenceApiProvider = Provider<IntelligenceApi>((ref) {
  final accessToken = ref.watch(
    authProvider.select((state) => state.user?.token ?? ''),
  );
  return IntelligenceApi(accessToken: accessToken);
});

final intelligenceRepositoryProvider = Provider<IntelligenceRepository>((ref) {
  final api = ref.watch(intelligenceApiProvider);
  return IntelligenceRepository(api: api);
});

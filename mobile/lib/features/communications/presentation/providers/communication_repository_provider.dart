import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/communications/data/data.dart';

final communicationApiProvider = Provider<CommunicationApi>((ref) {
  final accessToken = ref.watch(authProvider.select((state) => state.user?.token ?? ''));
  return CommunicationApi(accessToken: accessToken);
});

final communicationRepositoryProvider = Provider<CommunicationRepository>((ref) {
  final communicationApi = ref.watch(communicationApiProvider);
  return CommunicationRepository(communicationApi: communicationApi);
});

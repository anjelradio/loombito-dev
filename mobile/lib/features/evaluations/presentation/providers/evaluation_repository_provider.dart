import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/evaluations/data/data.dart';

final evaluationApiProvider = Provider<EvaluationApi>((ref) {
  final accessToken = ref.watch(
    authProvider.select((state) => state.user?.token ?? ''),
  );

  return EvaluationApi(accessToken: accessToken);
});

final evaluationRepositoryProvider = Provider<EvaluationRepository>((ref) {
  final evaluationApi = ref.watch(evaluationApiProvider);
  return EvaluationRepository(evaluationApi: evaluationApi);
});

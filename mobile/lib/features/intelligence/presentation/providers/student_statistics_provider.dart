import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/intelligence/domain/domain.dart';
import 'package:mobile/features/intelligence/presentation/providers/intelligence_repository_provider.dart';

typedef StudentStatisticsParams = ({String schoolId, String studentId});

final studentStatisticsProvider = FutureProvider.family<StudentStatistics, StudentStatisticsParams>((ref, params) async {
  final repository = ref.watch(intelligenceRepositoryProvider);
  return repository.getStudentStatistics(params.schoolId, params.studentId);
});

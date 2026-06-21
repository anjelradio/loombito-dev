import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mobile/features/reports/presentation/providers/reports_repository_provider.dart';

class StudentBoletinState {
  final bool isLoading;
  final bool hasError;
  StudentBoletinState({this.isLoading = false, this.hasError = false});
}

class StudentBoletinNotifier extends Notifier<StudentBoletinState> {
  @override
  StudentBoletinState build() {
    return StudentBoletinState();
  }

  Future<void> downloadBoletin(String studentId, String studentName) async {
    state = StudentBoletinState(isLoading: true);
    try {
      final repository = ref.read(reportsRepositoryProvider);
      final bytes = await repository.exportStudentBoletinForParent(studentId: studentId);
      final tempDir = await getTemporaryDirectory();
      final sanitizedName = studentName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final file = File('${tempDir.path}/boletin_$sanitizedName.pdf');
      
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
      state = StudentBoletinState();
    } catch (e) {
      state = StudentBoletinState(hasError: true);
    }
  }
}

final studentBoletinProvider = NotifierProvider<StudentBoletinNotifier, StudentBoletinState>(() {
  return StudentBoletinNotifier();
});

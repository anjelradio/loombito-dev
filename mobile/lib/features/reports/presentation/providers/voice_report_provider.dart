import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/reports/data/data.dart';
import 'package:mobile/features/reports/presentation/providers/providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

final voiceReportProvider =
    StateNotifierProvider<VoiceReportNotifier, VoiceReportState>((ref) {
  final repository = ref.watch(reportsRepositoryProvider);
  return VoiceReportNotifier(repository: repository);
});

class VoiceReportNotifier extends StateNotifier<VoiceReportState> {
  final ReportsRepository _repository;
  final AudioRecorder _recorder = AudioRecorder();

  VoiceReportNotifier({required ReportsRepository repository})
    : _repository = repository,
      super(VoiceReportState());

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      state = state.copyWith(errorMessage: 'Permiso de microfono denegado.');
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/report_audio.wav';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav),
      path: path,
    );

    state = state.copyWith(
      audioPath: path,
      isRecording: true,
      errorMessage: null,
      pdfBytes: null,
    );
  }

  Future<void> stopRecording() async {
    final path = await _recorder.stop();
    state = state.copyWith(
      audioPath: path,
      isRecording: false,
    );
  }

  Future<void> uploadAudio({
    required String schoolId,
    required String assignmentId,
    required String termId,
  }) async {
    if (state.audioPath == null) return;

    state = state.copyWith(isUploading: true, errorMessage: null);

    try {
      final pdfBytes = await _repository.exportClusterReportFromAudio(
        schoolId: schoolId,
        assignmentId: assignmentId,
        termId: termId,
        audioPath: state.audioPath!,
      );

      state = state.copyWith(isUploading: false, pdfBytes: pdfBytes);
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'No se pudo generar el reporte. Intentalo nuevamente.',
      );
    }
  }

  void reset() {
    state = VoiceReportState();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}

class VoiceReportState {
  final String? audioPath;
  final bool isRecording;
  final bool isUploading;
  final List<int>? pdfBytes;
  final String? errorMessage;

  VoiceReportState({
    this.audioPath,
    this.isRecording = false,
    this.isUploading = false,
    this.pdfBytes,
    this.errorMessage,
  });

  VoiceReportState copyWith({
    String? audioPath,
    bool? isRecording,
    bool? isUploading,
    List<int>? pdfBytes,
    String? errorMessage,
    bool clearAudioPath = false,
    bool clearPdfBytes = false,
    bool clearError = false,
  }) => VoiceReportState(
    audioPath: clearAudioPath ? null : (audioPath ?? this.audioPath),
    isRecording: isRecording ?? this.isRecording,
    isUploading: isUploading ?? this.isUploading,
    pdfBytes: clearPdfBytes ? null : (pdfBytes ?? this.pdfBytes),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

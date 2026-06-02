import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/reports/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class VoiceReportSheet extends ConsumerStatefulWidget {
  final String schoolId;
  final String assignmentId;
  final String termId;

  const VoiceReportSheet({
    super.key,
    required this.schoolId,
    required this.assignmentId,
    required this.termId,
  });

  @override
  ConsumerState<VoiceReportSheet> createState() => _VoiceReportSheetState();
}

class _VoiceReportSheetState extends ConsumerState<VoiceReportSheet> {
  Timer? _timer;
  int _recordedSeconds = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(voiceReportProvider.notifier).reset(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _recordedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordedSeconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _onStartRecording() async {
    await ref.read(voiceReportProvider.notifier).startRecording();
    if (mounted && ref.read(voiceReportProvider).isRecording) {
      _startTimer();
    }
  }

  Future<void> _onStopRecording() async {
    _stopTimer();
    await ref.read(voiceReportProvider.notifier).stopRecording();
  }

  Future<void> _onUpload() async {
    await ref.read(voiceReportProvider.notifier).uploadAudio(
      schoolId: widget.schoolId,
      assignmentId: widget.assignmentId,
      termId: widget.termId,
    );

    if (!mounted) return;

    final state = ref.read(voiceReportProvider);
    final bytes = state.pdfBytes;
    if (bytes == null || bytes.isEmpty) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/reporte_clasificacion.pdf';
      await File(filePath).writeAsBytes(bytes);
      await OpenFilex.open(filePath);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el PDF.'),
            backgroundColor: Color(0xFF9C2F2F),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceReportProvider);

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6FAFF), Color(0xFFEEF4FB)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC8D5E3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 10),
            _SheetHeader(onClose: () => Navigator.of(context).pop()),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    if (state.pdfBytes != null)
                      _SuccessCard(
                        onOpenPdf: _onUpload,
                        onClose: () => Navigator.of(context).pop(),
                      )
                    else if (state.isUploading)
                      const _UploadingIndicator()
                    else
                      _RecordingSection(
                        state: state,
                        recordedSeconds: _recordedSeconds,
                        formattedTime: _formatTime(_recordedSeconds),
                        onStartRecording: _onStartRecording,
                        onStopRecording: _onStopRecording,
                        onUpload: _onUpload,
                      ),
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _ErrorCard(
                          message: state.errorMessage!,
                          onRetry: () =>
                              ref.read(voiceReportProvider.notifier).reset(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _SheetHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderIconButton(
          icon: Icons.close_rounded,
          onTap: onClose,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reporte por voz',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF0F2C4F),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Graba tu consulta para generar un PDF',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5E6B7D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1F476E),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _RecordingSection extends StatelessWidget {
  final VoiceReportState state;
  final int recordedSeconds;
  final String formattedTime;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onUpload;

  const _RecordingSection({
    required this.state,
    required this.recordedSeconds,
    required this.formattedTime,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Presiona el boton para comenzar a grabar',
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF4B5563),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _RecordButton(
          isRecording: state.isRecording,
          onStart: onStartRecording,
          onStop: onStopRecording,
        ),
        const SizedBox(height: 20),
        if (state.isRecording)
          Text(
            formattedTime,
            style: textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF9C2F2F),
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        if (state.audioPath != null && !state.isRecording) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: const Color(0xFF1E6A3F),
              ),
              const SizedBox(width: 6),
              Text(
                'Audio grabado ($formattedTime)',
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF1E6A3F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: CustomFilledButton(
                text: 'Generar PDF',
                onPressed: onUpload,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const _RecordButton({
    required this.isRecording,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isRecording ? onStop : onStart,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording ? const Color(0xFF9C2F2F) : const Color(0xFF1F476E),
          boxShadow: [
            BoxShadow(
              color: (isRecording ? const Color(0xFF9C2F2F) : const Color(0xFF1F476E))
                  .withValues(alpha: 0.30),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isRecording
              ? Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                )
              : const Icon(Icons.mic_rounded, size: 40, color: Colors.white),
        ),
      ),
    );
  }
}

class _UploadingIndicator extends StatelessWidget {
  const _UploadingIndicator();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 20),
        Text(
          'Generando reporte...',
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Esto puede tomar unos segundos',
          style: textTheme.bodySmall?.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final VoidCallback onOpenPdf;
  final VoidCallback onClose;

  const _SuccessCard({required this.onOpenPdf, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE6F7EC),
          ),
          child: const Icon(
            Icons.description_rounded,
            size: 40,
            color: Color(0xFF1E6A3F),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Reporte generado',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF0F2C4F),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'El PDF se ha generado correctamente.',
          style: textTheme.bodySmall?.copyWith(
            color: const Color(0xFF4B5563),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: CustomFilledButton(
            text: 'Abrir PDF',
            onPressed: onOpenPdf,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: CustomFilledButton(
            text: 'Cerrar',
            buttonColor: const Color(0xFFFDECEC),
            textColor: const Color(0xFF9F2F2F),
            onPressed: onClose,
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE8E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 20,
                color: Color(0xFF9C2F2F),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9C2F2F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: CustomFilledButton(
              text: 'Intentar de nuevo',
              buttonColor: const Color(0xFF9C2F2F),
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

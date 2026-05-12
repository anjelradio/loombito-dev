import 'package:flutter/material.dart';

class AppInstitutionalBackground extends StatelessWidget {
  final Widget child;

  const AppInstitutionalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF2FA), Color(0xFFF8FBFF)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _NotebookGridPainter()),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: _GridFadeOverlay()),
          ),
          const Positioned(top: -110, right: -70, child: _BackgroundGlow()),
          const Positioned(bottom: 110, left: -120, child: _BackgroundRing()),
          const Positioned(bottom: -140, right: -90, child: _BackgroundGlow()),
          child,
        ],
      ),
    );
  }
}

class _GridFadeOverlay extends StatelessWidget {
  const _GridFadeOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFEAF2FA).withValues(alpha: 0.14),
            const Color(0xFFEAF2FA).withValues(alpha: 0.66),
            const Color(0xFFF8FBFF).withValues(alpha: 0.22),
            const Color(0xFFF8FBFF).withValues(alpha: 0.74),
            const Color(0xFFF8FBFF).withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.20, 0.45, 0.72, 1.0],
        ),
      ),
    );
  }
}

class _NotebookGridPainter extends CustomPainter {
  const _NotebookGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 28.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF1E4A75).withValues(alpha: 0.10);

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF5C89B6).withValues(alpha: 0.16),
        ),
      ),
    );
  }
}

class _BackgroundRing extends StatelessWidget {
  const _BackgroundRing();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF6A8CAD).withValues(alpha: 0.16),
            width: 34,
          ),
        ),
      ),
    );
  }
}

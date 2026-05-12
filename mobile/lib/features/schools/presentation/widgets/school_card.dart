import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/schools/domain/domain.dart';

class SchoolCard extends StatelessWidget {
  final School school;
  final bool enabled;

  const SchoolCard({super.key, required this.school, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final palette = _SchoolCardPalette.fromType(school.type);

    const radius = BorderRadius.all(Radius.circular(20));

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: radius,
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFF1F476E).withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFF1F476E).withValues(alpha: 0.04);
          }
          return null;
        }),
        onTap: !enabled
            ? null
            : () {
                context.push('/schools/${school.id}/home');
              },
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(color: const Color(0xFFD6E3F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2C4F).withValues(alpha: 0.18),
                blurRadius: 26,
                spreadRadius: 0.8,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardBanner(school: school, palette: palette),
              Ink(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF5F9FD), Color(0xFFEFF5FB)],
                  ),
                  border: Border(
                    top: BorderSide(color: Color(0xFFDCE8F4), width: 1),
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACTIVIDADES RECIENTES',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _ActivityRow(
                      icon: Icons.event_note_outlined,
                      text: 'Revisa novedades del colegio',
                    ),
                    const SizedBox(height: 10),
                    const _ActivityRow(
                      icon: Icons.mail_outline,
                      text: 'Mensajes y avisos institucionales',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBanner extends StatelessWidget {
  final School school;
  final _SchoolCardPalette palette;

  const _CardBanner({required this.school, required this.palette});

  @override
  Widget build(BuildContext context) {
    final typeLabel = _typeLabel(school.type);
    final hasLogo = (school.logoImage ?? '').trim().isNotEmpty;

    return Ink(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.start, palette.end],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  school.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  typeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                ),
                if (hasLogo)
                  Positioned.fill(
                    child: ClipOval(
                      child: Image.network(
                        school.logoImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    final normalizedType = type.trim().toLowerCase();
    if (normalizedType == 'public') return 'Colegio publico';
    if (normalizedType == 'private') return 'Colegio privado';
    if (normalizedType == 'charter') return 'Colegio de convenio';
    return 'Institucion educativa';
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ActivityRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SchoolCardPalette {
  final Color start;
  final Color end;

  const _SchoolCardPalette({required this.start, required this.end});

  factory _SchoolCardPalette.fromType(String type) {
    final normalizedType = type.trim().toLowerCase();

    if (normalizedType == 'public') {
      return const _SchoolCardPalette(
        start: Color(0xFF275443),
        end: Color(0xFF3F7A61),
      );
    }

    if (normalizedType == 'charter') {
      return const _SchoolCardPalette(
        start: Color(0xFF6A2A2A),
        end: Color(0xFF9B4A38),
      );
    }

    return const _SchoolCardPalette(
      start: Color(0xFF0F2C4F),
      end: Color(0xFF1F476E),
    );
  }
}

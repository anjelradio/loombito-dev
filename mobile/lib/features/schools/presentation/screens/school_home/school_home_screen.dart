import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/academic/academic.dart';
import 'package:mobile/features/schools/domain/domain.dart';
import 'package:mobile/features/schools/presentation/providers/providers.dart';
import 'package:mobile/features/schools/presentation/widgets/school_home/school_home.dart';
import 'package:mobile/features/shared/shared.dart';

class SchoolHomeScreen extends ConsumerStatefulWidget {
  final String schoolId;

  const SchoolHomeScreen({super.key, required this.schoolId});

  @override
  ConsumerState<SchoolHomeScreen> createState() => _SchoolHomeScreenState();
}

class _SchoolHomeScreenState extends ConsumerState<SchoolHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(schoolsProvider.notifier).loadSchools());
    Future.microtask(
      () => ref
          .read(teacherAssignmentsProvider.notifier)
          .loadTeacherAssignmentGroups(widget.schoolId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolsState = ref.watch(schoolsProvider);
    School? school;
    for (final item in schoolsState.schools) {
      if (item.id == widget.schoolId) {
        school = item;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      body: AppInstitutionalBackground(
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            children: [
              const SchoolHomeHeader(),
              const SizedBox(height: 16),
              _SchoolHeroSection(school: school),
              const SizedBox(height: 16),
              Text(
                'Panel docente',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF0F2C4F),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Selecciona un modulo para gestionar tu trabajo academico.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 14),
              SchoolHomeModeActionCard(
                schoolId: widget.schoolId,
                mode: TeacherAssignmentMode.evaluations,
                title: 'Evaluaciones',
                description:
                    'Registra, revisa y comparte evaluaciones del curso.',
                icon: Icons.fact_check_outlined,
                startColor: const Color(0xFF0F2C4F),
                endColor: const Color(0xFF1F476E),
                height: 178,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SchoolHomeModeActionCard(
                      schoolId: widget.schoolId,
                      mode: TeacherAssignmentMode.attendance,
                      title: 'Asistencias',
                      description: 'Control diario de asistencias.',
                      icon: Icons.how_to_reg_rounded,
                      startColor: const Color(0xFF2E5B35),
                      endColor: const Color(0xFF3F7A61),
                      height: 166,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SchoolHomeModeActionCard(
                      schoolId: widget.schoolId,
                      mode: TeacherAssignmentMode.averages,
                      title: 'Promedios',
                      description: 'Consulta y calcula promedios.',
                      icon: Icons.bar_chart_rounded,
                      startColor: const Color(0xFF6A2A2A),
                      endColor: const Color(0xFF9B4A38),
                      height: 166,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.64),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD8E5F2)),
                ),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF1F476E),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pronto podras personalizar este panel con modulos del colegio.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF35597E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

class _SchoolHeroSection extends StatelessWidget {
  final School? school;

  const _SchoolHeroSection({required this.school});

  @override
  Widget build(BuildContext context) {
    final hasImage = (school?.logoImage ?? '').trim().isNotEmpty;

    return Container(
      height: 176,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2C4F), Color(0xFF1E4A75)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2C4F).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (hasImage)
            Positioned.fill(
              child: Image.network(
                school!.logoImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: hasImage ? 0.16 : 0.0),
                    Colors.black.withValues(alpha: hasImage ? 0.42 : 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -36,
            right: -22,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -48,
            left: -24,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Text(
                    'Entorno academico',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  school?.name ?? 'Mi colegio',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasImage
                      ? 'Panel institucional personalizado'
                      : 'Panel institucional listo para personalizar',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

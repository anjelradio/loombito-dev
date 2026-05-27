import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/home/presentation/models/home_linked_section.dart';
import 'package:mobile/features/home/presentation/widgets/home_linked_bottom_navigation.dart';
import 'package:mobile/features/schools/schools.dart';
import 'package:mobile/features/shared/shared.dart';
import 'package:mobile/features/students/students.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  HomeLinkedSection _selectedSection = HomeLinkedSection.schools;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(schoolsProvider.notifier).loadSchools();
      ref.read(linkedStudentsProvider.notifier).loadLinkedStudents();
    });
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade800),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(schoolsProvider, (previous, next) {
      final hasError = next.errorMessages.isNotEmpty;
      final previousError =
          previous != null && previous.errorMessages.isNotEmpty ? previous.errorMessages.first : null;
      final currentError = hasError ? next.errorMessages.first : null;

      if (!hasError || previousError == currentError) return;
      _showErrorSnackbar(context, currentError!);
    });

    ref.listen(linkedStudentsProvider, (previous, next) {
      final hasError = next.errorMessages.isNotEmpty;
      final previousError =
          previous != null && previous.errorMessages.isNotEmpty ? previous.errorMessages.first : null;
      final currentError = hasError ? next.errorMessages.first : null;

      if (!hasError || previousError == currentError) return;
      _showErrorSnackbar(context, currentError!);
    });

    final schoolsState = ref.watch(schoolsProvider);
    final studentsState = ref.watch(linkedStudentsProvider);

    final hasSchools = schoolsState.schools.isNotEmpty;
    final hasStudents = studentsState.students.isNotEmpty;
    final hasBoth = hasSchools && hasStudents;
    final isLoading = schoolsState.isLoading || studentsState.isLoading;
    final activeSection = _activeSection(hasSchools, hasStudents);
    final heroTitle = activeSection == HomeLinkedSection.schools
        ? 'Mis colegios'
        : 'Mis estudiantes';
    final heroSubtitle = activeSection == HomeLinkedSection.schools
        ? 'Bienvenido. Aqui puedes ver tus instituciones vinculadas.'
        : 'Bienvenido. Aqui puedes ver tus estudiantes vinculados.';

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const SchoolsJoinButton(),
      bottomNavigationBar: hasBoth
          ? HomeLinkedBottomNavigation(
              selectedSection: _selectedSection,
              onChanged: (section) {
                setState(() => _selectedSection = section);
              },
            )
          : null,
      body: AppInstitutionalBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MainHeader(),
                const SizedBox(height: 18),
                MainHeroSection(title: heroTitle, subtitle: heroSubtitle),
                const SizedBox(height: 14),
                Expanded(
                  child: isLoading
                      ? const SchoolsSkeletonList()
                      : _buildContent(
                          hasSchools: hasSchools,
                          hasStudents: hasStudents,
                          schoolsState: schoolsState,
                          studentsState: studentsState,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required bool hasSchools,
    required bool hasStudents,
    required SchoolsState schoolsState,
    required LinkedStudentsState studentsState,
  }) {
    final showSchools = _shouldShowSchools(hasSchools, hasStudents);

    if (showSchools) {
      if (!hasSchools) {
        return _HomeEmptyState(
          kind: _HomeEmptyKind.schools,
          onRetry: () => ref.read(schoolsProvider.notifier).loadSchools(),
        );
      }

      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: schoolsState.schools.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return SchoolCard(school: schoolsState.schools[index]);
        },
      );
    }

    if (!hasStudents) {
      return _HomeEmptyState(
        kind: _HomeEmptyKind.students,
        onRetry: () => ref.read(linkedStudentsProvider.notifier).loadLinkedStudents(),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: studentsState.students.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return LinkedStudentCard(student: studentsState.students[index]);
      },
    );
  }

  bool _shouldShowSchools(bool hasSchools, bool hasStudents) {
    if (hasSchools && !hasStudents) return true;
    if (!hasSchools && hasStudents) return false;
    return _selectedSection == HomeLinkedSection.schools;
  }

  HomeLinkedSection _activeSection(bool hasSchools, bool hasStudents) {
    if (hasSchools && !hasStudents) return HomeLinkedSection.schools;
    if (!hasSchools && hasStudents) return HomeLinkedSection.students;
    return _selectedSection;
  }
}

enum _HomeEmptyKind { schools, students }

class _HomeEmptyState extends StatelessWidget {
  final _HomeEmptyKind kind;
  final VoidCallback onRetry;

  const _HomeEmptyState({required this.kind, required this.onRetry});

  String get _description {
    if (kind == _HomeEmptyKind.students) {
      return 'Aqui apareceran tus estudiantes vinculados. Usa el boton inferior para vincularte con un codigo.';
    }
    return 'Aqui apareceran tus colegios vinculados. Comienza usando el boton inferior para unirte a una institucion.';
  }

  Widget _buildTopCard() {
    if (kind == _HomeEmptyKind.students) {
      return const _StudentsEmptyStateCard();
    }
    return const SchoolsEmptyStateCard();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildTopCard(),
            const SizedBox(height: 26),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                'Bienvenido a LoomBo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                _description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4B5563),
                      height: 1.45,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

class _StudentsEmptyStateCard extends StatelessWidget {
  const _StudentsEmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD5E2F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1F476E).withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care_outlined, color: Color(0xFF1F476E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aun no tienes estudiantes vinculados',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1E3A5F),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

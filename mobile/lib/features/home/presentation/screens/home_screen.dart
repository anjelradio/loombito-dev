import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/schools/schools.dart';
import 'package:mobile/features/shared/shared.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(schoolsProvider.notifier).loadSchools());
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
          previous != null && previous.errorMessages.isNotEmpty
          ? previous.errorMessages.first
          : null;
      final currentError = hasError ? next.errorMessages.first : null;

      if (!hasError || previousError == currentError) return;
      _showErrorSnackbar(context, currentError!);
    });

    final schoolsState = ref.watch(schoolsProvider);
    final hasSchools = schoolsState.schools.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const SchoolsJoinButton(),
      body: AppInstitutionalBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MainHeader(),
                const SizedBox(height: 18),
                const MainHeroSection(),
                const SizedBox(height: 14),
                Expanded(
                  child: schoolsState.isLoading
                      ? const SchoolsSkeletonList()
                      : hasSchools
                      ? ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: schoolsState.schools.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            return SchoolCard(
                              school: schoolsState.schools[index],
                            );
                          },
                        )
                      : _HomeEmptyState(
                          onRetry: () {
                            ref.read(schoolsProvider.notifier).loadSchools();
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _HomeEmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SchoolsEmptyStateCard(),
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
                'Aqui apareceran tus colegios vinculados. Comienza usando el boton inferior para unirte a una institucion.',
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

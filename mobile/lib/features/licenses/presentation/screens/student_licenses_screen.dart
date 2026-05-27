import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/licenses/presentation/providers/providers.dart';
import 'package:mobile/features/licenses/presentation/widgets/widgets.dart';
import 'package:mobile/features/shared/shared.dart';

class StudentLicensesScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String studentId;
  final String? studentName;

  const StudentLicensesScreen({
    super.key,
    required this.schoolId,
    required this.studentId,
    this.studentName,
  });

  @override
  ConsumerState<StudentLicensesScreen> createState() => _StudentLicensesScreenState();
}

class _StudentLicensesScreenState extends ConsumerState<StudentLicensesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(studentLicensesProvider.notifier).load(widget.schoolId, widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentLicensesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      floatingActionButton: RegisterLicenseFabButton(
        schoolId: widget.schoolId,
        studentId: widget.studentId,
        onCreated: () {
          ref.read(studentLicensesProvider.notifier).load(
                widget.schoolId,
                widget.studentId,
                forceRefresh: true,
              );
        },
      ),
      body: AppInstitutionalBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppCircleIconButton(onPressed: context.pop, icon: Icons.arrow_back_ios_new_rounded),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Licencias',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF0F2C4F),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if ((widget.studentName ?? '').trim().isNotEmpty)
                  Text(
                    widget.studentName!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF35597E),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFD8E5F2)),
                              ),
                              child: Text(
                                'Licencias registradas: ${state.licenses.length}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF1E3A5F),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (state.licenses.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFD8E5F2)),
                                ),
                                child: Text(
                                  'Aun no hay licencias registradas para este estudiante.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF4B5563),
                                      ),
                                ),
                              )
                            else
                              ...state.licenses.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FBFF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFD5E3F3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _reasonLabel(item.reason),
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                color: const Color(0xFF1F4D7D),
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.startDate} - ${item.endDate}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: const Color(0xFF6A8CB2),
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(item.description, style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
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
      ),
    );
  }

  String _reasonLabel(String reason) {
    switch (reason) {
      case 'illness':
        return 'Enfermedad';
      case 'travel':
        return 'Viaje';
      case 'personal':
        return 'Personal';
      default:
        return reason;
    }
  }
}

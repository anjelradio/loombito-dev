import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/payments/presentation/providers/student_debts_provider.dart';
import 'package:mobile/features/payments/presentation/widgets/empty_debts_view.dart';
import 'package:mobile/features/payments/presentation/widgets/student_debt_list_item.dart';
import 'package:mobile/features/payments/presentation/widgets/pay_debt_qr_sheet.dart';

class StudentDebtsScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String studentId;
  final String studentName;

  const StudentDebtsScreen({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
  });

  @override
  ConsumerState<StudentDebtsScreen> createState() => _StudentDebtsScreenState();
}

class _StudentDebtsScreenState extends ConsumerState<StudentDebtsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studentDebtsProvider(widget.studentId).notifier).loadDebts(widget.schoolId, widget.studentId);
    });
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF1F476E)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(studentDebtsProvider(widget.studentId).notifier).loadDebts(widget.schoolId, widget.studentId),
              child: const Text('Reintentar'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentDebtsProvider(widget.studentId));

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FAFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F476E), size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Estado de cuenta',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF0F2C4F),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              widget.studentName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4C6480),
                  ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F476E)))
          : state.hasError
              ? _buildErrorView(context, state.errorMessage)
              : state.debts.isEmpty
                  ? const EmptyDebtsView()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.debts.length,
                      itemBuilder: (context, index) {
                        final debt = state.debts[index];
                        return StudentDebtListItem(
                          debt: debt,
                          onPayPressed: () async {
                            final result = await showPayDebtQrSheet(context, debt);
                            if (result == true) {
                              final success = await ref.read(studentDebtsProvider(widget.studentId).notifier).payDebt(widget.schoolId, widget.studentId, debt.id);
                              if (!context.mounted) return;
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pago registrado correctamente'),
                                    backgroundColor: Color.fromARGB(255, 31, 110, 69),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Error al registrar el pago'),
                                    backgroundColor: Colors.red.shade800,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
    );
  }
}

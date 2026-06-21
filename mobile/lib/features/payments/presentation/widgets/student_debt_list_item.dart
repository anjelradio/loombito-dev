import 'package:flutter/material.dart';
import 'package:mobile/features/payments/domain/entities/student_debt.dart';
import 'package:mobile/features/shared/shared.dart';

class StudentDebtListItem extends StatelessWidget {
  final StudentDebt debt;
  final VoidCallback onPayPressed;

  const StudentDebtListItem({
    super.key,
    required this.debt,
    required this.onPayPressed,
  });

  String _getMonthName(int month) {
    const months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final periodText = debt.billingMonth != null && debt.billingYear != null
        ? '${_getMonthName(debt.billingMonth!)} ${debt.billingYear}'
        : 'Pago Único';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2C8C8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB84F4F).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PENDIENTE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB84F4F),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      debt.conceptName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7D1F1F),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF2C8C8)),
                ),
                child: Text(
                  'Bs. ${debt.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB84F4F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Color(0xFFB84F4F)),
                const SizedBox(width: 4),
                Text(
                  periodText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7D1F1F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomFilledButton(
              text: 'Pagar',
              buttonColor: const Color(0xFFB84F4F),
              textColor: Colors.white,
              onPressed: onPayPressed,
            ),
          ),
        ],
      ),
    );
  }
}

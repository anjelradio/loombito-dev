import 'package:flutter/material.dart';
import 'package:mobile/features/attendance/domain/domain.dart';
import 'package:mobile/features/shared/shared.dart';

class AttendanceSessionInfoCard extends StatelessWidget {
  final AttendanceSession session;
  final bool isFinalizing;
  final VoidCallback onFinalize;

  const AttendanceSessionInfoCard({
    super.key,
    required this.session,
    required this.isFinalizing,
    required this.onFinalize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Fecha', value: session.attendanceDate),
          _InfoRow(label: 'Trimestre', value: session.termName),
          _InfoRow(
            label: 'Estado',
            value: session.isClosed ? 'Finalizada' : 'Abierta',
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: CustomFilledButton(
              text: session.isClosed
                  ? 'Sesion finalizada'
                  : isFinalizing
                  ? 'Finalizando...'
                  : 'Finalizar asistencia',
              onPressed: session.isClosed || isFinalizing ? null : onFinalize,
              buttonColor: session.isClosed ? const Color(0xFFDCE8F5) : null,
              textColor: session.isClosed ? const Color(0xFF345B86) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF1F476E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

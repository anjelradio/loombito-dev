import 'package:flutter/material.dart';
import 'package:mobile/features/attendance/domain/domain.dart';
import 'package:mobile/features/attendance/presentation/widgets/attendance_list_item_card.dart';

class AttendanceSessionsListCard extends StatelessWidget {
  final List<AttendanceSession> sessions;
  final void Function(AttendanceSession session) onTapSession;

  const AttendanceSessionsListCard({
    super.key,
    required this.sessions,
    required this.onTapSession,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asistencias',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF0F2C4F),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (sessions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No hay asistencias registradas para esta materia.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF4B5563)),
              ),
            )
          else
            ...sessions.map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AttendanceListItemCard(
                  session: session,
                  onTap: () => onTapSession(session),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

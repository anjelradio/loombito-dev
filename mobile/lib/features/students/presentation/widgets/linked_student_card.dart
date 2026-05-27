import 'package:flutter/material.dart';
import 'package:mobile/features/licenses/licenses.dart';
import 'package:mobile/features/students/domain/domain.dart';

class LinkedStudentCard extends StatelessWidget {
  final LinkedStudent student;

  const LinkedStudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(20));

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: radius,
        onTap: () async {
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => StudentActionsSheet(student: student),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(color: const Color(0xFFD6E3F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2C4F).withValues(alpha: 0.14),
                blurRadius: 22,
                spreadRadius: 0.6,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Ink(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D4B6A), Color(0xFF476D96)],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.child_care_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${student.lastName} ${student.firstName}'.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            student.schoolName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.94),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Ink(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF5F9FD), Color(0xFFEFF5FB)],
                  ),
                  border: Border(top: BorderSide(color: Color(0xFFDCE8F4), width: 1)),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DETALLES',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.account_balance_outlined,
                      text: student.schoolName,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.class_outlined,
                      text: student.courseName?.trim().isNotEmpty == true
                          ? student.courseName!
                          : 'Sin curso asignado',
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

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

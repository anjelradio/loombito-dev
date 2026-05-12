import 'package:flutter/material.dart';

class TeacherAssignmentTileIcon extends StatelessWidget {
  final IconData icon;

  const TeacherAssignmentTileIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0F8),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFD2E0EF)),
      ),
      child: Icon(icon, color: const Color(0xFF1F476E), size: 20),
    );
  }
}

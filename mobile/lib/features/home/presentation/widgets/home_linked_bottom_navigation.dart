import 'package:flutter/material.dart';
import 'package:mobile/features/home/presentation/models/home_linked_section.dart';

class HomeLinkedBottomNavigation extends StatelessWidget {
  final HomeLinkedSection selectedSection;
  final ValueChanged<HomeLinkedSection> onChanged;

  const HomeLinkedBottomNavigation({
    super.key,
    required this.selectedSection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        border: const Border(top: BorderSide(color: Color(0xFFD9E3EE))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2C4F).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: 66,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: const Color(0xFFDCE9F7),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textStyle?.copyWith(color: const Color(0xFF153B64));
          }
          return textStyle?.copyWith(color: const Color(0xFF64748B));
        }),
        selectedIndex: selectedSection == HomeLinkedSection.schools ? 0 : 1,
        onDestinationSelected: (index) {
          onChanged(index == 0 ? HomeLinkedSection.schools : HomeLinkedSection.students);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Colegios',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Estudiantes',
          ),
        ],
      ),
    );
  }
}

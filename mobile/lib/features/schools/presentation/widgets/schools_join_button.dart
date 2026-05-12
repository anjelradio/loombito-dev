import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/shared/shared.dart';

class SchoolsJoinButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SchoolsJoinButton({super.key, this.onPressed});

  Future<void> _openJoinOptionsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unirse o vincularse',
                  style: Theme.of(sheetContext).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF0F2C4F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecciona como quieres vincular tu cuenta.',
                  style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: CustomFilledButton(
                    text: 'Unirse a un colegio',
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.push('/join/school-code');
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: CustomFilledButton(
                    text: 'Vincularse a un estudiante',
                    buttonColor: const Color(0xFFE4EBF4),
                    textColor: const Color(0xFF1F476E),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _showComingSoonSnackbar(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComingSoonSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Proximamente podras vincularte a un estudiante.'),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalPageFabButton(
      onTap: onPressed ?? () => _openJoinOptionsSheet(context),
      text: 'Unirse o vincular codigo',
      icon: Icons.add,
    );
  }
}

import 'package:flutter/material.dart';

class EmptyDebtsView extends StatelessWidget {
  const EmptyDebtsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F1FC),
              shape: BoxShape.circle,
            ),
            child: const Text('🎉', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Al día!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF0F2C4F),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'El estudiante no tiene ninguna\ndeuda pendiente.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4C6480),
                ),
          ),
        ],
      ),
    );
  }
}

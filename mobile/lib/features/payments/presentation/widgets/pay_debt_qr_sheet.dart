import 'package:flutter/material.dart';
import 'package:mobile/features/payments/domain/entities/student_debt.dart';
import 'package:mobile/features/shared/shared.dart';

Future<bool?> showPayDebtQrSheet(BuildContext context, StudentDebt debt) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PayDebtQrSheetContent(debt: debt),
  );
}

class _PayDebtQrSheetContent extends StatefulWidget {
  final StudentDebt debt;

  const _PayDebtQrSheetContent({required this.debt});

  @override
  State<_PayDebtQrSheetContent> createState() => _PayDebtQrSheetContentState();
}

class _PayDebtQrSheetContentState extends State<_PayDebtQrSheetContent> {
  bool _isLoadingQr = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isLoadingQr = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pagar por QR',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF0F2C4F),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escanea este código para pagar la deuda.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF4B5563)),
            ),
            const SizedBox(height: 12),
            Text(
              'Bs. ${widget.debt.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB84F4F),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Center(
                child: _isLoadingQr
                    ? const CircularProgressIndicator(color: Color(0xFF1F476E))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/qr.jpg',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomFilledButton(
                      text: 'Cancelar',
                      buttonColor: const Color(0xFFE4EBF4),
                      textColor: const Color(0xFF1F476E),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFilledButton(
                      text: 'Ya pagué',
                      onPressed: _isLoadingQr ? null : () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}

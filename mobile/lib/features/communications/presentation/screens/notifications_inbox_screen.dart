import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/communications/domain/domain.dart';
import 'package:mobile/features/communications/presentation/providers/providers.dart';
import 'package:mobile/features/shared/shared.dart';

class NotificationsInboxScreen extends ConsumerStatefulWidget {
  const NotificationsInboxScreen({super.key});

  @override
  ConsumerState<NotificationsInboxScreen> createState() =>
      _NotificationsInboxScreenState();
}

class _NotificationsInboxScreenState
    extends ConsumerState<NotificationsInboxScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      body: AppInstitutionalBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppCircleIconButton(
                      onPressed: context.pop,
                      icon: Icons.arrow_back_ios_new_rounded,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Notificaciones',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF0F2C4F),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFD8E5F2)),
                              ),
                              child: Text(
                                'Pendientes: ${state.notifications.where((item) => !item.isRead).length}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF1E3A5F),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (state.notifications.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFD8E5F2)),
                                ),
                                child: Text(
                                  'No tienes notificaciones pendientes.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              )
                            else
                              ...state.notifications.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _NotificationCard(item: item),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final CommunicationNotification item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final markRead = await showDialog<bool>(
            context: context,
            builder: (_) => AppDialogShell(
              title: item.title,
              description: item.body,
              onCancel: () => Navigator.of(context).pop(false),
              cancelText: 'Cerrar',
              child: SizedBox(
                width: double.infinity,
                child: CustomFilledButton(
                  text: 'Marcar como visto',
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ),
          );

          if (markRead != true || !context.mounted) return;

          await ref.read(notificationsProvider.notifier).markAsReadLocally(item.id);
        },
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: item.isRead ? const Color(0xFFF2F7FD) : const Color(0xFFF8FBFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD5E3F3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF1F4D7D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.isRead ? 'Vista' : 'No leida',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: item.isRead ? const Color(0xFF35597E) : const Color(0xFF9F2D2D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          asyncData.maybeWhen(
            data: (d) => d.items.any((n) => !n.isRead)
                ? TextButton(
                    onPressed: () async {
                      await ref.read(notificationsRepositoryProvider).markAllRead();
                      ref.invalidate(notificationsProvider);
                      ref.invalidate(unreadCountProvider);
                    },
                    child: const Text('Mark all read'),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (d) => d.items.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications',
                subtitle: 'You\'re all caught up!',
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  ref.invalidate(notificationsProvider);
                  ref.invalidate(unreadCountProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: d.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _NotificationTile(
                    notification: d.items[i],
                    onTap: () async {
                      final n = d.items[i];
                      if (!n.isRead) {
                        await ref.read(notificationsRepositoryProvider).markRead(n.id);
                        ref.invalidate(notificationsProvider);
                        ref.invalidate(unreadCountProvider);
                      }
                      if (context.mounted && n.routePath != null) {
                        context.push(n.routePath!);
                      }
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (notification.type) {
      'new_message' => (Icons.chat_bubble_outline_rounded, AppColors.primary),
      'new_comment' => (Icons.forum_outlined, AppColors.accent),
      _ => (Icons.notifications_outlined, AppColors.textSecondary),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Theme.of(context).cardColor
              : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _timeAgo(notification.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}

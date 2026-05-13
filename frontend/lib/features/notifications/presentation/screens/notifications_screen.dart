import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _mockNotifications = [
    _NotifData(
      icon: Icons.local_offer_outlined,
      title: 'New offer on your issue',
      subtitle: 'Al-Riyadh Garage sent you an offer for your AC repair request.',
      time: '2m ago',
      color: AppColors.primary,
    ),
    _NotifData(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'New message',
      subtitle: 'You have a new message from Parts World.',
      time: '1h ago',
      color: AppColors.accent,
    ),
    _NotifData(
      icon: Icons.check_circle_outline,
      title: 'Listing approved',
      subtitle: 'Your Toyota Camry 2019 listing is now live.',
      time: '3h ago',
      color: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _mockNotifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications',
              subtitle: 'You\'re all caught up!',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _mockNotifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _NotificationTile(data: _mockNotifications[i]),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _NotifData data;
  const _NotificationTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(data.subtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(data.time, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _NotifData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  const _NotifData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
}

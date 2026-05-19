import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notifications_repository.dart';

final notificationsProvider = FutureProvider<({List<NotificationModel> items, int unreadCount})>(
  (ref) => ref.read(notificationsRepositoryProvider).getNotifications(),
);

final unreadCountProvider = FutureProvider<int>(
  (ref) => ref.read(notificationsRepositoryProvider).getUnreadCount(),
);

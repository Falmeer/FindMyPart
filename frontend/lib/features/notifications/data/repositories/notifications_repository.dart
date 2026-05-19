import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  final ApiClient _api;
  NotificationsRepository(this._api);

  Future<({List<NotificationModel> items, int unreadCount})> getNotifications() async {
    final res = await _api.get('/notifications');
    final list = (res.data['data'] as List)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final unread = res.data['unread_count'] as int? ?? 0;
    return (items: list, unreadCount: unread);
  }

  Future<int> getUnreadCount() async {
    final res = await _api.get('/notifications/unread-count');
    return res.data['data']['count'] as int? ?? 0;
  }

  Future<void> markRead(String id) async {
    await _api.post('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _api.post('/notifications/read-all');
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.read(apiClientProvider)),
);

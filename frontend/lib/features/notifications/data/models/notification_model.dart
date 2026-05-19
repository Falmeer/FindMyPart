class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'unknown',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: data,
      isRead: json['read_at'] != null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String? get routePath {
    switch (type) {
      case 'new_message':
        final chatId = data['chat_id'];
        final senderName = Uri.encodeComponent(data['sender_name'] as String? ?? 'User');
        if (chatId != null) return '/conversations/$chatId?name=$senderName';
      case 'new_comment':
        final issueId = data['issue_id'];
        if (issueId != null) return '/issues/$issueId';
    }
    return null;
  }
}

class ConversationModel {
  final int id;
  final String participantName;
  final String? participantAvatar;
  final String? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const ConversationModel({
    required this.id,
    required this.participantName,
    this.participantAvatar,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) => ConversationModel(
        id: json['id'] as int,
        participantName: json['participant']?['name'] as String? ?? 'Unknown',
        participantAvatar: json['participant']?['avatar'] as String?,
        lastMessage: json['last_message']?['body'] as String?,
        unreadCount: json['unread_count'] as int? ?? 0,
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class MessageModel {
  final int id;
  final String body;
  final String? attachmentUrl;
  final int senderId;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.body,
    this.attachmentUrl,
    required this.senderId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as int,
        body: json['body'] as String? ?? '',
        attachmentUrl: json['attachment_url'] as String?,
        senderId: json['sender_id'] as int,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

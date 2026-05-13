import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/conversation_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.read(apiClientProvider));
});

class ChatRepository {
  final ApiClient _client;
  ChatRepository(this._client);

  Future<List<ConversationModel>> getConversations() async {
    final response = await _client.get('/conversations');
    final data = response.data['data'] as List;
    return data.map((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MessageModel>> getMessages(int chatId, {int? afterId}) async {
    final response = await _client.get(
      '/conversations/$chatId/messages',
      queryParameters: afterId != null ? {'after_id': afterId} : null,
    );
    final data = response.data['data'] as List;
    return data.map((e) {
      final map = e as Map<String, dynamic>;
      return MessageModel.fromJson({
        ...map,
        'attachment_url': _fixUrl(map['attachment_url'] as String?),
      });
    }).toList();
  }

  Future<MessageModel> sendMessage(
    int chatId, {
    String body = '',
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final Response response;
    if (imageBytes != null) {
      final formData = FormData.fromMap({
        if (body.isNotEmpty) 'body': body,
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: imageName ?? 'image.jpg',
        ),
      });
      response = await _client.postMultipart('/conversations/$chatId/messages', formData);
    } else {
      response = await _client.post(
        '/conversations/$chatId/messages',
        data: {'body': body},
      );
    }
    final map = response.data['data'] as Map<String, dynamic>;
    return MessageModel.fromJson({
      ...map,
      'attachment_url': _fixUrl(map['attachment_url'] as String?),
    });
  }

  Future<int> findOrCreateChat(int recipientId) async {
    final response = await _client.post(
      '/conversations',
      data: {'recipient_id': recipientId},
    );
    return response.data['data']['id'] as int;
  }

  /// Replaces the host baked into stored URLs with the current backend host,
  /// so images load correctly on both iOS simulator and Android emulator.
  static String? _fixUrl(String? url) {
    if (url == null) return null;
    final backendBase = AppConstants.baseUrl.replaceFirst('/api/v1', '');
    return url.replaceFirst(RegExp(r'https?://[^/]+'), backendBase);
  }
}

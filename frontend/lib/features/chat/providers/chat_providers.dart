import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/conversation_model.dart';
import '../data/repositories/chat_repository.dart';

final conversationsProvider = FutureProvider<List<ConversationModel>>((ref) {
  return ref.read(chatRepositoryProvider).getConversations();
});

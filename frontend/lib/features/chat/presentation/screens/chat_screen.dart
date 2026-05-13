import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final String participantName;
  const ChatScreen({super.key, required this.conversationId, this.participantName = 'Chat'});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  PusherChannelsClient? _pusherClient;
  PrivateChannel? _channel;
  StreamSubscription? _connectionSub;
  StreamSubscription? _eventSub;

  List<MessageModel> _messages = [];
  bool _initialLoading = true;
  bool _sending = false;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _loadInitialAndConnect();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _connectionSub?.cancel();
    _channel?.unsubscribe();
    _pusherClient?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialAndConnect() async {
    try {
      final messages = await ref
          .read(chatRepositoryProvider)
          .getMessages(widget.conversationId);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _initialLoading = false;
      });
      _scrollToBottom(jump: true);
    } catch (_) {
      if (mounted) setState(() => _initialLoading = false);
    }
    _connectReverb();
  }

  void _connectReverb() async {
    final token = await const FlutterSecureStorage()
        .read(key: AppConstants.tokenKey);
    if (token == null || !mounted) return;

    final baseWithoutApi = AppConstants.baseUrl.replaceFirst('/api/v1', '');
    final authEndpoint = Uri.parse('$baseWithoutApi/broadcasting/auth');

    final options = PusherChannelsOptions.fromHost(
      scheme: 'ws',
      host: AppConstants.reverbHost,
      key: AppConstants.reverbKey,
      port: AppConstants.reverbPort,
    );

    _pusherClient = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (exception, trace, refresh) {
        Future.delayed(const Duration(seconds: 3), refresh);
      },
    );

    _channel = _pusherClient!.privateChannel(
      'private-chat.${widget.conversationId}',
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: authEndpoint,
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    _connectionSub = _pusherClient!.onConnectionEstablished.listen((_) {
      _channel!.subscribeIfNotUnsubscribed();
      if (mounted) setState(() => _connected = true);
    });

    _eventSub = _channel!.bind('MessageSent').listen(_onEvent);

    unawaited(_pusherClient!.connect());
  }

  void _onEvent(ChannelReadEvent event) {
    final data = jsonDecode(event.data as String) as Map<String, dynamic>;
    final myId = ref.read(currentUserProvider)?.id;
    if (data['sender_id'] == myId) return; // already shown locally

    final rawUrl = data['attachment_url'] as String?;
    final backendBase = AppConstants.baseUrl.replaceFirst('/api/v1', '');
    final fixedUrl = rawUrl?.replaceFirst(RegExp(r'https?://[^/]+'), backendBase);

    final msg = MessageModel(
      id: data['id'] as int,
      senderId: data['sender_id'] as int,
      body: data['body'] as String? ?? '',
      attachmentUrl: fixedUrl,
      createdAt: DateTime.parse(data['created_at'] as String),
    );

    if (mounted) {
      setState(() => _messages.add(msg));
      _scrollToBottom();
    }
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      if (!pos.hasContentDimensions) return;
      if (jump) {
        _scrollController.jumpTo(pos.maxScrollExtent);
      } else {
        _scrollController.animateTo(
          pos.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send({Uint8List? imageBytes, String? imageName}) async {
    final text = _messageController.text.trim();
    if (text.isEmpty && imageBytes == null || _sending) return;
    _messageController.clear();
    setState(() => _sending = true);
    try {
      final message = await ref
          .read(chatRepositoryProvider)
          .sendMessage(widget.conversationId,
              body: text, imageBytes: imageBytes, imageName: imageName);
      if (mounted) {
        setState(() => _messages.add(message));
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        if (text.isNotEmpty) _messageController.text = text;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    await _send(imageBytes: bytes, imageName: picked.name);
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                widget.participantName.isNotEmpty
                    ? widget.participantName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.participantName, style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(
              Icons.circle,
              size: 10,
              color: _connected ? AppColors.success : AppColors.textTertiary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _initialLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text('Send the first message!',
                            style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isMine = msg.senderId == myId;
                          final showDate = i == 0 ||
                              !_sameDay(_messages[i - 1].createdAt, msg.createdAt);
                          return Column(
                            children: [
                              if (showDate) _DateDivider(date: msg.createdAt),
                              _MessageBubble(message: msg, isMine: isMine),
                            ],
                          );
                        },
                      ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: () => _send(),
            onPickImage: _pickAndSendImage,
            sending: _sending,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final hasImage = message.attachmentUrl != null;
    final hasText = message.body.isNotEmpty;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMine ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight:
                isMine ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMine ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight:
                isMine ? const Radius.circular(4) : const Radius.circular(16),
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (hasImage)
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Image.network(
                    message.attachmentUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.primary),
                            ),
                          ),
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.broken_image_outlined,
                          color: AppColors.textTertiary, size: 36),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  hasImage ? 6 : 10,
                  12,
                  10,
                ),
                child: Column(
                  crossAxisAlignment:
                      isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (hasText)
                      Text(
                        message.body,
                        style: TextStyle(
                          color: isMine ? Colors.white : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    if (hasText) const SizedBox(height: 3),
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMine
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final bool sending;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: sending ? null : onPickImage,
            icon: const Icon(Icons.image_outlined),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Type a message...'),
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: sending ? AppColors.border : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

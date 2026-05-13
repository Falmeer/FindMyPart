import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/chat/data/repositories/chat_repository.dart';

class ContactButton extends ConsumerStatefulWidget {
  final int recipientId;
  final String recipientName;
  final bool expanded;

  const ContactButton({
    super.key,
    required this.recipientId,
    required this.recipientName,
    this.expanded = true,
  });

  @override
  ConsumerState<ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends ConsumerState<ContactButton> {
  bool _loading = false;

  Future<void> _openChat() async {
    if (_loading) return;
    if (ref.read(currentUserProvider) == null) {
      context.push('/auth/login');
      return;
    }
    setState(() => _loading = true);
    try {
      final chatId = await ref
          .read(chatRepositoryProvider)
          .findOrCreateChat(widget.recipientId);
      if (mounted) {
        context.push(
          '/conversations/$chatId?name=${Uri.encodeComponent(widget.recipientName)}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: _loading ? null : _openChat,
      icon: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.chat_bubble_outline_rounded),
      label: const Text('Contact'),
    );

    return widget.expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

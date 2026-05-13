import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_card.dart';
import '../../data/models/conversation_model.dart';
import '../../providers/chat_providers.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversationsAsync.when(
        data: (conversations) => conversations.isEmpty
            ? const EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No conversations yet',
                subtitle: 'Contact a seller or garage to start chatting',
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(conversationsProvider),
                child: ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (_, i) =>
                      _ConversationTile(conversation: conversations[i]),
                ),
              ),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(count: 6, itemHeight: 72),
        ),
        error: (e, _) => ErrorState(message: e.toString()),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final name = conversation.participantName;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          initials,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: conversation.lastMessage != null
          ? Text(
              conversation.lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation.updatedAt),
            style: TextStyle(
              fontSize: 11,
              color: hasUnread ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                    fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
      onTap: () => context.push(
        '/conversations/${conversation.id}?name=${Uri.encodeComponent(conversation.participantName)}',
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}

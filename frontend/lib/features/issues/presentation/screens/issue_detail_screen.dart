import 'dart:async';
import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/reverb_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/share_card.dart';
import '../../../../features/chat/data/repositories/chat_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/issue_model.dart';
import '../../data/repositories/issues_repository.dart';
import '../../providers/issues_provider.dart';

class IssueDetailScreen extends ConsumerWidget {
  final int issueId;
  const IssueDetailScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issueAsync = ref.watch(issueDetailProvider(issueId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
        actions: [
          issueAsync.maybeWhen(
            data: (issue) {
              final isOwnIssue = currentUser != null && issue.userId == currentUser.id;
              if (isOwnIssue || issue.userId == 0) return const SizedBox.shrink();
              return _IssueContactIconButton(issue: issue);
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: issueAsync.when(
        data: (issue) => _IssueDetailBody(
          issue: issue,
          onRefresh: () => ref.invalidate(issueDetailProvider(issueId)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _IssueDetailBody extends ConsumerStatefulWidget {
  final IssueModel issue;
  final VoidCallback onRefresh;

  const _IssueDetailBody({required this.issue, required this.onRefresh});

  @override
  ConsumerState<_IssueDetailBody> createState() => _IssueDetailBodyState();
}

class _IssueDetailBodyState extends ConsumerState<_IssueDetailBody> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  late List<IssueCommentModel> _comments;
  int _lastCommentId = 0;
  Timer? _pollTimer;
  final _reverb = ReverbPublicChannel();
  static const _kPollInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.issue.comments);
    if (_comments.isNotEmpty) {
      _lastCommentId = _comments.map((c) => c.id).reduce(max);
    }
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _poll());
    _reverb.connect(
      channelName: 'issues.${widget.issue.id}',
      eventName: 'CommentPosted',
      onEvent: (data) {
        if (!mounted) return;
        final myId = ref.read(currentUserProvider)?.id;
        final commentUserId = data['user_id'] as int?;
        if (commentUserId == myId) return; // already added locally on submit
        final comment = IssueCommentModel.fromJson(data);
        setState(() {
          _comments.insert(0, comment);
          _lastCommentId = max(_lastCommentId, comment.id);
        });
      },
    );
  }

  Future<void> _poll() async {
    try {
      final newComments = await ref
          .read(issuesRepositoryProvider)
          .getComments(widget.issue.id, afterId: _lastCommentId);
      if (!mounted || newComments.isEmpty) return;
      setState(() {
        _comments.insertAll(0, newComments);
        _lastCommentId = newComments.map((c) => c.id).reduce(max);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _reverb.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _sending) return;
    _commentController.clear();
    setState(() => _sending = true);
    try {
      final comment = await ref
          .read(issuesRepositoryProvider)
          .postComment(widget.issue.id, text);
      setState(() {
        _comments.insert(0, comment);
        _lastCommentId = max(_lastCommentId, comment.id);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        _commentController.text = text;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(currentUserProvider)?.id;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _comments.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) return _PostHeader(issue: widget.issue, commentCount: _comments.length);
              return _CommentTile(
                comment: _comments[i - 1],
                isMe: _comments[i - 1].userId == myId,
              );
            },
          ),
        ),
        if (ref.watch(currentUserProvider) != null)
          _ReplyBar(
            controller: _commentController,
            onSend: _submitComment,
            sending: _sending,
          )
        else
          _GuestCommentBar(),
      ],
    );
  }
}

class _PostHeader extends StatelessWidget {
  final IssueModel issue;
  final int commentCount;
  const _PostHeader({required this.issue, required this.commentCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post card
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  _Avatar(name: issue.userName ?? '?', size: 32, fontSize: 13),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.userName ?? 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        _timeAgo(issue.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _StatusBadge(status: issue.status),
                ],
              ),
              const SizedBox(height: 12),
              // Vehicle title
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    issue.vehicleLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Description
              Text(
                issue.description,
                style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              // Footer stats
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 15, color: AppColors.textTertiary),
                  const SizedBox(width: 5),
                  Text(
                    '$commentCount ${commentCount == 1 ? 'comment' : 'comments'}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (commentCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Comments',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

class _CommentTile extends StatelessWidget {
  final IssueCommentModel comment;
  final bool isMe;
  const _CommentTile({required this.comment, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: comment.userName, size: 34, fontSize: 13),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isMe ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('you', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.body, style: const TextStyle(fontSize: 14, height: 1.5)),
                const SizedBox(height: 10),
                const Divider(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final double size;
  final double fontSize;
  const _Avatar({required this.name, required this.size, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final colors = [
      AppColors.primary,
      const Color(0xFF6366F1),
      const Color(0xFF0EA5E9),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];
    final color = colors[name.codeUnitAt(0) % colors.length];
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(initial, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _ReplyBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;
  const _ReplyBar({required this.controller, required this.onSend, required this.sending});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Add a comment...'),
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: sending ? AppColors.border : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueContactIconButton extends ConsumerStatefulWidget {
  final IssueModel issue;
  const _IssueContactIconButton({required this.issue});

  @override
  ConsumerState<_IssueContactIconButton> createState() => _IssueContactIconButtonState();
}

class _IssueContactIconButtonState extends ConsumerState<_IssueContactIconButton> {
  bool _loading = false;

  Future<void> _contact() async {
    if (_loading) return;
    if (ref.read(currentUserProvider) == null) {
      context.push('/auth/login');
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final chatId = await repo.findOrCreateChat(widget.issue.userId);
      final desc = widget.issue.description;
      final card = ShareCard(
        kind: 'issue',
        id: widget.issue.id,
        title: widget.issue.vehicleLabel,
        subtitle: desc.length > 80 ? '${desc.substring(0, 80)}…' : desc,
      );
      if (mounted) {
        context.push(
          '/conversations/$chatId?name=${Uri.encodeComponent(widget.issue.userName ?? 'User')}',
          extra: card,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      icon: const Icon(Icons.chat_bubble_outline_rounded),
      tooltip: 'Message poster',
      onPressed: _contact,
    );
  }
}

class _GuestCommentBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Sign in to join the discussion',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/auth/login'),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'open'        => ('Open', AppColors.success),
      'in_progress' => ('In Progress', AppColors.accent),
      'resolved'    => ('Resolved', AppColors.primary),
      _             => ('Closed', AppColors.textTertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

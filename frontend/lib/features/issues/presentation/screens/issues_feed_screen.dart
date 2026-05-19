import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/reverb_service.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_card.dart';
import '../../data/models/issue_model.dart';
import '../../providers/issues_provider.dart';

class IssuesFeedScreen extends ConsumerStatefulWidget {
  const IssuesFeedScreen({super.key});

  @override
  ConsumerState<IssuesFeedScreen> createState() => _IssuesFeedScreenState();
}

class _IssuesFeedScreenState extends ConsumerState<IssuesFeedScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  String? _selectedBrand;
  bool _myIssuesOnly = false;
  Timer? _refreshTimer;
  final _reverb = ReverbPublicChannel();

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_myIssuesOnly) {
        ref.invalidate(myIssuesProvider);
      } else {
        ref.invalidate(openIssuesProvider);
      }
    });
    _reverb.connect(
      channelName: 'issues',
      eventName: 'IssuePosted',
      onEvent: (_) {
        ref.invalidate(openIssuesProvider);
        ref.invalidate(myIssuesProvider);
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _reverb.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<IssueModel> _filter(List<IssueModel> issues) {
    return issues.where((issue) {
      if (_selectedBrand != null &&
          issue.brand.toLowerCase() != _selectedBrand!.toLowerCase()) {
        return false;
      }
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!issue.brand.toLowerCase().contains(q) &&
            !issue.model.toLowerCase().contains(q) &&
            !issue.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(currentUserProvider) != null;
    final effectiveMyIssues = _myIssuesOnly && isLoggedIn;
    final issuesAsync =
        effectiveMyIssues ? ref.watch(myIssuesProvider) : ref.watch(openIssuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issues'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () {
                if (!isLoggedIn) {
                  context.push('/auth/login');
                  return;
                }
                setState(() => _myIssuesOnly = !_myIssuesOnly);
              },
              icon: Icon(
                _myIssuesOnly ? Icons.person_rounded : Icons.people_outline,
                size: 18,
                color: _myIssuesOnly ? AppColors.primary : AppColors.textSecondary,
              ),
              label: Text(
                _myIssuesOnly ? 'Mine' : 'All',
                style: TextStyle(
                  color: _myIssuesOnly ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/garages/post-issue'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Post Issue'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by car, issue...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _search = v.trim()),
            ),
          ),
          issuesAsync.when(
            data: (issues) {
              final brands = issues.map((e) => e.brand).toSet().toList()..sort();
              if (brands.isEmpty) return const SizedBox(height: 8);
              return SizedBox(
                height: 50,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: brands.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return FilterChip(
                        label: const Text('All'),
                        selected: _selectedBrand == null,
                        onSelected: (_) => setState(() => _selectedBrand = null),
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                      );
                    }
                    final brand = brands[i - 1];
                    return FilterChip(
                      label: Text(brand),
                      selected: _selectedBrand == brand,
                      onSelected: (_) => setState(
                          () => _selectedBrand = _selectedBrand == brand ? null : brand),
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox(height: 8),
          ),
          Expanded(
            child: issuesAsync.when(
              data: (issues) {
                final filtered = _filter(issues);
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.forum_outlined,
                    title: effectiveMyIssues ? 'No issues posted yet' : 'No open issues',
                    subtitle: effectiveMyIssues
                        ? 'Tap "Post Issue" to describe your car problem'
                        : 'Check back later or adjust your filter',
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    if (effectiveMyIssues) {
                      ref.invalidate(myIssuesProvider);
                    } else {
                      ref.invalidate(openIssuesProvider);
                    }
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _IssueCard(
                      issue: filtered[i],
                      onTap: () => context.push('/issues/${filtered[i].id}'),
                    ),
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerList(count: 5, itemHeight: 100),
              ),
              error: (e, _) => ErrorState(message: e.toString()),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final IssueModel issue;
  final VoidCallback onTap;

  const _IssueCard({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_car, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                issue.vehicleLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(status: issue.status),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          issue.description,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${issue.commentCount} ${issue.commentCount == 1 ? 'comment' : 'comments'}',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    _timeAgo(issue.createdAt),
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                  if (issue.userName != null) ...[
                    const Spacer(),
                    const Icon(Icons.person_outline,
                        size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      issue.userName!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'open' => ('Open', AppColors.success),
      'in_progress' => ('In Progress', AppColors.accent),
      'resolved' => ('Resolved', AppColors.primary),
      _ => ('Closed', AppColors.textTertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

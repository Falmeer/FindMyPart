import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../data/models/issue_model.dart';
import '../../providers/issues_provider.dart';

class OpenIssuesScreen extends ConsumerWidget {
  const OpenIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(openIssuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Issues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(openIssuesProvider),
          ),
        ],
      ),
      body: issuesAsync.when(
        data: (issues) => issues.isEmpty
            ? const EmptyState(
                icon: Icons.report_problem_outlined,
                title: 'No open issues',
                subtitle: 'Check back later — customers will post issues here',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: issues.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _OpenIssueCard(
                  issue: issues[i],
                  onTap: () => context.push('/issues/${issues[i].id}'),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _OpenIssueCard extends StatelessWidget {
  final IssueModel issue;
  final VoidCallback onTap;

  const _OpenIssueCard({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final alreadySent = issue.myOffer != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: alreadySent ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    issue.vehicleLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                if (alreadySent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Offer Sent',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              issue.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  issue.userName ?? 'Customer',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.local_offer_outlined, size: 14, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  '${issue.offerCount} offer${issue.offerCount == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.accent),
                ),
                const Spacer(),
                Text(
                  DateFormat('d MMM').format(issue.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

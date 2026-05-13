import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_button.dart';
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
    final user = ref.watch(currentUserProvider);
    final isGarage = user?.isGarage == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Issue Details')),
      body: issueAsync.when(
        data: (issue) => _IssueDetailBody(
          issue: issue,
          isGarage: isGarage,
          onRefresh: () => ref.invalidate(issueDetailProvider(issueId)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _IssueDetailBody extends ConsumerWidget {
  final IssueModel issue;
  final bool isGarage;
  final VoidCallback onRefresh;

  const _IssueDetailBody({
    required this.issue,
    required this.isGarage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vehicle info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_car, size: 36, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.vehicleLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: issue.status),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Description
        const Text('Issue Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(issue.description, style: const TextStyle(fontSize: 14, height: 1.5)),
        ),

        if (isGarage && issue.userName != null) ...[
          const SizedBox(height: 16),
          const Text('Posted by', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(issue.userName!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Garage action: send offer
        if (isGarage) ...[
          if (issue.myOffer == null)
            AppButton(
              label: 'Send Offer',
              onPressed: () => _showSendOfferSheet(context, ref),
            )
          else ...[
            const Text('Your Offer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            _OfferCard(offer: issue.myOffer!, isCustomer: false, onAction: null),
          ],
        ],

        // Customer side: list offers
        if (!isGarage) ...[
          Text(
            'Offers (${issue.offers.length})',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (issue.offers.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text(
                  'No offers yet. Garages will respond soon.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...issue.offers.map((offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OfferCard(
                    offer: offer,
                    isCustomer: true,
                    onAction: issue.status == 'open'
                        ? (status) => _updateOffer(context, ref, offer.id, status)
                        : null,
                  ),
                )),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  void _showSendOfferSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SendOfferSheet(
        issueId: issue.id,
        onSent: onRefresh,
      ),
    );
  }

  Future<void> _updateOffer(BuildContext context, WidgetRef ref, int offerId, String status) async {
    try {
      await ref.read(issuesRepositoryProvider).updateOffer(issue.id, offerId, status);
      onRefresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offer ${status == 'accepted' ? 'accepted' : 'rejected'}'),
            backgroundColor: status == 'accepted' ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _OfferCard extends StatelessWidget {
  final OfferModel offer;
  final bool isCustomer;
  final void Function(String status)? onAction;

  const _OfferCard({required this.offer, required this.isCustomer, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: offer.status == 'accepted'
              ? AppColors.success
              : offer.status == 'rejected'
                  ? AppColors.error
                  : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.car_repair, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  offer.garageName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              _OfferStatusBadge(status: offer.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(offer.message, style: const TextStyle(fontSize: 13, height: 1.4)),
          if (offer.price != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 15, color: AppColors.success),
                Text(
                  'Estimated: BHD ${offer.price!.toStringAsFixed(3)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success),
                ),
              ],
            ),
          ],
          if (isCustomer && onAction != null && offer.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onAction!('rejected'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAction!('accepted'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SendOfferSheet extends ConsumerStatefulWidget {
  final int issueId;
  final VoidCallback onSent;

  const _SendOfferSheet({required this.issueId, required this.onSent});

  @override
  ConsumerState<_SendOfferSheet> createState() => _SendOfferSheetState();
}

class _SendOfferSheetState extends ConsumerState<_SendOfferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Send an Offer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Your message to the customer',
                hintText: 'Describe how you can help and your availability...',
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Message is required';
                if (v.trim().length < 10) return 'Please write at least 10 characters';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Estimated price (BHD) — optional',
                prefixText: 'BHD ',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit Offer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final price = double.tryParse(_priceController.text.trim());
      await ref.read(issuesRepositoryProvider).sendOffer(
            widget.issueId,
            message: _messageController.text.trim(),
            price: price,
          );
      if (mounted) {
        Navigator.pop(context);
        widget.onSent();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _OfferStatusBadge extends StatelessWidget {
  final String status;
  const _OfferStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'accepted' => ('Accepted', AppColors.success),
      'rejected' => ('Rejected', AppColors.error),
      _ => ('Pending', AppColors.accent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

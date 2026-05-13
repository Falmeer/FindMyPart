import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/contact_button.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../../../../shared/widgets/network_image_widget.dart';
import '../../../../shared/widgets/condition_badge.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../providers/spare_parts_provider.dart';

class SparePartDetailScreen extends ConsumerWidget {
  final int id;
  const SparePartDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partAsync = ref.watch(sparePartDetailProvider(id));
    final theme = Theme.of(context);

    return partAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: ErrorState(message: e.toString())),
      data: (part) => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: NetworkImageWidget(
                  imageUrl: part.thumbnailUrl,
                  height: 260,
                  width: double.infinity,
                  placeholderIcon: Icons.build_outlined,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(part.name,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                        ConditionBadge(condition: part.condition),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(part.category,
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'SAR ${part.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                        const Spacer(),
                        if (part.hasWarranty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Warranty',
                                style: TextStyle(
                                    color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                      ],
                    ),
                    const Divider(height: 28),
                    _InfoRow(label: 'Category', value: part.category),
                    _InfoRow(label: 'Condition', value: part.condition),
                    if (part.compatibility != null)
                      _InfoRow(label: 'Compatible With', value: part.compatibility!),
                    _InfoRow(label: 'Quantity Available', value: part.quantity.toString()),
                    const Divider(height: 28),
                    Text('Description', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(part.description,
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    const Divider(height: 28),
                    _SellerTile(name: part.sellerName, phone: part.sellerPhone),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 20, offset: const Offset(0, -4))],
          ),
          child: Row(
            children: [
              FavoriteButton(
                type: 'part',
                id: part.id,
                initialValue: part.isFavorited,
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ContactButton(
                  recipientId: part.sellerId,
                  recipientName: part.sellerName,
                  expanded: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SellerTile extends StatelessWidget {
  final String name;
  final String? phone;
  const _SellerTile({required this.name, this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.store_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Seller', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

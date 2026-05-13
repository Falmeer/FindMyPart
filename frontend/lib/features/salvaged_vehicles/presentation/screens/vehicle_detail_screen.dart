import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/contact_button.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../../../../shared/widgets/network_image_widget.dart';
import '../../../../shared/widgets/price_tag.dart';
import '../../../../shared/widgets/condition_badge.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/models/vehicle_model.dart';
import '../../providers/vehicles_provider.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final int id;
  const VehicleDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleDetailProvider(id));
    final theme = Theme.of(context);

    return vehicleAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: ErrorState(message: e.toString())),
      data: (vehicle) => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: NetworkImageWidget(
                  imageUrl: vehicle.thumbnailUrl,
                  height: 280,
                  width: double.infinity,
                  placeholderIcon: Icons.directions_car_outlined,
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
                          child: Text(vehicle.title,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                        ConditionBadge(condition: vehicle.condition),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PriceTag(price: vehicle.price, fontSize: 22),
                    const SizedBox(height: 20),
                    _SpecGrid(vehicle: vehicle),
                    const Divider(height: 32),
                    Text('Description', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(vehicle.description,
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    const Divider(height: 32),
                    _SellerCard(
                      name: vehicle.sellerName,
                      phone: vehicle.sellerPhone,
                    ),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              FavoriteButton(
                type: 'vehicle',
                id: vehicle.id,
                initialValue: vehicle.isFavorited,
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ContactButton(
                  recipientId: vehicle.sellerId,
                  recipientName: vehicle.sellerName,
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

class _SpecGrid extends StatelessWidget {
  final VehicleModel vehicle;
  const _SpecGrid({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final specs = <(String, String?, IconData)>[
      ('Year', vehicle.year.toString(), Icons.calendar_today_outlined),
      ('Mileage', vehicle.mileage != null ? '${vehicle.mileage! ~/ 1000}k km' : 'N/A', Icons.speed),
      ('Engine', vehicle.engine ?? 'N/A', Icons.settings_outlined),
      ('Transmission', vehicle.transmission ?? 'N/A', Icons.alt_route),
      if (vehicle.vin != null) ('VIN', vehicle.vin!, Icons.pin_outlined),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3.2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: specs
          .map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(s.$3, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.$1, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        Text(s.$2 ?? 'N/A',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _SellerCard extends StatelessWidget {
  final String name;
  final String? phone;
  const _SellerCard({required this.name, this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Seller', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}

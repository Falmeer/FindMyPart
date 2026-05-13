import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../salvaged_vehicles/presentation/widgets/vehicle_card.dart';
import '../../../salvaged_vehicles/providers/vehicles_provider.dart';
import '../../../spare_parts/presentation/widgets/spare_part_card.dart';
import '../../../spare_parts/providers/spare_parts_provider.dart';
import '../../../garages/presentation/widgets/garage_card.dart';
import '../../../garages/providers/garages_provider.dart';
import '../widgets/home_banner.dart';
import '../widgets/category_grid.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final vehiclesAsync = ref.watch(featuredVehiclesProvider);
    final partsAsync = ref.watch(featuredPartsProvider);
    final garagesAsync = ref.watch(nearbyGaragesProvider);

    return Scaffold(
      appBar: AppBar(
        title: _buildGreeting(user?.name),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () => context.push('/conversations'),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredVehiclesProvider);
          ref.invalidate(featuredPartsProvider);
          ref.invalidate(nearbyGaragesProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: const SearchBarWidget(),
                  ),
                  const HomeBanner(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _AIScannerCard(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(title: AppStrings.categories),
                  ),
                  const SizedBox(height: 12),
                  const CategoryGrid(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(
                      title: AppStrings.featuredVehicles,
                      actionLabel: AppStrings.seeAll,
                      onAction: () => context.go('/vehicles'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            vehiclesAsync.when(
              data: (vehicles) => SliverToBoxAdapter(
                child: SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vehicles.take(6).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 200,
                      child: VehicleCard(vehicle: vehicles[i], compact: true),
                    ),
                  ),
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(height: 240, child: _HorizontalShimmer()),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(
                      title: AppStrings.featuredParts,
                      actionLabel: AppStrings.seeAll,
                      onAction: () => context.go('/parts'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            partsAsync.when(
              data: (parts) => SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: parts.take(6).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 170,
                      child: SparePartCard(part: parts[i], compact: true),
                    ),
                  ),
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(height: 220, child: _HorizontalShimmer()),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(
                      title: AppStrings.nearbyGarages,
                      actionLabel: AppStrings.seeAll,
                      onAction: () => context.go('/garages'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            garagesAsync.when(
              data: (garages) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: GarageCard(garage: garages[i]),
                  ),
                  childCount: garages.take(3).length,
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: _VerticalShimmer()),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(String? name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('FindMyPart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        if (name != null)
          Text('Hello, $name',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _AIScannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/ai-scan'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Warning Light Scanner',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Scan your dashboard light for instant diagnosis',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

class _HorizontalShimmer extends StatelessWidget {
  const _HorizontalShimmer();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _VerticalShimmer extends StatelessWidget {
  const _VerticalShimmer();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

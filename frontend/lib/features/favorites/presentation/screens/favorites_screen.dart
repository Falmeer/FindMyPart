import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_card.dart';
import '../../../salvaged_vehicles/presentation/widgets/vehicle_card.dart';
import '../../../spare_parts/presentation/widgets/spare_part_card.dart';
import '../../../garages/presentation/widgets/garage_card.dart';
import '../../../scrapyards/presentation/widgets/scrapyard_card.dart';
import '../../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(favoriteVehiclesProvider);
    final partsAsync = ref.watch(favoritePartsProvider);
    final garagesAsync = ref.watch(favoriteGaragesProvider);
    final scrapyardsAsync = ref.watch(favoriteScrapyardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Vehicles'),
            Tab(text: 'Parts'),
            Tab(text: 'Garages'),
            Tab(text: 'Scrapyards'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Vehicles tab
          vehiclesAsync.when(
            data: (vehicles) => vehicles.isEmpty
                ? const EmptyState(
                    icon: Icons.directions_car_outlined,
                    title: 'No saved vehicles',
                    subtitle: 'Tap the heart on any vehicle to save it here',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(favoriteVehiclesProvider),
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: vehicles.length,
                      itemBuilder: (_, i) => VehicleCard(vehicle: vehicles[i]),
                    ),
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerGrid(),
            ),
            error: (e, _) => ErrorState(message: e.toString()),
          ),

          // Parts tab
          partsAsync.when(
            data: (parts) => parts.isEmpty
                ? const EmptyState(
                    icon: Icons.build_outlined,
                    title: 'No saved parts',
                    subtitle: 'Tap the heart on any part to save it here',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(favoritePartsProvider),
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: parts.length,
                      itemBuilder: (_, i) => SparePartCard(part: parts[i]),
                    ),
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerGrid(),
            ),
            error: (e, _) => ErrorState(message: e.toString()),
          ),

          // Garages tab
          garagesAsync.when(
            data: (garages) => garages.isEmpty
                ? const EmptyState(
                    icon: Icons.car_repair,
                    title: 'No saved garages',
                    subtitle: 'Tap the heart on any garage to save it here',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(favoriteGaragesProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: garages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => GarageCard(garage: garages[i]),
                    ),
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(count: 4, itemHeight: 100),
            ),
            error: (e, _) => ErrorState(message: e.toString()),
          ),

          // Scrapyards tab
          scrapyardsAsync.when(
            data: (scrapyards) => scrapyards.isEmpty
                ? const EmptyState(
                    icon: Icons.recycling,
                    title: 'No saved scrapyards',
                    subtitle: 'Tap the heart on any scrapyard to save it here',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(favoriteScrapyardsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: scrapyards.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => ScrapyardCard(scrapyard: scrapyards[i]),
                    ),
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(count: 4, itemHeight: 100),
            ),
            error: (e, _) => ErrorState(message: e.toString()),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_card.dart';
import '../../providers/garages_provider.dart';
import '../../../scrapyards/providers/scrapyards_provider.dart';
import '../../../scrapyards/presentation/widgets/scrapyard_card.dart';
import '../widgets/garage_card.dart';
import '../widgets/garages_map_view.dart';

class GaragesScreen extends ConsumerStatefulWidget {
  const GaragesScreen({super.key});

  @override
  ConsumerState<GaragesScreen> createState() => _GaragesScreenState();
}

class _GaragesScreenState extends ConsumerState<GaragesScreen> {
  final _searchController = TextEditingController();
  String? _search;
  bool _showMap = false;
  String _type = 'garage';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final garagesAsync = ref.watch(garagesListProvider(_search));
    final scrapyardsAsync = ref.watch(scrapyardsListProvider(_search));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Garages & Scrapyards'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list_rounded : Icons.map_outlined),
            tooltip: _showMap ? 'List view' : 'Map view',
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/garages/post-issue'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.report_problem_outlined),
        label: const Text('Post Issue'),
      ),
      body: Column(
        children: [
          // Type toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _TypeTab(
                    label: 'Garages',
                    icon: Icons.car_repair,
                    selected: _type == 'garage',
                    onTap: () => setState(() => _type = 'garage'),
                  ),
                  _TypeTab(
                    label: 'Scrapyards',
                    icon: Icons.recycling,
                    selected: _type == 'scrapyard',
                    onTap: () => setState(() => _type = 'scrapyard'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _type == 'garage' ? 'Search garages...' : 'Search scrapyards...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = null);
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) => setState(() => _search = v.trim().isEmpty ? null : v.trim()),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _showMap
                ? GaragesMapView(search: _search, type: _type)
                : _type == 'scrapyard'
                    ? scrapyardsAsync.when(
                        data: (scrapyards) => scrapyards.isEmpty
                            ? const EmptyState(
                                icon: Icons.recycling,
                                title: 'No scrapyards found',
                                subtitle: 'Try a different search',
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                itemCount: scrapyards.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (_, i) => ScrapyardCard(scrapyard: scrapyards[i]),
                              ),
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: ShimmerList(count: 6, itemHeight: 100),
                        ),
                        error: (e, _) => ErrorState(message: e.toString()),
                      )
                    : garagesAsync.when(
                        data: (garages) => garages.isEmpty
                            ? const EmptyState(
                                icon: Icons.car_repair,
                                title: 'No garages found',
                                subtitle: 'Try a different search',
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                itemCount: garages.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (_, i) => GarageCard(garage: garages[i]),
                              ),
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: ShimmerList(count: 6, itemHeight: 100),
                        ),
                        error: (e, _) => ErrorState(message: e.toString()),
                      ),
          ),
        ],
      ),
    );
  }

}

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

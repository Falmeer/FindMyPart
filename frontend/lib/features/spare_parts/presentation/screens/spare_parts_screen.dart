import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/spare_parts_provider.dart';
import '../widgets/spare_part_card.dart';

const _categories = [
  'All', 'Engine', 'Transmission', 'Suspension', 'Brakes',
  'AC', 'Electrical', 'Interior', 'Exterior', 'Tires',
  'Electronics', 'Cooling', 'Exhaust', 'Lighting',
];

class SparePartsScreen extends ConsumerStatefulWidget {
  const SparePartsScreen({super.key});

  @override
  ConsumerState<SparePartsScreen> createState() => _SparePartsScreenState();
}

class _SparePartsScreenState extends ConsumerState<SparePartsScreen> {
  final _searchController = TextEditingController();
  String? _search;
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = SparePartFilter(
      search: _search,
      category: _selectedCategory == 'All' ? null : _selectedCategory.toLowerCase(),
    );
    final partsAsync = ref.watch(sparePartsListProvider(filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Spare Parts')),
      floatingActionButton: ref.watch(currentUserProvider) != null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/parts/add'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('List Part'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search parts...',
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
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: partsAsync.when(
              data: (parts) => parts.isEmpty
                  ? const EmptyState(
                      icon: Icons.build_outlined,
                      title: 'No parts found',
                      subtitle: 'Try a different category or search',
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: parts.length,
                      itemBuilder: (_, i) => SparePartCard(part: parts[i]),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerGrid(),
              ),
              error: (e, _) => ErrorState(message: e.toString()),
            ),
          ),
        ],
      ),
    );
  }
}

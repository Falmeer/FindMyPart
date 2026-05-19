import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/reverb_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/car_api_service.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/vehicles_provider.dart';
import '../widgets/vehicle_card.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  final String? initialSearch;
  const VehiclesScreen({super.key, this.initialSearch});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  late final TextEditingController _searchController;
  String? _search;
  String? _brand;
  String? _model;
  int? _yearFrom;
  int? _yearTo;
  String? _condition;

  Timer? _refreshTimer;
  final _reverb = ReverbPublicChannel();

  @override
  void initState() {
    super.initState();
    _search = widget.initialSearch?.isNotEmpty == true ? widget.initialSearch : null;
    _searchController = TextEditingController(text: _search ?? '');
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      ref.invalidate(vehiclesListProvider);
    });
    _reverb.connect(
      channelName: 'vehicles',
      eventName: 'VehicleListed',
      onEvent: (_) => ref.invalidate(vehiclesListProvider),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _reverb.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _brand != null || _model != null || _yearFrom != null || _yearTo != null || _condition != null;

  @override
  Widget build(BuildContext context) {
    final filter = VehicleFilter(
      search: _search,
      brand: _brand,
      model: _model,
      yearFrom: _yearFrom,
      yearTo: _yearTo,
      condition: _condition,
    );
    final vehiclesAsync = ref.watch(vehiclesListProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salvaged Vehicles'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: _showFilterSheet,
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: ref.watch(currentUserProvider)?.isYardOwner == true
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/vehicles/add'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('List Vehicle'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by brand, model...',
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
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _filterSummary,
                      style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: vehiclesAsync.when(
              data: (vehicles) => vehicles.isEmpty
                  ? const EmptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'No vehicles found',
                      subtitle: 'Try adjusting your filters',
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: vehicles.length,
                      itemBuilder: (_, i) => VehicleCard(vehicle: vehicles[i]),
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

  String get _filterSummary {
    final parts = <String>[];
    if (_brand != null) parts.add(_brand!);
    if (_model != null) parts.add(_model!);
    if (_yearFrom != null && _yearTo != null) {
      parts.add('$_yearFrom–$_yearTo');
    } else if (_yearFrom != null) parts.add('From $_yearFrom');
    else if (_yearTo != null) parts.add('Up to $_yearTo');
    if (_condition != null) parts.add(_condition!);
    return parts.join(' · ');
  }

  void _clearFilters() {
    setState(() {
      _brand = null;
      _model = null;
      _yearFrom = null;
      _yearTo = null;
      _condition = null;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(
        initialBrand: _brand,
        initialModel: _model,
        initialYearFrom: _yearFrom,
        initialYearTo: _yearTo,
        initialCondition: _condition,
        onApply: (brand, model, yearFrom, yearTo, condition) {
          setState(() {
            _brand = brand;
            _model = model;
            _yearFrom = yearFrom;
            _yearTo = yearTo;
            _condition = condition;
          });
        },
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  final String? initialBrand;
  final String? initialModel;
  final int? initialYearFrom;
  final int? initialYearTo;
  final String? initialCondition;
  final void Function(String?, String?, int?, int?, String?) onApply;

  const _FilterSheet({
    required this.initialBrand,
    required this.initialModel,
    required this.initialYearFrom,
    required this.initialYearTo,
    required this.initialCondition,
    required this.onApply,
  });

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  final _brandController = TextEditingController();
  String? _brand;
  String? _model;
  int? _yearFrom;
  int? _yearTo;
  String? _condition;

  static final _years = List.generate(2027 - 1930 + 1, (i) => 2027 - i);

  static const _conditions = ['Used', 'Damaged', 'Parts Only'];

  @override
  void initState() {
    super.initState();
    _brand = widget.initialBrand;
    _model = widget.initialModel;
    _yearFrom = widget.initialYearFrom;
    _yearTo = widget.initialYearTo;
    _condition = widget.initialCondition;
    _brandController.text = _brand ?? '';
  }

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsAsync = _brand != null ? ref.watch(carModelsProvider(_brand!)) : null;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Filter Vehicles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _brand = null;
                      _model = null;
                      _yearFrom = null;
                      _yearTo = null;
                      _condition = null;
                      _brandController.clear();
                    });
                  },
                  child: const Text('Reset'),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Brand autocomplete
                const Text('Brand', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  final makes = ref.watch(carMakesProvider);
                  return Autocomplete<String>(
                    initialValue: TextEditingValue(text: _brand ?? ''),
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) return makes;
                      final query = textEditingValue.text.toLowerCase();
                      return makes.where((m) => m.toLowerCase().contains(query));
                    },
                    onSelected: (value) {
                      setState(() {
                        _brand = value;
                        _model = null;
                      });
                    },
                    fieldViewBuilder: (_, controller, focusNode, onSubmit) => TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (v) {
                        if (v.isEmpty) setState(() { _brand = null; _model = null; });
                      },
                      decoration: InputDecoration(
                        hintText: 'Type to search brand...',
                        prefixIcon: _brand != null
                            ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: BrandLogo(brand: _brand!, size: 22),
                              )
                            : const Icon(Icons.directions_car_outlined, size: 18),
                      ),
                    ),
                    optionsViewBuilder: (context, onSelected, options) => Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (_, i) {
                              final option = options.elementAt(i);
                              return ListTile(
                                dense: true,
                                leading: BrandLogo(brand: option, size: 28),
                                title: Text(option, style: const TextStyle(fontSize: 13)),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Model dropdown
                const Text('Model', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                if (_brand == null)
                  const Text('Select a brand first',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 13))
                else if (modelsAsync != null)
                  modelsAsync.when(
                    data: (models) => models.isEmpty
                        ? const Text('No models found',
                            style: TextStyle(color: AppColors.textTertiary, fontSize: 13))
                        : _StyledDropdown<String>(
                            value: _model,
                            hint: 'Select model',
                            items: [null, ...models],
                            labelOf: (v) => v ?? 'Any model',
                            onChanged: (v) => setState(() => _model = v),
                          ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Could not load models',
                        style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ),

                const SizedBox(height: 20),

                // Year range
                const Text('Year Range', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StyledDropdown<int>(
                        value: _yearFrom,
                        hint: 'From',
                        items: [null, ..._years.reversed],
                        labelOf: (v) => v != null ? '$v' : 'Any',
                        onChanged: (v) => setState(() => _yearFrom = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StyledDropdown<int>(
                        value: _yearTo,
                        hint: 'To',
                        items: [null, ..._years],
                        labelOf: (v) => v != null ? '$v' : 'Any',
                        onChanged: (v) => setState(() => _yearTo = v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Condition
                const Text('Condition', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _conditions.map((c) => FilterChip(
                    label: Text(c),
                    selected: _condition == c,
                    onSelected: (selected) => setState(() => _condition = selected ? c : null),
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                  )).toList(),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onApply(_brand, _model, _yearFrom, _yearTo, _condition);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T?> items;
  final String Function(T?) labelOf;
  final void Function(T?) onChanged;

  const _StyledDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        hint: Text(hint, style: const TextStyle(color: AppColors.textTertiary)),
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(labelOf(item), overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

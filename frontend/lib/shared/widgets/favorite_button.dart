import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/favorites/data/repositories/favorites_repository.dart';
import '../../features/favorites/providers/favorites_provider.dart';
import '../../features/salvaged_vehicles/providers/vehicles_provider.dart';
import '../../features/spare_parts/providers/spare_parts_provider.dart';
import '../../features/garages/providers/garages_provider.dart';
import '../../features/scrapyards/providers/scrapyards_provider.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final String type; // 'vehicle' | 'part' | 'garage'
  final int id;
  final bool initialValue;
  final bool expanded;

  const FavoriteButton({
    super.key,
    required this.type,
    required this.id,
    this.initialValue = false,
    this.expanded = true,
  });

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  late bool _isFavorited;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.initialValue;
  }

  Future<void> _toggle() async {
    if (_loading) return;
    if (ref.read(currentUserProvider) == null) {
      context.push('/auth/login');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await ref.read(favoritesRepositoryProvider).toggle(widget.type, widget.id);
      setState(() => _isFavorited = result);
      // Invalidate favorites list + detail cache so both screens reflect the new state
      switch (widget.type) {
        case 'vehicle':
          ref.invalidate(favoriteVehiclesProvider);
          ref.invalidate(vehicleDetailProvider(widget.id));
        case 'part':
          ref.invalidate(favoritePartsProvider);
          ref.invalidate(sparePartDetailProvider(widget.id));
        case 'garage':
          ref.invalidate(favoriteGaragesProvider);
          ref.invalidate(garageDetailProvider(widget.id));
        case 'scrapyard':
          ref.invalidate(favoriteScrapyardsProvider);
          ref.invalidate(scrapyardDetailProvider(widget.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.expanded
          ? const Expanded(child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))))
          : const SizedBox(width: 44, height: 44, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))));
    }

    final icon = _isFavorited ? Icons.favorite : Icons.favorite_border;
    final color = _isFavorited ? AppColors.error : null;

    if (widget.expanded) {
      return Expanded(
        child: OutlinedButton.icon(
          onPressed: _toggle,
          icon: Icon(icon, color: color),
          label: Text(_isFavorited ? 'Saved' : 'Save', style: TextStyle(color: color)),
          style: _isFavorited
              ? OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error))
              : null,
        ),
      );
    }

    return IconButton(
      onPressed: _toggle,
      icon: Icon(icon, color: color),
    );
  }
}

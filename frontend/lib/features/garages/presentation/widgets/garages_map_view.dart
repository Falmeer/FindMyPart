import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/business_place.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/garages_provider.dart';
import '../../../scrapyards/providers/scrapyards_provider.dart';

class GaragesMapView extends ConsumerStatefulWidget {
  final String? search;
  final String type;
  const GaragesMapView({super.key, this.search, this.type = 'garage'});

  @override
  ConsumerState<GaragesMapView> createState() => _GaragesMapViewState();
}

class _GaragesMapViewState extends ConsumerState<GaragesMapView> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);
  BusinessPlace? _selected;

  @override
  void initState() {
    super.initState();
    _locateUser();
  }

  Future<void> _locateUser() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        if (!mounted) return;
        setState(() => _center = LatLng(position.latitude, position.longitude));
        _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
      }
    } catch (_) {}
  }

  Set<Marker> _buildMarkers(List<BusinessPlace> places) {
    return places
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) => Marker(
              markerId: MarkerId('${p.favoriteType}_${p.id}'),
              position: LatLng(p.latitude!, p.longitude!),
              infoWindow: InfoWindow(title: p.name),
              onTap: () => setState(() => _selected = p),
            ))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final garagesAsync = ref.watch(garagesListProvider(widget.search));
    final scrapyardsAsync = ref.watch(scrapyardsListProvider(widget.search));

    final placesAsync = widget.type == 'scrapyard'
        ? scrapyardsAsync.whenData((s) => List<BusinessPlace>.from(s))
        : garagesAsync.whenData((g) => List<BusinessPlace>.from(g));

    return Stack(
      children: [
        placesAsync.when(
          data: (places) => GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: AppConstants.defaultZoom,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _buildMarkers(places),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            onTap: (_) => setState(() => _selected = null),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
        if (_selected != null)
          Positioned(
            bottom: 108,
            left: 16,
            right: 16,
            child: _BusinessPreviewCard(
              place: _selected!,
              onClose: () => setState(() => _selected = null),
              onOpen: () => context.push('${_selected!.routePrefix}/${_selected!.id}'),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _BusinessPreviewCard extends StatelessWidget {
  final BusinessPlace place;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  const _BusinessPreviewCard({
    required this.place,
    required this.onClose,
    required this.onOpen,
  });

  Future<void> _launchDirections(double lat, double lng, String name) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=${Uri.encodeComponent(name)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isScrapyard = place.favoriteType == 'scrapyard';
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            if (place.address != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      place.address!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                RatingBarIndicator(
                  rating: place.rating,
                  itemSize: 14,
                  itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starRating),
                ),
                const SizedBox(width: 6),
                Text(
                  '${place.rating.toStringAsFixed(1)} (${place.reviewCount})',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (place.distanceKm != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.directions_car_outlined, size: 13, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text(
                    '${place.distanceKm!.toStringAsFixed(1)} km',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ],
              ],
            ),
            if (place.services.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: place.services.take(3).map((s) => Chip(
                  label: Text(s, style: const TextStyle(fontSize: 10)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.primaryLight,
                  side: BorderSide.none,
                )).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: place.latitude != null && place.longitude != null
                        ? () => _launchDirections(place.latitude!, place.longitude!, place.name)
                        : null,
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Directions'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOpen,
                    child: Text(isScrapyard ? 'View Scrapyard' : 'View Garage'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

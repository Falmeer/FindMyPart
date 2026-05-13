import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/garage_model.dart';
import '../data/repositories/garages_repository.dart';
import '../../../core/constants/app_constants.dart';

final nearbyGaragesProvider = FutureProvider<List<GarageModel>>((ref) async {
  try {
    final permission = await Geolocator.checkPermission();
    LocationPermission resolved = permission;

    if (permission == LocationPermission.denied) {
      resolved = await Geolocator.requestPermission();
    }

    if (resolved == LocationPermission.whileInUse ||
        resolved == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();
      return ref.read(garagesRepositoryProvider).getGarages(
            lat: position.latitude,
            lng: position.longitude,
            radius: AppConstants.nearbyRadiusKm,
          );
    }
  } catch (_) {}

  return ref.read(garagesRepositoryProvider).getGarages();
});

final garagesListProvider =
    FutureProvider.family<List<GarageModel>, String?>((ref, search) async {
  return ref.read(garagesRepositoryProvider).getGarages(search: search);
});

final garageDetailProvider = FutureProvider.family<GarageModel, int>((ref, id) async {
  return ref.read(garagesRepositoryProvider).getGarage(id);
});

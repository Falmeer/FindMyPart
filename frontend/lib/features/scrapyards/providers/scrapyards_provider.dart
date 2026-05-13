import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/scrapyard_model.dart';
import '../data/repositories/scrapyards_repository.dart';
import '../../../core/constants/app_constants.dart';

final nearbyScrapyardsProvider = FutureProvider<List<ScrapyardModel>>((ref) async {
  try {
    final permission = await Geolocator.checkPermission();
    LocationPermission resolved = permission;

    if (permission == LocationPermission.denied) {
      resolved = await Geolocator.requestPermission();
    }

    if (resolved == LocationPermission.whileInUse ||
        resolved == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();
      return ref.read(scrapyardsRepositoryProvider).getScrapyards(
            lat: position.latitude,
            lng: position.longitude,
            radius: AppConstants.nearbyRadiusKm,
          );
    }
  } catch (_) {}

  return ref.read(scrapyardsRepositoryProvider).getScrapyards();
});

final scrapyardsListProvider =
    FutureProvider.family<List<ScrapyardModel>, String?>((ref, search) async {
  return ref.read(scrapyardsRepositoryProvider).getScrapyards(search: search);
});

final scrapyardDetailProvider =
    FutureProvider.family<ScrapyardModel, int>((ref, id) async {
  return ref.read(scrapyardsRepositoryProvider).getScrapyard(id);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../salvaged_vehicles/data/models/vehicle_model.dart';
import '../../spare_parts/data/models/spare_part_model.dart';
import '../../garages/data/models/garage_model.dart';
import '../../scrapyards/data/models/scrapyard_model.dart';
import '../data/repositories/favorites_repository.dart';

final favoriteVehiclesProvider = FutureProvider<List<VehicleModel>>((ref) {
  return ref.read(favoritesRepositoryProvider).getFavoriteVehicles();
});

final favoritePartsProvider = FutureProvider<List<SparePartModel>>((ref) {
  return ref.read(favoritesRepositoryProvider).getFavoriteParts();
});

final favoriteGaragesProvider = FutureProvider<List<GarageModel>>((ref) {
  return ref.read(favoritesRepositoryProvider).getFavoriteGarages();
});

final favoriteScrapyardsProvider = FutureProvider<List<ScrapyardModel>>((ref) {
  return ref.read(favoritesRepositoryProvider).getFavoriteScrapyards();
});

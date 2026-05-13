import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../salvaged_vehicles/data/models/vehicle_model.dart';
import '../../../spare_parts/data/models/spare_part_model.dart';
import '../../../garages/data/models/garage_model.dart';
import '../../../scrapyards/data/models/scrapyard_model.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.read(apiClientProvider));
});

class FavoritesRepository {
  final ApiClient _client;
  FavoritesRepository(this._client);

  Future<List<VehicleModel>> getFavoriteVehicles() async {
    final response = await _client.get('/favorites', queryParameters: {'type': 'vehicle'});
    final data = response.data['data'] as List;
    return data.map((e) => VehicleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SparePartModel>> getFavoriteParts() async {
    final response = await _client.get('/favorites', queryParameters: {'type': 'part'});
    final data = response.data['data'] as List;
    return data.map((e) => SparePartModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<GarageModel>> getFavoriteGarages() async {
    final response = await _client.get('/favorites', queryParameters: {'type': 'garage'});
    final data = response.data['data'] as List;
    return data.map((e) => GarageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ScrapyardModel>> getFavoriteScrapyards() async {
    final response = await _client.get('/favorites', queryParameters: {'type': 'scrapyard'});
    final data = response.data['data'] as List;
    return data.map((e) => ScrapyardModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<bool> toggle(String type, int id) async {
    final response = await _client.post('/favorites/toggle', data: {'type': type, 'id': id});
    return response.data['favorited'] as bool;
  }
}

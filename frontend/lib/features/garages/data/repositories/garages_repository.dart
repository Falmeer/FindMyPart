import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/garage_model.dart';

final garagesRepositoryProvider = Provider<GaragesRepository>((ref) {
  return GaragesRepository(ref.read(apiClientProvider));
});

class GaragesRepository {
  final ApiClient _client;
  GaragesRepository(this._client);

  Future<List<GarageModel>> getGarages({
    int page = 1,
    double? lat,
    double? lng,
    double? radius,
    String? search,
  }) async {
    final response = await _client.get('/garages', queryParameters: {
      'page': page,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (radius != null) 'radius': radius,
      if (search != null) 'search': search,
    });
    final data = response.data['data'] as List;
    return data.map((e) => GarageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GarageModel> getGarage(int id) async {
    final response = await _client.get('/garages/$id');
    return GarageModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> postIssue(Map<String, dynamic> data) async {
    await _client.post('/vehicle-issues', data: data);
  }
}

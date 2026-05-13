import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/scrapyard_model.dart';

final scrapyardsRepositoryProvider = Provider<ScrapyardsRepository>((ref) {
  return ScrapyardsRepository(ref.read(apiClientProvider));
});

class ScrapyardsRepository {
  final ApiClient _client;
  ScrapyardsRepository(this._client);

  Future<List<ScrapyardModel>> getScrapyards({
    int page = 1,
    double? lat,
    double? lng,
    double? radius,
    String? search,
  }) async {
    final response = await _client.get('/scrapyards', queryParameters: {
      'page': page,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (radius != null) 'radius': radius,
      if (search != null) 'search': search,
    });
    final data = response.data['data'] as List;
    return data.map((e) => ScrapyardModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ScrapyardModel> getScrapyard(int id) async {
    final response = await _client.get('/scrapyards/$id');
    return ScrapyardModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

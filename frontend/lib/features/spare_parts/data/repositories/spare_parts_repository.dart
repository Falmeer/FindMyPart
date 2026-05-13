import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/image_picker_grid.dart';
import '../models/spare_part_model.dart';

final sparePartsRepositoryProvider = Provider<SparePartsRepository>((ref) {
  return SparePartsRepository(ref.read(apiClientProvider));
});

class SparePartsRepository {
  final ApiClient _client;
  SparePartsRepository(this._client);

  Future<List<SparePartModel>> getParts({
    int page = 1,
    String? category,
    String? condition,
    double? minPrice,
    double? maxPrice,
    String? search,
  }) async {
    final response = await _client.get('/spare-parts', queryParameters: {
      'page': page,
      if (category != null) 'category': category,
      if (condition != null) 'condition': condition,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (search != null) 'search': search,
    });
    final data = response.data['data'] as List;
    return data.map((e) => SparePartModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SparePartModel> getPart(int id) async {
    final response = await _client.get('/spare-parts/$id');
    return SparePartModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<SparePartModel> createPart({
    required Map<String, dynamic> fields,
    List<PickedImage> images = const [],
  }) async {
    final formData = FormData.fromMap({
      ...fields,
      if (images.isNotEmpty)
        'images[]': images.map((img) {
          final ext = img.name.split('.').last.toLowerCase();
          final subtype = ext == 'jpg' ? 'jpeg' : ext;
          return MultipartFile.fromBytes(
            img.bytes,
            filename: img.name,
            contentType: DioMediaType('image', subtype),
          );
        }).toList(),
    });
    final response = await _client.post('/spare-parts', data: formData);
    return SparePartModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

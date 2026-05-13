import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/image_picker_grid.dart';
import '../models/vehicle_model.dart';

final vehiclesRepositoryProvider = Provider<VehiclesRepository>((ref) {
  return VehiclesRepository(ref.read(apiClientProvider));
});

class VehiclesRepository {
  final ApiClient _client;
  VehiclesRepository(this._client);

  Future<List<VehicleModel>> getVehicles({
    int page = 1,
    String? brand,
    String? model,
    int? yearFrom,
    int? yearTo,
    String? condition,
    String? search,
  }) async {
    final response = await _client.get('/vehicles', queryParameters: {
      'page': page,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (yearFrom != null) 'year_from': yearFrom,
      if (yearTo != null) 'year_to': yearTo,
      if (condition != null) 'condition': condition,
      if (search != null) 'search': search,
    });
    final data = response.data['data'] as List;
    return data.map((e) => VehicleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<VehicleModel> getVehicle(int id) async {
    final response = await _client.get('/vehicles/$id');
    return VehicleModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<VehicleModel> createVehicle({
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
    final response = await _client.post('/vehicles', data: formData);
    return VehicleModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteVehicle(int id) => _client.delete('/vehicles/$id');
}

import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/warning_light_result.dart';

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return AIRepository(ref.read(apiClientProvider));
});

class AIRepository {
  final ApiClient _client;
  AIRepository(this._client);

  Future<WarningLightResult> analyzeWarningLight(
      Uint8List imageBytes, String filename) async {
    final ext = filename.split('.').last.toLowerCase();
    final subtype = ext == 'jpg' ? 'jpeg' : ext;

    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: filename,
        contentType: DioMediaType('image', subtype),
      ),
    });

    final response = await _client.post(
      '/ai/warning-light',
      data: formData,
    );

    return WarningLightResult.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}

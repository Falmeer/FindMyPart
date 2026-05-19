import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) => _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) => _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  Future<Response> postMultipart(String path, FormData formData) =>
      _dio.post(path, data: formData);
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appEx;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        appEx = const NetworkException('Connection timed out. Check your internet.');
      case DioExceptionType.connectionError:
        appEx = const NetworkException('No internet connection.');
      default:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        final msg = data is Map ? (data['message'] ?? 'Something went wrong').toString() : 'Something went wrong';

        switch (statusCode) {
          case 401:
            appEx = const UnauthorizedException();
          case 404:
            appEx = NotFoundException(msg);
          case 422:
            final errors = <String, List<String>>{};
            if (data is Map && data['errors'] is Map) {
              (data['errors'] as Map).forEach((k, v) {
                errors[k.toString()] = (v as List).map((e) => e.toString()).toList();
              });
            }
            appEx = ValidationException(msg, errors);
          case 500:
            appEx = const ServerException();
          default:
            appEx = NetworkException(msg, statusCode: statusCode);
        }
    }

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      message: appEx.message,
      error: appEx,
    ));
  }
}

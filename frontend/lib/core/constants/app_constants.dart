class AppConstants {
  AppConstants._();

  static const String appName = 'FindMyPart';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Reverb / WebSocket
  static const String reverbKey    = 'aeusmpjdjjk62m1oi14d';
  static const String reverbHost   = 'localhost';
  static const int    reverbPort   = 8080;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';

  // Pagination
  static const int defaultPageSize = 15;

  // Map — default center: Manama, Bahrain
  static const double defaultLat = 26.2154;
  static const double defaultLng = 50.5832;
  static const double defaultZoom = 13.0;
  static const double nearbyRadiusKm = 10.0;
}

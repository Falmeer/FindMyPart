abstract class BusinessPlace {
  int get id;
  int? get userId;
  String get name;
  String get description;
  List<String> get services;
  String? get workingHours;
  String? get phone;
  String? get address;
  double? get latitude;
  double? get longitude;
  List<String> get images;
  double get rating;
  int get reviewCount;
  double? get distanceKm;
  bool get isFavorited;
  String? get thumbnailUrl;
  String get routePrefix;
  String get favoriteType;
}

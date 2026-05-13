import '../../../../core/models/business_place.dart';

class ScrapyardModel implements BusinessPlace {
  @override final int id;
  @override final int? userId;
  @override final String name;
  @override final String description;
  @override final List<String> services;
  @override final String? workingHours;
  @override final String? phone;
  @override final String? address;
  @override final double? latitude;
  @override final double? longitude;
  @override final List<String> images;
  @override final double rating;
  @override final int reviewCount;
  @override final double? distanceKm;
  @override final bool isFavorited;

  const ScrapyardModel({
    required this.id,
    this.userId,
    required this.name,
    required this.description,
    required this.services,
    this.workingHours,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    required this.images,
    required this.rating,
    required this.reviewCount,
    this.distanceKm,
    this.isFavorited = false,
  });

  @override String? get thumbnailUrl => images.isNotEmpty ? images.first : null;
  @override String get routePrefix => '/scrapyards';
  @override String get favoriteType => 'scrapyard';

  factory ScrapyardModel.fromJson(Map<String, dynamic> json) => ScrapyardModel(
        id: json['id'] as int,
        userId: json['user_id'] as int?,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        services: (json['services'] as List?)?.map((e) => e.toString()).toList() ?? [],
        workingHours: json['working_hours'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        images: (json['images'] as List?)?.map((e) => e['url'] as String).toList() ?? [],
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: json['review_count'] as int? ?? 0,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        isFavorited: json['is_favorited'] as bool? ?? false,
      );
}

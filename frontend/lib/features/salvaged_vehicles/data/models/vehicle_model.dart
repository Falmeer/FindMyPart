class VehicleModel {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String? engine;
  final String? transmission;
  final int? mileage;
  final String condition;
  final String? vin;
  final String description;
  final double? price;
  final List<String> images;
  final String sellerName;
  final String? sellerPhone;
  final int sellerId;
  final bool isFavorited;
  final DateTime createdAt;

  const VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.engine,
    this.transmission,
    this.mileage,
    required this.condition,
    this.vin,
    required this.description,
    this.price,
    required this.images,
    required this.sellerName,
    this.sellerPhone,
    required this.sellerId,
    this.isFavorited = false,
    required this.createdAt,
  });

  String get title => '$year $brand $model';
  String? get thumbnailUrl => images.isNotEmpty ? images.first : null;

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'] as int,
        brand: json['brand'] as String,
        model: json['model'] as String,
        year: (json['year'] as num?)?.toInt() ?? int.parse(json['year'].toString()),
        engine: json['engine'] as String?,
        transmission: json['transmission'] as String?,
        mileage: json['mileage'] != null ? (json['mileage'] as num).toInt() : null,
        condition: json['condition'] as String? ?? 'Used',
        vin: json['vin'] as String?,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble(),
        images: (json['images'] as List?)?.map((e) => e['url'] as String).toList() ?? [],
        sellerName: json['seller']?['name'] as String? ?? 'Unknown',
        sellerPhone: json['seller']?['phone'] as String?,
        sellerId: json['user_id'] as int? ?? 0,
        isFavorited: json['is_favorited'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

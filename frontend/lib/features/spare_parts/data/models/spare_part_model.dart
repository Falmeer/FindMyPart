class SparePartModel {
  final int id;
  final String name;
  final String category;
  final String condition;
  final double price;
  final int quantity;
  final String description;
  final List<String> images;
  final String? compatibility;
  final bool hasWarranty;
  final String sellerName;
  final String? sellerPhone;
  final int sellerId;
  final bool isFavorited;
  final DateTime createdAt;

  const SparePartModel({
    required this.id,
    required this.name,
    required this.category,
    required this.condition,
    required this.price,
    required this.quantity,
    required this.description,
    required this.images,
    this.compatibility,
    this.hasWarranty = false,
    required this.sellerName,
    this.sellerPhone,
    required this.sellerId,
    this.isFavorited = false,
    required this.createdAt,
  });

  String? get thumbnailUrl => images.isNotEmpty ? images.first : null;

  factory SparePartModel.fromJson(Map<String, dynamic> json) => SparePartModel(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category']?['name'] as String? ?? json['category'] as String? ?? 'Other',
        condition: json['condition'] as String? ?? 'Used',
        price: double.parse(json['price'].toString()),
        quantity: int.parse(json['quantity']?.toString() ?? '1'),
        description: json['description'] as String? ?? '',
        images: (json['images'] as List?)?.map((e) => e['url'] as String).toList() ?? [],
        compatibility: json['compatibility'] as String?,
        hasWarranty: json['has_warranty'] == true || json['has_warranty'] == 1,
        sellerName: json['seller']?['name'] as String? ?? 'Unknown',
        sellerPhone: json['seller']?['phone'] as String?,
        sellerId: json['user_id'] as int? ?? 0,
        isFavorited: json['is_favorited'] == true || json['is_favorited'] == 1,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

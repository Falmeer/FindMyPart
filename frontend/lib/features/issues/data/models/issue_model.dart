class OfferModel {
  final int id;
  final int garageId;
  final String garageName;
  final String message;
  final double? price;
  final String status; // pending, accepted, rejected

  const OfferModel({
    required this.id,
    required this.garageId,
    required this.garageName,
    required this.message,
    this.price,
    required this.status,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
        id: json['id'] as int,
        garageId: json['garage_id'] as int,
        garageName: (json['garage'] as Map<String, dynamic>?)?['name'] as String? ?? 'Unknown Garage',
        message: json['message'] as String,
        price: (json['price'] as num?)?.toDouble(),
        status: json['status'] as String? ?? 'pending',
      );
}

class IssueModel {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String description;
  final String status; // open, in_progress, resolved, closed
  final int offerCount;
  final List<OfferModel> offers;
  final String? userName;
  final String? userPhone;
  final OfferModel? myOffer;
  final DateTime createdAt;

  const IssueModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.description,
    required this.status,
    required this.offerCount,
    required this.offers,
    this.userName,
    this.userPhone,
    this.myOffer,
    required this.createdAt,
  });

  String get vehicleLabel => '$year $brand $model';

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    final offersList = (json['offers'] as List?)
            ?.map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final myOfferJson = json['my_offer'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;

    return IssueModel(
      id: json['id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'open',
      offerCount: json['offer_count'] as int? ?? offersList.length,
      offers: offersList,
      userName: userJson?['name'] as String?,
      userPhone: userJson?['phone'] as String?,
      myOffer: myOfferJson != null ? OfferModel.fromJson(myOfferJson) : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

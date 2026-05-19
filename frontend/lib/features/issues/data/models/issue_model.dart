class IssueCommentModel {
  final int id;
  final int userId;
  final String userName;
  final String body;
  final DateTime createdAt;

  const IssueCommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.body,
    required this.createdAt,
  });

  factory IssueCommentModel.fromJson(Map<String, dynamic> json) => IssueCommentModel(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        userName: json['user_name'] as String? ?? 'Anonymous',
        body: json['body'] as String,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class IssueModel {
  final int id;
  final int userId;
  final String brand;
  final String model;
  final int year;
  final String description;
  final String status;
  final int commentCount;
  final List<IssueCommentModel> comments;
  final String? userName;
  final DateTime createdAt;

  const IssueModel({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    required this.description,
    required this.status,
    required this.commentCount,
    required this.comments,
    this.userName,
    required this.createdAt,
  });

  String get vehicleLabel => '$year $brand $model';

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    final commentsList = (json['comments'] as List?)
            ?.map((e) => IssueCommentModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final userJson = json['user'] as Map<String, dynamic>?;

    return IssueModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? userJson?['id'] as int? ?? 0,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'open',
      commentCount: json['comment_count'] as int? ?? commentsList.length,
      comments: commentsList,
      userName: userJson?['name'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

import 'dart:convert';

class ShareCard {
  final String kind; // 'vehicle', 'part', 'issue'
  final int id;
  final String title;
  final String subtitle;
  final String? imageUrl;

  const ShareCard({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  String toMessageBody() => jsonEncode({
        '_share_type': kind,
        'id': id,
        'title': title,
        'subtitle': subtitle,
        if (imageUrl != null) 'image_url': imageUrl,
      });

  static ShareCard? tryParse(String body) {
    if (!body.startsWith('{')) return null;
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      final kind = map['_share_type'] as String?;
      if (kind == null) return null;
      return ShareCard(
        kind: kind,
        id: map['id'] as int,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String,
        imageUrl: map['image_url'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  String get routePath {
    switch (kind) {
      case 'vehicle':
        return '/vehicles/$id';
      case 'part':
        return '/parts/$id';
      case 'issue':
        return '/issues/$id';
      default:
        return '/';
    }
  }

  String get kindLabel {
    switch (kind) {
      case 'vehicle':
        return 'Salvaged Vehicle';
      case 'part':
        return 'Spare Part';
      case 'issue':
        return 'Car Issue';
      default:
        return 'Listing';
    }
  }
}

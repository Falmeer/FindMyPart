class WarningLightItem {
  final String name;
  final String explanation;
  final String severity; // 'low' | 'medium' | 'high'
  final String action;

  const WarningLightItem({
    required this.name,
    required this.explanation,
    required this.severity,
    required this.action,
  });

  factory WarningLightItem.fromJson(Map<String, dynamic> json) =>
      WarningLightItem(
        name: json['name'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        severity: json['severity'] as String? ?? 'low',
        action: json['action'] as String? ?? '',
      );
}

class WarningLightResult {
  final bool identified;
  final List<WarningLightItem> lights;
  final String? message; // when not identified

  const WarningLightResult({
    required this.identified,
    this.lights = const [],
    this.message,
  });

  factory WarningLightResult.fromJson(Map<String, dynamic> json) {
    final identified = json['identified'] as bool? ?? false;
    final rawLights = json['lights'];
    final lights = identified && rawLights is List
        ? rawLights
            .whereType<Map<String, dynamic>>()
            .map(WarningLightItem.fromJson)
            .toList()
        : <WarningLightItem>[];
    return WarningLightResult(
      identified: identified,
      lights: lights,
      message: json['message'] as String?,
    );
  }
}

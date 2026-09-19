class CommodityProfile {
  CommodityProfile({
    required this.id,
    required this.name,
    required this.variety,
    required this.version,
    required this.method,
    Map<String, dynamic>? features,
    Map<String, dynamic>? grades,
    Map<String, dynamic>? firmness,
    Map<String, dynamic>? calibration,
    this.createdAt,
  })  : features = features ?? {},
        grades = grades ?? {'A': {}, 'B': {}, 'REJECT': {}},
        firmness = firmness ?? {},
        calibration = calibration ?? {
          'sample_count': 0,
          'calibrated_at': DateTime.now().toIso8601String(),
        };

  final String id;
  final String name;
  final String variety;
  final int version;
  final String method;
  final Map<String, dynamic> features;
  final Map<String, dynamic> grades;
  final Map<String, dynamic> firmness;
  final Map<String, dynamic> calibration;
  final DateTime? createdAt;

  List<String> get gradeLabels => grades.keys.toList();

  factory CommodityProfile.fromJson(Map<String, dynamic> json) {
    return CommodityProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      variety: json['variety'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      method: json['method'] as String? ?? 'hsv_geometry',
      features: Map<String, dynamic>.from(json['features'] as Map? ?? {}),
      grades: Map<String, dynamic>.from(json['grades'] as Map? ?? {'A': {}, 'B': {}, 'REJECT': {}}),
      firmness: Map<String, dynamic>.from(json['firmness'] as Map? ?? {}),
      calibration: Map<String, dynamic>.from(json['calibration'] as Map? ?? {}),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'variety': variety,
      'version': version,
      'method': method,
      'features': features,
      'grades': grades,
      'firmness': firmness,
      'calibration': calibration,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }
}

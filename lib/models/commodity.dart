import 'dart:convert';

class Commodity {
  Commodity({
    required this.id,
    required this.name,
    required this.variety,
    this.version = 1,
    this.method = 'hsv_geometry',
    Map<String, dynamic>? features,
    Map<String, dynamic>? grades,
    Map<String, dynamic>? firmness,
    Map<String, dynamic>? calibration,
    DateTime? createdAt,
  }) : features = features ?? {'color': {}, 'geometry': {}},
       grades = grades ?? {'A': {}, 'B': {}, 'REJECT': {}},
       firmness = firmness ?? {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
       calibration =
           calibration ??
           {
             'sample_count': 0,
             'calibrated_at': (createdAt ?? DateTime.now()).toIso8601String(),
           },
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String variety;
  final int version;
  final String method;
  final Map<String, dynamic> features;
  final Map<String, dynamic> grades;
  final Map<String, dynamic> firmness;
  final Map<String, dynamic> calibration;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'variety': variety,
      'version': version,
      'method': method,
      'features': jsonEncode(features),
      'grades': jsonEncode(grades),
      'firmness': jsonEncode(firmness),
      'calibration': jsonEncode(calibration),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Commodity.fromMap(Map<String, dynamic> map) {
    return Commodity(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      variety: map['variety'] as String? ?? '',
      version: map['version'] as int? ?? 1,
      method: map['method'] as String? ?? 'hsv_geometry',
      features: _decodeMap(map['features'], {'color': {}, 'geometry': {}}),
      grades: _decodeMap(map['grades'], {'A': {}, 'B': {}, 'REJECT': {}}),
      firmness: _decodeMap(map['firmness'], {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'}),
      calibration: _decodeMap(map['calibration'], {'sample_count': 0}),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  static Map<String, dynamic> _decodeMap(Object? value, Map<String, dynamic> fallback) {
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      try {
        return Map<String, dynamic>.from(jsonDecode(value) as Map);
      } catch (_) {}
    }
    return fallback;
  }
}

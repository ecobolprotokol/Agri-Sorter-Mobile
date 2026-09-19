import 'dart:convert';

class SortingResult {
  SortingResult({
    required this.resultId,
    required this.sessionId,
    required this.commodityId,
    required this.profileVersion,
    required this.grade,
    required this.confidence,
    required this.firmness,
    required this.timestamp,
    this.ripePercentage,
    this.imagePath,
    this.reason = const [],
    this.visionFeatures = const {},
  });

  final String resultId;
  final String sessionId;
  final String commodityId;
  final int profileVersion;
  final String grade;
  final double confidence;
  final String firmness;
  final DateTime timestamp;
  final double? ripePercentage;
  final String? imagePath;
  final List<String> reason;
  final Map<String, dynamic> visionFeatures;

  Map<String, dynamic> toJson() {
    return {
      'result_id': resultId,
      'session_id': sessionId,
      'commodity_id': commodityId,
      'profile_version': profileVersion,
      'grade': grade,
      'confidence': confidence,
      'firmness': firmness,
      'timestamp': timestamp.toIso8601String(),
      'ripe_percentage': ripePercentage,
      'image_path': imagePath,
      'reason': jsonEncode(reason),
      'vision_features': jsonEncode(visionFeatures),
    };
  }

  factory SortingResult.fromJson(Map<String, dynamic> json) {
    return SortingResult(
      resultId: (json['result_id'] ?? json['resultId']) as String? ?? '',
      sessionId: (json['session_id'] ?? json['sessionId']) as String? ?? '',
      commodityId: (json['commodity_id'] ?? json['commodityId']) as String? ?? '',
      profileVersion: (json['profile_version'] ?? json['profileVersion']) as int? ?? 1,
      grade: json['grade'] as String? ?? 'REJECT',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      firmness: json['firmness'] as String? ?? 'MEDIUM',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      ripePercentage: ((json['ripe_percentage'] ?? json['ripePercentage']) as num?)?.toDouble(),
      imagePath: (json['image_path'] ?? json['imagePath']) as String?,
      reason: _decodeList(json['reason']),
      visionFeatures: _decodeMap(json['vision_features']),
    );
  }

  static List<String> _decodeList(Object? value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    if (value is String) {
      try {
        return List<String>.from(jsonDecode(value) as List);
      } catch (_) {}
    }
    return const [];
  }

  static Map<String, dynamic> _decodeMap(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      try {
        return Map<String, dynamic>.from(jsonDecode(value) as Map);
      } catch (_) {}
    }
    return const {};
  }
}

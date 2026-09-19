class GradingResult {
  GradingResult({
    required this.grade,
    required this.confidence,
    required this.ripePercentage,
    required this.firmness,
    required this.reason,
    this.uncertain = false,
    this.visionFeatures = const {},
  });

  final String grade;
  final double confidence;
  final double ripePercentage;
  final String firmness;
  final List<String> reason;
  final bool uncertain;
  final Map<String, dynamic> visionFeatures;

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'confidence': confidence,
      'ripe_percentage': ripePercentage,
      'firmness': firmness,
      'reason': reason,
      'uncertain': uncertain,
      'vision_features': visionFeatures,
    };
  }

  factory GradingResult.fromMap(Map<String, dynamic> map) {
    return GradingResult(
      grade: map['grade'] as String? ?? 'REJECT',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0,
      ripePercentage: (map['ripe_percentage'] as num?)?.toDouble() ?? 0,
      firmness: map['firmness'] as String? ?? 'MEDIUM',
      reason: List<String>.from(map['reason'] as List? ?? const []),
      uncertain: map['uncertain'] as bool? ?? false,
      visionFeatures: Map<String, dynamic>.from(map['vision_features'] as Map? ?? const {}),
    );
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'resultId': resultId,
      'sessionId': sessionId,
      'commodityId': commodityId,
      'profileVersion': profileVersion,
      'grade': grade,
      'confidence': confidence,
      'firmness': firmness,
      'timestamp': timestamp.toIso8601String(),
      'ripePercentage': ripePercentage,
      'imagePath': imagePath,
    };
  }

  factory SortingResult.fromJson(Map<String, dynamic> json) {
    return SortingResult(
      resultId: json['resultId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      commodityId: json['commodityId'] as String? ?? '',
      profileVersion: json['profileVersion'] as int? ?? 1,
      grade: json['grade'] as String? ?? 'REJECT',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      firmness: json['firmness'] as String? ?? 'MEDIUM',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      ripePercentage: (json['ripePercentage'] as num?)?.toDouble(),
      imagePath: json['imagePath'] as String?,
    );
  }
}

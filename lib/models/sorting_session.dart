class SortingSession {
  SortingSession({
    required this.id,
    required this.startedAt,
    this.finishedAt,
    this.operator,
    this.location,
    this.commodity,
    this.totalItems = 0,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? operator;
  final String? location;
  final String? commodity;
  final int totalItems;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'operator': operator,
      'location': location,
      'commodity': commodity,
      'totalItems': totalItems,
    };
  }

  factory SortingSession.fromJson(Map<String, dynamic> json) {
    return SortingSession(
      id: json['id'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ?? DateTime.now(),
      finishedAt: json['finishedAt'] != null ? DateTime.tryParse(json['finishedAt'] as String) : null,
      operator: json['operator'] as String?,
      location: json['location'] as String?,
      commodity: json['commodity'] as String?,
      totalItems: json['totalItems'] as int? ?? 0,
    );
  }
}

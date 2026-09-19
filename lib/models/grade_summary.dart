class GradeSummary {
  const GradeSummary({
    required this.total,
    required this.gradeA,
    required this.gradeB,
    required this.reject,
  });

  final int total;
  final int gradeA;
  final int gradeB;
  final int reject;

  double get gradeAPercentage => total == 0 ? 0 : (gradeA / total) * 100;

  double get gradeBPercentage => total == 0 ? 0 : (gradeB / total) * 100;

  double get rejectPercentage => total == 0 ? 0 : (reject / total) * 100;

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'gradeA': gradeA,
      'gradeB': gradeB,
      'reject': reject,
    };
  }

  factory GradeSummary.fromJson(Map<String, dynamic> json) {
    return GradeSummary(
      total: json['total'] as int? ?? 0,
      gradeA: json['gradeA'] as int? ?? 0,
      gradeB: json['gradeB'] as int? ?? 0,
      reject: json['reject'] as int? ?? 0,
    );
  }
}

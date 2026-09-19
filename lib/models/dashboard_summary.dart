import 'sorting_result.dart';

class DashboardSummary {
  DashboardSummary({
    required this.totalItems,
    required this.gradeA,
    required this.gradeB,
    required this.reject,
  });

  final int totalItems;
  final int gradeA;
  final int gradeB;
  final int reject;

  double get gradeAPercentage =>
      totalItems == 0 ? 0 : (gradeA / totalItems) * 100;

  double get gradeBPercentage =>
      totalItems == 0 ? 0 : (gradeB / totalItems) * 100;

  double get rejectPercentage =>
      totalItems == 0 ? 0 : (reject / totalItems) * 100;

  factory DashboardSummary.fromResults(List<SortingResult> results) {
    var a = 0;
    var b = 0;
    var reject = 0;

    for (final result in results) {
      switch (result.grade.toUpperCase()) {
        case 'A':
          a++;
          break;
        case 'B':
          b++;
          break;
        case 'REJECT':
        case 'AFKIR':
          reject++;
          break;
        default:
          reject++;
      }
    }

    return DashboardSummary(
      totalItems: results.length,
      gradeA: a,
      gradeB: b,
      reject: reject,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'gradeA': gradeA,
      'gradeB': gradeB,
      'reject': reject,
    };
  }
}

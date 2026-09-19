import 'package:flutter_test/flutter_test.dart';
import 'package:agri_sorter_mobile/models/commodity_profile.dart';
import 'package:agri_sorter_mobile/models/grade_summary.dart';

void main() {
  group('CommodityProfile', () {
    test('creates default grade labels for a commodity profile', () {
      final profile = CommodityProfile(
        id: 'papaya_california',
        name: 'Pepaya',
        variety: 'California',
        version: 1,
        method: 'hsv_geometry',
        grades: {'A': {}, 'B': {}, 'REJECT': {}},
      );

      expect(profile.gradeLabels, containsAll(['A', 'B', 'REJECT']));
      expect(profile.gradeLabels.length, 3);
    });
  });

  group('GradeSummary', () {
    test('calculates grade percentages from totals', () {
      final summary = GradeSummary(
        total: 400,
        gradeA: 200,
        gradeB: 120,
        reject: 80,
      );

      expect(summary.gradeAPercentage, closeTo(50.0, 0.01));
      expect(summary.gradeBPercentage, closeTo(30.0, 0.01));
      expect(summary.rejectPercentage, closeTo(20.0, 0.01));
    });
  });
}

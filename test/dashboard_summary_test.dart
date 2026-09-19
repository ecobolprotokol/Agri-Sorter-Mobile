import 'package:flutter_test/flutter_test.dart';
import 'package:agri_sorter_mobile/models/dashboard_summary.dart';
import 'package:agri_sorter_mobile/models/sorting_result.dart';

void main() {
  test('dashboard summary aggregates results by grade', () {
    final results = [
      SortingResult(
        resultId: 'r1',
        sessionId: 's1',
        commodityId: 'papaya',
        profileVersion: 1,
        grade: 'A',
        confidence: 91,
        firmness: 'FIRM',
        timestamp: DateTime(2026, 9, 19),
      ),
      SortingResult(
        resultId: 'r2',
        sessionId: 's1',
        commodityId: 'papaya',
        profileVersion: 1,
        grade: 'B',
        confidence: 72,
        firmness: 'MEDIUM',
        timestamp: DateTime(2026, 9, 19, 1),
      ),
      SortingResult(
        resultId: 'r3',
        sessionId: 's2',
        commodityId: 'tomato',
        profileVersion: 1,
        grade: 'REJECT',
        confidence: 40,
        firmness: 'SOFT',
        timestamp: DateTime(2026, 9, 19, 2),
      ),
    ];

    final summary = DashboardSummary.fromResults(results);

    expect(summary.totalItems, 3);
    expect(summary.gradeA, 1);
    expect(summary.gradeB, 1);
    expect(summary.reject, 1);
    expect(summary.gradeAPercentage, closeTo(33.33, 0.01));
    expect(summary.gradeBPercentage, closeTo(33.33, 0.01));
    expect(summary.rejectPercentage, closeTo(33.33, 0.01));
  });
}

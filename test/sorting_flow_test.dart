import 'package:flutter_test/flutter_test.dart';
import 'package:agri_sorter_mobile/models/commodity.dart';
import 'package:agri_sorter_mobile/services/grading_engine.dart';

void main() {
  test('grading engine returns a valid grade when firmness and visual score are strong', () {
    final commodity = Commodity(
      id: 'papaya',
      name: 'Pepaya',
      variety: 'California',
      version: 1,
      features: {
        'color': {'hue_mean': 42.5},
        'geometry': {'circularity': 0.87},
      },
      grades: {'A': {}, 'B': {}, 'REJECT': {}},
      firmness: {'FIRM': '1', 'MEDIUM': '2', 'SOFT': '3'},
      calibration: {'sample_count': 50},
    );

    final result = GradingEngine().grade(
      commodity: commodity,
      ripePercentage: 92,
      hueMean: 42.5,
      circularity: 0.87,
      firmness: 'FIRM',
    );

    expect(result.grade, 'A');
    expect(result.confidence, greaterThan(80));
  });
}

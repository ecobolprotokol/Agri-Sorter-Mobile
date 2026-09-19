import '../models/commodity.dart';
import '../models/grading_result.dart';

class GradingEngine {
  GradingEngine();

  GradingResult grade({
    required Commodity commodity,
    required double ripePercentage,
    required double hueMean,
    required double circularity,
    required String firmness,
  }) {
    final visualScore = _computeVisualScore(
      ripePercentage: ripePercentage,
      hueMean: hueMean,
      circularity: circularity,
      commodity: commodity,
    );

    final firmnessScore = _firmnessScore(firmness);
    final finalScore = visualScore + firmnessScore;

    final reason = <String>[];
    final colorTarget = ((commodity.features['color'] as Map?)?['hue_mean'] as num?)?.toDouble() ?? 42.5;
    final colorScore = (1 - ((hueMean - colorTarget).abs() / 60)).clamp(0.0, 1.0);
    final geometryScore = circularity.clamp(0.0, 1.0);
    final maturityThreshold = _threshold(commodity, 'A', 0.8) * 100;
    String grade;

    if (finalScore >= _threshold(commodity, 'A', 0.8)) {
      grade = 'A';
    } else if (finalScore >= _threshold(commodity, 'B', 0.5)) {
      grade = 'B';
    } else {
      grade = 'REJECT';
    }

    reason.add(colorScore >= 0.6 && ripePercentage >= maturityThreshold
        ? '✓ Kematangan dan warna sesuai profile'
        : '✗ Kematangan atau warna di bawah profile');
    reason.add(geometryScore >= 0.6 ? '✓ Bentuk sesuai profile' : '✗ Bentuk perlu diperiksa');
    reason.add(firmness.toUpperCase() == 'SOFT' ? '✗ Firmness terlalu lunak' : '✓ Firmness operator sesuai');

    final confidence = (finalScore * 100).clamp(0, 100).toDouble();

    final uncertain = grade == 'B' && confidence < 70;

    return GradingResult(
      grade: grade,
      confidence: confidence,
      ripePercentage: ripePercentage,
      firmness: firmness,
      reason: reason,
      uncertain: uncertain,
      visionFeatures: {
        'ripe_percentage': ripePercentage,
        'hue_mean': hueMean,
        'circularity': circularity,
      },
    );
  }

  double _computeVisualScore({
    required double ripePercentage,
    required double hueMean,
    required double circularity,
    required Commodity commodity,
  }) {
    final colorScore = (ripePercentage / 100).clamp(0.0, 1.0);
    final colorTarget = ((commodity.features['color'] as Map?)?['hue_mean'] as num?)?.toDouble() ?? 42.5;
    final hueScore = (1 - ((hueMean - colorTarget).abs() / 60)).clamp(0.0, 1.0);
    final geometryScore = circularity.clamp(0.0, 1.0);

    final weights = commodity.features['weights'] as Map?;
    final colorWeight = (weights?['color'] as num?)?.toDouble() ?? 0.6;
    final geometryWeight = (weights?['geometry'] as num?)?.toDouble() ?? 0.4;

    return (colorScore * colorWeight) +
        (hueScore * 0.2) +
        (geometryScore * geometryWeight);
  }

  double _threshold(Commodity commodity, String grade, double fallback) {
    final value = (commodity.grades[grade] as Map?)?['threshold'];
    return value is num ? value.toDouble() : fallback;
  }

  double _firmnessScore(String firmness) {
    switch (firmness.toUpperCase()) {
      case 'FIRM':
        return 0.2;
      case 'MEDIUM':
        return 0.12;
      case 'SOFT':
        return 0.0;
      default:
        return 0.1;
    }
  }
}

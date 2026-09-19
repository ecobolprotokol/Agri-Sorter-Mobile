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
    String grade;

    if (finalScore >= 0.8) {
      grade = 'A';
      reason.addAll([
        '✓ Kematangan sesuai',
        '✓ Bentuk sesuai',
        '✓ Firmness sesuai',
      ]);
    } else if (finalScore >= 0.5) {
      grade = 'B';
      reason.addAll([
        '✓ Bentuk sesuai',
        '△ Kematangan sedang',
        '✓ Firmness cukup',
      ]);
    } else {
      grade = 'REJECT';
      reason.addAll([
        '✗ Kematangan di bawah threshold',
        '✗ Bentuk tidak sesuai',
        '✗ Firmness terlalu lunak',
      ]);
    }

    final confidence = (finalScore * 100).clamp(0, 100).toDouble();

    final uncertain = grade == 'B' && confidence < 70;

    return GradingResult(
      grade: grade,
      confidence: confidence,
      ripePercentage: ripePercentage,
      firmness: firmness,
      reason: reason,
      uncertain: uncertain,
    );
  }

  double _computeVisualScore({
    required double ripePercentage,
    required double hueMean,
    required double circularity,
    required Commodity commodity,
  }) {
    final colorScore = (ripePercentage / 100).clamp(0.0, 1.0);
    final hueScore = (1 - ((hueMean - 42.5).abs() / 60)).clamp(0.0, 1.0);
    final geometryScore = circularity.clamp(0.0, 1.0);

    final colorWeight = 0.6;
    final geometryWeight = 0.4;

    return (colorScore * colorWeight) +
        (hueScore * 0.2) +
        (geometryScore * geometryWeight);
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

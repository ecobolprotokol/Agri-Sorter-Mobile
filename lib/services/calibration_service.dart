import '../models/commodity.dart';
import '../models/dataset_sample.dart';

class CalibrationService {
  CalibrationValidation validate(List<DatasetSample> samples) {
    if (samples.length < 3) {
      return const CalibrationValidation(
        false,
        'Minimal 3 sampel diperlukan untuk kalibrasi.',
      );
    }
    final labels = samples.map((sample) => sample.label.toUpperCase()).toSet();
    final hasReject = labels.contains('REJECT') || labels.contains('AFKIR');
    if (!labels.contains('A') || !labels.contains('B') || !hasReject) {
      return const CalibrationValidation(
        false,
        'Dataset harus memiliki label A, B, dan REJECT/Afkir.',
      );
    }
    return const CalibrationValidation(true, 'Dataset valid.');
  }

  Map<String, dynamic> summarize({
    required Commodity commodity,
    required List<DatasetSample> samples,
  }) {
    final labelCounts = <String, int>{};
    for (final sample in samples) {
      final label = sample.label.toUpperCase();
      labelCounts[label] = (labelCounts[label] ?? 0) + 1;
    }

    final summary = {
      'sample_count': samples.length,
      'label_counts': labelCounts,
      'calibrated_at': DateTime.now().toIso8601String(),
      'method': commodity.method,
      'version': commodity.version,
    };

    commodity.calibration['sample_count'] = samples.length;
    commodity.calibration['label_counts'] = labelCounts;
    commodity.calibration['calibrated_at'] = summary['calibrated_at'];
    commodity.calibration['method'] = commodity.method;
    commodity.calibration['version'] = commodity.version;

    return summary;
  }
}

class CalibrationValidation {
  const CalibrationValidation(this.isValid, this.message);

  final bool isValid;
  final String message;
}

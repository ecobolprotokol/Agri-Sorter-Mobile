import '../models/commodity.dart';
import '../models/dataset_sample.dart';

class CalibrationService {
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

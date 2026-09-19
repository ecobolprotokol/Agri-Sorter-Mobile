import 'package:flutter_test/flutter_test.dart';
import 'package:agri_sorter_mobile/models/commodity.dart';
import 'package:agri_sorter_mobile/models/dataset_sample.dart';
import 'package:agri_sorter_mobile/services/calibration_service.dart';

void main() {
  test('calibration summary counts dataset labels and updates calibration metadata', () {
    final commodity = Commodity(
      id: 'papaya',
      name: 'Pepaya',
      variety: 'California',
      version: 2,
      calibration: {'sample_count': 0},
    );

    final samples = [
      DatasetSample(id: '1', commodityId: 'papaya', label: 'A', imagePath: 'a.jpg'),
      DatasetSample(id: '2', commodityId: 'papaya', label: 'A', imagePath: 'b.jpg'),
      DatasetSample(id: '3', commodityId: 'papaya', label: 'B', imagePath: 'c.jpg'),
      DatasetSample(id: '4', commodityId: 'papaya', label: 'REJECT', imagePath: 'd.jpg'),
    ];

    final summary = CalibrationService().summarize(commodity: commodity, samples: samples);

    expect(summary['sample_count'], 4);
    expect(summary['label_counts']['A'], 2);
    expect(summary['label_counts']['B'], 1);
    expect(summary['label_counts']['REJECT'], 1);
  });
}

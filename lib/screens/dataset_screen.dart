import 'package:flutter/material.dart';

import '../models/commodity.dart';
import '../models/dataset_sample.dart';
import '../screens/dataset_form_screen.dart';
import '../services/app_repository.dart';
import '../services/calibration_service.dart';

class DatasetScreen extends StatefulWidget {
  const DatasetScreen({super.key});

  @override
  State<DatasetScreen> createState() => _DatasetScreenState();
}

class _DatasetScreenState extends State<DatasetScreen> {
  final AppRepository _repository = AppRepository();
  final CalibrationService _calibrationService = CalibrationService();
  List<Commodity> _commodities = [];
  List<DatasetSample> _samples = [];
  String? _selectedCommodityId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final commodities = await _repository.loadCommodities();
    if (!mounted) return;
    setState(() {
      _commodities = commodities;
      _selectedCommodityId = commodities.isNotEmpty ? commodities.first.id : null;
      _isLoading = false;
    });
    if (_selectedCommodityId != null) {
      await _loadSamples();
    }
  }

  Future<void> _loadSamples() async {
    if (_selectedCommodityId == null) return;
    final samples = await _repository.loadDatasetSamples(_selectedCommodityId!);
    if (!mounted) return;
    setState(() {
      _samples = samples;
    });
  }

  Future<void> _addSample() async {
    if (_selectedCommodityId == null) return;

    final label = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const DatasetFormScreen()),
    );

    if (label == null || label.trim().isEmpty) return;

    final sample = DatasetSample(
      id: 'sample_${DateTime.now().millisecondsSinceEpoch}',
      commodityId: _selectedCommodityId!,
      label: label.trim(),
      imagePath: 'local://sample_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await _repository.addDatasetSample(sample);
    await _loadSamples();
  }

  Future<void> _runCalibration() async {
    if (_selectedCommodityId == null) return;
    final commodity = _commodities.firstWhere((item) => item.id == _selectedCommodityId);
    final summary = _calibrationService.summarize(commodity: commodity, samples: _samples);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kalibrasi selesai: ${summary['sample_count']} sampel')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCommodity = _commodities.firstWhere(
      (commodity) => commodity.id == _selectedCommodityId,
      orElse: () => Commodity(id: 'unknown', name: 'Belum ada', variety: ''),
    );

    final summary = [
      _Metric(label: 'Total Sample', value: '${_samples.length}'),
      _Metric(label: 'Label A', value: '${_samples.where((sample) => sample.label.toUpperCase() == 'A').length}'),
      _Metric(label: 'Label B', value: '${_samples.where((sample) => sample.label.toUpperCase() == 'B').length}'),
      _Metric(label: 'Afkir', value: '${_samples.where((sample) => sample.label.toUpperCase() == 'REJECT' || sample.label.toUpperCase() == 'AFKIR').length}'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dataset')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCommodityId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Komoditas aktif'),
                    items: _commodities
                        .map(
                          (commodity) => DropdownMenuItem(
                            value: commodity.id,
                            child: Text('${commodity.name} (${commodity.variety})'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        _selectedCommodityId = value;
                      });
                      await _loadSamples();
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dataset ${selectedCommodity.name}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: summary.map((item) => _MetricCard(metric: item)).toList(),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addSample,
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: const Text('+ Tambah Foto'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text('Import Dataset'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.label_important_rounded),
                        label: const Text('Kelola Label'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _runCalibration,
                        icon: const Icon(Icons.auto_fix_high_rounded),
                        label: const Text('Kalibrasi'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sample list',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (_samples.isEmpty)
                    const Text('Belum ada sampel untuk komoditas ini.')
                  else
                    ..._samples.map(
                      (sample) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.image_rounded),
                          title: Text(sample.label),
                          subtitle: Text(sample.imagePath),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _Metric {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(metric.label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(metric.value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

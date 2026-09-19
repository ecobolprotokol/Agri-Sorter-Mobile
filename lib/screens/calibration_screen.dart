import 'package:flutter/material.dart';

import '../models/commodity.dart';
import '../services/app_repository.dart';
import '../services/calibration_service.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final AppRepository _repository = AppRepository();
  final CalibrationService _service = CalibrationService();
  List<Commodity> _commodities = [];
  String? _selectedId;
  Map<String, dynamic>? _summary;
  bool _loading = true;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _loadCommodities();
  }

  Future<void> _loadCommodities() async {
    final commodities = await _repository.loadCommodities();
    if (!mounted) return;
    setState(() {
      _commodities = commodities;
      _selectedId = commodities.isNotEmpty ? commodities.first.id : null;
      _loading = false;
    });
  }

  Future<void> _runCalibration() async {
    final id = _selectedId;
    if (id == null) return;
    setState(() => _running = true);
    final commodity = _commodities.firstWhere((item) => item.id == id);
    final samples = await _repository.loadDatasetSamples(id);
    final validation = _service.validate(samples);
    if (!validation.isValid) {
      if (!mounted) return;
      setState(() => _running = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validation.message)));
      return;
    }
    final summary = _service.summarize(commodity: commodity, samples: samples);
    await _repository.saveCommodity(
      Commodity(
        id: commodity.id,
        name: commodity.name,
        variety: commodity.variety,
        version: commodity.version + 1,
        method: commodity.method,
        features: commodity.features,
        grades: commodity.grades,
        firmness: commodity.firmness,
        calibration: commodity.calibration,
        createdAt: commodity.createdAt,
      ),
    );
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Pilih Dataset',
      'Validasi Dataset',
      'Extract Features',
      'Kalibrasi HSV',
      'Kalibrasi Geometri',
      'Test Validation',
      'Preview Parameter',
      'Simpan Profile',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Kalibrasi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedId,
                    decoration: const InputDecoration(labelText: 'Dataset komoditas'),
                    items: _commodities
                        .map((item) => DropdownMenuItem(
                              value: item.id,
                              child: Text('${item.name} (${item.variety})'),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedId = value),
                  ),
                  const SizedBox(height: 16),
                  ...steps.asMap().entries.map(
                        (entry) => Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${entry.key + 1}')),
                            title: Text(entry.value),
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _running ? null : _runCalibration,
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    label: Text(_running ? 'Memproses...' : 'Jalankan Kalibrasi'),
                  ),
                  if (_summary != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Profile tersimpan\n'
                          'Sampel: ${_summary!['sample_count']}\n'
                          'Label: ${_summary!['label_counts']}',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

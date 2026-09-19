import 'package:flutter/material.dart';

import '../models/commodity.dart';
import '../models/sorting_result.dart';
import '../screens/sorting_result_screen.dart';
import '../services/app_repository.dart';
import '../services/grading_engine.dart';

class CameraSortingScreen extends StatefulWidget {
  const CameraSortingScreen({super.key});

  @override
  State<CameraSortingScreen> createState() => _CameraSortingScreenState();
}

class _CameraSortingScreenState extends State<CameraSortingScreen> {
  final AppRepository _repository = AppRepository();
  final GradingEngine _gradingEngine = GradingEngine();
  List<Commodity> _commodities = [];
  String? _selectedCommodityId;
  String _status = 'Camera Ready';
  String _firmness = 'MEDIUM';
  double _ripePercentage = 72;
  double _hueMean = 42.5;
  bool _isLoading = true;

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
      if (commodities.isNotEmpty) {
        _selectedCommodityId = commodities.first.id;
        final first = commodities.first;
        final hueValue = (first.features['color'] as Map? ?? {})['hue_mean'] as num? ?? 42.5;
        final geometry = (first.features['geometry'] as Map? ?? {})['circularity'] as num? ?? 0.85;
        _hueMean = hueValue.toDouble();
        _ripePercentage = 75;
        _status = 'Komoditas ${first.name} siap';
      }
      _isLoading = false;
    });
  }

  Future<void> _confirmGrade() async {
    if (_selectedCommodityId == null) {
      return;
    }

    final commodity = _commodities.firstWhere(
      (item) => item.id == _selectedCommodityId,
      orElse: () => _commodities.first,
    );

    final session = await _repository.createSession(
      commodity: commodity.id,
      operator: 'Operator',
      location: 'R. Sortir 2',
    );

    final resultData = _gradingEngine.grade(
      commodity: commodity,
      ripePercentage: _ripePercentage,
      hueMean: _hueMean,
      circularity: ((commodity.features['geometry'] as Map? ?? {})['circularity'] as num? ?? 0.85).toDouble(),
      firmness: _firmness,
    );

    final result = SortingResult(
      resultId: 'result_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: session.id,
      commodityId: commodity.id,
      profileVersion: commodity.version,
      grade: resultData.grade,
      confidence: resultData.confidence,
      firmness: resultData.firmness,
      timestamp: DateTime.now(),
      ripePercentage: resultData.ripePercentage,
    );

    await _repository.addResult(result: result);

    if (!mounted) return;

    setState(() {
      _status = 'Grade ${result.grade} • ${result.confidence.toStringAsFixed(1)}%';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hasil tersimpan: Grade ${result.grade}')),
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SortingResultScreen(
          result: result,
          commodity: commodity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCommodity = _commodities.firstWhere(
      (item) => item.id == _selectedCommodityId,
      orElse: () => _commodities.isNotEmpty ? _commodities.first : Commodity(
          id: 'unknown',
          name: 'Belum ada komoditas',
          variety: '',
        ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Sortir Kamera')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_alt_rounded, size: 72, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _status,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
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
                    onChanged: (value) {
                      if (value == null) return;
                      final commodity = _commodities.firstWhere((item) => item.id == value);
                      final hue = (commodity.features['color'] as Map? ?? {})['hue_mean'] as num? ?? 42.5;
                      setState(() {
                        _selectedCommodityId = value;
                        _hueMean = hue.toDouble();
                        _status = 'Komoditas ${commodity.name} siap';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Visual & firmness', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text('Kematangan visual: ${_ripePercentage.toStringAsFixed(0)}%'),
                          Slider(
                            value: _ripePercentage,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: _ripePercentage.round().toString(),
                            onChanged: (value) {
                              setState(() {
                                _ripePercentage = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Text('Hue rata-rata: ${_hueMean.toStringAsFixed(1)}'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['FIRM', 'MEDIUM', 'SOFT']
                                .map(
                                  (item) => ChoiceChip(
                                    label: Text(item),
                                    selected: _firmness == item,
                                    onSelected: (_) {
                                      setState(() {
                                        _firmness = item;
                                        _status = 'Periksa firmness';
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmGrade,
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Konfirmasi Grade'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Komoditas aktif: ${selectedCommodity.name}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}

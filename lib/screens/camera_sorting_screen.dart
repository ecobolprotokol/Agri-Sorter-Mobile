import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../models/commodity.dart';
import '../models/sorting_result.dart';
import '../models/sorting_session.dart';
import '../screens/sorting_result_screen.dart';
import '../services/app_repository.dart';
import '../services/camera_service.dart';
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
  String _status = 'Menyiapkan kamera...';
  String _firmness = 'MEDIUM';
  LiveVisionFeatures? _liveFeatures;
  SortingSession? _activeSession;
  bool _isLoading = true;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  DateTime _lastAnalysis = DateTime.fromMillisecondsSinceEpoch(0);

  Commodity? get _selectedCommodity {
    for (final commodity in _commodities) {
      if (commodity.id == _selectedCommodityId) return commodity;
    }
    return _commodities.isEmpty ? null : _commodities.first;
  }

  @override
  void initState() {
    super.initState();
    _loadCommodities();
  }

  Future<void> _loadCommodities() async {
    try {
      final commodities = await _repository.loadCommodities();
      if (!mounted) return;
      setState(() {
        _commodities = commodities;
        _selectedCommodityId = commodities.isEmpty ? null : commodities.first.id;
        _isLoading = false;
      });
      await CameraService.initialize();
      await CameraService.startLiveAnalysis(_onLiveFeatures);
      if (mounted) setState(() => _status = 'Mencari objek komoditas...');
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _status = 'Kamera tidak tersedia di perangkat ini';
        });
      }
    }
  }

  void _onLiveFeatures(LiveVisionFeatures features) {
    final now = DateTime.now();
    if (now.difference(_lastAnalysis) < const Duration(milliseconds: 450) || !mounted) return;
    _lastAnalysis = now;
    setState(() {
      _liveFeatures = features;
      _isAnalyzing = true;
      _status = 'Objek terdeteksi - kategori diperbarui otomatis';
    });
  }

  String _gradePreview() {
    final commodity = _selectedCommodity;
    final features = _liveFeatures;
    if (commodity == null || features == null) return '-';
    final result = _gradingEngine.grade(
      commodity: commodity,
      ripePercentage: features.ripePercentage,
      hueMean: features.hueMean,
      circularity: _profileCircularity(commodity),
      firmness: _firmness,
    );
    return result.grade;
  }

  double _profileCircularity(Commodity commodity) {
    final geometry = commodity.features['geometry'] as Map?;
    return (geometry?['circularity'] as num?)?.toDouble() ?? 0.85;
  }

  Future<void> _saveAutomaticResult() async {
    final commodity = _selectedCommodity;
    final features = _liveFeatures;
    if (commodity == null || features == null || _isSaving) return;
    setState(() => _isSaving = true);
    _activeSession ??= await _repository.createSession(
      commodity: commodity.id,
      operator: 'Operator',
      location: 'R. Sortir 2',
    );
    final grading = _gradingEngine.grade(
      commodity: commodity,
      ripePercentage: features.ripePercentage,
      hueMean: features.hueMean,
      circularity: _profileCircularity(commodity),
      firmness: _firmness,
    );
    final result = SortingResult(
      resultId: 'result_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: _activeSession!.id,
      commodityId: commodity.id,
      profileVersion: commodity.version,
      grade: grading.grade,
      confidence: grading.confidence,
      firmness: grading.firmness,
      timestamp: DateTime.now(),
      ripePercentage: grading.ripePercentage,
      reason: grading.reason,
      visionFeatures: {
        ...grading.visionFeatures,
        'saturation_mean': features.saturationMean,
        'value_mean': features.valueMean,
      },
    );
    await _repository.addResult(result: result);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _status = 'Hasil ${result.grade} tersimpan';
    });
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SortingResultScreen(result: result, commodity: commodity)));
  }

  @override
  void dispose() {
    unawaited(CameraService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = CameraService.controller;
    final commodity = _selectedCommodity;
    final grade = _gradePreview();
    return Scaffold(
      appBar: AppBar(title: const Text('Sortir Otomatis')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: controller?.value.aspectRatio ?? 4 / 3,
                    child: controller?.value.isInitialized == true
                        ? CameraPreview(controller!)
                        : Container(
                            color: Colors.black12,
                            child: const Center(child: Text('Kamera belum siap')),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(_isAnalyzing ? Icons.visibility_rounded : Icons.search_rounded, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_status, style: const TextStyle(fontWeight: FontWeight.w600))),
                        Chip(label: Text('Grade $grade')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCommodityId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Komoditas'),
                  items: _commodities.map((item) => DropdownMenuItem(value: item.id, child: Text('${item.name} - ${item.variety}'))).toList(),
                  onChanged: (value) => setState(() {
                    _selectedCommodityId = value;
                    _liveFeatures = null;
                    _isAnalyzing = false;
                    _status = 'Mencari objek komoditas...';
                  }),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pemeriksaan kekerasan oleh operator', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: ['FIRM', 'MEDIUM', 'SOFT'].map((value) => ChoiceChip(
                            label: Text(value == 'FIRM' ? 'Keras' : value == 'MEDIUM' ? 'Sedang' : 'Lunak'),
                            selected: _firmness == value,
                            onSelected: (_) => setState(() => _firmness = value),
                          )).toList(),
                        ),
                        if (_liveFeatures != null) ...[
                          const SizedBox(height: 12),
                          Text('Kematangan visual: ${_liveFeatures!.ripePercentage.toStringAsFixed(0)}%'),
                          Text('Warna rata-rata: ${_liveFeatures!.hueMean.toStringAsFixed(1)}°'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _liveFeatures == null || _isSaving ? null : _saveAutomaticResult,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Menyimpan...' : 'Simpan hasil kategori $grade'),
                ),
                const SizedBox(height: 8),
                Text(
                  commodity == null ? 'Belum ada komoditas' : 'Profile v${commodity.version} digunakan untuk kategori otomatis',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
    );
  }
}

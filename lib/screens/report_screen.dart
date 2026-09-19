import 'package:flutter/material.dart';

import '../models/dashboard_summary.dart';
import '../models/sorting_result.dart';
import '../services/app_repository.dart';
import '../services/export_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final AppRepository _repository = AppRepository();
  final ExportService _exportService = ExportService();
  DashboardSummary _summary = DashboardSummary(
    totalItems: 0,
    gradeA: 0,
    gradeB: 0,
    reject: 0,
  );
  List<SortingResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final results = await _repository.loadResults();
    if (!mounted) return;
    setState(() {
      _results = results;
      _summary = DashboardSummary.fromResults(results);
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _exportRows() {
    final grouped = <String, Map<String, dynamic>>{};
    for (final result in _results) {
      final key = '${result.sessionId}|${result.commodityId}|${result.grade}';
      final row = grouped.putIfAbsent(key, () => {
            'session_id': result.sessionId,
            'commodity': result.commodityId,
            'grade': result.grade,
            'count': 0,
          });
      row['count'] = (row['count'] as int) + 1;
    }
    for (final row in grouped.values) {
      row['percentage'] = _summary.totalItems == 0
          ? 0
          : ((row['count'] as int) / _summary.totalItems * 100).toStringAsFixed(1);
    }
    return grouped.values.toList();
  }

  Future<void> _exportCsv() async {
    final file = await _exportService.exportCsv(rows: _exportRows(), fileName: 'agri_sorter_report');
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV tersimpan: ${file.path}')));
  }

  Future<void> _exportJson() async {
    final file = await _exportService.exportJson(
      fileName: 'agri_sorter_report',
      payload: {'summary': _summary.toJson(), 'rows': _exportRows()},
    );
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('JSON tersimpan: ${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(tooltip: 'Export CSV', onPressed: _exportCsv, icon: const Icon(Icons.table_view_rounded)),
          IconButton(tooltip: 'Export JSON', onPressed: _exportJson, icon: const Icon(Icons.data_object_rounded)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  if (_results.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: Text('Belum ada hasil sortir untuk dilaporkan.')),
                    ),
                  const Text(
                    'GENERAL AGRI-SORTER',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sorting Report',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Session: ${_results.isEmpty ? '-' : _results.first.sessionId}',
                  ),
                  Text(
                    'Tanggal: ${_results.isEmpty ? '-' : _results.first.timestamp.toLocal().toString().split(' ').first}',
                  ),
                  Text(
                    'Komoditas: ${_results.isEmpty ? '-' : _results.first.commodityId}',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SUMMARY',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Total: ${_summary.totalItems}'),
                  Text('Grade A: ${_summary.gradeA}'),
                  Text('Grade B: ${_summary.gradeB}'),
                  Text('Afkir: ${_summary.reject}'),
                  const SizedBox(height: 20),
                  const Text(
                    'DETAIL',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ..._results.map(
                    (result) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '- ${result.commodityId}: Grade ${result.grade} (${result.confidence.toStringAsFixed(1)}%)',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

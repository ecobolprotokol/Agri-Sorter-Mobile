import 'package:flutter/material.dart';

import '../models/dashboard_summary.dart';
import '../models/sorting_result.dart';
import '../services/app_repository.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final AppRepository _repository = AppRepository();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
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

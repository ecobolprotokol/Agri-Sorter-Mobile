import 'package:flutter/material.dart';

import '../models/commodity.dart';
import '../models/sorting_result.dart';

class SortingResultScreen extends StatelessWidget {
  const SortingResultScreen({
    super.key,
    required this.result,
    required this.commodity,
  });

  final SortingResult result;
  final Commodity commodity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Sortir')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Grade ${result.grade}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _SummaryRow(label: 'Komoditas', value: commodity.name),
            _SummaryRow(
              label: 'Confidence',
              value: '${result.confidence.toStringAsFixed(1)}%',
            ),
            _SummaryRow(label: 'Firmness', value: result.firmness),
            _SummaryRow(
              label: 'Ripe Percentage',
              value: '${(result.ripePercentage ?? 0).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 20),
            const Text(
              'Reason:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...result.reason.map(Text.new),
            if (result.visionFeatures.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Vision Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ...result.visionFeatures.entries.map((entry) => _SummaryRow(label: entry.key, value: '${entry.value}')),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

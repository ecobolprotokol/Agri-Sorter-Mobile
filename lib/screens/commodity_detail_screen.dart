import 'package:flutter/material.dart';

import '../models/commodity.dart';

class CommodityDetailScreen extends StatelessWidget {
  const CommodityDetailScreen({super.key, required this.commodity});

  final Commodity commodity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(commodity.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              '${commodity.name} ${commodity.variety}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _SummaryCard(title: 'Version', value: commodity.version.toString()),
            _SummaryCard(title: 'Method', value: commodity.method),
            _SummaryCard(
              title: 'Grade Labels',
              value: commodity.grades.keys.join(', '),
            ),
            _SummaryCard(
              title: 'Sample Count',
              value: '${(commodity.calibration['sample_count'] ?? 0)}',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open_rounded),
                  label: const Text('Dataset'),
                  onPressed: null,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_fix_high_rounded),
                  label: const Text('Kalibrasi'),
                  onPressed: null,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.science_rounded),
                  label: const Text('Test'),
                  onPressed: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

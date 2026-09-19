import 'package:flutter/material.dart';

class GradeDetailScreen extends StatelessWidget {
  const GradeDetailScreen({super.key, required this.commodity, required this.grade, required this.count});

  final String commodity;
  final String grade;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grade $grade')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(commodity, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _StatRow(label: 'Jumlah', value: count.toString()),
            _StatRow(label: 'Persentase', value: '62.5%'),
            _StatRow(label: 'Avg Confidence', value: '91.2%'),
            _StatRow(label: 'Avg Maturity', value: '87.4%'),
            const SizedBox(height: 20),
            const Text('Firmness', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            const _StatRow(label: 'Firm', value: '78'),
            const _StatRow(label: 'Medium', value: '47'),
            const _StatRow(label: 'Soft', value: '0'),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

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

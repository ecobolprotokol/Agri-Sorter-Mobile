import 'package:flutter/material.dart';

class CalibrationScreen extends StatelessWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calibration Pipeline',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: steps.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(steps[index]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: const Text('Jalankan Kalibrasi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

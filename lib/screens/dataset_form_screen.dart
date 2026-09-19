import 'package:flutter/material.dart';

class DatasetFormScreen extends StatefulWidget {
  const DatasetFormScreen({super.key});

  @override
  State<DatasetFormScreen> createState() => _DatasetFormScreenState();
}

class _DatasetFormScreenState extends State<DatasetFormScreen> {
  final _labelController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Label Dataset')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Label baru'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_labelController.text.trim().isNotEmpty) {
                    Navigator.of(context).pop(_labelController.text.trim());
                  }
                },
                child: const Text('Simpan Label'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

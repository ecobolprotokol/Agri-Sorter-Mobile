import 'package:flutter/material.dart';

import '../models/commodity.dart';
import '../services/app_repository.dart';

class SortingScreen extends StatefulWidget {
  const SortingScreen({super.key});

  @override
  State<SortingScreen> createState() => _SortingScreenState();
}

class _SortingScreenState extends State<SortingScreen> {
  final AppRepository _repository = AppRepository();
  List<Commodity> _commodities = [];
  String? _selectedCommodityId;
  final TextEditingController _operatorController = TextEditingController(text: 'Operator');
  final TextEditingController _locationController = TextEditingController(text: 'R. Sortir 2');

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
      _selectedCommodityId = commodities.isNotEmpty ? commodities.first.id : null;
    });
  }

  Future<void> _startSession() async {
    if (_selectedCommodityId == null) {
      return;
    }

    final session = await _repository.createSession(
      commodity: _selectedCommodityId!,
      operator: _operatorController.text.trim().isEmpty ? 'Operator' : _operatorController.text.trim(),
      location: _locationController.text.trim().isEmpty ? 'R. Sortir 2' : _locationController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Session dibuat: ${session.id}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statCards = [
      _InfoTile(label: 'Session', value: '#${DateTime.now().millisecondsSinceEpoch % 100000}'),
      _InfoTile(label: 'Komoditas', value: _selectedCommodityId ?? 'Belum dipilih'),
      _InfoTile(label: 'Operator', value: _operatorController.text.trim().isEmpty ? 'Operator' : _operatorController.text.trim()),
      _InfoTile(label: 'Lokasi', value: _locationController.text.trim().isEmpty ? 'R. Sortir 2' : _locationController.text.trim()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mulai Sortir')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Workflow Hands-Free',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text('START SESSION → Camera Ready → Object Detected → Capture'),
                    const SizedBox(height: 8),
                    const Text('Visual Analysis → Periksa firmness → Grading → Save Result'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedCommodityId ?? 'none'),
              initialValue: _selectedCommodityId,
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
                setState(() {
                  _selectedCommodityId = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _operatorController,
              decoration: const InputDecoration(labelText: 'Operator'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Lokasi'),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: statCards.map((item) => _InfoTileWidget(tile: item)).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Mulai Session'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Periksa firmness')),
                );
              },
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Tes TTS'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;
}

class _InfoTileWidget extends StatelessWidget {
  const _InfoTileWidget({required this.tile});

  final _InfoTile tile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tile.label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(tile.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/commodity.dart';
import '../screens/commodity_detail_screen.dart';
import '../screens/commodity_form_screen.dart';
import '../services/app_repository.dart';

class CommodityScreen extends StatefulWidget {
  const CommodityScreen({super.key});

  @override
  State<CommodityScreen> createState() => _CommodityScreenState();
}

class _CommodityScreenState extends State<CommodityScreen> {
  final AppRepository _repository = AppRepository();
  List<Commodity> _commodities = [];
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
      _isLoading = false;
    });
  }

  Future<void> _openAddForm() async {
    final result = await Navigator.of(context).push<Commodity>(
      MaterialPageRoute(builder: (_) => const CommodityFormScreen()),
    );

    if (result != null) {
      await _repository.saveCommodity(result);
      await _loadCommodities();
    }
  }

  Future<void> _openEditForm(Commodity commodity) async {
    final result = await Navigator.of(context).push<Commodity>(
      MaterialPageRoute(builder: (_) => CommodityFormScreen(commodity: commodity)),
    );

    if (result != null) {
      await _repository.saveCommodity(result);
      await _loadCommodities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Komoditas')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddForm,
        child: const Icon(Icons.add_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const SizedBox(height: 8),
                  ..._commodities.map(
                    (commodity) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CommodityDetailScreen(commodity: commodity),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${commodity.name} (${commodity.variety})',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Chip(label: Text('v${commodity.version}')),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Dataset: ${(commodity.calibration['sample_count'] ?? 0)} sampel'),
                              const SizedBox(height: 4),
                              Text('Method: ${commodity.method}'),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CommodityDetailScreen(commodity: commodity),
                                        ),
                                      );
                                    },
                                    child: const Text('Detail'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _openEditForm(commodity),
                                    child: const Text('Edit'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

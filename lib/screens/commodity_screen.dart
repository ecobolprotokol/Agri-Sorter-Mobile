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
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
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
      MaterialPageRoute(
        builder: (_) => CommodityFormScreen(commodity: commodity),
      ),
    );

    if (result != null) {
      await _repository.saveCommodity(result);
      await _loadCommodities();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCommodities = _commodities.where((commodity) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery = '${commodity.name} ${commodity.variety}'
          .toLowerCase()
          .contains(query);
      final matchesFilter =
          _selectedFilter == 'Semua' || commodity.method == _selectedFilter;
      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Komoditas'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang katalog',
            onPressed: _loadCommodities,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah komoditas',
        onPressed: _openAddForm,
        child: const Icon(Icons.add_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Cari komoditas',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                              icon: const Icon(Icons.clear_rounded),
                            ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['Semua', 'hsv_geometry'].map((filter) {
                      return ChoiceChip(
                        label: Text(
                          filter == 'Semua' ? filter : 'HSV + geometri',
                        ),
                        selected: _selectedFilter == filter,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = filter),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (filteredCommodities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 52,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text('Komoditas tidak ditemukan'),
                        ],
                      ),
                    ),
                  ...filteredCommodities.map(
                    (commodity) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CommodityDetailScreen(commodity: commodity),
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
                              Text(
                                'Dataset: ${(commodity.calibration['sample_count'] ?? 0)} sampel',
                              ),
                              const SizedBox(height: 4),
                              Text('Method: ${commodity.method}'),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CommodityDetailScreen(
                                            commodity: commodity,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.visibility_outlined),
                                    label: const Text('Detail'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _openEditForm(commodity),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Edit'),
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

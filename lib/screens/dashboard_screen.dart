import 'package:flutter/material.dart';

import '../models/dashboard_summary.dart';
import '../services/app_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onNavigate});

  final ValueChanged<int>? onNavigate;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppRepository _repository = AppRepository();
  DashboardSummary _summary = DashboardSummary(
    totalItems: 0,
    gradeA: 0,
    gradeB: 0,
    reject: 0,
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final results = await _repository.loadResults();
    if (!mounted) return;
    setState(() {
      _summary = DashboardSummary.fromResults(results);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatCard(
        title: 'Session Hari Ini',
        value: '${_summary.totalItems}',
        subtitle: 'Total objek',
        color: Colors.green,
      ),
      _StatCard(
        title: 'Komoditas Hari Ini',
        value: '${_summary.totalItems}',
        subtitle: 'Items ter-sorting',
        color: Colors.blue,
      ),
      _StatCard(
        title: 'Grade A',
        value: '${_summary.gradeA}',
        subtitle: '${_summary.gradeAPercentage.toStringAsFixed(1)}%',
        color: Colors.teal,
      ),
      _StatCard(
        title: 'Grade B',
        value: '${_summary.gradeB}',
        subtitle: '${_summary.gradeBPercentage.toStringAsFixed(1)}%',
        color: Colors.orange,
      ),
      _StatCard(
        title: 'Afkir',
        value: '${_summary.reject}',
        subtitle: '${_summary.rejectPercentage.toStringAsFixed(1)}%',
        color: Colors.red,
      ),
    ];

    final actionCards = [
      _QuickAction(label: 'Mulai Sortir', icon: Icons.play_arrow_rounded, index: 1),
      _QuickAction(label: 'Komoditas', icon: Icons.eco_rounded, index: 4),
      _QuickAction(label: 'Dataset', icon: Icons.folder_open_rounded, index: 5),
      _QuickAction(label: 'Kalibrasi', icon: Icons.tune_rounded, index: 6),
      _QuickAction(label: 'Riwayat', icon: Icons.history_rounded, index: 7),
      _QuickAction(label: 'Laporan', icon: Icons.article_rounded, index: 8),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('General Agri-Sorter')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.65,
                      children: stats
                          .map((stat) => _StatCardWidget(stat: stat))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Akses Cepat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.7,
                      children: actionCards
                          .map((action) => _QuickActionCard(action: action, onTap: widget.onNavigate))
                          .toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
}

class _QuickAction {
  const _QuickAction({required this.label, required this.icon, required this.index});

  final String label;
  final IconData icon;
  final int index;
}

class _StatCardWidget extends StatelessWidget {
  const _StatCardWidget({required this.stat});

  final _StatCard stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stat.color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stat.color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            stat.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            stat.value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            stat.subtitle,
            style: TextStyle(fontSize: 12, color: stat.color.darken(0.2)),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action, this.onTap});

  final _QuickAction action;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap?.call(action.index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, size: 30, color: Colors.green.shade700),
              const SizedBox(height: 12),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}

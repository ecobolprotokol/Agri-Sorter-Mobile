import 'package:flutter/material.dart';

import '../models/sorting_session.dart';
import '../services/app_repository.dart';
import 'report_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AppRepository _repository = AppRepository();
  List<SortingSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _repository.loadSessions();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            tooltip: 'Buka laporan',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportScreen())),
            icon: const Icon(Icons.article_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _sessions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final summary = session.totalItems > 0
                    ? 'Total: ${session.totalItems} buah'
                    : 'Belum ada hasil';

                return Card(
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportScreen())),
                    title: Text(
                      session.startedAt.toLocal().toString().split(' ').first,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          '${session.commodity ?? 'Komoditas'} • ${session.location ?? 'Lokasi'}',
                        ),
                        const SizedBox(height: 4),
                        Text(summary),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

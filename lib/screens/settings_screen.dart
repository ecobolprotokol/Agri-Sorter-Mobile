import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = [
      _SettingsItem(icon: Icons.location_on_rounded, title: 'Lokasi Operator', value: 'R. Sortir 2'),
      _SettingsItem(icon: Icons.volume_up_rounded, title: 'Text-to-Speech', value: 'Offline'),
      _SettingsItem(icon: Icons.dark_mode_rounded, title: 'Tema', value: 'Light'),
      _SettingsItem(icon: Icons.security_rounded, title: 'Privacy', value: 'Local only'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: settings.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          final item = settings[index];
          return ListTile(
            leading: Icon(item.icon, color: Colors.green.shade700),
            title: Text(item.title),
            trailing: Text(item.value),
          );
        },
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;
}

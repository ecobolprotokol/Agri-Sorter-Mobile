import 'package:flutter/material.dart';

import '../models/commodity.dart';

class CommodityFormScreen extends StatefulWidget {
  const CommodityFormScreen({super.key, this.commodity});

  final Commodity? commodity;

  @override
  State<CommodityFormScreen> createState() => _CommodityFormScreenState();
}

class _CommodityFormScreenState extends State<CommodityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.commodity != null) {
      _nameController.text = widget.commodity!.name;
      _varietyController.text = widget.commodity!.variety;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.commodity == null ? 'Tambah Komoditas' : 'Edit Komoditas',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                widget.commodity == null
                    ? 'Buat profil baru'
                    : 'Perbarui profil komoditas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Profil ini tersimpan lokal dan dapat digunakan untuk proses sortir offline.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Komoditas',
                  prefixIcon: Icon(Icons.eco_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _varietyController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Varietas',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final commodity = Commodity(
                        id:
                            widget.commodity?.id ??
                            _nameController.text
                                .trim()
                                .toLowerCase()
                                .replaceAll(' ', '_'),
                        name: _nameController.text.trim(),
                        variety: _varietyController.text.trim().isEmpty
                            ? 'General'
                            : _varietyController.text.trim(),
                        version: widget.commodity?.version ?? 1,
                      );

                      Navigator.of(context).pop(commodity);
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan Profil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/camera_service.dart';

class RealCameraScreen extends StatefulWidget {
  const RealCameraScreen({super.key});

  @override
  State<RealCameraScreen> createState() => _RealCameraScreenState();
}

class _RealCameraScreenState extends State<RealCameraScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await CameraService.initialize();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Kamera tidak tersedia: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    CameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = CameraService.controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Camera Sortir')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(child: Text(_errorMessage))
                : Column(
                    children: [
                      if (controller != null && controller.value.isInitialized)
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: CameraPreview(controller),
                          ),
                        )
                      else
                        const Expanded(
                          child: Center(child: Text('Camera belum siap')),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final file = await CameraService.takePicture();
                                  setState(() {
                                    _capturedImage = file;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _errorMessage = 'Gagal menangkap gambar: $e';
                                  });
                                }
                              },
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: const Text('Ambil Foto'),
                            ),
                          ),
                        ],
                      ),
                      if (_capturedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Image.file(
                            File(_capturedImage!.path),
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}

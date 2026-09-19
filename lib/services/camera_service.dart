import 'package:camera/camera.dart';

class CameraService {
  static CameraController? _controller;
  static List<CameraDescription>? _cameras;

  static Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      throw StateError('No camera available');
    }

    _controller = CameraController(
      _cameras!.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  static CameraController? get controller => _controller;

  static Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw StateError('Camera not initialized');
    }
    return _controller!.takePicture();
  }

  static Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}

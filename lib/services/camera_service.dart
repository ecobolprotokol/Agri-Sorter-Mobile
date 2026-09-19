import 'dart:math' as math;

import 'package:camera/camera.dart';

class LiveVisionFeatures {
  const LiveVisionFeatures({
    required this.hueMean,
    required this.saturationMean,
    required this.valueMean,
    required this.ripePercentage,
  });

  final double hueMean;
  final double saturationMean;
  final double valueMean;
  final double ripePercentage;
}

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

  static Future<void> startLiveAnalysis(
    void Function(LiveVisionFeatures features) onFeatures,
  ) async {
    final activeController = _controller;
    if (activeController == null || !activeController.value.isInitialized) {
      throw StateError('Camera not initialized');
    }
    if (activeController.value.isStreamingImages) return;
    await activeController.startImageStream((image) {
      final features = _extractFeatures(image);
      if (features != null) onFeatures(features);
    });
  }

  static Future<void> stopLiveAnalysis() async {
    final activeController = _controller;
    if (activeController?.value.isStreamingImages == true) {
      await activeController!.stopImageStream();
    }
  }

  static LiveVisionFeatures? _extractFeatures(CameraImage image) {
    if (image.planes.isEmpty) return null;
    final yPlane = image.planes[0];
    final uPlane = image.planes.length > 1 ? image.planes[1] : null;
    final vPlane = image.planes.length > 2 ? image.planes[2] : null;
    if (uPlane == null || vPlane == null) return null;

    var hueTotal = 0.0;
    var saturationTotal = 0.0;
    var valueTotal = 0.0;
    var ripePixels = 0;
    var count = 0;
    final stepY = math.max(1, image.height ~/ 24);
    final stepX = math.max(1, image.width ~/ 24);

    for (var y = 0; y < image.height; y += stepY) {
      for (var x = 0; x < image.width; x += stepX) {
        final yIndex = y * yPlane.bytesPerRow + x;
        final uvX = x ~/ 2;
        final uvY = y ~/ 2;
        final uIndex = uvY * uPlane.bytesPerRow + uvX * uPlane.bytesPerPixel!;
        final vIndex = uvY * vPlane.bytesPerRow + uvX * vPlane.bytesPerPixel!;
        if (yIndex >= yPlane.bytes.length || uIndex >= uPlane.bytes.length || vIndex >= vPlane.bytes.length) continue;
        final luminance = yPlane.bytes[yIndex].toDouble();
        final u = uPlane.bytes[uIndex].toDouble() - 128;
        final v = vPlane.bytes[vIndex].toDouble() - 128;
        final red = (luminance + 1.402 * v).clamp(0, 255).toDouble() / 255;
        final green = (luminance - 0.344 * u - 0.714 * v).clamp(0, 255).toDouble() / 255;
        final blue = (luminance + 1.772 * u).clamp(0, 255).toDouble() / 255;
        final hsv = _rgbToHsv(red, green, blue);
        hueTotal += hsv.$1;
        saturationTotal += hsv.$2;
        valueTotal += hsv.$3;
        if (hsv.$2 > 0.25 && hsv.$3 > 0.35) ripePixels++;
        count++;
      }
    }
    if (count == 0) return null;
    return LiveVisionFeatures(
      hueMean: hueTotal / count,
      saturationMean: saturationTotal / count,
      valueMean: valueTotal / count,
      ripePercentage: ripePixels / count * 100,
    );
  }

  static (double, double, double) _rgbToHsv(double red, double green, double blue) {
    final maxValue = math.max(red, math.max(green, blue));
    final minValue = math.min(red, math.min(green, blue));
    final delta = maxValue - minValue;
    var hue = 0.0;
    if (delta != 0) {
      if (maxValue == red) {
        hue = 60 * (((green - blue) / delta) % 6);
      } else if (maxValue == green) {
        hue = 60 * ((blue - red) / delta + 2);
      } else {
        hue = 60 * ((red - green) / delta + 4);
      }
    }
    if (hue < 0) hue += 360;
    final saturation = maxValue == 0 ? 0.0 : delta / maxValue;
    return (hue, saturation, maxValue);
  }

  static Future<void> dispose() async {
    await stopLiveAnalysis();
    await _controller?.dispose();
    _controller = null;
  }
}

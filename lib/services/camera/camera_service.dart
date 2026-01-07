import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  CameraService._internal();

  factory CameraService() {
    return _instance;
  }

  bool get isInitialized => _isInitialized;
  CameraController? get cameraController => _cameraController;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        return false;
      }

      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        return false;
      }

      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> dispose() async {
    await _cameraController?.dispose();
    _isInitialized = false;
  }
}

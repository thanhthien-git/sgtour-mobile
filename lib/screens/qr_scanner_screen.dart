import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/config/app_text_styles.dart';
import 'package:sgtour_mobile/services/qr_code_service.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';
import 'package:sgtour_mobile/widgets/common/base_scaffold.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  final ImagePicker _imagePicker = ImagePicker();
  final QrCodeService _qrCodeService = QrCodeService.instance;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _useCameraView = true;
  String? _detectedValue;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.location_permissionDeniedDesc)),
          );
          setState(() => _useCameraView = false);
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: ${e.toString()}')),
        );
        setState(() => _useCameraView = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isCameraInitialized || _cameraController == null) return;

    if (state == AppLifecycleState.resumed) {
      _cameraController!.initialize();
    } else if (state == AppLifecycleState.paused) {
      _cameraController!.dispose();
    }
  }

  Future<void> _captureAndDetectQr() async {
    if (!_isCameraInitialized || _isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      final image = await _cameraController!.takePicture();
      final qrValue = await _qrCodeService.detectFromImage(File(image.path));

      if (!mounted) return;

      if (qrValue != null && qrValue.isNotEmpty) {
        setState(() => _detectedValue = qrValue);
        _handleQrDetected(qrValue);
      } else {
        _showErrorSnackBar('No QR code detected');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final status = await Permission.photos.request();

      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.location_permissionDeniedDesc)),
          );
        }
        return;
      }

      setState(() => _isProcessing = true);

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
        try {
          final qrValue = await _qrCodeService.detectFromImage(
            File(pickedFile.path),
          );

          if (!mounted) return;

          if (qrValue != null && qrValue.isNotEmpty) {
            setState(() => _detectedValue = qrValue);
            _handleQrDetected(qrValue);
          } else {
            _showErrorSnackBar('No QR code detected');
          }
        } catch (e) {
          if (!mounted) return;
          _showErrorSnackBar('Error: ${e.toString()}');
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error: ${e.toString()}');
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleQrDetected(String value) {
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseScaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Quét mã QR',
                    style: AppTextStyles.heading3.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Camera or placeholder view
            Expanded(
              child: _isCameraInitialized
                  ? CameraPreview(_cameraController!)
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 80,
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Camera not available',
                            style: AppTextStyles.body2.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_isCameraInitialized)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isProcessing ? null : _captureAndDetectQr,
                        icon: _isProcessing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              )
                            : const Icon(Icons.camera),
                        label: Text(
                          _isProcessing ? 'Đang quét...' : 'Quét bằng camera',
                          style: AppTextStyles.subtitle2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: _isProcessing
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  if (_isCameraInitialized) const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isProcessing ? null : _pickFromGallery,
                      icon: const Icon(Icons.image),
                      label: Text(
                        'Ảnh có sẵn',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

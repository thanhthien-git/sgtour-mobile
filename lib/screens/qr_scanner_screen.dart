import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/services/qr_code/qr_code_service.dart';
import 'package:sgtourcus/utils/extensions/localization_extension.dart';
import 'package:sgtourcus/widgets/common/base_scaffold.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final QrCodeService _qrCodeService = QrCodeService.instance;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  String? _detectedValue;
  Timer? _debounceTimer;
  bool _hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() => _hasCameraPermission = status.isGranted);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    for (final barcode in barcodes) {
      final value = barcode.rawValue ?? barcode.displayValue;
      if (value != null && value.isNotEmpty) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _detectedValue = value);
            _handleQrDetected(value);
          }
        });
        break;
      }
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
            _showErrorSnackBar(context.l10n.qr_scanner_no_code_detected);
          }
        } catch (e) {
          if (mounted) return;
          _showErrorSnackBar('Error: ${e.toString()}');
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      });
    } catch (e) {
      if (mounted) return;
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
                    context.l10n.qr_scanner_title,
                    style: AppTextStyles.subtitle1.copyWith(
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: _hasCameraPermission
                      ? AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: MobileScanner(
                              controller: _scannerController,
                              onDetect: _onDetect,
                            ),
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 80,
                                  color: AppColors.primary
                                      .withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.l10n.qr_scanner_camera_not_available,
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
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_hasCameraPermission)
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        context.l10n.qr_scanner_scan_button,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body2.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  if (_hasCameraPermission) const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isProcessing ? null : _pickFromGallery,
                      icon: const Icon(Icons.image),
                      label: Text(
                        context.l10n.qr_scanner_gallery_button,
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

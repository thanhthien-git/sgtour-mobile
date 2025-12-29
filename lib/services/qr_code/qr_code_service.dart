import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:permission_handler/permission_handler.dart';

class QrCodeService {
  static final QrCodeService _instance = QrCodeService._internal();

  late BarcodeScanner _barcodeScanner;

  QrCodeService._internal() {
    _barcodeScanner = BarcodeScanner();
  }

  static QrCodeService get instance => _instance;

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<String?> detectFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) return null;

      for (final barcode in barcodes) {
        final value = barcode.displayValue ?? barcode.rawValue;
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }

      return null;
    } catch (e) {
      throw QrCodeException('Failed to detect QR code: $e');
    }
  }

  Future<List<String>> detectFromMultipleImages(List<File> imageFiles) async {
    final results = <String>[];

    try {
      for (final file in imageFiles) {
        final result = await detectFromImage(file);
        if (result != null) {
          results.add(result);
        }
      }
      return results;
    } catch (e) {
      throw QrCodeException('Failed to process images: $e');
    }
  }

  void dispose() {
    _barcodeScanner.close();
  }
}

class QrCodeException implements Exception {
  final String message;

  QrCodeException(this.message);

  @override
  String toString() => 'QrCodeException: $message';
}

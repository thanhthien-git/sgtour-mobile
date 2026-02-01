import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryService {
  static const String cloudName = 'dqybphwx5';
  static const String uploadPreset = 'sgtour';

  static final Dio _dio = Dio();

  static Future<String?> uploadImage(File file, {String? folder}) async {
    try {
      String fileName = file.path.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
        "upload_preset": uploadPreset,
        if (folder != null) "folder": folder,
      });

      Response response = await _dio.post(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
      return null;
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return null;
    }
  }

  /// Upload video file (Cloudinary video/upload)
  static Future<String?> uploadVideo(File file, {String? folder}) async {
    try {
      String fileName = file.path.split(RegExp(r'[/\\]')).last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
        "upload_preset": uploadPreset,
        "resource_type": "video",
        if (folder != null) "folder": folder,
      });
      Response response = await _dio.post(
        "https://api.cloudinary.com/v1_1/$cloudName/video/upload",
        data: formData,
      );
      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
      return null;
    } catch (e) {
      print("Cloudinary Video Upload Error: $e");
      return null;
    }
  }
}

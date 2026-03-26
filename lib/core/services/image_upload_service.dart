import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../constants/api_endpoints.dart';
import 'api_service.dart';

class ImageUploadService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> uploadImages(List<File> files) async {
    List<MultipartFile> multipartFiles = [];
    for (var file in files) {
      String fileName = file.path.split('/').last;
      multipartFiles.add(
        await MultipartFile.fromFile(file.path, filename: fileName),
      );
    }

    FormData formData = FormData.fromMap({
      "image":
          multipartFiles, // Backend expects "image" as a list for multiple files
    });

    final response = await _apiService.post(
      ApiEndpoints.uploadImage,
      data: formData,
    );

    if (response.data['status'] == 'success') {
      return {
        'image_url': response.data['image_url'],
        'image_urls': List<String>.from(response.data['image_urls'] ?? []),
      };
    } else {
      throw Exception(response.data['message'] ?? 'Failed to upload images');
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      final result = await uploadImages([file]);
      return result['image_url'];
    } catch (e) {
      debugPrint('Upload Error: $e');
      return null;
    }
  }
}

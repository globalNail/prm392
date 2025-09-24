import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service để xử lý upload và quản lý ảnh
class ImageService {
  static const String _imageFolder = 'product_images';
  final ImagePicker _picker = ImagePicker();

  /// Chọn ảnh từ gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from gallery: $e');
      }
      rethrow;
    }
  }

  /// Chọn ảnh từ camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from camera: $e');
      }
      rethrow;
    }
  }

  /// Lưu ảnh vào local storage và trả về đường dẫn
  Future<String?> saveImage(XFile imageFile) async {
    try {
      if (kIsWeb) {
        // Trên web, ta sẽ lưu dưới dạng base64 hoặc blob URL
        return await _saveImageWeb(imageFile);
      } else {
        // Trên mobile, lưu vào app directory
        return await _saveImageMobile(imageFile);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving image: $e');
      }
      return null;
    }
  }

  /// Lưu ảnh trên web platform
  Future<String> _saveImageWeb(XFile imageFile) async {
    // Trên web, ta có thể chuyển thành data URL hoặc blob URL
    final bytes = await imageFile.readAsBytes();

    // Trong thực tế, bạn có thể upload lên server hoặc cloud storage
    // Hiện tại ta sẽ tạo data URL để hiển thị
    final base64String = base64UrlEncode(bytes);
    return 'data:image/${imageFile.path.split('.').last};base64,$base64String';
  }

  /// Lưu ảnh trên mobile platform
  Future<String> _saveImageMobile(XFile imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDir.path, _imageFolder));

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
    final filePath = path.join(imageDir.path, fileName);

    final bytes = await imageFile.readAsBytes();
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  /// Xóa ảnh theo đường dẫn
  Future<bool> deleteImage(String imagePath) async {
    try {
      if (kIsWeb) {
        // Trên web, không cần xóa vì sử dụng data URL
        return true;
      } else {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      return false;
    }
  }

  /// Kiểm tra xem ảnh có tồn tại không
  Future<bool> imageExists(String imagePath) async {
    try {
      if (kIsWeb) {
        // Trên web, ta giả sử data URL luôn tồn tại
        return imagePath.startsWith('data:image') ||
            imagePath.startsWith('http');
      } else {
        final file = File(imagePath);
        return await file.exists();
      }
    } catch (e) {
      return false;
    }
  }

  /// Hiển thị dialog chọn nguồn ảnh (Gallery hoặc Camera)
  Future<XFile?> showImageSourceDialog(context) async {
    if (kIsWeb) {
      // Trên web chỉ hỗ trợ gallery
      return await pickImageFromGallery();
    }

    return await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn nguồn ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện ảnh'),
              onTap: () async {
                final image = await pickImageFromGallery();
                Navigator.of(context).pop(image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Máy ảnh'),
              onTap: () async {
                final image = await pickImageFromCamera();
                Navigator.of(context).pop(image);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }
}

/// Extension để encode base64 URL safe
String base64UrlEncode(List<int> bytes) {
  return base64Encode(
    bytes,
  ).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
}

/// Hàm decode base64 URL safe
Uint8List base64UrlDecode(String str) {
  String output = str.replaceAll('-', '+').replaceAll('_', '/');
  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
    default:
      throw Exception('Illegal base64url string');
  }
  return base64Decode(output);
}

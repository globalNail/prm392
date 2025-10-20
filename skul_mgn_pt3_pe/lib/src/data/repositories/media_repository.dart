import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../common/result.dart';
import '../../common/app_logger.dart';

/// Repository for media operations (camera, gallery)
class MediaRepository {
  final ImagePicker _picker;
  static final _logger = AppLogger('MediaRepository');

  MediaRepository({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Pick image from camera
  Future<Result<String>> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        return const Failure('Không có ảnh được chọn');
      }

      final savedPath = await _saveImage(image);
      return Success(savedPath);
    } catch (e, stackTrace) {
      _logger.error('Error picking image from camera', e, stackTrace);
      return Failure('Không thể chụp ảnh', error: e, stackTrace: stackTrace);
    }
  }

  /// Pick image from gallery
  Future<Result<String>> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        return const Failure('Không có ảnh được chọn');
      }

      final savedPath = await _saveImage(image);
      return Success(savedPath);
    } catch (e, stackTrace) {
      _logger.error('Error picking image from gallery', e, stackTrace);
      return Failure('Không thể chọn ảnh', error: e, stackTrace: stackTrace);
    }
  }

  /// Save image to app directory
  Future<String> _saveImage(XFile image) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagesDir = path.join(appDir.path, 'avatars');

    // Create directory if it doesn't exist
    await Directory(imagesDir).create(recursive: true);

    // Generate unique filename
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
    final String savePath = path.join(imagesDir, fileName);

    // Copy file to app directory
    await File(image.path).copy(savePath);

    _logger.info('Image saved to: $savePath');
    return savePath;
  }

  /// Delete image file
  Future<Result<void>> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        _logger.info('Deleted image: $imagePath');
      }
      return const Success(null);
    } catch (e, stackTrace) {
      _logger.error('Error deleting image: $imagePath', e, stackTrace);
      return Failure('Không thể xóa ảnh', error: e, stackTrace: stackTrace);
    }
  }
}

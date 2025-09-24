import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_image.dart';
import '../services/image_service.dart';

/// Widget để chọn và hiển thị ảnh
class ImagePickerWidget extends StatefulWidget {
  final String? initialImagePath;
  final Function(String?)? onImageChanged;
  final double width;
  final double height;
  final String? placeholder;
  final bool allowRemove;

  const ImagePickerWidget({
    super.key,
    this.initialImagePath,
    this.onImageChanged,
    this.width = 200,
    this.height = 200,
    this.placeholder,
    this.allowRemove = true,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imagePath;
  final ImageService _imageService = ImageService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  @override
  void didUpdateWidget(ImagePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImagePath != widget.initialImagePath) {
      setState(() {
        _imagePath = widget.initialImagePath;
      });
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? pickedFile = await _imageService.showImageSourceDialog(
        context,
      );

      if (pickedFile != null) {
        final savedPath = await _imageService.saveImage(pickedFile);

        if (savedPath != null) {
          setState(() {
            _imagePath = savedPath;
          });
          widget.onImageChanged?.call(savedPath);
        } else {
          _showErrorMessage('Không thể lưu ảnh');
        }
      }
    } catch (e) {
      _showErrorMessage('Lỗi khi chọn ảnh: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeImage() async {
    if (_imagePath != null) {
      await _imageService.deleteImage(_imagePath!);
      setState(() {
        _imagePath = null;
      });
      widget.onImageChanged?.call(null);
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildImageWidget() {
    if (_imagePath == null || _imagePath!.isEmpty) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              widget.placeholder ?? 'Chọn ảnh',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: AppImage(
        src: _imagePath,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _isLoading ? null : _pickImage,
          child: _isLoading
              ? Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              : _buildImageWidget(),
        ),
        if (_imagePath != null && widget.allowRemove && !_isLoading)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget nhỏ gọn để hiển thị ảnh sản phẩm
class ProductImageWidget extends StatelessWidget {
  final String? imagePath;
  final double width;
  final double height;
  final BoxFit fit;

  const ProductImageWidget({
    super.key,
    this.imagePath,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return AppImage(
      src: imagePath,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(8),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/utils/product_image_builder.dart';
import '../../domain/entities/product.dart';
import '../providers/product_list_controller.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  late final TextEditingController _descriptionController;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSubmitting = false;
  bool _isProcessingImage = false;
  String _previewImagePath = '';

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    _imageController = TextEditingController(text: product?.image ?? '');
    _previewImagePath = _imageController.text.trim();
    _imageController.addListener(_handleImagePathChanged);
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
  }

  @override
  void dispose() {
    _imageController.removeListener(_handleImagePathChanged);
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleImagePathChanged() {
    final nextPath = _imageController.text.trim();
    if (nextPath == _previewImagePath) {
      return;
    }
    setState(() {
      _previewImagePath = nextPath;
    });
  }

  Future<void> _pickImage() async {
    if (_isProcessingImage) return;
    try {
      final XFile? picked =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _isProcessingImage = true);

        final rawBytes = await picked.readAsBytes();
        final decoded = img.decodeImage(rawBytes);
        if (decoded == null) {
          throw 'Định dạng ảnh không được hỗ trợ';
        }

        const maxSize = 1600;
        final longestSide =
            decoded.width > decoded.height ? decoded.width : decoded.height;
        final shouldResize = longestSide > maxSize;
        final scale = shouldResize ? maxSize / longestSide : 1.0;
        final targetWidth = (decoded.width * scale).round();
        final targetHeight = (decoded.height * scale).round();
        final processed = shouldResize
            ? img.copyResize(
                decoded,
                width: targetWidth > 0 ? targetWidth : 1,
                height: targetHeight > 0 ? targetHeight : 1,
                interpolation: img.Interpolation.cubic,
              )
            : decoded;

        final encodedBytes = img.encodeJpg(processed, quality: 85);

        final directory = await getApplicationDocumentsDirectory();
        final imagesDir = Directory(p.join(directory.path, 'product_images'));
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedPath = p.join(imagesDir.path, fileName);
        final file = File(savedPath);
        await file.writeAsBytes(encodedBytes, flush: true);

        if (!mounted) return;
        _imageController.text = savedPath;
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xử lý ảnh: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingImage = false);
      }
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final price = double.parse(_priceController.text.replaceAll(',', '.'));
      final baseProduct = widget.product ??
          Product(
            id: '',
            name: _nameController.text.trim(),
            price: price,
            description: _descriptionController.text.trim(),
            image: _imageController.text.trim(),
          );

      final updated = baseProduct.copyWith(
        name: _nameController.text.trim(),
        price: price,
        description: _descriptionController.text.trim(),
        image: _imageController.text.trim(),
      );

      final notifier = ref.read(productListControllerProvider.notifier);
      Product result;
      if (_isEditing) {
        result = await notifier.update(updated);
      } else {
        result = await notifier.add(updated);
      }

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giá sản phẩm không hợp lệ.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lưu sản phẩm: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImagePreview(
                imagePath: _previewImagePath,
                isProcessing: _isProcessingImage,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                labelText: 'Tên sản phẩm',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _priceController,
                labelText: 'Giá (VND)',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập giá sản phẩm';
                  }
                  final parsed = double.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null || parsed < 0) {
                    return 'Giá phải lớn hơn hoặc bằng 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _imageController,
                labelText: 'Ảnh (đường dẫn)',
                helperText:
                    'Hỗ trợ đường dẫn asset, http(s) hoặc đường dẫn tệp trong máy.',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.photo_library_outlined),
                  tooltip: 'Chọn ảnh trong máy',
                  onPressed:
                      _isSubmitting || _isProcessingImage ? null : _pickImage,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập đường dẫn ảnh';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                labelText: 'Mô tả',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AppButton(
                label: _isEditing ? 'Cập nhật' : 'Thêm mới',
                onPressed: _isSubmitting ? null : _submit,
              ),
              if (_isSubmitting) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.imagePath,
    required this.isProcessing,
  });

  final String imagePath;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imagePath.trim().isNotEmpty;

    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surfaceVariant,
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? buildProductImage(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chưa có ảnh sản phẩm',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
        ),
        if (isProcessing)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

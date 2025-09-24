import 'package:flutter/material.dart';
import '../models/product.dart';
import 'image_picker_widget.dart';

// Widget tái sử dụng cho form thêm/sửa sản phẩm
class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, this.product, required this.onSave});

  final Product? product;
  final Function(Product) onSave;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _imageController;
  late final TextEditingController _descController;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _imageController = TextEditingController(
      text: widget.product?.imageUrl ?? '',
    );
    _descController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _selectedImagePath = widget.product?.localImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // Ưu tiên ảnh local trước, nếu không có thì dùng URL
    String imageUrl = _imageController.text.trim().isEmpty
        ? 'https://via.placeholder.com/150'
        : _imageController.text.trim();

    final product = Product(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: name,
      imageUrl: imageUrl,
      description: _descController.text.trim(),
      localImagePath: _selectedImagePath,
    );

    widget.onSave(product);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Image picker section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ảnh sản phẩm',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ImagePickerWidget(
                      initialImagePath:
                          _selectedImagePath ?? widget.product?.imageUrl,
                      onImageChanged: (path) {
                        setState(() {
                          _selectedImagePath = path;
                        });
                      },
                      width: 120,
                      height: 120,
                      placeholder: 'Chọn ảnh',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'URL ảnh (tùy chọn)',
                        border: OutlineInputBorder(),
                        helperText: 'Hoặc chọn ảnh từ thiết bị',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Mô tả',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  child: Text(widget.product == null ? 'Thêm' : 'Lưu'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

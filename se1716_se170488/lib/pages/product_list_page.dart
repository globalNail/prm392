import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<Product> _products = [
    Product(
      id: 1,
      name: 'iPhone 15',
      imageUrl:
          'https://images.unsplash.com/photo-1696446706343-88a1dc8c1a17?q=80&w=800&auto=format&fit=crop',
      description: 'Điện thoại thông minh cao cấp của Apple.',
    ),
    Product(
      id: 2,
      name: 'Galaxy S24',
      imageUrl:
          'https://images.unsplash.com/photo-1609250291996-fdebe6020a5a?q=80&w=800&auto=format&fit=crop',
      description: 'Flagship Android của Samsung.',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  int _nextId = 3;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _products;
    return _products
        .where((p) => p.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  void _openDetail(Product p) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)));
    if (result is Product) {
      setState(() {
        final idx = _products.indexWhere((e) => e.id == result.id);
        if (idx >= 0) _products[idx] = result;
      });
    } else if (result is Map && result['deleted'] == true) {
      setState(() {
        _products.removeWhere((e) => e.id == result['id']);
      });
    }
  }

  void _showEditDialog({Product? editing}) {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final imageCtrl = TextEditingController(text: editing?.imageUrl ?? '');
    final descCtrl = TextEditingController(text: editing?.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                editing == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ảnh (URL) - có thể để trống',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        setState(() {
                          if (editing == null) {
                            _products.add(
                              Product(
                                id: _nextId++,
                                name: name,
                                imageUrl: imageCtrl.text.trim().isEmpty
                                    ? 'https://via.placeholder.com/150'
                                    : imageCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                              ),
                            );
                          } else {
                            editing
                              ..name = name
                              ..imageUrl = imageCtrl.text.trim().isEmpty
                                  ? 'https://via.placeholder.com/150'
                                  : imageCtrl.text.trim()
                              ..description = descCtrl.text.trim();
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(editing == null ? 'Thêm' : 'Lưu'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _delete(Product p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _products.removeWhere((e) => e.id == p.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
        actions: [
          IconButton(
            tooltip: 'Thêm sản phẩm',
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _filteredProducts.isEmpty
          ? const Center(child: Text('Không có sản phẩm'))
          : ListView.separated(
              itemCount: _filteredProducts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final p = _filteredProducts[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      p.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text(p.name),
                  subtitle: Text(
                    p.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _openDetail(p),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Sửa',
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(editing: p),
                      ),
                      IconButton(
                        tooltip: 'Xóa',
                        icon: const Icon(Icons.delete),
                        onPressed: () => _delete(p),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

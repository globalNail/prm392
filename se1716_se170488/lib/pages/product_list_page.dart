import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/search_field.dart';
import 'base_page.dart';
import 'product_detail_page.dart';

class ProductListPage extends BasePage {
  const ProductListPage({super.key})
    : super(
        title: 'Danh sách sản phẩm',
        showBackButton: false,
        actions: const [],
      );

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends BasePageState<ProductListPage> {
  List<Product> _products = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void onInitState() {
    super.onInitState();
    _loadProducts();
  }

  @override
  void onDispose() {
    _searchController.dispose();
    super.onDispose();
  }

  Future<void> _loadProducts() async {
    showLoading();
    try {
      final products = await storageService.getProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      showError('Lỗi khi tải danh sách sản phẩm: ${e.toString()}');
    } finally {
      hideLoading();
    }
  }

  List<Product> get _filteredProducts {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _products;
    return _products
        .where((p) => p.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  void _openDetail(Product product) async {
    final result = await navigateTo(ProductDetailPage(product: product));
    if (result is Product) {
      await _loadProducts(); // Reload products after edit
    } else if (result is Map && result['deleted'] == true) {
      await _loadProducts(); // Reload products after delete
    }
  }

  void _showEditDialog({Product? editing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ProductFormDialog(product: editing, onSave: _saveProduct);
      },
    );
  }

  Future<void> _saveProduct(Product product) async {
    showLoading();
    try {
      await storageService.saveProduct(product);
      await _loadProducts();
      showSuccess(
        product.id == DateTime.now().millisecondsSinceEpoch
            ? 'Thêm sản phẩm thành công!'
            : 'Cập nhật sản phẩm thành công!',
      );
    } catch (e) {
      showError('Lỗi khi lưu sản phẩm: ${e.toString()}');
    } finally {
      hideLoading();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showConfirmationDialog(
      title: 'Xóa sản phẩm',
      content: 'Bạn có chắc muốn xóa "${product.name}"?',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
    );

    if (confirm) {
      showLoading();
      try {
        await storageService.deleteProduct(product.id);
        await _loadProducts();
        showSuccess('Xóa sản phẩm thành công!');
      } catch (e) {
        showError('Lỗi khi xóa sản phẩm: ${e.toString()}');
      } finally {
        hideLoading();
      }
    }
  }

  @override
  Widget buildBody() {
    return Stack(
      children: [
        Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchField(
                controller: _searchController,
                hintText: 'Tìm kiếm sản phẩm...',
                onChanged: (_) => setState(() {}),
              ),
            ),

            // Products list
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Không có sản phẩm',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () => _openDetail(product),
                          onEdit: () => _showEditDialog(editing: product),
                          onDelete: () => _deleteProduct(product),
                        );
                      },
                    ),
            ),
          ],
        ),

        // Floating add button at bottom-right
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showEditDialog(),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

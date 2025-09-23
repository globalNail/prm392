import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../widgets/search_field.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/widget_builders.dart';
import '../models/product.dart';

// Ví dụ cách sử dụng các widget đã tổ chức
class ImprovedProductListPage extends StatefulWidget {
  const ImprovedProductListPage({super.key});

  @override
  State<ImprovedProductListPage> createState() => _ImprovedProductListPageState();
}

class _ImprovedProductListPageState extends State<ImprovedProductListPage> {
  final List<Product> _products = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate loading
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Add sample products
      _products.addAll([
        Product(
          id: 1,
          name: 'iPhone 15',
          imageUrl: 'https://images.unsplash.com/photo-1696446706343-88a1dc8c1a17?q=80&w=800',
          description: 'Điện thoại thông minh cao cấp của Apple.',
        ),
        Product(
          id: 2,
          name: 'Galaxy S24',
          imageUrl: 'https://images.unsplash.com/photo-1609250291996-fdebe6020a5a?q=80&w=800',
          description: 'Flagship Android của Samsung.',
        ),
      ]);
      
      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _products;
    return _products.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  void _showAddProductDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductFormDialog(
        onSave: (product) {
          setState(() {
            _products.add(product);
          });
        },
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductFormDialog(
        product: product,
        onSave: (updatedProduct) {
          setState(() {
            final index = _products.indexWhere((p) => p.id == product.id);
            if (index >= 0) {
              _products[index] = updatedProduct;
            }
          });
        },
      ),
    );
  }

  void _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _products.removeWhere((p) => p.id == product.id);
      });
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return WidgetBuilders.buildLoadingState('Đang tải sản phẩm...');
    }

    if (_error != null) {
      return WidgetBuilders.buildErrorState(
        error: _error!,
        onRetry: _loadProducts,
      );
    }

    final filteredProducts = _filteredProducts;

    if (filteredProducts.isEmpty) {
      return WidgetBuilders.buildEmptyState(
        title: _searchController.text.isEmpty 
            ? 'Chưa có sản phẩm nào'
            : 'Không tìm thấy sản phẩm',
        subtitle: _searchController.text.isEmpty
            ? 'Hãy thêm sản phẩm đầu tiên'
            : 'Thử từ khóa tìm kiếm khác',
        icon: Icons.inventory_2_outlined,
        onAction: _searchController.text.isEmpty ? _showAddProductDialog : null,
        actionText: 'Thêm sản phẩm',
      );
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () {
            // Navigate to product detail
          },
          onEdit: () => _showEditProductDialog(product),
          onDelete: () => _deleteProduct(product),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm (Improved)'),
        actions: [
          IconButton(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            hintText: 'Tìm kiếm sản phẩm...',
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
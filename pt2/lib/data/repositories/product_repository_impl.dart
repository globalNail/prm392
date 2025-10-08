import 'dart:math';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_memory_source.dart';
import '../mappers/product_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._memorySource);

  final ProductMemorySource _memorySource;
  final Random _random = Random();

  @override
  Future<List<Product>> loadProducts() async {
    final rawProducts = await _memorySource.loadProducts();
    return rawProducts.map(ProductMapper.fromJson).toList(growable: false);
  }

  @override
  Future<Product?> findById(String id) async {
    final products = await loadProducts();
    for (final product in products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  @override
  Future<List<Product>> searchByName(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return loadProducts();
    }
    final lowercaseQuery = trimmed.toLowerCase();
    final products = await loadProducts();
    return products
        .where(
          (product) => product.name.toLowerCase().contains(lowercaseQuery),
        )
        .toList(growable: false);
  }

  @override
  Future<Product> addProduct(Product product) async {
    final products = await loadProducts();
    final newProduct = product.id.isEmpty
        ? product.copyWith(id: _generateId(products))
        : product;
    final updated = <Product>[...products, newProduct];
    await _persist(updated);
    return newProduct;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final products = await loadProducts();
    final index = products.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      throw AppException('Không tìm thấy sản phẩm để cập nhật.');
    }
    final updated = [...products]..[index] = product;
    await _persist(updated);
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    final products = await loadProducts();
    final exists = products.any((product) => product.id == id);
    if (!exists) {
      throw AppException('Không tìm thấy sản phẩm để xóa.');
    }
    final updated = products.where((product) => product.id != id).toList();
    await _persist(updated);
  }

  Future<void> _persist(List<Product> products) async {
    final mapped = products.map(ProductMapper.toJson).toList(growable: false);
    await _memorySource.writeProducts(mapped);
  }

  String _generateId(List<Product> products) {
    final existingIds = products.map((product) => product.id).toSet();
    String candidate =
        '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';
    while (existingIds.contains(candidate)) {
      candidate =
          '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';
    }
    return candidate;
  }
}

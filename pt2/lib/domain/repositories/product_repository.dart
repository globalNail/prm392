import '../entities/product.dart';

/// Abstract repository defining operations for managing products.
abstract class ProductRepository {
  Future<List<Product>> loadProducts();

  Future<Product?> findById(String id);

  Future<List<Product>> searchByName(String query);

  Future<Product> addProduct(Product product);

  Future<Product> updateProduct(Product product);

  Future<void> deleteProduct(String id);
}

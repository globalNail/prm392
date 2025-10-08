import '../entities/product.dart';
import '../repositories/product_repository.dart';

class LoadProducts {
  const LoadProducts(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call() => _repository.loadProducts();
}

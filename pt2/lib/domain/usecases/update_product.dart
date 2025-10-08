import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  const UpdateProduct(this._repository);

  final ProductRepository _repository;

  Future<Product> call(Product product) => _repository.updateProduct(product);
}

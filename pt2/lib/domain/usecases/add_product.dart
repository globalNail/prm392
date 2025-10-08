import '../entities/product.dart';
import '../repositories/product_repository.dart';

class AddProduct {
  const AddProduct(this._repository);

  final ProductRepository _repository;

  Future<Product> call(Product product) => _repository.addProduct(product);
}

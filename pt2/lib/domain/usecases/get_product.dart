import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProduct {
  const GetProduct(this._repository);

  final ProductRepository _repository;

  Future<Product?> call(String id) => _repository.findById(id);
}

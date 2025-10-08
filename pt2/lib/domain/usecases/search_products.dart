import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProducts {
  const SearchProducts(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call(String query) =>
      _repository.searchByName(query.trim());
}

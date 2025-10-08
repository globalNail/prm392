import '../../domain/entities/product.dart';

class ProductMapper {
  const ProductMapper._();

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      image: json['image'] as String,
    );
  }

  static Map<String, dynamic> toJson(Product product) {
    return <String, dynamic>{
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'image': product.image,
    };
  }
}

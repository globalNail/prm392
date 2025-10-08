import 'package:flutter/foundation.dart';

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  final String id;
  final String name;
  final double price;
  final String description;
  final String image;

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? image,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.description == description &&
        other.image == image;
  }

  @override
  int get hashCode => Object.hash(id, name, price, description, image);
}

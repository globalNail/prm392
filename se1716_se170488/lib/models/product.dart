class Product {
  final int id;
  String name;
  String imageUrl;
  String description;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  Product copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }
}

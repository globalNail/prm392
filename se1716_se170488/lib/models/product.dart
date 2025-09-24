import 'base_entity.dart';

class Product extends BaseEntity {
  String name;
  String imageUrl;
  String description;
  String? localImagePath; // Đường dẫn ảnh local (nếu có)

  Product({
    required super.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    this.localImagePath,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'localImagePath': localImagePath,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      localImagePath: json['localImagePath'],
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? description,
    String? localImagePath,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      localImagePath: localImagePath ?? this.localImagePath,
    );
  }

  /// Lấy đường dẫn ảnh để hiển thị (ưu tiên local trước)
  String get displayImagePath => localImagePath ?? imageUrl;

  /// Kiểm tra có ảnh local không
  bool get hasLocalImage =>
      localImagePath != null && localImagePath!.isNotEmpty;
}

abstract class BaseEntity {
  final int id;

  BaseEntity({required this.id});

  // Abstract methods that implementing classes must define
  Map<String, dynamic> toJson();

  // Common functionality for all entities
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$runtimeType(id: $id)';
}

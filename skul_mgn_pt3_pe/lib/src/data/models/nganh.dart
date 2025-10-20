/// Model for Nganh (Department/Major)
class Nganh {
  final int? id;
  final String ma; // Unique code
  final String ten; // Name
  final String? moTa; // Description
  final int? createdAt;
  final int? updatedAt;

  const Nganh({
    this.id,
    required this.ma,
    required this.ten,
    this.moTa,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with updated fields
  Nganh copyWith({
    int? id,
    String? ma,
    String? ten,
    String? moTa,
    int? createdAt,
    int? updatedAt,
  }) {
    return Nganh(
      id: id ?? this.id,
      ma: ma ?? this.ma,
      ten: ten ?? this.ten,
      moTa: moTa ?? this.moTa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from database map
  factory Nganh.fromMap(Map<String, dynamic> map) {
    return Nganh(
      id: map['id'] as int?,
      ma: map['ma'] as String,
      ten: map['ten'] as String,
      moTa: map['moTa'] as String?,
      createdAt: map['createdAt'] as int?,
      updatedAt: map['updatedAt'] as int?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ma': ma,
      'ten': ten,
      'moTa': moTa,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Nganh(id: $id, ma: $ma, ten: $ten, moTa: $moTa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Nganh &&
        other.id == id &&
        other.ma == ma &&
        other.ten == ten &&
        other.moTa == moTa &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, ma, ten, moTa, createdAt, updatedAt);
  }
}

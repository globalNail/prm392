/// Model for Account (user authentication)
class Account {
  final int? id;
  final String username;
  final String passwordHash;
  final int? sinhVienId; // Foreign key to SinhVien
  final int? createdAt;

  const Account({
    this.id,
    required this.username,
    required this.passwordHash,
    this.sinhVienId,
    this.createdAt,
  });

  /// Create a copy with updated fields
  Account copyWith({
    int? id,
    String? username,
    String? passwordHash,
    int? sinhVienId,
    int? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      sinhVienId: sinhVienId ?? this.sinhVienId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert from database map
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['passwordHash'] as String,
      sinhVienId: map['sinhVienId'] as int?,
      createdAt: map['createdAt'] as int?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'sinhVienId': sinhVienId,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'Account(id: $id, username: $username, sinhVienId: $sinhVienId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account &&
        other.id == id &&
        other.username == username &&
        other.passwordHash == passwordHash &&
        other.sinhVienId == sinhVienId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, username, passwordHash, sinhVienId, createdAt);
  }
}

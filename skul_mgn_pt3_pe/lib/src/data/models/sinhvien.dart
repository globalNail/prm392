/// Model for SinhVien (Student)
class SinhVien {
  final int? id;
  final String maSV; // Unique student code
  final String hoTen; // Full name
  final String? ngaySinh; // Birth date (ISO8601)
  final String? diaChi; // Address
  final String? sdt; // Phone number
  final String? email;
  final int? nganhId; // Foreign key to Nganh
  final String? avatarPath; // Path to avatar image
  final double? lat; // Latitude
  final double? lng; // Longitude
  final int? createdAt;
  final int? updatedAt;

  const SinhVien({
    this.id,
    required this.maSV,
    required this.hoTen,
    this.ngaySinh,
    this.diaChi,
    this.sdt,
    this.email,
    this.nganhId,
    this.avatarPath,
    this.lat,
    this.lng,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with updated fields
  SinhVien copyWith({
    int? id,
    String? maSV,
    String? hoTen,
    String? ngaySinh,
    String? diaChi,
    String? sdt,
    String? email,
    int? nganhId,
    String? avatarPath,
    double? lat,
    double? lng,
    int? createdAt,
    int? updatedAt,
  }) {
    return SinhVien(
      id: id ?? this.id,
      maSV: maSV ?? this.maSV,
      hoTen: hoTen ?? this.hoTen,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      diaChi: diaChi ?? this.diaChi,
      sdt: sdt ?? this.sdt,
      email: email ?? this.email,
      nganhId: nganhId ?? this.nganhId,
      avatarPath: avatarPath ?? this.avatarPath,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert from database map
  factory SinhVien.fromMap(Map<String, dynamic> map) {
    return SinhVien(
      id: map['id'] as int?,
      maSV: map['maSV'] as String,
      hoTen: map['hoTen'] as String,
      ngaySinh: map['ngaySinh'] as String?,
      diaChi: map['diaChi'] as String?,
      sdt: map['sdt'] as String?,
      email: map['email'] as String?,
      nganhId: map['nganhId'] as int?,
      avatarPath: map['avatarPath'] as String?,
      lat: map['lat'] as double?,
      lng: map['lng'] as double?,
      createdAt: map['createdAt'] as int?,
      updatedAt: map['updatedAt'] as int?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'maSV': maSV,
      'hoTen': hoTen,
      'ngaySinh': ngaySinh,
      'diaChi': diaChi,
      'sdt': sdt,
      'email': email,
      'nganhId': nganhId,
      'avatarPath': avatarPath,
      'lat': lat,
      'lng': lng,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'SinhVien(id: $id, maSV: $maSV, hoTen: $hoTen, nganhId: $nganhId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SinhVien &&
        other.id == id &&
        other.maSV == maSV &&
        other.hoTen == hoTen &&
        other.ngaySinh == ngaySinh &&
        other.diaChi == diaChi &&
        other.sdt == sdt &&
        other.email == email &&
        other.nganhId == nganhId &&
        other.avatarPath == avatarPath &&
        other.lat == lat &&
        other.lng == lng &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      maSV,
      hoTen,
      ngaySinh,
      diaChi,
      sdt,
      email,
      nganhId,
      avatarPath,
      lat,
      lng,
      createdAt,
      updatedAt,
    );
  }
}

/// Extended student model with Nganh information
class SinhVienWithNganh {
  final SinhVien sinhVien;
  final String? nganhTen; // Department name
  final String? nganhMa; // Department code

  const SinhVienWithNganh({
    required this.sinhVien,
    this.nganhTen,
    this.nganhMa,
  });

  factory SinhVienWithNganh.fromMap(Map<String, dynamic> map) {
    return SinhVienWithNganh(
      sinhVien: SinhVien.fromMap(map),
      nganhTen: map['nganhTen'] as String?,
      nganhMa: map['nganhMa'] as String?,
    );
  }
}

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../common/app_logger.dart';

/// Application database manager
class AppDatabase {
  static const String _databaseName = 'skul_mgn.db';
  static const int _databaseVersion = 1;
  static final _logger = AppLogger('AppDatabase');

  static Database? _database;

  /// Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  static Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);

    _logger.info('Initializing database at: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database (enable foreign keys)
  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create tables
  static Future<void> _onCreate(Database db, int version) async {
    _logger.info('Creating database tables (version $version)');

    // Create Nganh table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Nganh (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ma TEXT NOT NULL UNIQUE,
        ten TEXT NOT NULL,
        moTa TEXT,
        createdAt INTEGER,
        updatedAt INTEGER
      )
    ''');

    // Create SinhVien table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS SinhVien (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        maSV TEXT NOT NULL UNIQUE,
        hoTen TEXT NOT NULL,
        ngaySinh TEXT,
        diaChi TEXT,
        sdt TEXT,
        email TEXT,
        nganhId INTEGER,
        avatarPath TEXT,
        lat REAL,
        lng REAL,
        createdAt INTEGER,
        updatedAt INTEGER,
        FOREIGN KEY(nganhId) REFERENCES Nganh(id) ON DELETE SET NULL
      )
    ''');

    // Create Account table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Account (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        sinhVienId INTEGER UNIQUE,
        createdAt INTEGER,
        FOREIGN KEY(sinhVienId) REFERENCES SinhVien(id) ON DELETE CASCADE
      )
    ''');

    // Create migrations table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS _Migrations (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        appliedAt INTEGER NOT NULL
      )
    ''');

    // Record initial migration
    await db.insert('_Migrations', {
      'name': 'initial_schema',
      'appliedAt': DateTime.now().millisecondsSinceEpoch,
    });

    // Seed sample data
    await _seedData(db);
  }

  /// Upgrade database
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    _logger.info('Upgrading database from version $oldVersion to $newVersion');
    // Handle future migrations here
  }

  /// Seed sample data for demo
  static Future<void> _seedData(Database db) async {
    _logger.info('Seeding sample data');

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Nganh (Departments)
    final nganhData = [
      {
        'ma': 'CNTT',
        'ten': 'Công nghệ thông tin',
        'moTa': 'Khoa Công nghệ thông tin',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'ma': 'KTPM',
        'ten': 'Kỹ thuật phần mềm',
        'moTa': 'Khoa Kỹ thuật phần mềm',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'ma': 'KHMT',
        'ten': 'Khoa học máy tính',
        'moTa': 'Khoa Khoa học máy tính',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'ma': 'ATTT',
        'ten': 'An toàn thông tin',
        'moTa': 'Khoa An toàn thông tin',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'ma': 'TMDT',
        'ten': 'Thương mại điện tử',
        'moTa': 'Khoa Thương mại điện tử',
        'createdAt': now,
        'updatedAt': now,
      },
    ];

    for (var nganh in nganhData) {
      await db.insert('Nganh', nganh);
    }

    // Seed SinhVien (Students)
    final sinhVienData = [
      {
        'maSV': 'SV001',
        'hoTen': 'Nguyễn Văn An',
        'ngaySinh': '2002-05-15',
        'diaChi': '123 Nguyễn Huệ, Quận 1, TP.HCM',
        'sdt': '0901234567',
        'email': 'nguyenvanan@example.com',
        'nganhId': 1,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'maSV': 'SV002',
        'hoTen': 'Trần Thị Bình',
        'ngaySinh': '2003-08-20',
        'diaChi': '456 Lê Lợi, Quận 3, TP.HCM',
        'sdt': '0902345678',
        'email': 'tranthibinh@example.com',
        'nganhId': 2,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'maSV': 'SV003',
        'hoTen': 'Lê Hoàng Châu',
        'ngaySinh': '2002-11-10',
        'diaChi': '789 Trần Hưng Đạo, Quận 5, TP.HCM',
        'sdt': '0903456789',
        'email': 'lehoangchau@example.com',
        'nganhId': 1,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'maSV': 'SV004',
        'hoTen': 'Phạm Minh Dương',
        'ngaySinh': '2003-03-25',
        'diaChi': '321 Võ Văn Tần, Quận 3, TP.HCM',
        'sdt': '0904567890',
        'email': 'phamminhduong@example.com',
        'nganhId': 3,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'maSV': 'SV005',
        'hoTen': 'Hoàng Thị Hoa',
        'ngaySinh': '2002-07-18',
        'diaChi': '654 Hai Bà Trưng, Quận 1, TP.HCM',
        'sdt': '0905678901',
        'email': 'hoangthihoa@example.com',
        'nganhId': 4,
        'createdAt': now,
        'updatedAt': now,
      },
    ];

    for (var sv in sinhVienData) {
      await db.insert('SinhVien', sv);
    }

    _logger.info('Sample data seeded successfully');
  }

  /// Close database
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      _logger.info('Database closed');
    }
  }

  /// Delete database (for testing)
  static Future<void> deleteDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);

    await close();
    await databaseFactory.deleteDatabase(path);
    _logger.info('Database deleted');
  }
}

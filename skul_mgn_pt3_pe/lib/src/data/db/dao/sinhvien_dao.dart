import 'package:sqflite/sqflite.dart';
import '../../db/app_database.dart';
import '../../models/sinhvien.dart';
import '../../../common/app_logger.dart';

/// Data Access Object for SinhVien table
class SinhVienDao {
  static const String tableName = 'SinhVien';
  static final _logger = AppLogger('SinhVienDao');

  /// Get all SinhVien records
  Future<List<SinhVien>> getAll() async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'hoTen ASC',
      );
      return maps.map((map) => SinhVien.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error getting all SinhVien', e, stackTrace);
      rethrow;
    }
  }

  /// Get all SinhVien with Nganh information
  Future<List<SinhVienWithNganh>> getAllWithNganh() async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          s.*,
          n.ten as nganhTen,
          n.ma as nganhMa
        FROM SinhVien s
        LEFT JOIN Nganh n ON s.nganhId = n.id
        ORDER BY s.hoTen ASC
      ''');

      return maps.map((map) => SinhVienWithNganh.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error getting all SinhVien with Nganh', e, stackTrace);
      rethrow;
    }
  }

  /// Get SinhVien by ID
  Future<SinhVien?> getById(int id) async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return SinhVien.fromMap(maps.first);
    } catch (e, stackTrace) {
      _logger.error('Error getting SinhVien by ID: $id', e, stackTrace);
      rethrow;
    }
  }

  /// Get SinhVien by ID with Nganh information
  Future<SinhVienWithNganh?> getByIdWithNganh(int id) async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT 
          s.*,
          n.ten as nganhTen,
          n.ma as nganhMa
        FROM SinhVien s
        LEFT JOIN Nganh n ON s.nganhId = n.id
        WHERE s.id = ?
        LIMIT 1
      ''',
        [id],
      );

      if (maps.isEmpty) return null;
      return SinhVienWithNganh.fromMap(maps.first);
    } catch (e, stackTrace) {
      _logger.error(
        'Error getting SinhVien with Nganh by ID: $id',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get SinhVien by student code (maSV)
  Future<SinhVien?> getByMaSV(String maSV) async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'maSV = ?',
        whereArgs: [maSV],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return SinhVien.fromMap(maps.first);
    } catch (e, stackTrace) {
      _logger.error('Error getting SinhVien by maSV: $maSV', e, stackTrace);
      rethrow;
    }
  }

  /// Search SinhVien by name or student code
  Future<List<SinhVienWithNganh>> search(String query) async {
    try {
      final db = await AppDatabase.database;
      final searchPattern = '%$query%';

      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT 
          s.*,
          n.ten as nganhTen,
          n.ma as nganhMa
        FROM SinhVien s
        LEFT JOIN Nganh n ON s.nganhId = n.id
        WHERE s.hoTen LIKE ? OR s.maSV LIKE ?
        ORDER BY s.hoTen ASC
      ''',
        [searchPattern, searchPattern],
      );

      return maps.map((map) => SinhVienWithNganh.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.error(
        'Error searching SinhVien with query: $query',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Insert a new SinhVien
  Future<int> insert(SinhVien sinhVien) async {
    try {
      final db = await AppDatabase.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final data = sinhVien.toMap()
        ..['createdAt'] = now
        ..['updatedAt'] = now;

      final id = await db.insert(
        tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      _logger.info('Inserted SinhVien with ID: $id');
      return id;
    } catch (e, stackTrace) {
      _logger.error('Error inserting SinhVien', e, stackTrace);
      rethrow;
    }
  }

  /// Update an existing SinhVien
  Future<int> update(SinhVien sinhVien) async {
    try {
      if (sinhVien.id == null) {
        throw ArgumentError('SinhVien ID must not be null for update');
      }

      final db = await AppDatabase.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final data = sinhVien.toMap()..['updatedAt'] = now;

      final count = await db.update(
        tableName,
        data,
        where: 'id = ?',
        whereArgs: [sinhVien.id],
      );

      _logger.info('Updated SinhVien with ID: ${sinhVien.id}');
      return count;
    } catch (e, stackTrace) {
      _logger.error('Error updating SinhVien', e, stackTrace);
      rethrow;
    }
  }

  /// Delete a SinhVien by ID
  Future<int> delete(int id) async {
    try {
      final db = await AppDatabase.database;
      final count = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.info('Deleted SinhVien with ID: $id');
      return count;
    } catch (e, stackTrace) {
      _logger.error('Error deleting SinhVien with ID: $id', e, stackTrace);
      rethrow;
    }
  }

  /// Check if a SinhVien with the given student code (maSV) already exists
  Future<bool> existsByMaSV(String maSV, {int? excludeId}) async {
    try {
      final db = await AppDatabase.database;
      String where = 'maSV = ?';
      List<dynamic> whereArgs = [maSV];

      if (excludeId != null) {
        where += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      final count = Sqflite.firstIntValue(
        await db.query(
          tableName,
          columns: ['COUNT(*)'],
          where: where,
          whereArgs: whereArgs,
        ),
      );

      return (count ?? 0) > 0;
    } catch (e, stackTrace) {
      _logger.error(
        'Error checking SinhVien existence by maSV: $maSV',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get count of all SinhVien records
  Future<int> getCount() async {
    try {
      final db = await AppDatabase.database;
      final count = Sqflite.firstIntValue(
        await db.query(tableName, columns: ['COUNT(*)']),
      );
      return count ?? 0;
    } catch (e, stackTrace) {
      _logger.error('Error getting SinhVien count', e, stackTrace);
      rethrow;
    }
  }

  /// Get SinhVien by Nganh ID
  Future<List<SinhVien>> getByNganhId(int nganhId) async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'nganhId = ?',
        whereArgs: [nganhId],
        orderBy: 'hoTen ASC',
      );
      return maps.map((map) => SinhVien.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.error(
        'Error getting SinhVien by nganhId: $nganhId',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}

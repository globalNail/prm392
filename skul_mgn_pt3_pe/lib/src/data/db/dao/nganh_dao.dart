import 'package:sqflite/sqflite.dart';
import '../../db/app_database.dart';
import '../../models/nganh.dart';
import '../../../common/app_logger.dart';

/// Data Access Object for Nganh table
class NganhDao {
  static const String tableName = 'Nganh';
  static final _logger = AppLogger('NganhDao');

  /// Get all Nganh records
  Future<List<Nganh>> getAll() async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'ten ASC',
      );
      return maps.map((map) => Nganh.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error getting all Nganh', e, stackTrace);
      rethrow;
    }
  }

  /// Get Nganh by ID
  Future<Nganh?> getById(int id) async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Nganh.fromMap(maps.first);
    } catch (e, stackTrace) {
      _logger.error('Error getting Nganh by ID: $id', e, stackTrace);
      rethrow;
    }
  }

  /// Get Nganh by code (ma)
  Future<Nganh?> getByMa(String ma) async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'ma = ?',
        whereArgs: [ma],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Nganh.fromMap(maps.first);
    } catch (e, stackTrace) {
      _logger.error('Error getting Nganh by ma: $ma', e, stackTrace);
      rethrow;
    }
  }

  /// Insert a new Nganh
  Future<int> insert(Nganh nganh) async {
    try {
      final db = await AppDatabase.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final data = nganh.toMap()
        ..['createdAt'] = now
        ..['updatedAt'] = now;

      final id = await db.insert(
        tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      _logger.info('Inserted Nganh with ID: $id');
      return id;
    } catch (e, stackTrace) {
      _logger.error('Error inserting Nganh', e, stackTrace);
      rethrow;
    }
  }

  /// Update an existing Nganh
  Future<int> update(Nganh nganh) async {
    try {
      if (nganh.id == null) {
        throw ArgumentError('Nganh ID must not be null for update');
      }

      final db = await AppDatabase.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final data = nganh.toMap()..['updatedAt'] = now;

      final count = await db.update(
        tableName,
        data,
        where: 'id = ?',
        whereArgs: [nganh.id],
      );

      _logger.info('Updated Nganh with ID: ${nganh.id}');
      return count;
    } catch (e, stackTrace) {
      _logger.error('Error updating Nganh', e, stackTrace);
      rethrow;
    }
  }

  /// Delete a Nganh by ID
  Future<int> delete(int id) async {
    try {
      final db = await AppDatabase.database;
      final count = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.info('Deleted Nganh with ID: $id');
      return count;
    } catch (e, stackTrace) {
      _logger.error('Error deleting Nganh with ID: $id', e, stackTrace);
      rethrow;
    }
  }

  /// Check if a Nganh with the given code (ma) already exists
  Future<bool> existsByMa(String ma, {int? excludeId}) async {
    try {
      final db = await AppDatabase.database;
      String where = 'ma = ?';
      List<dynamic> whereArgs = [ma];

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
      _logger.error('Error checking Nganh existence by ma: $ma', e, stackTrace);
      rethrow;
    }
  }

  /// Get count of all Nganh records
  Future<int> getCount() async {
    try {
      final db = await AppDatabase.database;
      final count = Sqflite.firstIntValue(
        await db.query(tableName, columns: ['COUNT(*)']),
      );
      return count ?? 0;
    } catch (e, stackTrace) {
      _logger.error('Error getting Nganh count', e, stackTrace);
      rethrow;
    }
  }
}

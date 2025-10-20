import 'package:sqflite/sqflite.dart';
import '../../db/app_database.dart';
import '../../models/account.dart';
import '../../../common/app_logger.dart';

/// Data Access Object for Account table
class AccountDao {
  static const String tableName = 'Account';
  static final _logger = AppLogger('AccountDao');

  /// Get all Account records
  Future<List<Account>> getAll() async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'username ASC',
      );
      return maps.map((map) => Account.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.error('Error getting all Account', e, stackTrace);
      rethrow;
    }
  }

  /// Get Account by ID
  Future<Account?> getById(int id) async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Account.fromMap(maps.first);
    } catch (e, stackTrace) {
      _logger.error('Error getting Account by ID: $id', e, stackTrace);
      rethrow;
    }
  }

  /// Get Account by username
  Future<Account?> getByUsername(String username) async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'username = ?',
        whereArgs: [username],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Account.fromMap(maps.first);
    } catch (e, stackTrace) {
      _logger.error(
        'Error getting Account by username: $username',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get Account by SinhVien ID
  Future<Account?> getBySinhVienId(int sinhVienId) async {
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'sinhVienId = ?',
        whereArgs: [sinhVienId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Account.fromMap(maps.first);
    } catch (e, stackTrace) {
      _logger.error(
        'Error getting Account by sinhVienId: $sinhVienId',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Insert a new Account
  Future<int> insert(Account account) async {
    try {
      final db = await AppDatabase.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final data = account.toMap()..['createdAt'] = now;

      final id = await db.insert(
        tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      _logger.info('Inserted Account with ID: $id');
      return id;
    } catch (e, stackTrace) {
      _logger.error('Error inserting Account', e, stackTrace);
      rethrow;
    }
  }

  /// Update an existing Account
  Future<int> update(Account account) async {
    try {
      if (account.id == null) {
        throw ArgumentError('Account ID must not be null for update');
      }

      final db = await AppDatabase.database;
      final data = account.toMap();

      final count = await db.update(
        tableName,
        data,
        where: 'id = ?',
        whereArgs: [account.id],
      );

      _logger.info('Updated Account with ID: ${account.id}');
      return count;
    } catch (e, stackTrace) {
      _logger.error('Error updating Account', e, stackTrace);
      rethrow;
    }
  }

  /// Delete an Account by ID
  Future<int> delete(int id) async {
    try {
      final db = await AppDatabase.database;
      final count = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      _logger.info('Deleted Account with ID: $id');
      return count;
    } catch (e, stackTrace) {
      _logger.error('Error deleting Account with ID: $id', e, stackTrace);
      rethrow;
    }
  }

  /// Delete Account by SinhVien ID
  Future<int> deleteBySinhVienId(int sinhVienId) async {
    try {
      final db = await AppDatabase.database;
      final count = await db.delete(
        tableName,
        where: 'sinhVienId = ?',
        whereArgs: [sinhVienId],
      );

      _logger.info('Deleted Account with sinhVienId: $sinhVienId');
      return count;
    } catch (e, stackTrace) {
      _logger.error(
        'Error deleting Account with sinhVienId: $sinhVienId',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Check if a username already exists
  Future<bool> existsByUsername(String username, {int? excludeId}) async {
    try {
      final db = await AppDatabase.database;
      String where = 'username = ?';
      List<dynamic> whereArgs = [username];

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
        'Error checking Account existence by username: $username',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get count of all Account records
  Future<int> getCount() async {
    try {
      final db = await AppDatabase.database;
      final count = Sqflite.firstIntValue(
        await db.query(tableName, columns: ['COUNT(*)']),
      );
      return count ?? 0;
    } catch (e, stackTrace) {
      _logger.error('Error getting Account count', e, stackTrace);
      rethrow;
    }
  }
}

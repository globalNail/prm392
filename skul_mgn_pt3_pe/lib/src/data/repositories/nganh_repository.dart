import '../db/dao/nganh_dao.dart';
import '../models/nganh.dart';
import '../../common/result.dart';
import '../../common/app_logger.dart';

/// Repository for Nganh data operations
class NganhRepository {
  final NganhDao _dao;
  static final _logger = AppLogger('NganhRepository');

  NganhRepository({NganhDao? dao}) : _dao = dao ?? NganhDao();

  /// Get all Nganh records
  Future<Result<List<Nganh>>> getAll() async {
    try {
      final nganhs = await _dao.getAll();
      return Success(nganhs);
    } catch (e, stackTrace) {
      _logger.error('Error getting all Nganh', e, stackTrace);
      return Failure(
        'Không thể tải danh sách ngành',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get Nganh by ID
  Future<Result<Nganh>> getById(int id) async {
    try {
      final nganh = await _dao.getById(id);
      if (nganh == null) {
        return const Failure('Không tìm thấy ngành');
      }
      return Success(nganh);
    } catch (e, stackTrace) {
      _logger.error('Error getting Nganh by ID: $id', e, stackTrace);
      return Failure(
        'Không thể tải thông tin ngành',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get Nganh by code (ma)
  Future<Result<Nganh>> getByMa(String ma) async {
    try {
      final nganh = await _dao.getByMa(ma);
      if (nganh == null) {
        return Failure('Không tìm thấy ngành với mã: $ma');
      }
      return Success(nganh);
    } catch (e, stackTrace) {
      _logger.error('Error getting Nganh by ma: $ma', e, stackTrace);
      return Failure(
        'Không thể tải thông tin ngành',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Create a new Nganh
  Future<Result<int>> create(Nganh nganh) async {
    try {
      // Check if ma already exists
      final exists = await _dao.existsByMa(nganh.ma);
      if (exists) {
        return Failure('Mã ngành "${nganh.ma}" đã tồn tại');
      }

      final id = await _dao.insert(nganh);
      return Success(id);
    } catch (e, stackTrace) {
      _logger.error('Error creating Nganh', e, stackTrace);
      return Failure(
        'Không thể tạo ngành mới',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update an existing Nganh
  Future<Result<void>> update(Nganh nganh) async {
    try {
      if (nganh.id == null) {
        return const Failure('ID ngành không hợp lệ');
      }

      // Check if ma already exists (excluding current record)
      final exists = await _dao.existsByMa(nganh.ma, excludeId: nganh.id);
      if (exists) {
        return Failure('Mã ngành "${nganh.ma}" đã tồn tại');
      }

      await _dao.update(nganh);
      return const Success(null);
    } catch (e, stackTrace) {
      _logger.error('Error updating Nganh', e, stackTrace);
      return Failure(
        'Không thể cập nhật ngành',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete a Nganh by ID
  Future<Result<void>> delete(int id) async {
    try {
      await _dao.delete(id);
      return const Success(null);
    } catch (e, stackTrace) {
      _logger.error('Error deleting Nganh with ID: $id', e, stackTrace);
      return Failure('Không thể xóa ngành', error: e, stackTrace: stackTrace);
    }
  }

  /// Get count of all Nganh records
  Future<Result<int>> getCount() async {
    try {
      final count = await _dao.getCount();
      return Success(count);
    } catch (e, stackTrace) {
      _logger.error('Error getting Nganh count', e, stackTrace);
      return Failure(
        'Không thể đếm số lượng ngành',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

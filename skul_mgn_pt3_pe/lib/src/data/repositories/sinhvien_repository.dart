import '../db/dao/sinhvien_dao.dart';
import '../models/sinhvien.dart';
import '../../common/result.dart';
import '../../common/app_logger.dart';

/// Repository for SinhVien data operations
class SinhVienRepository {
  final SinhVienDao _dao;
  static final _logger = AppLogger('SinhVienRepository');

  SinhVienRepository({SinhVienDao? dao}) : _dao = dao ?? SinhVienDao();

  /// Get all SinhVien records
  Future<Result<List<SinhVien>>> getAll() async {
    try {
      final sinhViens = await _dao.getAll();
      return Success(sinhViens);
    } catch (e, stackTrace) {
      _logger.error('Error getting all SinhVien', e, stackTrace);
      return Failure(
        'Không thể tải danh sách sinh viên',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get all SinhVien with Nganh information
  Future<Result<List<SinhVienWithNganh>>> getAllWithNganh() async {
    try {
      final sinhViens = await _dao.getAllWithNganh();
      return Success(sinhViens);
    } catch (e, stackTrace) {
      _logger.error('Error getting all SinhVien with Nganh', e, stackTrace);
      return Failure(
        'Không thể tải danh sách sinh viên',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get SinhVien by ID
  Future<Result<SinhVien>> getById(int id) async {
    try {
      final sinhVien = await _dao.getById(id);
      if (sinhVien == null) {
        return const Failure('Không tìm thấy sinh viên');
      }
      return Success(sinhVien);
    } catch (e, stackTrace) {
      _logger.error('Error getting SinhVien by ID: $id', e, stackTrace);
      return Failure(
        'Không thể tải thông tin sinh viên',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get SinhVien by ID with Nganh information
  Future<Result<SinhVienWithNganh>> getByIdWithNganh(int id) async {
    try {
      final sinhVien = await _dao.getByIdWithNganh(id);
      if (sinhVien == null) {
        return const Failure('Không tìm thấy sinh viên');
      }
      return Success(sinhVien);
    } catch (e, stackTrace) {
      _logger.error(
        'Error getting SinhVien with Nganh by ID: $id',
        e,
        stackTrace,
      );
      return Failure(
        'Không thể tải thông tin sinh viên',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get SinhVien by student code (maSV)
  Future<Result<SinhVien>> getByMaSV(String maSV) async {
    try {
      final sinhVien = await _dao.getByMaSV(maSV);
      if (sinhVien == null) {
        return Failure('Không tìm thấy sinh viên với mã: $maSV');
      }
      return Success(sinhVien);
    } catch (e, stackTrace) {
      _logger.error('Error getting SinhVien by maSV: $maSV', e, stackTrace);
      return Failure(
        'Không thể tải thông tin sinh viên',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Search SinhVien by name or student code
  Future<Result<List<SinhVienWithNganh>>> search(String query) async {
    try {
      final sinhViens = await _dao.search(query);
      return Success(sinhViens);
    } catch (e, stackTrace) {
      _logger.error(
        'Error searching SinhVien with query: $query',
        e,
        stackTrace,
      );
      return Failure(
        'Không thể tìm kiếm sinh viên',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Create a new SinhVien
  Future<Result<int>> create(SinhVien sinhVien) async {
    try {
      // Check if maSV already exists
      final exists = await _dao.existsByMaSV(sinhVien.maSV);
      if (exists) {
        return Failure('Mã sinh viên "${sinhVien.maSV}" đã tồn tại');
      }

      final id = await _dao.insert(sinhVien);
      return Success(id);
    } catch (e, stackTrace) {
      _logger.error('Error creating SinhVien', e, stackTrace);
      return Failure(
        'Không thể tạo sinh viên mới',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update an existing SinhVien
  Future<Result<void>> update(SinhVien sinhVien) async {
    try {
      if (sinhVien.id == null) {
        return const Failure('ID sinh viên không hợp lệ');
      }

      // Check if maSV already exists (excluding current record)
      final exists = await _dao.existsByMaSV(
        sinhVien.maSV,
        excludeId: sinhVien.id,
      );
      if (exists) {
        return Failure('Mã sinh viên "${sinhVien.maSV}" đã tồn tại');
      }

      await _dao.update(sinhVien);
      return const Success(null);
    } catch (e, stackTrace) {
      _logger.error('Error updating SinhVien', e, stackTrace);
      return Failure(
        'Không thể cập nhật sinh viên',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete a SinhVien by ID
  Future<Result<void>> delete(int id) async {
    try {
      await _dao.delete(id);
      return const Success(null);
    } catch (e, stackTrace) {
      _logger.error('Error deleting SinhVien with ID: $id', e, stackTrace);
      return Failure(
        'Không thể xóa sinh viên',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get count of all SinhVien records
  Future<Result<int>> getCount() async {
    try {
      final count = await _dao.getCount();
      return Success(count);
    } catch (e, stackTrace) {
      _logger.error('Error getting SinhVien count', e, stackTrace);
      return Failure(
        'Không thể đếm số lượng sinh viên',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get SinhVien by Nganh ID
  Future<Result<List<SinhVien>>> getByNganhId(int nganhId) async {
    try {
      final sinhViens = await _dao.getByNganhId(nganhId);
      return Success(sinhViens);
    } catch (e, stackTrace) {
      _logger.error(
        'Error getting SinhVien by nganhId: $nganhId',
        e,
        stackTrace,
      );
      return Failure(
        'Không thể tải danh sách sinh viên',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

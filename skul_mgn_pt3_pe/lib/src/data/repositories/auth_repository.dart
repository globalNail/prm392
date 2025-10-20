import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../db/dao/account_dao.dart';
import '../db/dao/sinhvien_dao.dart';
import '../models/account.dart';
import '../models/sinhvien.dart';
import '../../common/result.dart';
import '../../common/app_logger.dart';

/// Repository for authentication operations
class AuthRepository {
  final AccountDao _accountDao;
  final SinhVienDao _sinhVienDao;
  static final _logger = AppLogger('AuthRepository');

  AuthRepository({AccountDao? accountDao, SinhVienDao? sinhVienDao})
    : _accountDao = accountDao ?? AccountDao(),
      _sinhVienDao = sinhVienDao ?? SinhVienDao();

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register a new account
  Future<Result<int>> register({
    required String username,
    required String password,
    String? maSV,
  }) async {
    try {
      // Check if username already exists
      final usernameExists = await _accountDao.existsByUsername(username);
      if (usernameExists) {
        return Failure('Tên đăng nhập "$username" đã tồn tại');
      }

      // If maSV is provided, check if SinhVien exists and doesn't have an account
      int? sinhVienId;
      if (maSV != null && maSV.isNotEmpty) {
        final sinhVien = await _sinhVienDao.getByMaSV(maSV);
        if (sinhVien == null) {
          return Failure('Không tìm thấy sinh viên với mã: $maSV');
        }

        // Check if this SinhVien already has an account
        final existingAccount = await _accountDao.getBySinhVienId(sinhVien.id!);
        if (existingAccount != null) {
          return const Failure('Sinh viên này đã có tài khoản');
        }

        sinhVienId = sinhVien.id;
      }

      // Hash password and create account
      final passwordHash = _hashPassword(password);
      final account = Account(
        username: username,
        passwordHash: passwordHash,
        sinhVienId: sinhVienId,
      );

      final id = await _accountDao.insert(account);
      _logger.info('Registered new account with ID: $id');
      return Success(id);
    } catch (e, stackTrace) {
      _logger.error('Error registering account', e, stackTrace);
      return Failure(
        'Không thể đăng ký tài khoản',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Login with username and password
  Future<Result<Account>> login({
    required String username,
    required String password,
  }) async {
    try {
      final account = await _accountDao.getByUsername(username);
      if (account == null) {
        return const Failure('Tên đăng nhập không tồn tại');
      }

      final passwordHash = _hashPassword(password);
      if (account.passwordHash != passwordHash) {
        return const Failure('Mật khẩu không chính xác');
      }

      _logger.info('User logged in: ${account.username}');
      return Success(account);
    } catch (e, stackTrace) {
      _logger.error('Error logging in', e, stackTrace);
      return Failure('Không thể đăng nhập', error: e, stackTrace: stackTrace);
    }
  }

  /// Get Account by ID
  Future<Result<Account>> getAccountById(int id) async {
    try {
      final account = await _accountDao.getById(id);
      if (account == null) {
        return const Failure('Không tìm thấy tài khoản');
      }
      return Success(account);
    } catch (e, stackTrace) {
      _logger.error('Error getting account by ID: $id', e, stackTrace);
      return Failure(
        'Không thể tải thông tin tài khoản',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get SinhVien associated with Account
  Future<Result<SinhVien?>> getSinhVienForAccount(int accountId) async {
    try {
      final account = await _accountDao.getById(accountId);
      if (account == null) {
        return const Failure('Không tìm thấy tài khoản');
      }

      if (account.sinhVienId == null) {
        return const Success(null);
      }

      final sinhVien = await _sinhVienDao.getById(account.sinhVienId!);
      return Success(sinhVien);
    } catch (e, stackTrace) {
      _logger.error(
        'Error getting SinhVien for account: $accountId',
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

  /// Delete account by ID
  Future<Result<void>> deleteAccount(int id) async {
    try {
      await _accountDao.delete(id);
      _logger.info('Deleted account with ID: $id');
      return const Success(null);
    } catch (e, stackTrace) {
      _logger.error('Error deleting account with ID: $id', e, stackTrace);
      return Failure(
        'Không thể xóa tài khoản',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete account by SinhVien ID
  Future<Result<void>> deleteAccountBySinhVienId(int sinhVienId) async {
    try {
      await _accountDao.deleteBySinhVienId(sinhVienId);
      _logger.info('Deleted account with sinhVienId: $sinhVienId');
      return const Success(null);
    } catch (e, stackTrace) {
      _logger.error(
        'Error deleting account with sinhVienId: $sinhVienId',
        e,
        stackTrace,
      );
      return Failure(
        'Không thể xóa tài khoản',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Change password
  Future<Result<void>> changePassword({
    required int accountId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final account = await _accountDao.getById(accountId);
      if (account == null) {
        return const Failure('Không tìm thấy tài khoản');
      }

      final oldPasswordHash = _hashPassword(oldPassword);
      if (account.passwordHash != oldPasswordHash) {
        return const Failure('Mật khẩu cũ không chính xác');
      }

      final newPasswordHash = _hashPassword(newPassword);
      final updatedAccount = account.copyWith(passwordHash: newPasswordHash);
      await _accountDao.update(updatedAccount);

      _logger.info('Password changed for account: ${account.username}');
      return const Success(null);
    } catch (e, stackTrace) {
      _logger.error('Error changing password', e, stackTrace);
      return Failure(
        'Không thể đổi mật khẩu',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get all accounts
  Future<Result<List<Account>>> getAllAccounts() async {
    try {
      final accounts = await _accountDao.getAll();
      return Success(accounts);
    } catch (e, stackTrace) {
      _logger.error('Error getting all accounts', e, stackTrace);
      return Failure(
        'Không thể tải danh sách tài khoản',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

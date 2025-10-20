import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/account.dart';
import '../../common/app_logger.dart';
import '../../common/result.dart';

const String _authAccountIdKey = 'auth_account_id';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for current authenticated account
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<Account?>>((ref) {
      return AuthStateNotifier(ref);
    });

/// Notifier for managing authentication state
class AuthStateNotifier extends StateNotifier<AsyncValue<Account?>> {
  final Ref _ref;
  static final _logger = AppLogger('AuthStateNotifier');

  AuthStateNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadAuthState();
  }

  /// Load authentication state from persistent storage
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt(_authAccountIdKey);

      if (accountId == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final authRepo = _ref.read(authRepositoryProvider);
      final result = await authRepo.getAccountById(accountId);

      if (result is Success<Account>) {
        state = AsyncValue.data(result.data);
        _logger.info('Loaded auth state for account: ${result.data.username}');
      } else if (result is Failure<Account>) {
        _logger.warning('Failed to load auth state: ${result.message}');
        state = const AsyncValue.data(null);
        // Clear invalid account ID
        prefs.remove(_authAccountIdKey);
      }
    } catch (e, stackTrace) {
      _logger.error('Error loading auth state', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Login with username and password
  Future<bool> login(String username, String password) async {
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final result = await authRepo.login(
        username: username,
        password: password,
      );

      if (result is Success<Account>) {
        state = AsyncValue.data(result.data);

        // Save account ID to persistent storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_authAccountIdKey, result.data.id!);

        _logger.info('User logged in: ${result.data.username}');
        return true;
      } else {
        final failure = result as Failure<Account>;
        _logger.warning('Login failed: ${failure.message}');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Error during login', e, stackTrace);
      return false;
    }
  }

  /// Register a new account
  Future<bool> register({
    required String username,
    required String password,
    String? maSV,
  }) async {
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final result = await authRepo.register(
        username: username,
        password: password,
        maSV: maSV,
      );

      if (result is Success<int>) {
        _logger.info('Account registered with ID: ${result.data}');
        // Auto-login after registration
        return await login(username, password);
      } else {
        final failure = result as Failure<int>;
        _logger.warning('Registration failed: ${failure.message}');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Error during registration', e, stackTrace);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authAccountIdKey);
      state = const AsyncValue.data(null);
      _logger.info('User logged out');
    } catch (e, stackTrace) {
      _logger.error('Error during logout', e, stackTrace);
    }
  }

  /// Delete current account
  Future<bool> deleteAccount() async {
    try {
      final currentAccount = state.value;
      if (currentAccount == null) {
        return false;
      }

      final authRepo = _ref.read(authRepositoryProvider);
      final result = await authRepo.deleteAccount(currentAccount.id!);

      if (result is Success<void>) {
        await logout();
        _logger.info('Account deleted');
        return true;
      } else {
        final failure = result as Failure<void>;
        _logger.warning('Account deletion failed: ${failure.message}');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Error deleting account', e, stackTrace);
      return false;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return state.value != null;
  }
}

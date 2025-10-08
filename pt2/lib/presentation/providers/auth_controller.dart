import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';

class AuthState {
  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.error,
  });

  const AuthState.initial() : this(isAuthenticated: false);

  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState.initial());

  static const _username = 'demo';
  static const _password = '123456';

  Future<void> login(
      {required String username, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (username.trim() == _username && password == _password) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          error: AppStrings.invalidCredentials,
        );
      }
    } catch (error, stack) {
      debugPrint('Login error: $error');
      debugPrint('$stack');
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: AppStrings.loginFailed,
      );
    }
  }

  void logout() {
    state = const AuthState.initial();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) => AuthController());

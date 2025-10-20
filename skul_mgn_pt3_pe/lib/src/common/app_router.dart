import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/services/auth_service.dart';
import '../ui/features/auth/login_page.dart';
import '../ui/features/auth/register_page.dart';
import '../ui/features/sinhvien/list/sinhvien_list_page.dart';
import '../ui/features/sinhvien/detail/sinhvien_detail_page.dart';
import '../ui/features/sinhvien/edit/sinhvien_edit_page.dart';
import '../ui/features/nganh/list/nganh_list_page.dart';
import '../ui/features/nganh/edit/nganh_edit_page.dart';
import '../ui/features/map/map_page.dart';
import '../ui/features/report/report_page.dart';

/// Provider for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/sv',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.value != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';

      // Wait for auth state to load
      if (isLoading) {
        return null;
      }

      // Redirect to login if not authenticated and not going to login/register
      if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      // Redirect to home if authenticated and going to login
      if (isAuthenticated && isGoingToLogin) {
        return '/sv';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Student routes
      GoRoute(
        path: '/sv',
        builder: (context, state) => const SinhVienListPage(),
      ),
      GoRoute(
        path: '/sv/create',
        builder: (context, state) => const SinhVienEditPage(),
      ),
      GoRoute(
        path: '/sv/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SinhVienDetailPage(sinhVienId: id);
        },
      ),
      GoRoute(
        path: '/sv/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SinhVienEditPage(sinhVienId: id);
        },
      ),

      // Nganh routes
      GoRoute(
        path: '/nganh',
        builder: (context, state) => const NganhListPage(),
      ),
      GoRoute(
        path: '/nganh/create',
        builder: (context, state) => const NganhEditPage(),
      ),
      GoRoute(
        path: '/nganh/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return NganhEditPage(nganhId: id);
        },
      ),

      // Map route
      GoRoute(
        path: '/map',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MapPage(
            latitude: extra?['lat'] as double?,
            longitude: extra?['lng'] as double?,
            address: extra?['address'] as String?,
            studentName: extra?['studentName'] as String?,
          );
        },
      ),

      // Report route
      GoRoute(path: '/report', builder: (context, state) => const ReportPage()),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Lỗi')),
      body: Center(
        child: Text('Không tìm thấy trang: ${state.matchedLocation}'),
      ),
    ),
  );
});

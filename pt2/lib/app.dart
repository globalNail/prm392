import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/route_paths.dart';
import 'domain/entities/product.dart';
import 'presentation/providers/auth_controller.dart';
import 'presentation/screens/cart_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/product_detail_screen.dart';
import 'presentation/screens/product_list_screen.dart';
import 'presentation/screens/profile_screen.dart';

class GizmoHubApp extends ConsumerWidget {
  const GizmoHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: RoutePaths.login,
      onGenerateRoute: (settings) => _onGenerateRoute(settings, ref),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings, WidgetRef ref) {
    final authState = ref.read(authControllerProvider);
    switch (settings.name) {
      case RoutePaths.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RoutePaths.products:
        if (!authState.isAuthenticated) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case RoutePaths.cart:
        if (!authState.isAuthenticated) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case RoutePaths.profile:
        if (!authState.isAuthenticated) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        final name = settings.name ?? '';
        if (name.startsWith('${RoutePaths.products}/')) {
          if (!authState.isAuthenticated) {
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
          final id = name.replaceFirst('${RoutePaths.products}/', '');
          final initialProduct = settings.arguments is Product
              ? settings.arguments as Product
              : null;
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              productId: id,
              initialProduct: initialProduct,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text(AppStrings.appName)),
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}

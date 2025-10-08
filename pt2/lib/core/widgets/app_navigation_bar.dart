import 'package:flutter/material.dart';

import '../constants/route_paths.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) {
          return;
        }
        switch (index) {
          case 0:
            Navigator.of(context).pushReplacementNamed(RoutePaths.products);
            break;
          case 1:
            Navigator.of(context).pushReplacementNamed(RoutePaths.cart);
            break;
          case 2:
            Navigator.of(context).pushReplacementNamed(RoutePaths.profile);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront),
          label: 'Sản phẩm',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart),
          label: 'Giỏ hàng',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ],
    );
  }
}

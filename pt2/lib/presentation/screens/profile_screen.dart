import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_navigation_bar.dart';
import '../providers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(AppStrings.profileTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('demo@gizmohub.app'),
              const SizedBox(height: 32),
              AppButton(
                label: AppStrings.logout,
                onPressed: () {
                  ref.read(authControllerProvider.notifier).logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      RoutePaths.login, (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 2),
    );
  }
}

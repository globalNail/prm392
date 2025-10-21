import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/repositories/nganh_repository.dart';
import '../../../../data/models/nganh.dart';
import '../../../../common/result.dart';
import '../../../../common/snackbar_utils.dart';
import '../../../../common/app_theme.dart';
import '../../../../domain/services/auth_service.dart';

// Provider for Nganh list
final _nganhListProvider = FutureProvider.autoDispose<List<Nganh>>((ref) async {
  final repo = NganhRepository();
  final result = await repo.getAll();
  return result is Success<List<Nganh>> ? result.data : [];
});

class NganhListPage extends ConsumerStatefulWidget {
  const NganhListPage({super.key});

  @override
  ConsumerState<NganhListPage> createState() => _NganhListPageState();
}

class _NganhListPageState extends ConsumerState<NganhListPage> {
  int _selectedIndex = 1;

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Nganh nganh,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa ngành "${nganh.ten}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = NganhRepository();
              final result = await repo.delete(nganh.id!);

              if (context.mounted) {
                if (result is Success) {
                  showSuccessSnackBar(context, 'Đã xóa ngành');
                  ref.invalidate(_nganhListProvider);
                } else {
                  final failure = result as Failure;
                  showErrorSnackBar(context, 'Lỗi: ${failure.message}');
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nganhListAsync = ref.watch(_nganhListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách Ngành')),
      body: nganhListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Lỗi: $err'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.refresh(_nganhListProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (nganhList) {
          if (nganhList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có ngành học nào',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn nút + để thêm ngành mới',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_nganhListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: nganhList.length,
              itemBuilder: (context, index) {
                final nganh = nganhList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.school,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      nganh.ten,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Mã: ${nganh.ma}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        if (nganh.moTa != null && nganh.moTa!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            nganh.moTa!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          _showDeleteConfirmation(context, ref, nganh),
                    ),
                    onTap: () async {
                      await context.push('/nganh/${nganh.id}/edit');
                      // Reload list after returning from edit
                      ref.invalidate(_nganhListProvider);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/nganh/create');
          // Reload list after returning from create
          ref.invalidate(_nganhListProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm Ngành'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 3) {
            // Menu item - show bottom sheet
            _showMenuBottomSheet(context);
          } else {
            setState(() => _selectedIndex = index);
            switch (index) {
              case 0:
                // Student list
                context.push('/sv');
                break;
              case 1:
                // Current page - Nganh list
                break;
              case 2:
                // Report
                context.push('/report');
                break;
            }
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Sinh viên'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Ngành'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Báo cáo',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }

  void _showMenuBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme toggle
              ListTile(
                leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                title: const Text('Sáng tối'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
                onTap: () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
              const Divider(),
              // Logout
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Đăng xuất'),
                onTap: () {
                  ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

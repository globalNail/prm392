import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/repositories/sinhvien_repository.dart';
import '../../../../data/models/sinhvien.dart';
import '../../../../domain/services/auth_service.dart';
import '../../../../common/result.dart';
import '../../../../common/app_theme.dart';
import '../../../../common/snackbar_utils.dart';

/// Provider for SinhVienRepository
final _sinhVienRepoProvider = Provider((ref) => SinhVienRepository());

/// Provider for student list with search
final _studentListProvider =
    StateNotifierProvider<
      _StudentListNotifier,
      AsyncValue<List<SinhVienWithNganh>>
    >((ref) {
      return _StudentListNotifier(ref);
    });

class _StudentListNotifier
    extends StateNotifier<AsyncValue<List<SinhVienWithNganh>>> {
  final Ref _ref;
  String _searchQuery = '';

  _StudentListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    state = const AsyncValue.loading();

    final repo = _ref.read(_sinhVienRepoProvider);
    final result = _searchQuery.isEmpty
        ? await repo.getAllWithNganh()
        : await repo.search(_searchQuery);

    if (result is Success<List<SinhVienWithNganh>>) {
      state = AsyncValue.data(result.data);
    } else if (result is Failure<List<SinhVienWithNganh>>) {
      state = AsyncValue.error(result.message, StackTrace.current);
    }
  }

  void search(String query) {
    _searchQuery = query;
    loadStudents();
  }

  Future<void> deleteStudent(int id) async {
    final repo = _ref.read(_sinhVienRepoProvider);
    await repo.delete(id);
    loadStudents();
  }
}

class SinhVienListPage extends ConsumerStatefulWidget {
  const SinhVienListPage({super.key});

  @override
  ConsumerState<SinhVienListPage> createState() => _SinhVienListPageState();
}

class _SinhVienListPageState extends ConsumerState<SinhVienListPage> {
  final _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(
    BuildContext context,
    SinhVienWithNganh student,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa sinh viên "${student.sinhVien.hoTen}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(_studentListProvider.notifier)
                  .deleteStudent(student.sinhVien.id!);
              Navigator.pop(context);
              showSuccessSnackBar(context, 'Đã xóa sinh viên');
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
    final studentListAsync = ref.watch(_studentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách Sinh viên')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc mã SV...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(_studentListProvider.notifier).search('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(_studentListProvider.notifier).search(value);
              },
            ),
          ),

          // Student list
          Expanded(
            child: studentListAsync.when(
              data: (students) {
                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 80,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Chưa có sinh viên nào'
                              : 'Không tìm thấy sinh viên',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Nhấn nút + để thêm sinh viên mới'
                              : 'Thử tìm kiếm với từ khóa khác',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(_studentListProvider.notifier).loadStudents();
                  },
                  child: ListView.builder(
                    itemCount: students.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final studentWithNganh = students[index];
                      final student = studentWithNganh.sinhVien;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            backgroundImage:
                                student.avatarPath != null &&
                                    File(student.avatarPath!).existsSync()
                                ? FileImage(File(student.avatarPath!))
                                : null,
                            child: student.avatarPath == null
                                ? Text(
                                    student.hoTen.isNotEmpty
                                        ? student.hoTen[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            student.hoTen,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Mã SV: ${student.maSV}'),
                              if (studentWithNganh.nganhTen != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      studentWithNganh.nganhTen!,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _showDeleteConfirmation(
                              context,
                              studentWithNganh,
                            ),
                          ),
                          onTap: () async {
                            await context.push('/sv/${student.id}');
                            // Reload list when returning from detail page
                            ref
                                .read(_studentListProvider.notifier)
                                .loadStudents();
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${error.toString()}',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        ref.read(_studentListProvider.notifier).loadStudents();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/sv/create');
          // Reload list when returning from create page
          ref.read(_studentListProvider.notifier).loadStudents();
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm SV'),
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
                // Current page - Student list
                break;
              case 1:
                // Nganh list
                context.push('/nganh');
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

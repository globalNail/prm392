import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/sinhvien_repository.dart';
import '../../../data/repositories/nganh_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../common/result.dart';
import '../../../common/app_theme.dart';
import '../../../domain/services/auth_service.dart';

// Provider for database statistics
final _dbStatsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final sinhvienRepo = SinhVienRepository();
  final nganhRepo = NganhRepository();
  final authRepo = AuthRepository();

  final sinhvienResult = await sinhvienRepo.getAll();
  final nganhResult = await nganhRepo.getAll();
  final accountResult = await authRepo.getAllAccounts();

  int sinhvienCount = 0;
  int nganhCount = 0;
  int accountCount = 0;

  switch (sinhvienResult) {
    case Success(:final data):
      sinhvienCount = data.length;
    case Failure():
      break;
  }

  switch (nganhResult) {
    case Success(:final data):
      nganhCount = data.length;
    case Failure():
      break;
  }

  switch (accountResult) {
    case Success(:final data):
      accountCount = data.length;
    case Failure():
      break;
  }

  return {
    'sinhvien': sinhvienCount,
    'nganh': nganhCount,
    'account': accountCount,
  };
});

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(_dbStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo Database'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: () => ref.invalidate(_dbStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
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
                onPressed: () => ref.invalidate(_dbStatsProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.storage,
                            size: 32,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thông tin Database',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'SQLite Database Schema',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Statistics cards
              Text(
                'Thống kê',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.school,
                      title: 'Sinh viên',
                      count: stats['sinhvien'] ?? 0,
                      color: Colors.blue,
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.category,
                      title: 'Ngành học',
                      count: stats['nganh'] ?? 0,
                      color: Colors.green,
                      context: context,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.person,
                      title: 'Tài khoản',
                      count: stats['account'] ?? 0,
                      color: Colors.orange,
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.table_chart,
                      title: 'Tổng bảng',
                      count: 3,
                      color: Colors.purple,
                      context: context,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Schema description
              Text(
                'Cấu trúc Database',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Nganh table
              _TableCard(
                title: 'Bảng: Nganh',
                description: 'Thông tin các ngành học',
                fields: [
                  _Field('id', 'INTEGER', 'PRIMARY KEY, AUTOINCREMENT'),
                  _Field('ma', 'TEXT', 'UNIQUE, NOT NULL (Mã ngành)'),
                  _Field('ten', 'TEXT', 'NOT NULL (Tên ngành)'),
                  _Field('moTa', 'TEXT', 'Mô tả ngành'),
                  _Field('createdAt', 'INTEGER', 'Timestamp tạo'),
                  _Field('updatedAt', 'INTEGER', 'Timestamp cập nhật'),
                ],
              ),
              const SizedBox(height: 12),

              // SinhVien table
              _TableCard(
                title: 'Bảng: SinhVien',
                description: 'Thông tin sinh viên',
                fields: [
                  _Field('id', 'INTEGER', 'PRIMARY KEY, AUTOINCREMENT'),
                  _Field('maSV', 'TEXT', 'UNIQUE, NOT NULL (Mã sinh viên)'),
                  _Field('hoTen', 'TEXT', 'NOT NULL (Họ và tên)'),
                  _Field('ngaySinh', 'TEXT', 'Ngày sinh (ISO8601)'),
                  _Field('diaChi', 'TEXT', 'Địa chỉ'),
                  _Field('sdt', 'TEXT', 'Số điện thoại'),
                  _Field('email', 'TEXT', 'Email'),
                  _Field('nganhId', 'INTEGER', 'FOREIGN KEY → Nganh(id)'),
                  _Field('avatarPath', 'TEXT', 'Đường dẫn ảnh đại diện'),
                  _Field('lat', 'REAL', 'Vĩ độ (GPS)'),
                  _Field('lng', 'REAL', 'Kinh độ (GPS)'),
                  _Field('createdAt', 'INTEGER', 'Timestamp tạo'),
                  _Field('updatedAt', 'INTEGER', 'Timestamp cập nhật'),
                ],
              ),
              const SizedBox(height: 12),

              // Account table
              _TableCard(
                title: 'Bảng: Account',
                description: 'Tài khoản người dùng',
                fields: [
                  _Field('id', 'INTEGER', 'PRIMARY KEY, AUTOINCREMENT'),
                  _Field('username', 'TEXT', 'UNIQUE, NOT NULL'),
                  _Field('passwordHash', 'TEXT', 'NOT NULL (SHA-256)'),
                  _Field('sinhVienId', 'INTEGER', 'FOREIGN KEY → SinhVien(id)'),
                  _Field('createdAt', 'INTEGER', 'Timestamp tạo'),
                ],
              ),
              const SizedBox(height: 24),

              // Relationships
              Text(
                'Quan hệ giữa các bảng',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RelationshipRow(
                        from: 'SinhVien.nganhId',
                        to: 'Nganh.id',
                        type: 'Many-to-One',
                        description: 'Nhiều sinh viên thuộc 1 ngành',
                      ),
                      const Divider(),
                      _RelationshipRow(
                        from: 'Account.sinhVienId',
                        to: 'SinhVien.id',
                        type: 'One-to-One',
                        description: '1 tài khoản liên kết 1 sinh viên',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
                // Nganh list
                context.push('/nganh');
                break;
              case 2:
                // Current page - Report
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final BuildContext context;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  final String title;
  final String description;
  final List<_Field> fields;

  const _TableCard({
    required this.title,
    required this.description,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...fields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        field.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            field.type,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'monospace',
                                ),
                          ),
                          if (field.constraints.isNotEmpty)
                            Text(
                              field.constraints,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field {
  final String name;
  final String type;
  final String constraints;

  _Field(this.name, this.type, [this.constraints = '']);
}

class _RelationshipRow extends StatelessWidget {
  final String from;
  final String to;
  final String type;
  final String description;

  const _RelationshipRow({
    required this.from,
    required this.to,
    required this.type,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      from,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      to,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$type: $description',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

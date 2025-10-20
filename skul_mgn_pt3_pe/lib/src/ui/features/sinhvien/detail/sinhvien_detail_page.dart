import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/repositories/sinhvien_repository.dart';
import '../../../../data/models/sinhvien.dart';
import '../../../../data/models/nganh.dart';
import '../../../../common/result.dart';

// Provider to load student details
final _studentDetailProvider = FutureProvider.autoDispose
    .family<_StudentDetail?, int>((ref, id) async {
      final repo = SinhVienRepository();
      final result = await repo.getByIdWithNganh(id);

      if (result is Success<SinhVienWithNganh>) {
        final data = result.data;
        // Get full Nganh details if nganhId exists
        Nganh? nganh;
        if (data.sinhVien.nganhId != null) {
          // We'll use the simple data from SinhVienWithNganh
          nganh = Nganh(
            id: data.sinhVien.nganhId!,
            ma: data.nganhMa ?? '',
            ten: data.nganhTen ?? '',
          );
        }
        return _StudentDetail(sinhVien: data.sinhVien, nganh: nganh);
      }
      return null;
    });

class _StudentDetail {
  final SinhVien sinhVien;
  final Nganh? nganh;

  _StudentDetail({required this.sinhVien, this.nganh});
}

class SinhVienDetailPage extends ConsumerWidget {
  final int sinhVienId;

  const SinhVienDetailPage({super.key, required this.sinhVienId});

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc muốn xóa sinh viên này? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog first
              final repo = SinhVienRepository();
              final result = await repo.delete(sinhVienId);

              if (context.mounted) {
                if (result is Success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa sinh viên')),
                  );
                  context.pop(); // Go back to list
                } else if (result is Failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${result.message}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
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
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(_studentDetailProvider(sinhVienId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Sinh viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Chỉnh sửa',
            onPressed: () async {
              await context.push('/sv/$sinhVienId/edit');
              // Reload detail page after returning from edit
              ref.invalidate(_studentDetailProvider(sinhVienId));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Xóa',
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
      body: studentAsync.when(
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
                onPressed: () =>
                    ref.refresh(_studentDetailProvider(sinhVienId)),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (student) {
          if (student == null) {
            return const Center(child: Text('Không tìm thấy sinh viên'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with avatar
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        backgroundImage:
                            student.sinhVien.avatarPath != null &&
                                student.sinhVien.avatarPath!.isNotEmpty &&
                                File(student.sinhVien.avatarPath!).existsSync()
                            ? FileImage(File(student.sinhVien.avatarPath!))
                            : null,
                        child:
                            student.sinhVien.avatarPath == null ||
                                student.sinhVien.avatarPath!.isEmpty ||
                                !File(student.sinhVien.avatarPath!).existsSync()
                            ? Icon(
                                Icons.person,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface,
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        student.sinhVien.hoTen,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Student ID
                      Text(
                        student.sinhVien.maSV,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),

                // Information cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Department info
                      if (student.nganh != null)
                        _InfoCard(
                          icon: Icons.school,
                          title: 'Ngành học',
                          children: [
                            _InfoRow('Mã ngành', student.nganh!.ma),
                            _InfoRow('Tên ngành', student.nganh!.ten),
                            if (student.nganh!.moTa != null &&
                                student.nganh!.moTa!.isNotEmpty)
                              _InfoRow('Mô tả', student.nganh!.moTa!),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Contact info
                      _InfoCard(
                        icon: Icons.contact_phone,
                        title: 'Thông tin liên hệ',
                        children: [
                          if (student.sinhVien.email != null &&
                              student.sinhVien.email!.isNotEmpty)
                            _InfoRow(
                              'Email',
                              student.sinhVien.email!,
                              isSelectable: true,
                            ),
                          if (student.sinhVien.sdt != null &&
                              student.sinhVien.sdt!.isNotEmpty)
                            _InfoRow(
                              'Số điện thoại',
                              student.sinhVien.sdt!,
                              isSelectable: true,
                            ),
                          if (student.sinhVien.ngaySinh != null &&
                              student.sinhVien.ngaySinh!.isNotEmpty)
                            _InfoRow('Ngày sinh', student.sinhVien.ngaySinh!),
                        ],
                      ),

                      if (student.sinhVien.diaChi != null &&
                          student.sinhVien.diaChi!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _InfoCard(
                          icon: Icons.location_on,
                          title: 'Địa chỉ',
                          children: [
                            _InfoRow(
                              'Địa chỉ',
                              student.sinhVien.diaChi!,
                              isSelectable: true,
                            ),
                            if (student.sinhVien.lat != null &&
                                student.sinhVien.lng != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: FilledButton.icon(
                                  onPressed: () {
                                    context.push(
                                      '/map?lat=${student.sinhVien.lat}&lng=${student.sinhVien.lng}',
                                    );
                                  },
                                  icon: const Icon(Icons.map),
                                  label: const Text('Xem trên bản đồ'),
                                ),
                              ),
                          ],
                        ),
                      ],

                      // Timestamps
                      const SizedBox(height: 16),
                      _InfoCard(
                        icon: Icons.access_time,
                        title: 'Thông tin hệ thống',
                        children: [
                          if (student.sinhVien.createdAt != null)
                            _InfoRow(
                              'Ngày tạo',
                              _formatDate(student.sinhVien.createdAt!),
                            ),
                          if (student.sinhVien.updatedAt != null)
                            _InfoRow(
                              'Cập nhật lần cuối',
                              _formatDate(student.sinhVien.updatedAt!),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
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
                Icon(icon, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelectable;

  const _InfoRow(this.label, this.value, {this.isSelectable = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: isSelectable
                ? SelectableText(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

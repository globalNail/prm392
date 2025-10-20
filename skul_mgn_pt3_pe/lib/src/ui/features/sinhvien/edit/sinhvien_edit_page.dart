import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/repositories/sinhvien_repository.dart';
import '../../../../data/repositories/nganh_repository.dart';
import '../../../../data/repositories/media_repository.dart';
import '../../../../data/repositories/geocode_repository.dart';
import '../../../../data/models/sinhvien.dart';
import '../../../../data/models/nganh.dart';
import '../../../../common/result.dart';
import '../../../../common/snackbar_utils.dart';
import '../widgets/contact_picker_dialog.dart';

// Provider for loading existing student data
final _existingStudentProvider = FutureProvider.autoDispose
    .family<SinhVien?, int?>((ref, id) async {
      if (id == null) return null;
      final repo = SinhVienRepository();
      final result = await repo.getById(id);
      return result is Success<SinhVien> ? result.data : null;
    });

// Provider for loading Nganh list
final _nganhListProvider = FutureProvider.autoDispose<List<Nganh>>((ref) async {
  final repo = NganhRepository();
  final result = await repo.getAll();
  return result is Success<List<Nganh>> ? result.data : [];
});

class SinhVienEditPage extends ConsumerStatefulWidget {
  final int? sinhVienId;

  const SinhVienEditPage({super.key, this.sinhVienId});

  @override
  ConsumerState<SinhVienEditPage> createState() => _SinhVienEditPageState();
}

class _SinhVienEditPageState extends ConsumerState<SinhVienEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _maSVController = TextEditingController();
  final _hoTenController = TextEditingController();
  final _ngaySinhController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _sdtController = TextEditingController();
  final _emailController = TextEditingController();

  int? _selectedNganhId;
  String? _avatarPath;
  double? _lat;
  double? _lng;
  bool _isLoading = false;
  bool _isGeocodingAddress = false;

  @override
  void initState() {
    super.initState();
    // Load existing student data if editing
    if (widget.sinhVienId != null) {
      Future.microtask(() async {
        final student = await ref.read(
          _existingStudentProvider(widget.sinhVienId).future,
        );
        if (student != null && mounted) {
          _maSVController.text = student.maSV;
          _hoTenController.text = student.hoTen;
          _ngaySinhController.text = student.ngaySinh ?? '';
          _diaChiController.text = student.diaChi ?? '';
          _sdtController.text = student.sdt ?? '';
          _emailController.text = student.email ?? '';
          setState(() {
            _selectedNganhId = student.nganhId;
            _avatarPath = student.avatarPath;
            _lat = student.lat;
            _lng = student.lng;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _maSVController.dispose();
    _hoTenController.dispose();
    _ngaySinhController.dispose();
    _diaChiController.dispose();
    _sdtController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final mediaRepo = MediaRepository();
      final result = source == ImageSource.camera
          ? await mediaRepo.pickFromCamera()
          : await mediaRepo.pickFromGallery();

      if (result is Success<String>) {
        setState(() {
          _avatarPath = result.data;
        });
        if (mounted) {
          showSuccessSnackBar(context, 'Đã chọn ảnh');
        }
      } else {
        final failure = result as Failure<String>;
        if (mounted) {
          showErrorSnackBar(context, 'Lỗi: ${failure.message}');
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Lỗi: $e');
      }
    }
  }

  Future<void> _geocodeAddress() async {
    final address = _diaChiController.text.trim();
    if (address.isEmpty) {
      showInfoSnackBar(context, 'Vui lòng nhập địa chỉ trước');
      return;
    }

    setState(() => _isGeocodingAddress = true);

    try {
      final geocodeRepo = GeocodeRepository();
      final result = await geocodeRepo.geocodeAddress(address);

      if (result is Success<(double, double)>) {
        setState(() {
          _lat = result.data.$1; // first element of tuple
          _lng = result.data.$2; // second element of tuple
          _isGeocodingAddress = false;
        });
        if (mounted) {
          showSuccessSnackBar(context, 'Đã xác định vị trí');
        }
      } else {
        final failure = result as Failure<(double, double)>;
        setState(() => _isGeocodingAddress = false);
        if (mounted) {
          showErrorSnackBar(context, 'Lỗi: ${failure.message}');
        }
      }
    } catch (e) {
      setState(() => _isGeocodingAddress = false);
      if (mounted) {
        showErrorSnackBar(context, 'Lỗi: $e');
      }
    }
  }

  Future<void> _importFromContacts() async {
    final result = await showContactPicker(context);

    if (result != null) {
      setState(() {
        // Import name if current name is empty
        if (_hoTenController.text.trim().isEmpty) {
          _hoTenController.text = result.name;
        }

        // Import phone if available
        if (result.phone != null) {
          _sdtController.text = result.phone!;
        }

        // Import email if available
        if (result.email != null) {
          _emailController.text = result.email!;
        }
      });

      if (mounted) {
        showSuccessSnackBar(context, 'Đã nhập thông tin từ danh bạ');
      }
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = SinhVienRepository();
      final now = DateTime.now().millisecondsSinceEpoch;

      final student = SinhVien(
        id: widget.sinhVienId,
        maSV: _maSVController.text.trim(),
        hoTen: _hoTenController.text.trim(),
        ngaySinh: _ngaySinhController.text.trim().isNotEmpty
            ? _ngaySinhController.text.trim()
            : null,
        diaChi: _diaChiController.text.trim().isNotEmpty
            ? _diaChiController.text.trim()
            : null,
        sdt: _sdtController.text.trim().isNotEmpty
            ? _sdtController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        nganhId: _selectedNganhId,
        avatarPath: _avatarPath,
        lat: _lat,
        lng: _lng,
        createdAt: widget.sinhVienId == null ? now : null,
        updatedAt: now,
      );

      final result = widget.sinhVienId == null
          ? await repo.create(student)
          : await repo.update(student);

      setState(() => _isLoading = false);

      if (mounted) {
        if (result is Success) {
          showSuccessSnackBar(
            context,
            widget.sinhVienId == null
                ? 'Đã thêm sinh viên'
                : 'Đã cập nhật sinh viên',
          );
          context.pop();
        } else {
          final failure = result as Failure;
          showErrorSnackBar(context, 'Lỗi: ${failure.message}');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showErrorSnackBar(context, 'Lỗi: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nganhListAsync = ref.watch(_nganhListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sinhVienId == null ? 'Thêm Sinh viên' : 'Sửa Sinh viên',
        ),
      ),
      body: nganhListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64),
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
        data: (nganhList) => Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        backgroundImage:
                            _avatarPath != null &&
                                File(_avatarPath!).existsSync()
                            ? FileImage(File(_avatarPath!))
                            : null,
                        child:
                            _avatarPath == null ||
                                !File(_avatarPath!).existsSync()
                            ? Icon(
                                Icons.person,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: PopupMenuButton<ImageSource>(
                          icon: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: Icon(
                              Icons.camera_alt,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 20,
                            ),
                          ),
                          onSelected: _pickImage,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: ImageSource.camera,
                              child: Row(
                                children: [
                                  Icon(Icons.camera),
                                  SizedBox(width: 12),
                                  Text('Chụp ảnh'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: ImageSource.gallery,
                              child: Row(
                                children: [
                                  Icon(Icons.photo_library),
                                  SizedBox(width: 12),
                                  Text('Chọn từ thư viện'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Mã SV (required)
                TextFormField(
                  controller: _maSVController,
                  decoration: const InputDecoration(
                    labelText: 'Mã sinh viên *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mã sinh viên';
                    }
                    return null;
                  },
                  enabled: widget.sinhVienId == null, // Can't edit maSV
                ),
                const SizedBox(height: 16),

                // Họ tên (required)
                TextFormField(
                  controller: _hoTenController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nganh dropdown
                DropdownButtonFormField<int>(
                  value: _selectedNganhId,
                  decoration: const InputDecoration(
                    labelText: 'Ngành học',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: nganhList
                      .map(
                        (nganh) => DropdownMenuItem(
                          value: nganh.id,
                          child: Text('${nganh.ma} - ${nganh.ten}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedNganhId = value);
                  },
                ),
                const SizedBox(height: 16),

                // Ngày sinh
                TextFormField(
                  controller: _ngaySinhController,
                  decoration: const InputDecoration(
                    labelText: 'Ngày sinh',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                    hintText: 'dd/mm/yyyy',
                  ),
                ),
                const SizedBox(height: 16),

                // Import from contacts button
                OutlinedButton.icon(
                  onPressed: _importFromContacts,
                  icon: const Icon(Icons.contacts),
                  label: const Text('Nhập từ danh bạ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Số điện thoại
                TextFormField(
                  controller: _sdtController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Địa chỉ with geocoding button
                TextFormField(
                  controller: _diaChiController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: IconButton(
                      icon: _isGeocodingAddress
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      tooltip: 'Xác định tọa độ',
                      onPressed: _isGeocodingAddress ? null : _geocodeAddress,
                    ),
                  ),
                  maxLines: 2,
                ),
                if (_lat != null && _lng != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tọa độ: ${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 32),

                // Save button
                FilledButton.icon(
                  onPressed: _isLoading ? null : _saveStudent,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    widget.sinhVienId == null ? 'Thêm mới' : 'Cập nhật',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

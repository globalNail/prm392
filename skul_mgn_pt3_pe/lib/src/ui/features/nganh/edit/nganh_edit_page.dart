import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/repositories/nganh_repository.dart';
import '../../../../data/models/nganh.dart';
import '../../../../common/result.dart';
import '../../../../common/snackbar_utils.dart';

// Provider for loading existing nganh data
final _existingNganhProvider = FutureProvider.autoDispose.family<Nganh?, int?>((
  ref,
  id,
) async {
  if (id == null) return null;
  final repo = NganhRepository();
  final result = await repo.getById(id);
  return result is Success<Nganh> ? result.data : null;
});

class NganhEditPage extends ConsumerStatefulWidget {
  final int? nganhId;

  const NganhEditPage({super.key, this.nganhId});

  @override
  ConsumerState<NganhEditPage> createState() => _NganhEditPageState();
}

class _NganhEditPageState extends ConsumerState<NganhEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _maController = TextEditingController();
  final _tenController = TextEditingController();
  final _moTaController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load existing nganh data if editing
    if (widget.nganhId != null) {
      Future.microtask(() async {
        final nganh = await ref.read(
          _existingNganhProvider(widget.nganhId).future,
        );
        if (nganh != null && mounted) {
          _maController.text = nganh.ma;
          _tenController.text = nganh.ten;
          _moTaController.text = nganh.moTa ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _maController.dispose();
    _tenController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  Future<void> _saveNganh() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = NganhRepository();
      final now = DateTime.now().millisecondsSinceEpoch;

      final nganh = Nganh(
        id: widget.nganhId,
        ma: _maController.text.trim(),
        ten: _tenController.text.trim(),
        moTa: _moTaController.text.trim().isNotEmpty
            ? _moTaController.text.trim()
            : null,
        createdAt: widget.nganhId == null ? now : null,
        updatedAt: now,
      );

      final result = widget.nganhId == null
          ? await repo.create(nganh)
          : await repo.update(nganh);

      setState(() => _isLoading = false);

      if (mounted) {
        if (result is Success) {
          showSuccessSnackBar(
            context,
            widget.nganhId == null ? 'Đã thêm ngành' : 'Đã cập nhật ngành',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nganhId == null ? 'Thêm Ngành' : 'Sửa Ngành'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school,
                    size: 64,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Mã ngành (required, unique)
              TextFormField(
                controller: _maController,
                decoration: const InputDecoration(
                  labelText: 'Mã ngành *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                  helperText: 'Mã ngành phải là duy nhất',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mã ngành';
                  }
                  return null;
                },
                enabled: widget.nganhId == null, // Can't edit ma
              ),
              const SizedBox(height: 16),

              // Tên ngành (required)
              TextFormField(
                controller: _tenController,
                decoration: const InputDecoration(
                  labelText: 'Tên ngành *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên ngành';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mô tả (optional)
              TextFormField(
                controller: _moTaController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Save button
              FilledButton.icon(
                onPressed: _isLoading ? null : _saveNganh,
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
                label: Text(widget.nganhId == null ? 'Thêm mới' : 'Cập nhật'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

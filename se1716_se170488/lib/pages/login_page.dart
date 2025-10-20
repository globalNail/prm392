import 'package:flutter/material.dart';
import 'base_page.dart';
import 'product_list_page.dart';

class LoginPage extends BasePage {
  const LoginPage({super.key})
    : super(title: '', showBackButton: false, centerTitle: true);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends BasePageState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void onDispose() {
    _usernameController.dispose();
    _passwordController.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      showLoading();

      try {
        // Use storage service to validate credentials
        final account = await storageService.getAccountByCredentials(
          _usernameController.text,
          _passwordController.text,
        );

        hideLoading();

        if (account != null) {
          showSuccess('Đăng nhập thành công! Chào mừng ${account.name}');
          await Future.delayed(const Duration(milliseconds: 500));
          navigateToReplacement(const ProductListPage());
        } else {
          showError('Tên đăng nhập hoặc mật khẩu không đúng!');
        }
      } catch (e) {
        hideLoading();
        showError('Lỗi kết nối: ${e.toString()}');
      }
    }
  }

  @override
  Widget buildBody() {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Column(
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'lib/assets/images/logo.jpg',
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: FlutterLogo(size: 56),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên đăng nhập',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Vui lòng nhập tên đăng nhập'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Vui lòng nhập mật khẩu'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _submit, child: const Text('Login')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';

/// Abstract base page class that provides common functionality for all pages
abstract class BasePage extends StatefulWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool centerTitle;

  const BasePage({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.drawer,
    this.endDrawer,
    this.centerTitle = true,
  });
}

/// Base state class that provides common functionality
abstract class BasePageState<T extends BasePage> extends State<T> {
  // Get storage service from GetX dependency injection
  StorageService get storageService => Get.find<StorageService>();

  // Loading state management
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: widget.centerTitle,
        automaticallyImplyLeading: widget.showBackButton,
        actions: widget.actions,
        backgroundColor: widget.backgroundColor,
      ),
      body: Stack(
        children: [
          Padding(padding: const EdgeInsets.all(16.0), child: buildBody()),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
    );
  }

  /// Abstract method that child classes must implement to build their content
  Widget buildBody();

  /// Show loading indicator
  void showLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  /// Hide loading indicator
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  /// Show error message
  void showError(String message) {
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => clearError(),
        ),
      ),
    );
  }

  /// Clear error message
  void clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  /// Show success message
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 64, 172, 68),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show confirmation dialog
  Future<bool> showConfirmationDialog({
    required String title,
    required String content,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Navigate to a new page
  Future<R?> navigateTo<R>(Widget page) {
    return Navigator.of(
      context,
    ).push<R>(MaterialPageRoute(builder: (context) => page));
  }

  /// Replace current page with new page
  Future<R?> navigateToReplacement<R>(Widget page) {
    return Navigator.of(
      context,
    ).pushReplacement<R, void>(MaterialPageRoute(builder: (context) => page));
  }

  /// Go back to previous page
  void goBack([dynamic result]) {
    Navigator.of(context).pop(result);
  }

  /// Lifecycle methods that can be overridden
  @override
  void initState() {
    super.initState();
    onInitState();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  /// Called during initState - override in child classes for initialization
  void onInitState() {}

  /// Called during dispose - override in child classes for cleanup
  void onDispose() {}
}

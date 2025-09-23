import 'package:flutter/material.dart';

class WidgetBuilders {
  // Builder cho empty state
  static Widget buildEmptyState({
    required String title,
    String? subtitle,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              child: Text(actionText),
            ),
          ],
        ],
      ),
    );
  }

  // Builder cho loading state
  static Widget buildLoadingState([String? message]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message),
          ],
        ],
      ),
    );
  }

  // Builder cho error state
  static Widget buildErrorState({
    required String error,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ],
      ),
    );
  }
}
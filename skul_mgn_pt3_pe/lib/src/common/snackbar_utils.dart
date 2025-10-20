import 'package:flutter/material.dart';

/// Show a SnackBar at the top of the screen
void showTopSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
  IconData? icon,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 150,
        left: 10,
        right: 10,
        top: 10,
      ),
    ),
  );
}

/// Show a success message at the top
void showSuccessSnackBar(BuildContext context, String message) {
  showTopSnackBar(
    context,
    message,
    backgroundColor: Colors.green[700],
    icon: Icons.check_circle,
  );
}

/// Show an error message at the top
void showErrorSnackBar(BuildContext context, String message) {
  showTopSnackBar(
    context,
    message,
    backgroundColor: Colors.red[700],
    icon: Icons.error,
  );
}

/// Show an info message at the top
void showInfoSnackBar(BuildContext context, String message) {
  showTopSnackBar(
    context,
    message,
    backgroundColor: Colors.blue[700],
    icon: Icons.info,
  );
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String? src;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? error;

  const AppImage({
    super.key,
    required this.src,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderRadius ?? BorderRadius.circular(8);

    Widget child;
    if (src == null || src!.isEmpty) {
      child = _placeholder();
    } else if (kIsWeb && src!.startsWith('data:image')) {
      final base64String = src!.split(',').elementAtOrNull(1);
      if (base64String == null) {
        child = _error();
      } else {
        try {
          final bytes = base64Decode(base64String);
          child = Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (c, e, s) => _error(),
          );
        } catch (_) {
          child = _error();
        }
      }
    } else if (src!.startsWith('http')) {
      child = Image.network(
        src!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (c, e, s) => _error(),
      );
    } else {
      if (kIsWeb) {
        // On web, treat as relative/asset path
        child = Image.asset(
          src!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (c, e, s) => _error(),
        );
      } else {
        final file = File(src!);
        child = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (c, e, s) => _error(),
        );
      }
    }

    return ClipRRect(
      borderRadius: border,
      child: SizedBox(width: width, height: height, child: child),
    );
  }

  Widget _placeholder() => placeholder ?? _fallback(icon: Icons.image);
  Widget _error() => error ?? _fallback(icon: Icons.broken_image);

  Widget _fallback({required IconData icon}) {
    return Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.grey[400], size: width * 0.4),
    );
  }
}

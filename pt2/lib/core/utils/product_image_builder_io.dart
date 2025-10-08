import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider<Object>? buildFileImageProvider(String path) {
  String normalized = path.trim();
  if (normalized.isEmpty) {
    return null;
  }
  if (normalized.startsWith('file://')) {
    normalized = Uri.parse(normalized).toFilePath();
  }
  final file = File(normalized);
  if (file.existsSync()) {
    return FileImage(file);
  }
  return null;
}

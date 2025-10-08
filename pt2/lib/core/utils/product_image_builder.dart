import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import 'product_image_builder_stub.dart'
    if (dart.library.io) 'product_image_builder_io.dart';

ImageProvider<Object>? _fileImageProvider(String path) {
  if (kIsWeb) {
    return null;
  }
  return buildFileImageProvider(path);
}

const List<int> _transparentPixelPng = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0x0F,
  0x00,
  0x01,
  0x01,
  0x01,
  0x00,
  0x18,
  0xDD,
  0x8D,
  0xB1,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

Widget buildProductImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  AlignmentGeometry alignment = Alignment.center,
}) {
  final trimmed = path.trim();

  if (trimmed.isEmpty) {
    return _buildPlaceholder(
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
  }

  if (trimmed.startsWith('http')) {
    return Image.network(
      trimmed,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, __, ___) => _buildPlaceholder(
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
      ),
    );
  }

  final fileProvider = _fileImageProvider(trimmed);
  if (fileProvider != null) {
    return Image(
      image: fileProvider,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, __, ___) => _buildPlaceholder(
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
      ),
    );
  }

  return Image.asset(
    trimmed,
    width: width,
    height: height,
    fit: fit,
    alignment: alignment,
    errorBuilder: (_, __, ___) => _buildPlaceholder(
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    ),
  );
}

Widget _buildPlaceholder({
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  AlignmentGeometry alignment = Alignment.center,
}) {
  return Image.asset(
    AppAssets.placeholderImage,
    width: width,
    height: height,
    fit: fit,
    alignment: alignment,
    errorBuilder: (_, __, ___) => Image.memory(
      Uint8List.fromList(_transparentPixelPng),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    ),
  );
}

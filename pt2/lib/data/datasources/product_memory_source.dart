import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';

class ProductMemorySource {
  ProductMemorySource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const _assetPath = AppAssets.productsJson;

  final AssetBundle _bundle;

  List<Map<String, dynamic>>? _cache;

  Future<List<Map<String, dynamic>>> loadProducts() async {
    if (_cache != null) {
      return _cache!;
    }

    try {
      final jsonString = await _bundle.loadString(_assetPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _cache = jsonList
          .map((dynamic item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (error, stack) {
      debugPrint('Error loading $_assetPath: $error');
      debugPrint('$stack');
      _cache = <Map<String, dynamic>>[];
    }
    return _cache!;
  }

  Future<void> writeProducts(List<Map<String, dynamic>> products) async {
    _cache = List<Map<String, dynamic>>.from(products);
  }

  void clearCache() {
    _cache = null;
  }
}

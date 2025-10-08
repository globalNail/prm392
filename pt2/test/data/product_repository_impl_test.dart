import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gizmo_hub_demo/core/constants/app_assets.dart';
import 'package:gizmo_hub_demo/data/datasources/product_memory_source.dart';
import 'package:gizmo_hub_demo/data/repositories/product_repository_impl.dart';
import 'package:gizmo_hub_demo/domain/entities/product.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._manifest);

  final Map<String, String> _manifest;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _manifest[key];
    if (value == null) {
      throw StateError('Asset $key not found in fake bundle');
    }
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    final value = await loadString(key);
    return ByteData.view(Uint8List.fromList(utf8.encode(value)).buffer);
  }
}

void main() {
  const sampleJson =
      '[{"id":"p1","name":"Phone","description":"Great phone","price":1000000,"image":"assets/images/phone.png"},{"id":"p2","name":"Laptop","description":"Great laptop","price":2000000,"image":"assets/images/laptop.png"}]';

  late ProductRepositoryImpl repository;

  setUp(() {
    final bundle = _FakeAssetBundle({AppAssets.productsJson: sampleJson});
    final source = ProductMemorySource(bundle: bundle);
    repository = ProductRepositoryImpl(source);
  });

  test('loadProducts returns parsed products from assets', () async {
    final products = await repository.loadProducts();

    expect(products, hasLength(2));
    expect(products.first, isA<Product>());
    expect(products.first.name, 'Phone');
  });

  test('searchByName filters products case-insensitively', () async {
    final results = await repository.searchByName('lAp');

    expect(results, hasLength(1));
    expect(results.first.name, 'Laptop');
  });
}

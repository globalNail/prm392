import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/load_products.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/update_product.dart';
import '../../data/datasources/product_memory_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_product.dart';

class ProductListState {
  const ProductListState({
    required this.items,
    required this.filteredItems,
    this.query = '',
    this.isLoading = false,
    this.error,
  });

  const ProductListState.initial()
      : this(items: const [], filteredItems: const []);

  final List<Product> items;
  final List<Product> filteredItems;
  final String query;
  final bool isLoading;
  final String? error;

  bool get hasError => error != null && error!.isNotEmpty;
  bool get isEmpty => filteredItems.isEmpty && !isLoading;

  ProductListState copyWith({
    List<Product>? items,
    List<Product>? filteredItems,
    String? query,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProductListState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProductListController extends StateNotifier<ProductListState> {
  ProductListController(
    this._loadProducts,
    this._searchProducts,
    this._addProduct,
    this._updateProduct,
    this._deleteProduct,
  ) : super(const ProductListState.initial());

  final LoadProducts _loadProducts;
  final SearchProducts _searchProducts;
  final AddProduct _addProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;

  Timer? _debounce;

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) {
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final products = await _loadProducts();
      state = state.copyWith(
        items: List<Product>.unmodifiable(products),
        filteredItems: List<Product>.unmodifiable(products),
        isLoading: false,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    } catch (error, stack) {
      debugPrint('Failed to load products: $error');
      debugPrint('$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải danh sách sản phẩm.',
      );
    }
  }

  void setSearchQuery(String query) {
    _debounce?.cancel();
    state = state.copyWith(query: query);

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        if (query.trim().isEmpty) {
          state = state.copyWith(
            filteredItems: state.items,
            clearError: true,
          );
          return;
        }
        final results = await _searchProducts(query);
        state = state.copyWith(
          filteredItems: List<Product>.unmodifiable(results),
          clearError: true,
        );
      } catch (error, stack) {
        debugPrint('Search error: $error');
        debugPrint('$stack');
        state = state.copyWith(error: 'Không thể tìm kiếm sản phẩm.');
      }
    });
  }

  Future<Product> add(Product product) async {
    final created = await _addProduct(product);
    final updatedItems = [...state.items, created];
    _updateCollections(updatedItems, notify: true);
    return created;
  }

  Future<Product> update(Product product) async {
    final updatedProduct = await _updateProduct(product);
    final updatedItems = state.items.map((item) {
      return item.id == updatedProduct.id ? updatedProduct : item;
    }).toList();
    _updateCollections(updatedItems, notify: true);
    return updatedProduct;
  }

  Future<void> delete(String id) async {
    await _deleteProduct(id);
    final updatedItems = state.items.where((item) => item.id != id).toList();
    _updateCollections(updatedItems, notify: true);
  }

  void replaceLocally(Product product) {
    final updatedItems = state.items.map((item) {
      return item.id == product.id ? product : item;
    }).toList();
    _updateCollections(updatedItems, notify: true);
  }

  void removeLocally(String id) {
    final updatedItems = state.items.where((item) => item.id != id).toList();
    _updateCollections(updatedItems, notify: true);
  }

  void _updateCollections(
    List<Product> updatedItems, {
    bool notify = false,
  }) {
    final query = state.query.trim();
    List<Product> filtered;
    if (query.isEmpty) {
      filtered = updatedItems;
    } else {
      final lower = query.toLowerCase();
      filtered = updatedItems
          .where((item) => item.name.toLowerCase().contains(lower))
          .toList();
    }
    if (notify) {
      state = state.copyWith(
        items: List<Product>.unmodifiable(updatedItems),
        filteredItems: List<Product>.unmodifiable(filtered),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final productMemorySourceProvider = Provider<ProductMemorySource>((ref) {
  return ProductMemorySource();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final memorySource = ref.watch(productMemorySourceProvider);
  return ProductRepositoryImpl(memorySource);
});

final loadProductsProvider = Provider<LoadProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return LoadProducts(repository);
});

final searchProductsProvider = Provider<SearchProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return SearchProducts(repository);
});

final addProductProvider = Provider<AddProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return AddProduct(repository);
});

final updateProductProvider = Provider<UpdateProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return UpdateProduct(repository);
});

final deleteProductProvider = Provider<DeleteProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return DeleteProduct(repository);
});

final getProductProvider = Provider<GetProduct>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProduct(repository);
});

final productListControllerProvider =
    StateNotifierProvider<ProductListController, ProductListState>((ref) {
  return ProductListController(
    ref.watch(loadProductsProvider),
    ref.watch(searchProductsProvider),
    ref.watch(addProductProvider),
    ref.watch(updateProductProvider),
    ref.watch(deleteProductProvider),
  );
});

final filteredProductsProvider = Provider<UnmodifiableListView<Product>>((ref) {
  final state = ref.watch(productListControllerProvider);
  return UnmodifiableListView<Product>(state.filteredItems);
});

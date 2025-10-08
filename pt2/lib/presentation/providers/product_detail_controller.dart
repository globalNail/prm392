import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/update_product.dart';
import 'product_list_controller.dart';
import 'cart_controller.dart';

class ProductDetailState {
  const ProductDetailState({
    this.product,
    this.isLoading = false,
    this.error,
  });

  const ProductDetailState.initial() : this();

  final Product? product;
  final bool isLoading;
  final String? error;

  ProductDetailState copyWith({
    Product? product,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProductDetailController extends StateNotifier<ProductDetailState> {
  ProductDetailController(
    this._getProduct,
    this._updateProduct,
    this._deleteProduct,
    this._ref,
  ) : super(const ProductDetailState.initial());

  final GetProduct _getProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final Ref _ref;

  void seed(Product product) {
    state = state.copyWith(product: product);
  }

  Future<void> load(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final product = await _getProduct(id);
      if (product == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Không tìm thấy sản phẩm.',
        );
        return;
      }
      state = state.copyWith(
        product: product,
        isLoading: false,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    } catch (error, stack) {
      debugPrint('Detail load error: $error');
      debugPrint('$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải sản phẩm.',
      );
    }
  }

  Future<Product?> refresh() async {
    final current = state.product;
    if (current == null) {
      return null;
    }
    await load(current.id);
    return state.product;
  }

  Future<Product> update(Product product) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _updateProduct(product);
      _ref.read(productListControllerProvider.notifier).replaceLocally(updated);
      _ref.read(cartControllerProvider.notifier).syncProduct(updated);
      state = state.copyWith(
        product: updated,
        isLoading: false,
        clearError: true,
      );
      return updated;
    } on AppException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
      rethrow;
    } catch (error, stack) {
      debugPrint('Detail update error: $error');
      debugPrint('$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể cập nhật sản phẩm.',
      );
      rethrow;
    }
  }

  Future<void> deleteCurrent() async {
    final product = state.product;
    if (product == null) {
      return;
    }
    try {
      await _deleteProduct(product.id);
      _ref
          .read(productListControllerProvider.notifier)
          .removeLocally(product.id);
      _ref.read(cartControllerProvider.notifier).removeIfExists(product.id);
      state = state.copyWith(product: null, clearError: true);
    } on AppException catch (error) {
      state = state.copyWith(error: error.message);
      rethrow;
    } catch (error, stack) {
      debugPrint('Detail delete error: $error');
      debugPrint('$stack');
      state = state.copyWith(error: 'Không thể xóa sản phẩm.');
      rethrow;
    }
  }
}

final productDetailControllerProvider = StateNotifierProvider.family<
    ProductDetailController,
    ProductDetailState,
    ProductDetailInput>((ref, input) {
  final controller = ProductDetailController(
    ref.watch(getProductProvider),
    ref.watch(updateProductProvider),
    ref.watch(deleteProductProvider),
    ref,
  );
  if (input.product != null) {
    controller.seed(input.product!);
  }
  controller.load(input.id);
  return controller;
});

class ProductDetailInput {
  const ProductDetailInput({required this.id, this.product});

  final String id;
  final Product? product;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ProductDetailInput && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

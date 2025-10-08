import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/product.dart';

class CartLine {
  const CartLine({required this.product, required this.quantity})
      : assert(quantity >= 1, 'Quantity must be at least 1');

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  CartLine copyWith({Product? product, int? quantity}) {
    return CartLine(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  const CartState({required this.lines});

  const CartState.initial() : this(lines: const {});

  final Map<String, CartLine> lines;

  bool get isEmpty => lines.isEmpty;

  double get subtotal =>
      lines.values.fold(0, (total, line) => total + line.subtotal);

  double get total => subtotal;

  int get itemCount =>
      lines.values.fold(0, (total, line) => total + line.quantity);

  String get formattedTotal => CurrencyFormatter.vnd(total);

  UnmodifiableListView<CartLine> get items =>
      UnmodifiableListView<CartLine>(lines.values);

  CartState copyWith({Map<String, CartLine>? lines}) {
    return CartState(lines: lines ?? this.lines);
  }
}

class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState.initial());

  void add(Product product) {
    final updated = Map<String, CartLine>.from(state.lines);
    final existing = updated[product.id];
    if (existing != null) {
      updated[product.id] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updated[product.id] = CartLine(product: product, quantity: 1);
    }
    state = state.copyWith(lines: Map.unmodifiable(updated));
  }

  void remove(String productId) {
    if (!state.lines.containsKey(productId)) {
      return;
    }
    final updated = Map<String, CartLine>.from(state.lines);
    updated.remove(productId);
    state = state.copyWith(lines: Map.unmodifiable(updated));
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity < 1) {
      return;
    }
    final existing = state.lines[productId];
    if (existing == null) {
      return;
    }
    final updated = Map<String, CartLine>.from(state.lines);
    updated[productId] = existing.copyWith(quantity: quantity);
    state = state.copyWith(lines: Map.unmodifiable(updated));
  }

  void clear() {
    state = const CartState.initial();
  }

  void syncProduct(Product product) {
    final existing = state.lines[product.id];
    if (existing == null) {
      return;
    }
    final updated = Map<String, CartLine>.from(state.lines);
    updated[product.id] = existing.copyWith(product: product);
    state = state.copyWith(lines: Map.unmodifiable(updated));
  }

  void removeIfExists(String productId) {
    if (!state.lines.containsKey(productId)) {
      return;
    }
    final updated = Map<String, CartLine>.from(state.lines);
    updated.remove(productId);
    state = state.copyWith(lines: Map.unmodifiable(updated));
  }
}

final cartControllerProvider =
    StateNotifierProvider<CartController, CartState>((ref) {
  return CartController();
});

import 'package:flutter/foundation.dart';

@immutable
class CartItem {
  const CartItem({
    required this.productId,
    required this.quantity,
  }) : assert(quantity >= 1, 'Quantity must be at least 1');

  final String productId;
  final int quantity;

  CartItem copyWith({
    String? productId,
    int? quantity,
  }) {
    final nextQuantity = quantity ?? this.quantity;
    return CartItem(
      productId: productId ?? this.productId,
      quantity: nextQuantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CartItem &&
        other.productId == productId &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => Object.hash(productId, quantity);
}

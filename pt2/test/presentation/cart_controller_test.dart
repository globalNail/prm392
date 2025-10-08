import 'package:flutter_test/flutter_test.dart';

import 'package:gizmo_hub_demo/domain/entities/product.dart';
import 'package:gizmo_hub_demo/presentation/providers/cart_controller.dart';

void main() {
  late CartController controller;
  const product = Product(
    id: 'p1',
    name: 'Test Product',
    price: 100000,
    description: 'Test',
    image: 'assets/images/phone.png',
  );

  setUp(() {
    controller = CartController();
  });

  test('add adds product and increases totals', () {
    controller.add(product);

    final state = controller.state;
    expect(state.itemCount, 1);
    expect(state.total, 100000);
  });

  test('updateQuantity adjusts subtotal and total', () {
    controller.add(product);
    controller.updateQuantity(product.id, 3);

    final state = controller.state;
    expect(state.itemCount, 3);
    expect(state.total, 300000);
  });

  test('remove and clear work as expected', () {
    controller.add(product);
    controller.remove(product.id);

    expect(controller.state.isEmpty, isTrue);

    controller.add(product);
    controller.clear();

    expect(controller.state.isEmpty, isTrue);
  });
}

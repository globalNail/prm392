import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gizmo_hub_demo/core/constants/app_strings.dart';
import 'package:gizmo_hub_demo/core/utils/currency_formatter.dart';
import 'package:gizmo_hub_demo/core/widgets/product_card.dart';
import 'package:gizmo_hub_demo/domain/entities/product.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ProductCard renders and handles add to cart tap',
      (tester) async {
    bool didTapAdd = false;
    const product = Product(
      id: 'p1',
      name: 'Demo Product',
      price: 250000,
      description: 'Description',
      image: 'assets/images/phone.png',
    );

    final priceText = CurrencyFormatter.vnd(product.price);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ProductCard(
            product: product,
            onAddToCart: () => didTapAdd = true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text(product.name), findsOneWidget);
    expect(find.text(priceText), findsOneWidget);

    await tester.tap(find.text(AppStrings.addToCart));
    await tester.pump();

    expect(didTapAdd, isTrue);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:se1716_se170488/main.dart';

void main() {
  testWidgets('Login and navigate to product list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // See Login page (title and button both show 'Đăng nhập')
    expect(find.text('Đăng nhập'), findsWidgets);

    // Enter username/password and tap login
    await tester.enterText(find.byType(TextFormField).at(0), 'user');
    await tester.enterText(find.byType(TextFormField).at(1), 'pass');
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();

    // Now on product list page
    expect(find.text('Danh sách sản phẩm'), findsOneWidget);

    // Should see one of the seeded products
    expect(find.textContaining('iPhone'), findsWidgets);
  });
}

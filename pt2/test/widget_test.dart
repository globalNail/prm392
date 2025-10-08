// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gizmo_hub_demo/app.dart';
import 'package:gizmo_hub_demo/core/constants/app_strings.dart';
import 'package:gizmo_hub_demo/core/widgets/app_button.dart';

void main() {
  testWidgets('GizmoHub boots into login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GizmoHubApp()));

    expect(find.text(AppStrings.loginTitle), findsWidgets);
    expect(
      find.widgetWithText(AppButton, AppStrings.loginButton),
      findsOneWidget,
    );
  });
}

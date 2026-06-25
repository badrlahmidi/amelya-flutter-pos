import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos_app/restaurant_app.dart';

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1440, 900);
    binding.window.devicePixelRatioTestValue = 1;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  testWidgets('renders the desktop POS workflow shell',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RestaurantApp());
    await tester.pumpAndSettle();

    expect(find.text('Comptoir desktop POS'), findsOneWidget);
    expect(find.text('Commande active'), findsOneWidget);
    expect(find.text('Classic Burger'), findsOneWidget);
    expect(find.text('Application patron'), findsNothing);
  });

  testWidgets('adds an item and sends it to kitchen',
      (WidgetTester tester) async {
    final controller = RestaurantController();

    await tester.pumpWidget(RestaurantApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('item-classic-burger')));
    await tester.pumpAndSettle();

    expect(controller.draftLines.length, 1);
    expect(find.text('9.79 EUR'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('send-kitchen')));
    await tester.pumpAndSettle();

    expect(controller.draftLines, isEmpty);
    expect(controller.orders.first.status, OrderStatus.sentToKitchen);
    expect(controller.orders.first.tableName, 'Table 1');
  });

  testWidgets('patron report updates after direct payment',
      (WidgetTester tester) async {
    final controller = RestaurantController();

    await tester.pumpWidget(RestaurantApp(controller: controller));
    await tester.pumpAndSettle();

    final initialPaidOrders = controller.report.paidOrders.length;

    await tester.tap(find.byKey(const ValueKey<String>('item-double-cheese')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('pay-now')));
    await tester.pumpAndSettle();

    expect(controller.report.paidOrders.length, initialPaidOrders + 1);

    await tester.tap(find.byKey(const ValueKey<String>('nav-patron')));
    await tester.pumpAndSettle();

    expect(find.text('Application patron'), findsOneWidget);
    expect(find.text('Tickets payes'), findsOneWidget);
  });
}

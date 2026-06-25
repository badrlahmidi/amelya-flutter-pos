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

  testWidgets('renders the floor plan as default POS screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RestaurantApp());
    await tester.pumpAndSettle();

    expect(find.text('Plan de salle'), findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('start-takeaway')), findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('start-delivery')), findsOneWidget);
    expect(find.text('Commandes en cours'), findsOneWidget);
    expect(find.text('Application patron'), findsNothing);
  });

  testWidgets('opens a table order and sends it back to the floor plan',
      (WidgetTester tester) async {
    final controller = RestaurantController();

    await tester.pumpWidget(RestaurantApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('table-Table 1')));
    await tester.pumpAndSettle();

    expect(find.text('POS commande'), findsOneWidget);
    expect(find.text('Table 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('item-tacos-poulet')));
    await tester.pumpAndSettle();

    expect(controller.activeOrder!.lines.length, 1);
    expect(find.text('46.20 MAD'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('send-kitchen')));
    await tester.pumpAndSettle();

    expect(controller.activeOrder, isNull);
    expect(find.text('Plan de salle'), findsOneWidget);
    expect(controller.occupiedOrderForTable('Table 1')!.status,
        OrderStatus.sentToKitchen);
  });

  testWidgets('payment frees the table and updates patron reports',
      (WidgetTester tester) async {
    final controller = RestaurantController();

    await tester.pumpWidget(RestaurantApp(controller: controller));
    await tester.pumpAndSettle();

    final initialPaidOrders = controller.report.paidOrders.length;

    await tester.tap(find.byKey(const ValueKey<String>('table-Table 2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('item-burger-maison')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('open-payment')));
    await tester.pumpAndSettle();

    expect(find.text('Paiement Table 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('bill-100')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('confirm-payment')));
    await tester.pumpAndSettle();

    expect(controller.report.paidOrders.length, initialPaidOrders + 1);
    expect(controller.occupiedOrderForTable('Table 2'), isNull);
    expect(find.text('Plan de salle'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('nav-patron')));
    await tester.pumpAndSettle();

    expect(find.text('Application patron'), findsOneWidget);
    expect(find.text('Tickets payes'), findsOneWidget);
  });
}

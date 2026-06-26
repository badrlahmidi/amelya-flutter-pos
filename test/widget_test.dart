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

  Future<void> loginAndOpenPos(WidgetTester tester,
      {RestaurantController? controller}) async {
    await tester.pumpWidget(RestaurantApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('login-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('module-pos')));
    await tester.pumpAndSettle();
  }

  testWidgets('login opens the module hub with module tiles',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RestaurantApp());
    await tester.pumpAndSettle();

    expect(find.text('Connexion POS Pro'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Choisir un module'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('module-pos')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('module-menu-stock')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('module-reports')), findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('module-settings')), findsOneWidget);
  });

  testWidgets(
      'point de vente opens fullscreen floor plan without global sidebar',
      (WidgetTester tester) async {
    await loginAndOpenPos(tester);

    expect(find.text('Plan de salle'), findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('start-takeaway')), findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('start-delivery')), findsOneWidget);
    expect(find.text('Commandes en cours'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('back-hub-from-pos')),
        findsOneWidget);
    expect(find.text('Salle'), findsNothing);
  });

  testWidgets('opens a table order and sends it back to the floor plan',
      (WidgetTester tester) async {
    final controller = RestaurantController();

    await loginAndOpenPos(tester, controller: controller);

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

    await loginAndOpenPos(tester, controller: controller);

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

    await tester.tap(find.byKey(const ValueKey<String>('back-hub-from-pos')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('module-reports')));
    await tester.pumpAndSettle();

    expect(find.text('Application patron'), findsOneWidget);
    expect(find.text('Tickets payes'), findsOneWidget);
  });

  testWidgets('menu stock module uses its own sidebar shell',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RestaurantApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('login-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('module-menu-stock')));
    await tester.pumpAndSettle();

    expect(find.text('Menu et stock'), findsOneWidget);
    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Produits'), findsWidgets);
    expect(find.text('Modifiers'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Stock'), findsWidgets);
    expect(find.byKey(const ValueKey<String>('back-hub-from-module')),
        findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('section-produits')));
    await tester.pumpAndSettle();

    expect(find.text('Tacos Poulet'), findsOneWidget);
    expect(find.text('Burger Maison'), findsOneWidget);
  });
}

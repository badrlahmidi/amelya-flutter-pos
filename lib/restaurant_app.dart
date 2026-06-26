import 'package:flutter/material.dart';

enum AppWorkspace {
  floor,
  kitchen,
  patron,
  settings,
}

enum AppRoute {
  login,
  hub,
  pointOfSale,
  menuStock,
  reports,
  settings,
}

enum ManagementSection {
  categories,
  products,
  notes,
  modifiers,
  ingredients,
  stock,
  inventory,
  suppliers,
}

enum OrderType {
  dineIn,
  takeaway,
  delivery,
}

enum OrderStatus {
  draft,
  sentToKitchen,
  ready,
  paid,
  voided,
}

enum PaymentMethod {
  cash,
  card,
  mobile,
}

class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final IconData icon;
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.station,
    required this.price,
    required this.color,
    required this.icon,
    this.available = true,
  });

  final String id;
  final String categoryId;
  final String name;
  final String station;
  final double price;
  final Color color;
  final IconData icon;
  final bool available;
}

class OrderLine {
  const OrderLine({
    required this.item,
    required this.quantity,
    this.note = '',
  });

  final MenuItem item;
  final int quantity;
  final String note;

  double get total => item.price * quantity;

  OrderLine copyWith({
    MenuItem? item,
    int? quantity,
    String? note,
  }) {
    return OrderLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}

class RestaurantOrder {
  const RestaurantOrder({
    required this.id,
    required this.type,
    required this.serverName,
    required this.lines,
    required this.status,
    required this.createdAt,
    this.tableName,
    this.customerLabel,
    this.discountRate = 0,
    this.paidAt,
    this.paymentMethod,
    this.amountPaid = 0,
  });

  final String id;
  final OrderType type;
  final String serverName;
  final List<OrderLine> lines;
  final OrderStatus status;
  final DateTime createdAt;
  final String? tableName;
  final String? customerLabel;
  final double discountRate;
  final DateTime? paidAt;
  final PaymentMethod? paymentMethod;
  final double amountPaid;

  String get title {
    if (type == OrderType.dineIn) {
      return tableName ?? 'Table';
    }
    return customerLabel ?? _orderTypeName(type);
  }

  double get subtotal {
    return lines.fold<double>(0, (sum, line) => sum + line.total);
  }

  double get discount => subtotal * discountRate;

  double get tax => (subtotal - discount) * 0.1;

  double get total => subtotal - discount + tax;

  double get changeDue {
    final change = amountPaid - total;
    return change < 0 ? 0 : change;
  }

  int get itemCount {
    return lines.fold<int>(0, (sum, line) => sum + line.quantity);
  }

  RestaurantOrder copyWith({
    String? id,
    OrderType? type,
    String? serverName,
    List<OrderLine>? lines,
    OrderStatus? status,
    DateTime? createdAt,
    String? tableName,
    String? customerLabel,
    double? discountRate,
    DateTime? paidAt,
    PaymentMethod? paymentMethod,
    double? amountPaid,
  }) {
    return RestaurantOrder(
      id: id ?? this.id,
      type: type ?? this.type,
      serverName: serverName ?? this.serverName,
      lines: lines ?? this.lines,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      tableName: tableName ?? this.tableName,
      customerLabel: customerLabel ?? this.customerLabel,
      discountRate: discountRate ?? this.discountRate,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
    );
  }
}

class DailyReport {
  const DailyReport({
    required this.paidOrders,
    required this.openOrders,
    required this.salesByMethod,
    required this.topItems,
  });

  final List<RestaurantOrder> paidOrders;
  final List<RestaurantOrder> openOrders;
  final Map<PaymentMethod, double> salesByMethod;
  final List<ItemSales> topItems;

  double get grossSales {
    return paidOrders.fold<double>(0, (sum, order) => sum + order.total);
  }

  double get taxCollected {
    return paidOrders.fold<double>(0, (sum, order) => sum + order.tax);
  }
}

class ItemSales {
  const ItemSales({
    required this.name,
    required this.quantity,
    required this.amount,
  });

  final String name;
  final int quantity;
  final double amount;
}

class LocalRestaurantDatabase {
  LocalRestaurantDatabase()
      : categories = const [
          MenuCategory(id: 'grill', name: 'Grill', icon: Icons.outdoor_grill),
          MenuCategory(id: 'plats', name: 'Plats', icon: Icons.restaurant),
          MenuCategory(id: 'drinks', name: 'Boissons', icon: Icons.local_bar),
          MenuCategory(id: 'desserts', name: 'Desserts', icon: Icons.icecream),
        ],
        menu = const [
          MenuItem(
            id: 'tacos-poulet',
            categoryId: 'grill',
            name: 'Tacos Poulet',
            station: 'Grill',
            price: 42,
            color: Color(0xfff97316),
            icon: Icons.lunch_dining,
          ),
          MenuItem(
            id: 'burger-maison',
            categoryId: 'grill',
            name: 'Burger Maison',
            station: 'Grill',
            price: 55,
            color: Color(0xfffb923c),
            icon: Icons.fastfood,
          ),
          MenuItem(
            id: 'tagine-kefta',
            categoryId: 'plats',
            name: 'Tagine Kefta',
            station: 'Cuisine',
            price: 68,
            color: Color(0xffef4444),
            icon: Icons.restaurant,
          ),
          MenuItem(
            id: 'salade-marocaine',
            categoryId: 'plats',
            name: 'Salade Marocaine',
            station: 'Cuisine',
            price: 28,
            color: Color(0xff22c55e),
            icon: Icons.eco,
          ),
          MenuItem(
            id: 'jus-orange',
            categoryId: 'drinks',
            name: 'Jus Orange',
            station: 'Bar',
            price: 18,
            color: Color(0xfffacc15),
            icon: Icons.local_drink,
          ),
          MenuItem(
            id: 'the-menthe',
            categoryId: 'drinks',
            name: 'The Menthe',
            station: 'Bar',
            price: 14,
            color: Color(0xff38bdf8),
            icon: Icons.emoji_food_beverage,
          ),
          MenuItem(
            id: 'tiramisu',
            categoryId: 'desserts',
            name: 'Tiramisu',
            station: 'Patisserie',
            price: 32,
            color: Color(0xffa855f7),
            icon: Icons.cake,
          ),
          MenuItem(
            id: 'creme-caramel',
            categoryId: 'desserts',
            name: 'Creme Caramel',
            station: 'Patisserie',
            price: 24,
            color: Color(0xffec4899),
            icon: Icons.icecream,
          ),
        ];

  final List<MenuCategory> categories;
  final List<MenuItem> menu;
  final List<RestaurantOrder> _orders = <RestaurantOrder>[];

  List<RestaurantOrder> get orders =>
      List<RestaurantOrder>.unmodifiable(_orders);

  void seedDemoOrders() {
    if (_orders.isNotEmpty) {
      return;
    }

    _orders.addAll([
      RestaurantOrder(
        id: 'ORD-1001',
        type: OrderType.dineIn,
        tableName: 'Table 3',
        serverName: 'Mina',
        status: OrderStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        paidAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
        paymentMethod: PaymentMethod.card,
        amountPaid: 155.10,
        lines: [
          OrderLine(item: menu[0], quantity: 2),
          OrderLine(item: menu[4], quantity: 2),
          OrderLine(item: menu[6], quantity: 1),
        ],
      ),
      RestaurantOrder(
        id: 'ORD-1002',
        type: OrderType.dineIn,
        tableName: 'Table 8',
        serverName: 'Leo',
        status: OrderStatus.ready,
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
        lines: [
          OrderLine(item: menu[2], quantity: 1, note: 'Sans piment'),
          OrderLine(item: menu[5], quantity: 2),
        ],
      ),
      RestaurantOrder(
        id: 'ORD-1003',
        type: OrderType.takeaway,
        customerLabel: 'Emporter 12',
        serverName: 'Sara',
        status: OrderStatus.sentToKitchen,
        createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
        lines: [
          OrderLine(item: menu[1], quantity: 1),
          OrderLine(item: menu[4], quantity: 1),
        ],
      ),
    ]);
  }

  RestaurantOrder saveOrder(RestaurantOrder order) {
    final index = _orders.indexWhere((stored) => stored.id == order.id);
    if (index == -1) {
      _orders.insert(0, order);
    } else {
      _orders[index] = order;
    }
    return order;
  }
}

class RestaurantController extends ChangeNotifier {
  RestaurantController({LocalRestaurantDatabase? database})
      : database = database ?? LocalRestaurantDatabase() {
    this.database.seedDemoOrders();
    _selectedCategoryId = this.database.categories.first.id;
  }

  final LocalRestaurantDatabase database;
  final List<String> tables = const [
    'Table 1',
    'Table 2',
    'Table 3',
    'Table 4',
    'Table 5',
    'Table 6',
    'Table 7',
    'Table 8',
    'Table 9',
    'Table 10',
    'Table 11',
    'Table 12',
  ];
  final List<String> servers = const ['Mina', 'Leo', 'Sara', 'Nora'];

  AppRoute _route = AppRoute.login;
  AppWorkspace _workspace = AppWorkspace.floor;
  ManagementSection _managementSection = ManagementSection.categories;
  String _selectedCategoryId = '';
  String _selectedServer = 'Mina';
  String _search = '';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  int _nextOrderNumber = 1004;
  int _nextTakeawayNumber = 13;
  int _nextDeliveryNumber = 4;
  String? _activeOrderId;

  AppRoute get route => _route;
  AppWorkspace get workspace => _workspace;
  ManagementSection get managementSection => _managementSection;
  String get selectedCategoryId => _selectedCategoryId;
  String get selectedServer => _selectedServer;
  String get search => _search;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  List<RestaurantOrder> get orders => database.orders;
  RestaurantOrder? get activeOrder => _activeOrderId == null
      ? null
      : orders.cast<RestaurantOrder?>().firstWhere(
            (order) => order?.id == _activeOrderId,
            orElse: () => null,
          );

  bool get isEditingOrder => activeOrder != null;

  List<MenuItem> get filteredMenu {
    final normalizedSearch = _search.trim().toLowerCase();
    return database.menu.where((item) {
      final matchesCategory = item.categoryId == _selectedCategoryId;
      final matchesSearch = normalizedSearch.isEmpty ||
          item.name.toLowerCase().contains(normalizedSearch);
      return item.available && matchesCategory && matchesSearch;
    }).toList();
  }

  List<RestaurantOrder> get unpaidOrders {
    return orders
        .where((order) =>
            order.status != OrderStatus.paid &&
            order.status != OrderStatus.voided)
        .toList();
  }

  List<RestaurantOrder> get kitchenOrders {
    return unpaidOrders
        .where((order) =>
            order.status == OrderStatus.sentToKitchen ||
            order.status == OrderStatus.ready)
        .toList();
  }

  DailyReport get report {
    final paidOrders =
        orders.where((order) => order.status == OrderStatus.paid).toList();
    final openOrders = unpaidOrders;
    final salesByMethod = <PaymentMethod, double>{};
    final itemTotals = <String, ItemSales>{};

    for (final order in paidOrders) {
      final method = order.paymentMethod ?? PaymentMethod.card;
      salesByMethod[method] = (salesByMethod[method] ?? 0) + order.total;
      for (final line in order.lines) {
        final existing = itemTotals[line.item.name];
        itemTotals[line.item.name] = ItemSales(
          name: line.item.name,
          quantity: (existing?.quantity ?? 0) + line.quantity,
          amount: (existing?.amount ?? 0) + line.total,
        );
      }
    }

    final topItems = itemTotals.values.toList()
      ..sort((left, right) => right.amount.compareTo(left.amount));

    return DailyReport(
      paidOrders: paidOrders,
      openOrders: openOrders,
      salesByMethod: salesByMethod,
      topItems: topItems,
    );
  }

  RestaurantOrder? occupiedOrderForTable(String table) {
    return unpaidOrders.cast<RestaurantOrder?>().firstWhere(
          (order) =>
              order?.type == OrderType.dineIn && order?.tableName == table,
          orElse: () => null,
        );
  }

  void login() {
    _route = AppRoute.hub;
    _activeOrderId = null;
    notifyListeners();
  }

  void logout() {
    _route = AppRoute.login;
    _activeOrderId = null;
    notifyListeners();
  }

  void openModule(AppRoute route) {
    _route = route;
    _activeOrderId = null;
    _managementSection = ManagementSection.categories;
    if (route == AppRoute.pointOfSale) {
      _workspace = AppWorkspace.floor;
    }
    notifyListeners();
  }

  void goToHub() {
    _route = AppRoute.hub;
    _activeOrderId = null;
    notifyListeners();
  }

  void selectManagementSection(ManagementSection section) {
    _managementSection = section;
    notifyListeners();
  }

  void selectWorkspace(AppWorkspace workspace) {
    _workspace = workspace;
    if (workspace != AppWorkspace.floor) {
      _activeOrderId = null;
    }
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void selectServer(String server) {
    _selectedServer = server;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  RestaurantOrder openTable(String table) {
    final existing = occupiedOrderForTable(table);
    if (existing != null) {
      return openOrder(existing);
    }

    final order = RestaurantOrder(
      id: _nextOrderId(),
      type: OrderType.dineIn,
      tableName: table,
      serverName: _selectedServer,
      lines: const [],
      status: OrderStatus.draft,
      createdAt: DateTime.now(),
    );
    database.saveOrder(order);
    return openOrder(order);
  }

  RestaurantOrder startTakeaway() {
    final order = RestaurantOrder(
      id: _nextOrderId(),
      type: OrderType.takeaway,
      customerLabel: 'Emporter ${_nextTakeawayNumber++}',
      serverName: _selectedServer,
      lines: const [],
      status: OrderStatus.draft,
      createdAt: DateTime.now(),
    );
    database.saveOrder(order);
    return openOrder(order);
  }

  RestaurantOrder startDelivery() {
    final order = RestaurantOrder(
      id: _nextOrderId(),
      type: OrderType.delivery,
      customerLabel: 'Livraison ${_nextDeliveryNumber++}',
      serverName: _selectedServer,
      lines: const [],
      status: OrderStatus.draft,
      createdAt: DateTime.now(),
    );
    database.saveOrder(order);
    return openOrder(order);
  }

  RestaurantOrder openOrder(RestaurantOrder order) {
    _activeOrderId = order.id;
    _workspace = AppWorkspace.floor;
    notifyListeners();
    return order;
  }

  void closeEditor() {
    _activeOrderId = null;
    _workspace = AppWorkspace.floor;
    notifyListeners();
  }

  void addItem(MenuItem item) {
    final order = activeOrder;
    if (order == null) {
      return;
    }
    final lines = List<OrderLine>.from(order.lines);
    final index = lines.indexWhere((line) => line.item.id == item.id);
    if (index == -1) {
      lines.add(OrderLine(item: item, quantity: 1));
    } else {
      lines[index] = lines[index].copyWith(quantity: lines[index].quantity + 1);
    }
    database.saveOrder(order.copyWith(lines: lines, status: OrderStatus.draft));
    notifyListeners();
  }

  void decreaseItem(OrderLine line) {
    final order = activeOrder;
    if (order == null) {
      return;
    }
    final lines = List<OrderLine>.from(order.lines);
    final index = lines.indexWhere((stored) => stored.item.id == line.item.id);
    if (index == -1) {
      return;
    }
    if (lines[index].quantity <= 1) {
      lines.removeAt(index);
    } else {
      lines[index] = lines[index].copyWith(quantity: lines[index].quantity - 1);
    }
    database.saveOrder(order.copyWith(lines: lines));
    notifyListeners();
  }

  void applyDiscount() {
    final order = activeOrder;
    if (order == null) {
      return;
    }
    final nextRate = order.discountRate == 0 ? 0.1 : 0.0;
    database.saveOrder(order.copyWith(discountRate: nextRate));
    notifyListeners();
  }

  void transferTable() {
    final order = activeOrder;
    if (order == null || order.type != OrderType.dineIn) {
      return;
    }
    final freeTable = tables.firstWhere(
      (table) => occupiedOrderForTable(table) == null,
      orElse: () => order.tableName ?? tables.first,
    );
    database.saveOrder(order.copyWith(tableName: freeTable));
    notifyListeners();
  }

  void increaseLastLine() {
    final order = activeOrder;
    if (order == null || order.lines.isEmpty) {
      return;
    }
    addItem(order.lines.last.item);
  }

  RestaurantOrder? sendActiveToKitchen() {
    final order = activeOrder;
    if (order == null || order.lines.isEmpty) {
      return null;
    }
    final updated = order.copyWith(status: OrderStatus.sentToKitchen);
    database.saveOrder(updated);
    _activeOrderId = null;
    _workspace = AppWorkspace.floor;
    notifyListeners();
    return updated;
  }

  RestaurantOrder markReady(RestaurantOrder order) {
    final updated = order.copyWith(status: OrderStatus.ready);
    database.saveOrder(updated);
    notifyListeners();
    return updated;
  }

  RestaurantOrder payOrder(
    RestaurantOrder order,
    PaymentMethod method,
    double amountPaid,
  ) {
    final paidAmount = amountPaid < order.total ? order.total : amountPaid;
    final updated = order.copyWith(
      status: OrderStatus.paid,
      paymentMethod: method,
      amountPaid: paidAmount,
      paidAt: DateTime.now(),
    );
    database.saveOrder(updated);
    if (_activeOrderId == order.id) {
      _activeOrderId = null;
    }
    _workspace = AppWorkspace.floor;
    notifyListeners();
    return updated;
  }

  String _nextOrderId() => 'ORD-${_nextOrderNumber++}';
}

class RestaurantApp extends StatefulWidget {
  const RestaurantApp({Key? key, this.controller}) : super(key: key);

  final RestaurantController? controller;

  @override
  State<RestaurantApp> createState() => _RestaurantAppState();
}

class _RestaurantAppState extends State<RestaurantApp> {
  late final RestaurantController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? RestaurantController();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Restaurant POS Pro',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xff111318),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xffff7a1a),
              secondary: Color(0xff22c55e),
              surface: Color(0xff1d2029),
              background: Color(0xff111318),
            ),
          ),
          home: _AppRouter(controller: controller),
        );
      },
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.route) {
      case AppRoute.login:
        return _LoginPage(controller: controller);
      case AppRoute.hub:
        return _ModuleHubPage(controller: controller);
      case AppRoute.pointOfSale:
        return _PosFullscreenShell(controller: controller);
      case AppRoute.menuStock:
        return _MenuStockShell(controller: controller);
      case AppRoute.reports:
        return _ReportsShell(controller: controller);
      case AppRoute.settings:
        return _SettingsShell(controller: controller);
    }
  }
}

class _LoginPage extends StatelessWidget {
  const _LoginPage({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 460,
          child: _Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xffff7a1a),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.restaurant_menu,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(height: 22),
                const Text('Connexion POS Pro',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Connectez-vous pour choisir votre module.',
                    style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 22),
                TextField(
                  key: const ValueKey<String>('login-user'),
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'Utilisateur',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey<String>('login-pin'),
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'PIN',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: const ValueKey<String>('login-submit'),
                  onPressed: controller.login,
                  icon: const Icon(Icons.login),
                  label: const Text('Entrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleHubPage extends StatelessWidget {
  const _ModuleHubPage({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: _Header(
                    title: 'Choisir un module',
                    subtitle:
                        'Point de vente plein ecran ou back-office avec sidebar locale',
                  ),
                ),
                OutlinedButton.icon(
                  key: const ValueKey<String>('logout'),
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 0.95,
                children: [
                  _ModuleTile(
                    keyName: 'module-pos',
                    title: 'Point de vente',
                    subtitle: 'Plan tables, commande, paiement',
                    icon: Icons.point_of_sale,
                    color: const Color(0xffff7a1a),
                    onTap: () => controller.openModule(AppRoute.pointOfSale),
                  ),
                  _ModuleTile(
                    keyName: 'module-menu-stock',
                    title: 'Menu et stock',
                    subtitle: 'Categories, produits, stock',
                    icon: Icons.inventory_2,
                    color: const Color(0xff22c55e),
                    onTap: () => controller.openModule(AppRoute.menuStock),
                  ),
                  _ModuleTile(
                    keyName: 'module-reports',
                    title: 'Rapports',
                    subtitle: 'Ventes, paiements, articles',
                    icon: Icons.query_stats,
                    color: const Color(0xff38bdf8),
                    onTap: () => controller.openModule(AppRoute.reports),
                  ),
                  _ModuleTile(
                    keyName: 'module-settings',
                    title: 'Parametrage',
                    subtitle: 'Restaurant, taxes, utilisateurs',
                    icon: Icons.settings,
                    color: const Color(0xffa855f7),
                    onTap: () => controller.openModule(AppRoute.settings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    Key? key,
    required this.keyName,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  final String keyName;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey<String>(keyName),
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xff1d2029),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const Spacer(),
            Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}

class _PosFullscreenShell extends StatelessWidget {
  const _PosFullscreenShell({Key? key, required this.controller})
      : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                OutlinedButton.icon(
                  key: const ValueKey<String>('back-hub-from-pos'),
                  onPressed: controller.goToHub,
                  icon: const Icon(Icons.apps),
                  label: const Text('Modules'),
                ),
                const Spacer(),
                Text(
                  controller.isEditingOrder
                      ? 'Point de vente - commande'
                      : controller.workspace == AppWorkspace.kitchen
                          ? 'Point de vente - cuisine'
                          : 'Point de vente - plan de salle',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  key: const ValueKey<String>('pos-kitchen'),
                  onPressed: () => controller.selectWorkspace(
                    controller.workspace == AppWorkspace.kitchen
                        ? AppWorkspace.floor
                        : AppWorkspace.kitchen,
                  ),
                  icon: const Icon(Icons.soup_kitchen),
                  label: Text(controller.workspace == AppWorkspace.kitchen
                      ? 'Plan'
                      : 'Cuisine'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: controller.isEditingOrder
                  ? _OrderEntryWorkspace(controller: controller)
                  : controller.workspace == AppWorkspace.kitchen
                      ? _KitchenWorkspace(controller: controller)
                      : _FloorWorkspace(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuStockShell extends StatelessWidget {
  const _MenuStockShell({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return _ModuleSidebarShell(
      controller: controller,
      title: 'Menu et stock',
      subtitle: 'Gestion des categories, produits, notes, modifiers et stock',
      sections: const [
        _ModuleSectionItem(
          section: ManagementSection.categories,
          label: 'Categories',
          icon: Icons.category,
        ),
        _ModuleSectionItem(
          section: ManagementSection.products,
          label: 'Produits',
          icon: Icons.restaurant_menu,
        ),
        _ModuleSectionItem(
          section: ManagementSection.notes,
          label: 'Notes',
          icon: Icons.sticky_note_2,
        ),
        _ModuleSectionItem(
          section: ManagementSection.modifiers,
          label: 'Modifiers',
          icon: Icons.tune,
        ),
        _ModuleSectionItem(
          section: ManagementSection.ingredients,
          label: 'Ingredients',
          icon: Icons.kitchen,
        ),
        _ModuleSectionItem(
          section: ManagementSection.stock,
          label: 'Stock',
          icon: Icons.inventory,
        ),
      ],
      body: _MenuStockBody(controller: controller),
    );
  }
}

class _ReportsShell extends StatelessWidget {
  const _ReportsShell({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return _ModuleSidebarShell(
      controller: controller,
      title: 'Rapports',
      subtitle: 'Suivi patron: ventes, paiements, articles et tickets ouverts',
      sections: const [
        _ModuleSectionItem(
          section: ManagementSection.categories,
          label: 'Dashboard',
          icon: Icons.dashboard,
        ),
        _ModuleSectionItem(
          section: ManagementSection.products,
          label: 'Ventes',
          icon: Icons.trending_up,
        ),
        _ModuleSectionItem(
          section: ManagementSection.stock,
          label: 'Paiements',
          icon: Icons.payments,
        ),
      ],
      body: _PatronWorkspace(controller: controller),
    );
  }
}

class _SettingsShell extends StatelessWidget {
  const _SettingsShell({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return _ModuleSidebarShell(
      controller: controller,
      title: 'Parametrage',
      subtitle: 'Configuration restaurant, taxes, imprimantes et utilisateurs',
      sections: const [
        _ModuleSectionItem(
          section: ManagementSection.categories,
          label: 'Restaurant',
          icon: Icons.store,
        ),
        _ModuleSectionItem(
          section: ManagementSection.products,
          label: 'Taxes',
          icon: Icons.percent,
        ),
        _ModuleSectionItem(
          section: ManagementSection.notes,
          label: 'Imprimantes',
          icon: Icons.print,
        ),
        _ModuleSectionItem(
          section: ManagementSection.modifiers,
          label: 'Utilisateurs',
          icon: Icons.group,
        ),
      ],
      body: _SettingsWorkspace(controller: controller),
    );
  }
}

class _ModuleSectionItem {
  const _ModuleSectionItem({
    required this.section,
    required this.label,
    required this.icon,
  });

  final ManagementSection section;
  final String label;
  final IconData icon;
}

class _ModuleSidebarShell extends StatelessWidget {
  const _ModuleSidebarShell({
    Key? key,
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.body,
  }) : super(key: key);

  final RestaurantController controller;
  final String title;
  final String subtitle;
  final List<_ModuleSectionItem> sections;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 246,
            padding: const EdgeInsets.all(18),
            color: const Color(0xff181a22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey<String>('back-hub-from-module'),
                  onPressed: controller.goToHub,
                  icon: const Icon(Icons.apps),
                  label: const Text('Modules'),
                ),
                const SizedBox(height: 22),
                Text(title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: sections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = sections[index];
                      final active =
                          controller.managementSection == item.section;
                      return InkWell(
                        key: ValueKey<String>(
                            'section-${item.label.toLowerCase()}'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            controller.selectManagementSection(item.section),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xffff7a1a)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: active
                                    ? const Color(0xffff7a1a)
                                    : Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Icon(item.icon),
                              const SizedBox(width: 10),
                              Expanded(child: Text(item.label)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuStockBody extends StatelessWidget {
  const _MenuStockBody({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.managementSection) {
      case ManagementSection.categories:
        return _ManagementPlaceholder(
          title: 'Categories',
          subtitle: 'Creer et organiser les familles du menu.',
          icon: Icons.category,
          children: controller.database.categories
              .map((category) => category.name)
              .toList(),
        );
      case ManagementSection.products:
        return _ManagementPlaceholder(
          title: 'Produits',
          subtitle: 'Prix, stations cuisine, disponibilite et tuiles.',
          icon: Icons.restaurant_menu,
          children: controller.database.menu.map((item) => item.name).toList(),
        );
      case ManagementSection.notes:
        return const _ManagementPlaceholder(
          title: 'Notes',
          subtitle: 'Notes cuisine rapides: sans sel, bien cuit, allergie.',
          icon: Icons.sticky_note_2,
          children: ['Sans piment', 'Sauce a part', 'Bien cuit'],
        );
      case ManagementSection.modifiers:
        return const _ManagementPlaceholder(
          title: 'Modifiers',
          subtitle: 'Options produit: taille, supplements et cuisson.',
          icon: Icons.tune,
          children: ['Taille', 'Supplement fromage', 'Cuisson'],
        );
      case ManagementSection.ingredients:
        return const _ManagementPlaceholder(
          title: 'Ingredients',
          subtitle: 'Fiches recettes et ingredients lies au stock.',
          icon: Icons.kitchen,
          children: ['Pain burger', 'Poulet', 'Menthe'],
        );
      case ManagementSection.stock:
        return const _ManagementPlaceholder(
          title: 'Stock',
          subtitle: 'Quantites disponibles, alertes et mouvements.',
          icon: Icons.inventory,
          children: ['Poulet: 18 kg', 'Orange: 42 kg', 'The: 8 kg'],
        );
      case ManagementSection.inventory:
        return const _ManagementPlaceholder(
          title: 'Inventaire',
          subtitle: 'Comptages et ecarts.',
          icon: Icons.fact_check,
          children: ['Inventaire matin', 'Inventaire soir'],
        );
      case ManagementSection.suppliers:
        return const _ManagementPlaceholder(
          title: 'Fournisseurs',
          subtitle: 'Contacts et achats.',
          icon: Icons.local_shipping,
          children: ['Primeur', 'Boucher', 'Boissons'],
        );
    }
  }
}

class _ManagementPlaceholder extends StatelessWidget {
  const _ManagementPlaceholder({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(title: title, subtitle: subtitle),
        const SizedBox(height: 18),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.5,
            children: children.map((label) {
              return _Card(
                child: Row(
                  children: [
                    Icon(icon, color: const Color(0xffff9f43), size: 32),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FloorWorkspace extends StatelessWidget {
  const _FloorWorkspace({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          title: 'Plan de salle',
          subtitle:
              'Tables, commandes en cours, emporter et livraison par defaut',
          trailing: _ServerSelector(controller: controller),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            FilledButton.icon(
              key: const ValueKey<String>('start-takeaway'),
              onPressed: controller.startTakeaway,
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Emporter'),
            ),
            const SizedBox(width: 12),
            FilledButton.tonalIcon(
              key: const ValueKey<String>('start-delivery'),
              onPressed: controller.startDelivery,
              icon: const Icon(Icons.delivery_dining),
              label: const Text('Livraison'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tables',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 14),
                      Expanded(
                        child: GridView.count(
                          key: const ValueKey<String>('table-plan'),
                          crossAxisCount: 4,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.2,
                          children: controller.tables.map((table) {
                            final order =
                                controller.occupiedOrderForTable(table);
                            return _TableTile(
                              table: table,
                              order: order,
                              onTap: () => controller.openTable(table),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              SizedBox(
                width: 390,
                child: _OpenOrdersPanel(controller: controller),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableTile extends StatelessWidget {
  const _TableTile({
    Key? key,
    required this.table,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  final String table;
  final RestaurantOrder? order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final occupied = order != null;
    return InkWell(
      key: ValueKey<String>('table-$table'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: occupied ? const Color(0xff3a2419) : const Color(0xff20242f),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: occupied ? const Color(0xffff7a1a) : Colors.white10,
            width: occupied ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  occupied ? Icons.event_seat : Icons.table_bar,
                  color: occupied ? const Color(0xffff9f43) : Colors.white54,
                ),
                const Spacer(),
                _StatusDot(occupied: occupied),
              ],
            ),
            const Spacer(),
            Text(table,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            if (occupied) ...[
              Text('Waiter ${order!.serverName}',
                  style: const TextStyle(color: Colors.white70)),
              Text(_money(order!.total),
                  style: const TextStyle(
                      color: Color(0xffff9f43), fontWeight: FontWeight.w800)),
            ] else
              const Text('Libre', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _OpenOrdersPanel extends StatelessWidget {
  const _OpenOrdersPanel({Key? key, required this.controller})
      : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    final orders = controller.unpaidOrders;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Commandes en cours',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Recuperer une order pas payee',
              style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 14),
          Expanded(
            child: orders.isEmpty
                ? const _EmptyState(
                    icon: Icons.receipt_long,
                    title: 'Aucune commande',
                    message: 'Les tickets impayes apparaitront ici.',
                  )
                : ListView.separated(
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return InkWell(
                        key: ValueKey<String>('open-order-${order.id}'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => controller.openOrder(order),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xff252936),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _OrderSummary(order: order)),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderEntryWorkspace extends StatelessWidget {
  const _OrderEntryWorkspace({Key? key, required this.controller})
      : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    final order = controller.activeOrder;
    if (order == null) {
      return _FloorWorkspace(controller: controller);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 190, child: _CategoryColumn(controller: controller)),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _Header(
                title: 'POS commande',
                subtitle: 'Categories, produits et ticket en 3 zones',
                trailing: _SearchBox(controller: controller),
              ),
              const SizedBox(height: 16),
              Expanded(child: _MenuGrid(controller: controller)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 430,
          child: _TicketPanel(controller: controller, order: order),
        ),
      ],
    );
  }
}

class _CategoryColumn extends StatelessWidget {
  const _CategoryColumn({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            key: const ValueKey<String>('back-floor'),
            onPressed: controller.closeEditor,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Plan'),
          ),
          const SizedBox(height: 16),
          const Text('Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: controller.database.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final category = controller.database.categories[index];
                final active = category.id == controller.selectedCategoryId;
                return InkWell(
                  key: ValueKey<String>('category-${category.id}'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => controller.selectCategory(category.id),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xffff7a1a)
                          : const Color(0xff252936),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(category.icon),
                        const SizedBox(width: 10),
                        Expanded(child: Text(category.name)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.filteredMenu;
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.search_off,
        title: 'Aucun article',
        message: 'Changez de categorie ou de recherche.',
      );
    }

    return GridView.builder(
      key: const ValueKey<String>('product-grid'),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          key: ValueKey<String>('item-${item.id}'),
          borderRadius: BorderRadius.circular(22),
          onTap: () => controller.addItem(item),
          child: _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [item.color, item.color.withOpacity(0.55)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(item.icon, size: 54, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(item.station,
                    style: const TextStyle(color: Colors.white54)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(_money(item.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xffff9f43))),
                    ),
                    const Icon(Icons.add_circle, color: Color(0xff22c55e)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TicketPanel extends StatelessWidget {
  const _TicketPanel({
    Key? key,
    required this.controller,
    required this.order,
  }) : super(key: key);

  final RestaurantController controller;
  final RestaurantOrder order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_orderTypeName(order.type).toUpperCase(),
                        style: const TextStyle(
                            color: Color(0xffff9f43),
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(order.title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900)),
                    Text(
                        'Waiter ${order.serverName} - ${_statusName(order.status)}',
                        style: const TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Retour plan',
                onPressed: controller.closeEditor,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 26),
          const _TicketHeader(),
          const Divider(color: Colors.white10),
          Expanded(
            child: order.lines.isEmpty
                ? const _EmptyState(
                    icon: Icons.receipt_long,
                    title: 'Ticket vide',
                    message: 'Touchez un produit pour ajouter.',
                  )
                : ListView.separated(
                    itemCount: order.lines.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final line = order.lines[index];
                      return _TicketLine(
                        line: line,
                        onMinus: () => controller.decreaseItem(line),
                        onPlus: () => controller.addItem(line.item),
                      );
                    },
                  ),
          ),
          const Divider(color: Colors.white10),
          _AmountRow(label: 'Sous-total', value: _money(order.subtotal)),
          if (order.discountRate > 0)
            _AmountRow(
                label: 'Remise 10%', value: '-${_money(order.discount)}'),
          _AmountRow(label: 'Taxe 10%', value: _money(order.tax)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffff7a1a),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('TOTAL',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
                Text(_money(order.total),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                keyName: 'send-kitchen',
                label: 'Cuisine',
                icon: Icons.print,
                onTap: controller.sendActiveToKitchen,
              ),
              _ActionButton(
                keyName: 'discount',
                label: 'Remise',
                icon: Icons.percent,
                onTap: controller.applyDiscount,
              ),
              _ActionButton(
                keyName: 'transfer',
                label: 'Transfer',
                icon: Icons.swap_horiz,
                onTap: controller.transferTable,
              ),
              _ActionButton(
                keyName: 'bill',
                label: 'Addition',
                icon: Icons.receipt,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Addition prete a imprimer')),
                ),
              ),
              _ActionButton(
                keyName: 'qty',
                label: 'Qte',
                icon: Icons.add,
                onTap: controller.increaseLastLine,
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            key: const ValueKey<String>('open-payment'),
            onPressed: order.lines.isEmpty
                ? null
                : () => _showPaymentDialog(context, controller, order),
            icon: const Icon(Icons.payments),
            label: const Text('Payment'),
          ),
        ],
      ),
    );
  }
}

class _TicketHeader extends StatelessWidget {
  const _TicketHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(flex: 4, child: Text('Article')),
        Expanded(child: Center(child: Text('Qte'))),
        Expanded(
            child:
                Align(alignment: Alignment.centerRight, child: Text('Prix'))),
        Expanded(
            child:
                Align(alignment: Alignment.centerRight, child: Text('Total'))),
      ],
    );
  }
}

class _TicketLine extends StatelessWidget {
  const _TicketLine({
    Key? key,
    required this.line,
    required this.onMinus,
    required this.onPlus,
  }) : super(key: key);

  final OrderLine line;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(line.item.name,
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: onMinus, child: const Icon(Icons.remove, size: 14)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text('${line.quantity}'),
              ),
              InkWell(onTap: onPlus, child: const Icon(Icons.add, size: 14)),
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(_money(line.item.price)),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(_money(line.total)),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    Key? key,
    required this.keyName,
    required this.label,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final String keyName;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      child: OutlinedButton.icon(
        key: ValueKey<String>(keyName),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _KitchenWorkspace extends StatelessWidget {
  const _KitchenWorkspace({Key? key, required this.controller})
      : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    final orders = controller.kitchenOrders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Header(
          title: 'Cuisine & KOT',
          subtitle: 'Tickets envoyes depuis les tables, emporter et livraison',
        ),
        const SizedBox(height: 18),
        Expanded(
          child: orders.isEmpty
              ? const _EmptyState(
                  icon: Icons.soup_kitchen,
                  title: 'Aucun ticket cuisine',
                  message: 'Les nouvelles commandes apparaitront ici.',
                )
              : GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.86,
                  children: orders
                      .map((order) =>
                          _KitchenTicket(controller: controller, order: order))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _KitchenTicket extends StatelessWidget {
  const _KitchenTicket({
    Key? key,
    required this.controller,
    required this.order,
  }) : super(key: key);

  final RestaurantController controller;
  final RestaurantOrder order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.id,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              _StatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text('${order.title} - ${order.serverName}',
              style: const TextStyle(color: Colors.white60)),
          const Divider(color: Colors.white10, height: 24),
          Expanded(
            child: ListView(
              children: order.lines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                          '${line.quantity}x ${line.item.name}  [${line.item.station}]'),
                    ),
                  )
                  .toList(),
            ),
          ),
          FilledButton.icon(
            key: ValueKey<String>('ready-${order.id}'),
            onPressed: order.status == OrderStatus.ready
                ? null
                : () => controller.markReady(order),
            icon: const Icon(Icons.done_all),
            label: const Text('Marquer pret'),
          ),
        ],
      ),
    );
  }
}

class _PatronWorkspace extends StatelessWidget {
  const _PatronWorkspace({Key? key, required this.controller})
      : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    final report = controller.report;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Header(
          title: 'Application patron',
          subtitle: 'Statistiques, rapports journaliers et commandes ouvertes',
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
                child: _MetricCard(
                    title: 'Chiffre du jour',
                    value: _money(report.grossSales),
                    icon: Icons.payments)),
            const SizedBox(width: 14),
            Expanded(
                child: _MetricCard(
                    title: 'Taxes',
                    value: _money(report.taxCollected),
                    icon: Icons.account_balance)),
            const SizedBox(width: 14),
            Expanded(
                child: _MetricCard(
                    title: 'Tickets payes',
                    value: '${report.paidOrders.length}',
                    icon: Icons.receipt)),
            const SizedBox(width: 14),
            Expanded(
                child: _MetricCard(
                    title: 'Commandes ouvertes',
                    value: '${report.openOrders.length}',
                    icon: Icons.pending_actions)),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _Card(
                  child: _ReportList(
                    title: 'Top articles',
                    empty: 'Aucune vente article.',
                    rows: report.topItems
                        .map((item) =>
                            '${item.name}  x${item.quantity}  ${_money(item.amount)}')
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _Card(
                  child: _ReportList(
                    title: 'Paiements',
                    empty: 'Aucun paiement.',
                    rows: report.salesByMethod.entries
                        .map((entry) =>
                            '${_paymentName(entry.key)}  ${_money(entry.value)}')
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _Card(
                  child: _ReportList(
                    title: 'Tickets ouverts',
                    empty: 'Tout est solde.',
                    rows: report.openOrders
                        .map((order) =>
                            '${order.id}  ${order.title}  ${_statusName(order.status)}')
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsWorkspace extends StatelessWidget {
  const _SettingsWorkspace({Key? key, required this.controller})
      : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Header(
          title: 'Reglages backend local',
          subtitle: 'BDD locale en memoire, prete pour SQLite/Supabase',
        ),
        const SizedBox(height: 18),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.35,
            children: const [
              _SettingsTile(
                icon: Icons.storage,
                title: 'Orders impayes',
                body:
                    'Les commandes ouvertes restent recuperables depuis le plan de salle.',
              ),
              _SettingsTile(
                icon: Icons.print,
                title: 'Cuisine',
                body:
                    'Le bouton Cuisine envoie le KOT puis revient au plan de tables.',
              ),
              _SettingsTile(
                icon: Icons.payments,
                title: 'Paiement MAD',
                body:
                    'Popup avec cash/carte/mobile, numpad, billets rapides et rendu.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({
    Key? key,
    required this.controller,
    required this.order,
  }) : super(key: key);

  final RestaurantController controller;
  final RestaurantOrder order;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  PaymentMethod method = PaymentMethod.cash;
  String amountText = '';

  double get paidAmount => double.tryParse(amountText) ?? 0;
  double get change => paidAmount - widget.order.total;

  @override
  void initState() {
    super.initState();
    amountText = '';
  }

  @override
  Widget build(BuildContext context) {
    final canPay = paidAmount >= widget.order.total;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Paiement ${widget.order.title}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    _AmountRow(
                        label: 'Total a payer',
                        value: _money(widget.order.total),
                        strong: true),
                    _AmountRow(
                        label: 'Montant donne',
                        value: _money(paidAmount),
                        strong: true),
                    _AmountRow(
                        label: 'Rendu',
                        value: _money(change < 0 ? 0 : change),
                        strong: true),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: PaymentMethod.values.map((entry) {
                        return ChoiceChip(
                          key: ValueKey<String>('dialog-method-${entry.name}'),
                          selected: method == entry,
                          label: Text(_paymentName(entry)),
                          onSelected: (_) {
                            setState(() {
                              method = entry;
                              if (entry != PaymentMethod.cash) {
                                amountText =
                                    widget.order.total.toStringAsFixed(2);
                              } else {
                                amountText = '';
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Billets rapides Maroc',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [20, 50, 100, 200].map((bill) {
                        return _BillButton(
                          value: bill,
                          onTap: () => setState(() {
                            amountText = (paidAmount + bill).toStringAsFixed(0);
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      key: const ValueKey<String>('confirm-payment'),
                      onPressed: canPay
                          ? () {
                              widget.controller
                                  .payOrder(widget.order, method, paidAmount);
                              Navigator.of(context).pop();
                            }
                          : null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Valider paiement et liberer table'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 260,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xff111318),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        amountText.isEmpty ? '0' : amountText,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Numpad(
                      onTap: (value) => setState(() {
                        if (value == 'C') {
                          amountText = '';
                        } else if (value == '<') {
                          if (amountText.isNotEmpty) {
                            amountText =
                                amountText.substring(0, amountText.length - 1);
                          }
                        } else if (value == '.') {
                          if (!amountText.contains('.')) {
                            amountText =
                                amountText.isEmpty ? '0.' : '$amountText.';
                          }
                        } else {
                          amountText =
                              amountText == '0' ? value : '$amountText$value';
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showPaymentDialog(
  BuildContext context,
  RestaurantController controller,
  RestaurantOrder order,
) {
  showDialog<void>(
    context: context,
    builder: (_) => _PaymentDialog(controller: controller, order: order),
  );
}

class _BillButton extends StatelessWidget {
  const _BillButton({
    Key? key,
    required this.value,
    required this.onTap,
  }) : super(key: key);

  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey<String>('bill-$value'),
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 126,
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff15803d), Color(0xff22c55e)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payments, size: 20),
            const SizedBox(width: 6),
            Text('$value MAD',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({Key? key, required this.onTap}) : super(key: key);

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const keys = ['7', '8', '9', '4', '5', '6', '1', '2', '3', 'C', '0', '<'];
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: keys.map((keyText) {
        return FilledButton.tonal(
          key: ValueKey<String>('numpad-$keyText'),
          onPressed: () => onTap(keyText),
          child: Text(keyText,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        );
      }).toList(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
    required this.title,
    required this.subtitle,
    this.trailing,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Colors.white60)),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 18),
          SizedBox(width: 360, child: trailing),
        ],
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey<String>('menu-search'),
      onChanged: controller.setSearch,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xff1d2029),
        hintText: 'Rechercher produit...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ServerSelector extends StatelessWidget {
  const _ServerSelector({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: controller.selectedServer,
      decoration: InputDecoration(
        filled: true,
        labelText: 'Waiter',
        fillColor: const Color(0xff1d2029),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      items: controller.servers
          .map((server) => DropdownMenuItem<String>(
                value: server,
                child: Text(server),
              ))
          .toList(),
      onChanged: (server) {
        if (server != null) {
          controller.selectServer(server);
        }
      },
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({Key? key, required this.order}) : super(key: key);

  final RestaurantOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(order.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            _StatusPill(status: order.status),
          ],
        ),
        const SizedBox(height: 6),
        Text(
            '${order.id} - ${_orderTypeName(order.type)} - ${order.serverName}',
            style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 6),
        Text('${order.itemCount} articles - ${_money(order.total)}',
            style: const TextStyle(
                color: Color(0xffff9f43), fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffff7a1a).withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xffff9f43)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  const _ReportList({
    Key? key,
    required this.title,
    required this.empty,
    required this.rows,
  }) : super(key: key);

  final String title;
  final String empty;
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        Expanded(
          child: rows.isEmpty
              ? Text(empty, style: const TextStyle(color: Colors.white54))
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white10),
                  itemBuilder: (context, index) => Text(rows[index]),
                ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.body,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xffff9f43), size: 34),
          const SizedBox(height: 18),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(color: Colors.white60, height: 1.35)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({Key? key, required this.status}) : super(key: key);

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusName(status),
        style: TextStyle(
            color: _statusColor(status),
            fontSize: 12,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({Key? key, required this.occupied}) : super(key: key);

  final bool occupied;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: occupied ? const Color(0xffef4444) : const Color(0xff22c55e),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    Key? key,
    required this.label,
    required this.value,
    this.strong = false,
  }) : super(key: key);

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: strong ? Colors.white : Colors.white60))),
          Text(
            value,
            style: TextStyle(
              fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
              fontSize: strong ? 20 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff1d2029),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white24, size: 42),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

String _money(double value) {
  return '${value.toStringAsFixed(2)} MAD';
}

String _orderTypeName(OrderType type) {
  switch (type) {
    case OrderType.dineIn:
      return 'A table';
    case OrderType.takeaway:
      return 'Emporter';
    case OrderType.delivery:
      return 'Livraison';
  }
}

String _paymentName(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'Cash';
    case PaymentMethod.card:
      return 'Carte';
    case PaymentMethod.mobile:
      return 'Mobile';
  }
}

String _statusName(OrderStatus status) {
  switch (status) {
    case OrderStatus.draft:
      return 'Brouillon';
    case OrderStatus.sentToKitchen:
      return 'Cuisine';
    case OrderStatus.ready:
      return 'Pret';
    case OrderStatus.paid:
      return 'Paye';
    case OrderStatus.voided:
      return 'Annule';
  }
}

Color _statusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.draft:
      return Colors.white54;
    case OrderStatus.sentToKitchen:
      return const Color(0xfffacc15);
    case OrderStatus.ready:
      return const Color(0xff22c55e);
    case OrderStatus.paid:
      return const Color(0xff38bdf8);
    case OrderStatus.voided:
      return const Color(0xffef4444);
  }
}

import 'package:flutter/material.dart';

enum AppWorkspace {
  pos,
  waiter,
  kitchen,
  payment,
  patron,
  settings,
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
    this.available = true,
  });

  final String id;
  final String categoryId;
  final String name;
  final String station;
  final double price;
  final Color color;
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
    required this.tableName,
    required this.serverName,
    required this.lines,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.paymentMethod,
  });

  final String id;
  final String tableName;
  final String serverName;
  final List<OrderLine> lines;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final PaymentMethod? paymentMethod;

  double get subtotal {
    return lines.fold<double>(0, (sum, line) => sum + line.total);
  }

  double get tax => subtotal * 0.1;

  double get total => subtotal + tax;

  int get itemCount {
    return lines.fold<int>(0, (sum, line) => sum + line.quantity);
  }

  RestaurantOrder copyWith({
    String? id,
    String? tableName,
    String? serverName,
    List<OrderLine>? lines,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? paidAt,
    PaymentMethod? paymentMethod,
  }) {
    return RestaurantOrder(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      serverName: serverName ?? this.serverName,
      lines: lines ?? this.lines,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
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

  int get covers {
    return paidOrders.fold<int>(0, (sum, order) => sum + order.itemCount);
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
          MenuCategory(
              id: 'burgers', name: 'Burgers', icon: Icons.lunch_dining),
          MenuCategory(id: 'mains', name: 'Plats', icon: Icons.restaurant),
          MenuCategory(id: 'drinks', name: 'Boissons', icon: Icons.local_bar),
          MenuCategory(id: 'desserts', name: 'Desserts', icon: Icons.icecream),
        ],
        menu = const [
          MenuItem(
            id: 'classic-burger',
            categoryId: 'burgers',
            name: 'Classic Burger',
            station: 'Grill',
            price: 8.90,
            color: Color(0xfff97316),
          ),
          MenuItem(
            id: 'double-cheese',
            categoryId: 'burgers',
            name: 'Double Cheese',
            station: 'Grill',
            price: 12.50,
            color: Color(0xfffb923c),
          ),
          MenuItem(
            id: 'veggie-bowl',
            categoryId: 'mains',
            name: 'Veggie Bowl',
            station: 'Cuisine',
            price: 11.20,
            color: Color(0xff22c55e),
          ),
          MenuItem(
            id: 'steak-frites',
            categoryId: 'mains',
            name: 'Steak Frites',
            station: 'Cuisine',
            price: 18.40,
            color: Color(0xffef4444),
          ),
          MenuItem(
            id: 'iced-tea',
            categoryId: 'drinks',
            name: 'Iced Tea',
            station: 'Bar',
            price: 3.80,
            color: Color(0xff38bdf8),
          ),
          MenuItem(
            id: 'lemonade',
            categoryId: 'drinks',
            name: 'Lemonade Maison',
            station: 'Bar',
            price: 4.20,
            color: Color(0xfffacc15),
          ),
          MenuItem(
            id: 'brownie',
            categoryId: 'desserts',
            name: 'Brownie',
            station: 'Patisserie',
            price: 6.00,
            color: Color(0xffa855f7),
          ),
          MenuItem(
            id: 'cheesecake',
            categoryId: 'desserts',
            name: 'Cheesecake',
            station: 'Patisserie',
            price: 6.70,
            color: Color(0xffec4899),
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
        tableName: 'Table 3',
        serverName: 'Mina',
        status: OrderStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        paidAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
        paymentMethod: PaymentMethod.card,
        lines: [
          OrderLine(item: menu[0], quantity: 2),
          OrderLine(item: menu[4], quantity: 2),
          OrderLine(item: menu[6], quantity: 1),
        ],
      ),
      RestaurantOrder(
        id: 'ORD-1002',
        tableName: 'Table 8',
        serverName: 'Leo',
        status: OrderStatus.ready,
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
        lines: [
          OrderLine(item: menu[3], quantity: 1, note: 'Cuisson saignant'),
          OrderLine(item: menu[5], quantity: 2),
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
    'Takeaway',
  ];
  final List<String> servers = const ['Mina', 'Leo', 'Sara', 'Nora'];

  AppWorkspace _workspace = AppWorkspace.pos;
  String _selectedCategoryId = '';
  String _selectedTable = 'Table 1';
  String _selectedServer = 'Mina';
  String _search = '';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  int _nextOrderNumber = 1003;
  final List<OrderLine> _draftLines = <OrderLine>[];

  AppWorkspace get workspace => _workspace;
  String get selectedCategoryId => _selectedCategoryId;
  String get selectedTable => _selectedTable;
  String get selectedServer => _selectedServer;
  String get search => _search;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  List<OrderLine> get draftLines => List<OrderLine>.unmodifiable(_draftLines);
  List<RestaurantOrder> get orders => database.orders;

  List<MenuItem> get filteredMenu {
    final normalizedSearch = _search.trim().toLowerCase();
    return database.menu.where((item) {
      final matchesCategory = item.categoryId == _selectedCategoryId;
      final matchesSearch = normalizedSearch.isEmpty ||
          item.name.toLowerCase().contains(normalizedSearch);
      return item.available && matchesCategory && matchesSearch;
    }).toList();
  }

  List<RestaurantOrder> get kitchenOrders {
    return orders
        .where((order) =>
            order.status == OrderStatus.sentToKitchen ||
            order.status == OrderStatus.ready)
        .toList();
  }

  List<RestaurantOrder> get payableOrders {
    return orders
        .where((order) =>
            order.status == OrderStatus.sentToKitchen ||
            order.status == OrderStatus.ready)
        .toList();
  }

  double get draftSubtotal {
    return _draftLines.fold<double>(0, (sum, line) => sum + line.total);
  }

  double get draftTax => draftSubtotal * 0.1;

  double get draftTotal => draftSubtotal + draftTax;

  DailyReport get report {
    final paidOrders =
        orders.where((order) => order.status == OrderStatus.paid).toList();
    final openOrders =
        orders.where((order) => order.status != OrderStatus.paid).toList();
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

  void selectWorkspace(AppWorkspace workspace) {
    _workspace = workspace;
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void selectTable(String table) {
    _selectedTable = table;
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

  void addItem(MenuItem item) {
    final index = _draftLines.indexWhere((line) => line.item.id == item.id);
    if (index == -1) {
      _draftLines.add(OrderLine(item: item, quantity: 1));
    } else {
      _draftLines[index] = _draftLines[index].copyWith(
        quantity: _draftLines[index].quantity + 1,
      );
    }
    notifyListeners();
  }

  void decreaseItem(OrderLine line) {
    final index = _draftLines
        .indexWhere((storedLine) => storedLine.item.id == line.item.id);
    if (index == -1) {
      return;
    }
    if (_draftLines[index].quantity <= 1) {
      _draftLines.removeAt(index);
    } else {
      _draftLines[index] = _draftLines[index].copyWith(
        quantity: _draftLines[index].quantity - 1,
      );
    }
    notifyListeners();
  }

  void clearDraft() {
    _draftLines.clear();
    notifyListeners();
  }

  RestaurantOrder? sendDraftToKitchen() {
    if (_draftLines.isEmpty) {
      return null;
    }

    final order = RestaurantOrder(
      id: 'ORD-${_nextOrderNumber++}',
      tableName: _selectedTable,
      serverName: _selectedServer,
      status: OrderStatus.sentToKitchen,
      createdAt: DateTime.now(),
      lines: List<OrderLine>.from(_draftLines),
    );
    database.saveOrder(order);
    _draftLines.clear();
    notifyListeners();
    return order;
  }

  RestaurantOrder? payDraftNow() {
    final order = sendDraftToKitchen();
    if (order == null) {
      return null;
    }
    return settleOrder(order, _selectedPaymentMethod);
  }

  RestaurantOrder markReady(RestaurantOrder order) {
    final updated = order.copyWith(status: OrderStatus.ready);
    database.saveOrder(updated);
    notifyListeners();
    return updated;
  }

  RestaurantOrder settleOrder(RestaurantOrder order, PaymentMethod method) {
    final updated = order.copyWith(
      status: OrderStatus.paid,
      paymentMethod: method,
      paidAt: DateTime.now(),
    );
    database.saveOrder(updated);
    notifyListeners();
    return updated;
  }
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
          home: _RestaurantShell(controller: controller),
        );
      },
    );
  }
}

class _RestaurantShell extends StatelessWidget {
  const _RestaurantShell({Key? key, required this.controller})
      : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _SideRail(controller: controller),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: _workspaceView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workspaceView() {
    switch (controller.workspace) {
      case AppWorkspace.pos:
        return _PosWorkspace(controller: controller);
      case AppWorkspace.waiter:
        return _WaiterWorkspace(controller: controller);
      case AppWorkspace.kitchen:
        return _KitchenWorkspace(controller: controller);
      case AppWorkspace.payment:
        return _PaymentWorkspace(controller: controller);
      case AppWorkspace.patron:
        return _PatronWorkspace(controller: controller);
      case AppWorkspace.settings:
        return _SettingsWorkspace(controller: controller);
    }
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      color: const Color(0xff181a22),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xffff7a1a),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.restaurant_menu, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'POS Pro',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              children: [
                _railItem(AppWorkspace.pos, Icons.point_of_sale, 'POS'),
                _railItem(AppWorkspace.waiter, Icons.room_service, 'Serveurs'),
                _railItem(AppWorkspace.kitchen, Icons.soup_kitchen, 'Cuisine'),
                _railItem(AppWorkspace.payment, Icons.payments, 'Paiement'),
                _railItem(AppWorkspace.patron, Icons.query_stats, 'Patron'),
                _railItem(AppWorkspace.settings, Icons.settings, 'Reglages'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _railItem(AppWorkspace workspace, IconData icon, String label) {
    final active = controller.workspace == workspace;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        key: ValueKey<String>('nav-${workspace.name}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.selectWorkspace(workspace),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xffff7a1a) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? const Color(0xffff7a1a) : Colors.white10,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosWorkspace extends StatelessWidget {
  const _PosWorkspace({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                title: 'Comptoir desktop POS',
                subtitle: 'Prise de commande rapide, envoi cuisine et paiement',
                trailing: _SearchBox(controller: controller),
              ),
              const SizedBox(height: 18),
              _CategoryTabs(controller: controller),
              const SizedBox(height: 18),
              Expanded(child: _MenuGrid(controller: controller)),
            ],
          ),
        ),
        const SizedBox(width: 18),
        SizedBox(
          width: 380,
          child: _OrderPanel(controller: controller),
        ),
      ],
    );
  }
}

class _WaiterWorkspace extends StatelessWidget {
  const _WaiterWorkspace({Key? key, required this.controller})
      : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          title: 'Application serveurs',
          subtitle: 'Selection table, serveur et commande simplifiee',
          trailing: _ServerSelector(controller: controller),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tables',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: controller.tables.map((table) {
                            final active = controller.selectedTable == table;
                            return OutlinedButton(
                              key: ValueKey<String>('table-$table'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: active
                                    ? const Color(0xffff7a1a)
                                    : const Color(0xff242733),
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                    color: active
                                        ? const Color(0xffff7a1a)
                                        : Colors.white12),
                              ),
                              onPressed: () => controller.selectTable(table),
                              child: Text(table),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Expanded(child: _MenuGrid(controller: controller)),
                    const SizedBox(height: 18),
                    _PrimaryActionBar(controller: controller),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              SizedBox(
                  width: 340,
                  child: _OrderPanel(controller: controller, compact: true)),
            ],
          ),
        ),
      ],
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
          title: 'Cuisine & impression KOT',
          subtitle: 'Tickets par station, pret a imprimer ou bump cuisine',
        ),
        const SizedBox(height: 18),
        Expanded(
          child: orders.isEmpty
              ? const _EmptyState(
                  icon: Icons.soup_kitchen,
                  title: 'Aucun ticket cuisine',
                  message:
                      'Les nouvelles commandes apparaitront ici apres envoi.',
                )
              : GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.86,
                  children: orders.map((order) {
                    return _KitchenTicket(controller: controller, order: order);
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _PaymentWorkspace extends StatelessWidget {
  const _PaymentWorkspace({Key? key, required this.controller})
      : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    final orders = controller.payableOrders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Header(
          title: 'Paiement & caisse',
          subtitle: 'Encaissement cash, carte ou mobile avec cloture ticket',
        ),
        const SizedBox(height: 18),
        _PaymentMethods(controller: controller),
        const SizedBox(height: 18),
        Expanded(
          child: orders.isEmpty
              ? const _EmptyState(
                  icon: Icons.payments,
                  title: 'Aucune note a encaisser',
                  message: 'Envoyez une commande ou marquez un ticket pret.',
                )
              : ListView.separated(
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _OrderSummary(order: order),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            key: ValueKey<String>('pay-${order.id}'),
                            onPressed: () => controller.settleOrder(
                              order,
                              controller.selectedPaymentMethod,
                            ),
                            icon: const Icon(Icons.receipt_long),
                            label: Text('Encaisser - ${_money(order.total)}'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
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
          subtitle: 'Statistiques, rapports journaliers et performance service',
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
                child: _MetricCard(
                    title: 'Chiffre du jour',
                    value: _money(report.grossSales),
                    icon: Icons.euro)),
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
                            '${order.id}  ${order.tableName}  ${_statusName(order.status)}')
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
          subtitle:
              'Premiere BDD locale en memoire, prete a remplacer par SQLite/Supabase',
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
                title: 'BDD locale',
                body:
                    'Repository local avec categories, menu, commandes et ventes seed.',
              ),
              _SettingsTile(
                icon: Icons.print,
                title: 'Imprimantes cuisine',
                body:
                    'File KOT structuree par station: Grill, Bar, Cuisine, Patisserie.',
              ),
              _SettingsTile(
                icon: Icons.security,
                title: 'Roles',
                body:
                    'Espaces separes pour POS, serveur, cuisine, caisse et patron.',
              ),
            ],
          ),
        ),
      ],
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
        hintText: 'Rechercher menu...',
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
        fillColor: const Color(0xff1d2029),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      items: controller.servers
          .map((server) => DropdownMenuItem<String>(
                value: server,
                child: Text('Serveur $server'),
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

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({Key? key, required this.controller}) : super(key: key);

  final RestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.database.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = controller.database.categories[index];
          final active = category.id == controller.selectedCategoryId;
          return ChoiceChip(
            key: ValueKey<String>('category-${category.id}'),
            selected: active,
            avatar: Icon(category.icon, size: 18),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: Text(category.name),
            ),
            onSelected: (_) => controller.selectCategory(category.id),
          );
        },
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
      key: const ValueKey<String>('menu-grid'),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
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
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [item.color, item.color.withOpacity(0.55)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Icon(Icons.restaurant,
                        color: Colors.white.withOpacity(0.9), size: 34),
                  ),
                ),
                const SizedBox(height: 12),
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(item.station,
                    style: const TextStyle(color: Colors.white54)),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(_money(item.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xffff9f43))),
                    ),
                    const SizedBox(width: 8),
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

class _OrderPanel extends StatelessWidget {
  const _OrderPanel({
    Key? key,
    required this.controller,
    this.compact = false,
  }) : super(key: key);

  final RestaurantController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Commande active',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    Text(
                        '${controller.selectedTable} - ${controller.selectedServer}',
                        style: const TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Vider',
                onPressed: controller.clearDraft,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: controller.draftLines.isEmpty
                ? const _EmptyState(
                    icon: Icons.shopping_basket,
                    title: 'Panier vide',
                    message: 'Touchez un article pour commencer.',
                  )
                : ListView.separated(
                    itemCount: controller.draftLines.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final line = controller.draftLines[index];
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(line.item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                Text(
                                    '${line.item.station} - ${_money(line.item.price)}',
                                    style:
                                        const TextStyle(color: Colors.white54)),
                              ],
                            ),
                          ),
                          IconButton(
                            key: ValueKey<String>('decrease-${line.item.id}'),
                            onPressed: () => controller.decreaseItem(line),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${line.quantity}'),
                          IconButton(
                            key: ValueKey<String>('increase-${line.item.id}'),
                            onPressed: () => controller.addItem(line.item),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const Divider(color: Colors.white10),
          _AmountRow(
              label: 'Sous-total', value: _money(controller.draftSubtotal)),
          _AmountRow(label: 'Taxe 10%', value: _money(controller.draftTax)),
          _AmountRow(
              label: 'Total',
              value: _money(controller.draftTotal),
              strong: true),
          const SizedBox(height: 14),
          _PaymentMethods(controller: controller, dense: true),
          const SizedBox(height: 14),
          _PrimaryActionBar(controller: controller, compact: compact),
        ],
      ),
    );
  }
}

class _PrimaryActionBar extends StatelessWidget {
  const _PrimaryActionBar({
    Key? key,
    required this.controller,
    this.compact = false,
  }) : super(key: key);

  final RestaurantController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hasLines = controller.draftLines.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const ValueKey<String>('send-kitchen'),
          onPressed: hasLines ? controller.sendDraftToKitchen : null,
          icon: const Icon(Icons.print),
          label: const Text('Envoyer cuisine'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey<String>('pay-now'),
          onPressed: hasLines ? controller.payDraftNow : null,
          icon: const Icon(Icons.payments),
          label: const Text('Paiement direct'),
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
          Text('${order.tableName} - ${order.serverName}',
              style: const TextStyle(color: Colors.white60)),
          const Divider(color: Colors.white10, height: 24),
          Expanded(
            child: ListView(
              children: order.lines
                  .map((line) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                            '${line.quantity}x ${line.item.name}  [${line.item.station}]'),
                      ))
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

class _PaymentMethods extends StatelessWidget {
  const _PaymentMethods({
    Key? key,
    required this.controller,
    this.dense = false,
  }) : super(key: key);

  final RestaurantController controller;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PaymentMethod.values.map((method) {
        final active = controller.selectedPaymentMethod == method;
        return ChoiceChip(
          key: ValueKey<String>('payment-${method.name}'),
          selected: active,
          label: Text(_paymentName(method)),
          onSelected: (_) => controller.selectPaymentMethod(method),
        );
      }).toList(),
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
            Text(order.id,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(width: 10),
            _StatusPill(status: order.status),
          ],
        ),
        const SizedBox(height: 6),
        Text(
            '${order.tableName} - ${order.serverName} - ${order.itemCount} articles',
            style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 6),
        Text(_money(order.total),
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
  return '${value.toStringAsFixed(2)} EUR';
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

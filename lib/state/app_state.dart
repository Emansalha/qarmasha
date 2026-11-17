import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config.dart';
import '../data/api_service.dart';
import '../data/demo_menu.dart';
import '../data/models.dart';

/// حالة التطبيق: المنيو، السلة، الحساب، والطلبات.
class AppState extends ChangeNotifier {
  AppState({ApiService? api}) : api = api ?? ApiService();

  final ApiService api;

  // المنيو
  bool loadingMenu = false;
  bool usingDemoMenu = true;
  String? menuError;
  String currency = AppConfig.currencySymbol;
  bool openNow = true;
  List<PromoBanner> banners = DemoMenu.banners;
  List<FoodCategory> categories = DemoMenu.categories;
  List<MenuItem> items = DemoMenu.items;

  // السلة
  final List<CartLine> cart = [];

  // الحساب
  AppUser? user;
  bool get isLoggedIn => user != null;

  // الطلبات
  List<PlacedOrder> orders = [];

  // المفضلة
  final Set<int> favorites = {};

  // تفضيلات الطلب (تختارها من الرئيسية وتُستخدم في الدفع)
  OrderType orderMode = OrderType.dineIn;
  int? tableNumber;
  String savedAddress = '';
  bool onboardingSeen = false;

  /// نهاية عرض اليوم (عدّاد تنازلي في الرئيسية).
  final DateTime flashDealEnds = () {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return end.difference(now).inMinutes < 30
        ? now.add(const Duration(hours: 3))
        : end;
  }();

  static const _kToken = 'customer_token';
  static const _kUser = 'customer_user';
  static const _kOrders = 'orders';
  static const _kFav = 'favorites';
  static const _kMode = 'order_mode';
  static const _kTable = 'table_number';
  static const _kAddress = 'saved_address';
  static const _kOnboarding = 'onboarding_seen';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kToken);
    final userJson = prefs.getString(_kUser);
    if (token != null && userJson != null) {
      api.customerToken = token;
      user = AppUser.fromJson(
          Map<String, dynamic>.from(jsonDecode(userJson) as Map));
    }
    final ordersJson = prefs.getString(_kOrders);
    if (ordersJson != null) {
      final list = jsonDecode(ordersJson) as List;
      orders = list
          .map((e) => PlacedOrder.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    favorites.addAll(
        (prefs.getStringList(_kFav) ?? const []).map(int.parse));
    orderMode = prefs.getString(_kMode) == 'delivery'
        ? OrderType.delivery
        : OrderType.dineIn;
    tableNumber = prefs.getInt(_kTable);
    savedAddress = prefs.getString(_kAddress) ?? '';
    onboardingSeen = prefs.getBool(_kOnboarding) ?? false;
    notifyListeners();
    await loadMenu();
  }

  /// يحمّل المنيو من دوري؛ وإن لم يتوفر يبقى المنيو الاحتياطي.
  Future<void> loadMenu() async {
    loadingMenu = true;
    menuError = null;
    notifyListeners();
    try {
      final home = await api.fetchHome();
      final menu = await api.fetchMenu();
      if (menu.isNotEmpty) {
        items = menu;
        categories = home.categories.isNotEmpty
            ? home.categories
            : await api.fetchCategories();
        if (home.banners.isNotEmpty) banners = home.banners;
        currency = home.currencySymbol;
        openNow = home.openNow;
        usingDemoMenu = false;
      }
    } on ApiException catch (e) {
      menuError = e.message;
    } catch (_) {
      menuError = 'تعذّر الاتصال بالخادم — نعرض المنيو التجريبي';
    } finally {
      loadingMenu = false;
      notifyListeners();
    }
  }

  List<MenuItem> get featured {
    final f = items.where((i) => i.isFeatured).toList();
    return f.isNotEmpty ? f : items.take(6).toList();
  }

  List<MenuItem> get popular {
    final sorted = [...items]
      ..sort((a, b) => b.ordersCount.compareTo(a.ordersCount));
    return sorted.take(8).toList();
  }

  List<MenuItem> itemsIn(int? categoryId) => categoryId == null
      ? items
      : items.where((i) => i.categoryId == categoryId).toList();

  List<MenuItem> search(String q) {
    final query = q.trim();
    if (query.isEmpty) return const [];
    return items
        .where((i) =>
            i.name.contains(query) ||
            i.description.contains(query) ||
            (i.categoryName ?? '').contains(query))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // تفضيلات الطلب
  // ---------------------------------------------------------------------------

  Future<void> setOrderMode(OrderType mode) async {
    orderMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, mode.apiValue);
  }

  Future<void> setTable(int? table) async {
    tableNumber = table;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (table == null) {
      await prefs.remove(_kTable);
    } else {
      await prefs.setInt(_kTable, table);
    }
  }

  Future<void> saveAddress(String address) async {
    savedAddress = address;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAddress, address);
  }

  Future<void> markOnboardingSeen() async {
    onboardingSeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarding, true);
  }

  // ---------------------------------------------------------------------------
  // المفضلة
  // ---------------------------------------------------------------------------

  bool isFavorite(MenuItem item) => favorites.contains(item.id);

  Future<void> toggleFavorite(MenuItem item) async {
    if (!favorites.remove(item.id)) favorites.add(item.id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _kFav, favorites.map((e) => e.toString()).toList());
  }

  // ---------------------------------------------------------------------------
  // السلة
  // ---------------------------------------------------------------------------

  int get cartCount => cart.fold(0, (s, l) => s + l.quantity);
  double get cartSubtotal => cart.fold(0.0, (s, l) => s + l.total);

  int quantityOf(MenuItem item) => cart
      .where((l) => l.item.id == item.id)
      .fold(0, (s, l) => s + l.quantity);

  /// يزيد مرة كل إضافة (لتحريك أيقونة السلة).
  int cartPulse = 0;

  void addToCart(
    MenuItem item, {
    int quantity = 1,
    String note = '',
    ItemOption? size,
    List<ItemOption> extras = const [],
    int? spice,
  }) {
    final line = CartLine(
      item: item,
      quantity: quantity,
      note: note,
      size: size,
      extras: extras,
      spice: spice,
    );
    cartPulse++;
    for (final l in cart) {
      if (l.key == line.key) {
        l.quantity += quantity;
        if (note.isNotEmpty) l.note = note;
        notifyListeners();
        return;
      }
    }
    cart.add(line);
    notifyListeners();
  }

  /// يُنقص صنفاً بسيطاً (بدون خيارات) — يُستخدم من بطاقات المنيو.
  void decrementItem(MenuItem item) {
    for (final l in cart.reversed) {
      if (l.item.id == item.id) {
        changeQuantity(l, -1);
        return;
      }
    }
  }

  void changeQuantity(CartLine line, int delta) {
    line.quantity += delta;
    if (line.quantity <= 0) cart.remove(line);
    notifyListeners();
  }

  void removeLine(CartLine line) {
    cart.remove(line);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // الحساب
  // ---------------------------------------------------------------------------

  Future<void> _saveSession(String token, AppUser u) async {
    user = u;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kUser, jsonEncode(u.toJson()));
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final r = await api.login(email: email, password: password);
    await _saveSession(r.token, r.user);
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final r = await api.register(
        name: name, email: email, phone: phone, password: password);
    await _saveSession(r.token, r.user);
  }

  /// متابعة كضيف (للطلب في الوضع التجريبي فقط).
  void continueAsGuest(String name, String phone) {
    user = AppUser(name: name, email: '', phone: phone);
    notifyListeners();
  }

  Future<void> logout() async {
    await api.logout();
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // الطلب
  // ---------------------------------------------------------------------------

  String _newOrderCode() {
    final r = Random();
    return 'Q${DateTime.now().millisecondsSinceEpoch % 100000}${r.nextInt(90) + 10}';
  }

  Future<PlacedOrder> checkout({
    required OrderType type,
    required String customerName,
    required String phone,
    int? tableNumber,
    String? address,
    String notes = '',
    String paymentMethod = 'cash',
  }) async {
    if (cart.isEmpty) throw ApiException('السلة فارغة');
    final code = _newOrderCode();
    final lines = cart
        .map((l) => CartLine(
              item: l.item,
              quantity: l.quantity,
              note: l.note,
              size: l.size,
              extras: l.extras,
              spice: l.spice,
            ))
        .toList();
    if (type == OrderType.delivery && address != null) {
      await saveAddress(address);
    }
    final fee = type == OrderType.delivery ? AppConfig.deliveryFee : 0.0;

    var bookingIds = <int>[];
    final canSendToApi =
        !usingDemoMenu && api.customerToken != null && lines.every((l) => l.item.fromApi);
    if (canSendToApi) {
      bookingIds = await api.placeOrder(
        orderCode: code,
        lines: lines,
        type: type,
        customerName: customerName,
        phone: phone,
        tableNumber: tableNumber,
        address: address,
        notes: notes,
        paymentMethod: paymentMethod,
      );
    } else {
      // وضع تجريبي: محاكاة إرسال الطلب
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }

    final order = PlacedOrder(
      code: code,
      createdAt: DateTime.now(),
      type: type,
      tableNumber: tableNumber,
      address: address,
      customerName: customerName,
      phone: phone,
      notes: notes,
      paymentMethod: paymentMethod,
      lines: lines,
      subtotal: lines.fold(0.0, (s, l) => s + l.total),
      deliveryFee: fee,
      bookingIds: bookingIds,
      status: canSendToApi ? OrderStatus.pending : OrderStatus.preparing,
    );
    orders.insert(0, order);
    cart.clear();
    await _saveOrders();
    notifyListeners();
    return order;
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kOrders, jsonEncode(orders.map((o) => o.toJson()).toList()));
  }

  /// يحدّث حالة الطلبات من دوري.
  Future<void> refreshOrders() async {
    try {
      final statuses = await api.fetchBookingStatuses();
      if (statuses.isEmpty) return;
      for (final o in orders) {
        if (o.bookingIds.isEmpty) continue;
        final s = statuses[o.bookingIds.first];
        if (s != null) o.status = OrderStatusX.fromApi(s, o.type);
      }
      await _saveOrders();
      notifyListeners();
    } catch (_) {}
  }
}

/// يوفّر [AppState] لكل الشاشات.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

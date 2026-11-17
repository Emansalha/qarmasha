import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/demo_menu.dart';
import 'data/models.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/item_details_screen.dart';
import 'screens/main_shell.dart';
import 'screens/orders_screen.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

/// وضع المعاينة (للويب فقط): يفتح شاشة معيّنة مباشرة عبر ?screen=...
/// يُستخدم لالتقاط صور الشاشات تلقائياً في GitHub Actions.
class PreviewLauncher extends StatefulWidget {
  const PreviewLauncher({super.key, required this.screen});
  final String screen;

  @override
  State<PreviewLauncher> createState() => _PreviewLauncherState();
}

class _PreviewLauncherState extends State<PreviewLauncher> {
  Widget? _child;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final state = AppScope.read(context);
    await state.init();
    final items = DemoMenu.items;
    MenuItem byId(int id) => items.firstWhere((i) => i.id == id);

    if (const ['cart', 'checkout', 'home_cart'].contains(widget.screen)) {
      state.addToCart(byId(201),
          quantity: 2,
          size: ItemOptions.sizes[1],
          extras: [ItemOptions.extras[0]],
          spice: 3);
      state.addToCart(byId(101));
      state.addToCart(byId(501), quantity: 2);
    }
    if (widget.screen == 'orders' || widget.screen == 'tracking') {
      state.addToCart(byId(301), quantity: 2);
      state.addToCart(byId(401));
      await state.checkout(
        type: OrderType.dineIn,
        customerName: 'ليان',
        phone: '0599111222',
        tableNumber: 7,
      );
    }

    Widget screen;
    switch (widget.screen) {
      case 'welcome':
        screen = const WelcomeScreen();
        break;
      case 'menu':
        screen = const MainShell(initialIndex: 1);
        break;
      case 'orders':
        screen = const MainShell(initialIndex: 2);
        break;
      case 'offers':
        screen = const MainShell(initialIndex: 3);
        break;
      case 'profile':
        screen = const MainShell(initialIndex: 4);
        break;
      case 'item':
        screen = ItemDetailsScreen(item: byId(201));
        break;
      case 'cart':
        screen = const CartScreen();
        break;
      case 'checkout':
        screen = const CheckoutScreen();
        break;
      case 'tracking':
        screen = OrderDetailsScreen(order: state.orders.first);
        break;
      default:
        screen = const MainShell();
    }
    if (mounted) setState(() => _child = screen);
  }

  @override
  Widget build(BuildContext context) {
    return _child ??
        const Scaffold(
          backgroundColor: AppColors.background,
          body: SizedBox.shrink(),
        );
  }
}

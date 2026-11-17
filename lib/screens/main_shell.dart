import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/animations.dart';
import '../widgets/common.dart';
import '../state/app_state.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'offers_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

/// الهيكل الرئيسي مع شريط التنقل السفلي (الرئيسية، المنيو، الطلبات، العروض، حسابي).
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  static void goTo(BuildContext context, int index) {
    context.findAncestorStateOfType<_MainShellState>()?.select(index);
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;
  int? _menuCategory;

  void select(int index, {int? category}) {
    setState(() {
      _index = index;
      if (index == 1) _menuCategory = category;
    });
  }

  void openMenu(int? categoryId) => select(1, category: categoryId);

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pages = [
      HomeScreen(onOpenMenu: openMenu),
      MenuScreen(
          key: ValueKey('menu-$_menuCategory'),
          initialCategory: _menuCategory),
      const OrdersScreen(),
      const OffersScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          AnimatedIndexedStack(index: _index, children: pages),
          // شريط السلة العائم
          Positioned(
            right: 16,
            left: 16,
            bottom: MediaQuery.of(context).padding.bottom + 92,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (c, a) => SlideTransition(
                position: Tween(begin: const Offset(0, 1.4), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: a, curve: Curves.easeOutBack)),
                child: c,
              ),
              child: state.cartCount == 0 || _index == 2
                  ? const SizedBox.shrink(key: ValueKey('empty'))
                  : _MiniCartBar(key: const ValueKey('bar'), state: state),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 72,
          margin: const EdgeInsets.fromLTRB(40, 0, 40, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                  selected: _index == 0,
                  onTap: () => select(0)),
              _NavItem(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'المنيو',
                  selected: _index == 1,
                  onTap: () => select(1)),
              _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'طلباتي',
                  selected: _index == 2,
                  dot: state.orders.any((o) =>
                      o.status == OrderStatus.pending ||
                      o.status == OrderStatus.preparing),
                  onTap: () => select(2)),
              _NavItem(
                  icon: Icons.local_offer_rounded,
                  label: 'العروض',
                  selected: _index == 3,
                  onTap: () => select(3)),
              _NavItem(
                  icon: Icons.person_rounded,
                  label: 'حسابي',
                  selected: _index == 4,
                  onTap: () => select(4)),
            ],
          ),
        ),
      ),
    );
  }
}

/// عنصر تنقل: دائرة برتقالية متوهجة حول التبويب النشط.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dot = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool dot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: label,
        child: Pressable(
          scale: 0.85,
          onTap: onTap,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  width: selected ? 52 : 44,
                  height: selected ? 52 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: selected ? AppColors.fire : null,
                    boxShadow: selected ? glowShadow() : null,
                  ),
                  child: BounceIn(
                    active: selected,
                    child: Icon(icon,
                        size: 24,
                        color: selected ? Colors.white : AppColors.muted),
                  ),
                ),
                if (dot)
                  Positioned(
                    top: 6,
                    left: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.surface2, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniCartBar extends StatelessWidget {
  const _MiniCartBar({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final thumbs = state.cart.take(3).toList();
    return Pressable(
      scale: 0.97,
      onTap: () => openCart(context),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(22),
          boxShadow: glowShadow(AppColors.ink),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42.0 + (thumbs.length - 1) * 22,
              height: 42,
              child: Stack(
                children: [
                  for (var i = 0; i < thumbs.length; i++)
                    Positioned(
                      right: i * 22.0,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.ink, width: 3),
                        ),
                        child: ClipOval(
                            child: NetImage(thumbs[i].item.imageUrl)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${state.cartCount} صنف في السلة',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  PulseOnChange(
                    trigger: state.cartPulse,
                    child: Text(money(state.cartSubtotal, state.currency),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.fire,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('عرض السلة',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

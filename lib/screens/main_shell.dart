import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/animations.dart';
import '../widgets/common.dart';
import '../widgets/icon3d.dart';
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
          height: 74,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: softShadow(),
          ),
          child: Row(
            children: [
              _NavItem(
                  image: 'home',
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                  selected: _index == 0,
                  onTap: () => select(0)),
              _NavItem(
                  image: 'menu',
                  icon: Icons.grid_view_rounded,
                  label: 'المنيو',
                  selected: _index == 1,
                  onTap: () => select(1)),
              Expanded(
                child: GestureDetector(
                  onTap: () => select(2),
                  child: Transform.translate(
                    offset: const Offset(0, -18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              BounceIn(
                                active: _index == 2,
                                child: const Icon3D('orders', size: 30),
                              ),
                              if (state.orders.isNotEmpty)
                                Positioned(
                                  top: 10,
                                  left: 12,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _NavItem(
                  image: 'offers',
                  icon: Icons.local_offer_outlined,
                  label: 'العروض',
                  selected: _index == 3,
                  onTap: () => select(3)),
              _NavItem(
                  image: 'profile',
                  icon: Icons.person_outline_rounded,
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.image,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String image;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        scale: 0.88,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.all(selected ? 6 : 4),
              decoration: BoxDecoration(
                color: selected ? AppColors.cream : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: BounceIn(
                active: selected,
                child: Icon3D(image, size: 24, grayscale: !selected),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: kFont,
                fontSize: 11,
                color: selected ? AppColors.primary : AppColors.muted,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
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

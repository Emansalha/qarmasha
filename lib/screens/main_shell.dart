import 'package:flutter/material.dart';

import '../core/theme.dart';
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
      body: IndexedStack(index: _index, children: pages),
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
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                  selected: _index == 0,
                  onTap: () => select(0)),
              _NavItem(
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
                              const Icon(Icons.receipt_long_rounded,
                                  color: Colors.white),
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
                  icon: Icons.local_offer_outlined,
                  label: 'العروض',
                  selected: _index == 3,
                  onTap: () => select(3)),
              _NavItem(
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
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

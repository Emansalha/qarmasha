import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/animations.dart';
import '../widgets/common.dart';
import 'search_screen.dart';

/// المنيو الكامل مع تصنيفات أفقية (مثل شاشة التصنيفات في سطر).
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, this.initialCategory});
  final int? initialCategory;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late int? _category = widget.initialCategory;
  String _sort = 'default';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    var items = [...state.itemsIn(_category)];
    switch (_sort) {
      case 'price_low':
        items.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;
      case 'price_high':
        items.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;
      case 'popular':
        items.sort((a, b) => b.ordersCount.compareTo(a.ordersCount));
        break;
    }
    String title = 'المنيو';
    for (final c in state.categories) {
      if (c.id == _category) title = c.name;
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900)),
                ),
                CircleIconButton(
                  icon: Icons.search_rounded,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SearchScreen())),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (v) => setState(() => _sort = v),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'default', child: Text('الترتيب الافتراضي')),
                    PopupMenuItem(value: 'popular', child: Text('الأكثر طلباً')),
                    PopupMenuItem(value: 'price_low', child: Text('السعر: من الأقل')),
                    PopupMenuItem(value: 'price_high', child: Text('السعر: من الأعلى')),
                  ],
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: softShadow(),
                    ),
                    child: const Icon(Icons.tune_rounded),
                  ),
                ),
                const SizedBox(width: 10),
                const CartButton(),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              children: [
                CategoryBubble(
                  label: 'الكل',
                  emoji: '🍽️',
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final c in state.categories)
                  CategoryBubble(
                    label: c.name,
                    emoji: c.emoji,
                    imageUrl: c.imageUrl,
                    selected: _category == c.id,
                    onTap: () => setState(() => _category = c.id),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: state.loadMenu,
              child: items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text('لا توجد أصناف في هذا التصنيف بعد',
                              style: TextStyle(color: AppColors.muted)),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 170),
                      itemCount: items.length,
                      itemBuilder: (_, i) =>
                          FadeSlideIn(index: i, child: FoodTile(item: items[i])),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

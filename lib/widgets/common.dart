import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../screens/cart_screen.dart';
import '../screens/item_details_screen.dart';
import '../state/app_state.dart';

/// صورة من الإنترنت مع حالة تحميل وخطأ لطيفة.
class NetImage extends StatelessWidget {
  const NetImage(this.url,
      {super.key, this.fit = BoxFit.cover, this.radius = 0, this.height, this.width});

  final String url;
  final BoxFit fit;
  final double radius;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    Widget placeholder(IconData icon) => Container(
          height: height,
          width: width,
          color: const Color(0xFFFBEDE3),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary.withValues(alpha: 0.35)),
        );
    final img = url.isEmpty
        ? placeholder(Icons.fastfood_rounded)
        : Image.network(
            url,
            fit: fit,
            height: height,
            width: width,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : placeholder(Icons.restaurant),
            errorBuilder: (context, error, stack) =>
                placeholder(Icons.fastfood_rounded),
          );
    return radius == 0
        ? img
        : ClipRRect(borderRadius: BorderRadius.circular(radius), child: img);
  }
}

/// زر دائري أبيض (إشعارات، سلة، رجوع...).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = 0,
    this.size = 46,
    this.color = AppColors.text,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badge;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: softShadow(),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          if (badge > 0)
            Positioned(
              top: -4,
              left: -4,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  '$badge',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// زر السلة مع عدد الأصناف.
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return CircleIconButton(
      icon: Icons.shopping_bag_outlined,
      badge: state.cartCount,
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CartScreen())),
    );
  }
}

/// شارة صغيرة ملونة (الأكثر مبيعاً، وفّر 15%...).
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.color = AppColors.primary});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// زر الإضافة الدائري الأحمر.
class AddButton extends StatelessWidget {
  const AddButton({super.key, required this.onTap, this.size = 34});
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// عداد الكمية (- 2 +).
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.compact = false,
  });

  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = compact ? 30.0 : 40.0;
    Widget btn(IconData icon, VoidCallback onTap, bool filled) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              color: filled ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: filled ? AppColors.primary : AppColors.border),
            ),
            child: Icon(icon,
                size: compact ? 16 : 20,
                color: filled ? Colors.white : AppColors.text),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.add, onPlus, true),
        SizedBox(
          width: compact ? 30 : 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: compact ? 14 : 18, fontWeight: FontWeight.bold),
          ),
        ),
        btn(Icons.remove, onMinus, false),
      ],
    );
  }
}

/// عنوان قسم مع "عرض الكل".
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text)),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Row(
                children: [
                  Text('عرض الكل',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_back,
                      color: AppColors.primary, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

void openItem(BuildContext context, MenuItem item) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)),
  );
}

void showAddedSnack(BuildContext context, MenuItem item) {
  final nav = Navigator.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.text,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Text('تمت إضافة «${item.name}» إلى السلة 🛒'),
      action: SnackBarAction(
        label: 'السلة',
        textColor: AppColors.accent,
        onPressed: () =>
            nav.push(MaterialPageRoute(builder: (_) => const CartScreen())),
      ),
    ));
}

/// بطاقة صنف عمودية (مثل بطاقات "الوجبات الشائعة" في التصميم).
class FoodCard extends StatelessWidget {
  const FoodCard({super.key, required this.item, this.width = 190});
  final MenuItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final fav = state.isFavorite(item);
    return GestureDetector(
      onTap: () => openItem(context, item),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: softShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                NetImage(item.imageUrl, height: 130, width: width, radius: 24),
                if (item.badge != null)
                  Positioned(top: 10, right: 10, child: Tag(item.badge!)),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () => state.toggleFavorite(item),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        fav ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.accent, size: 18),
                      Text(' ${item.rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 12)),
                      if (item.ordersCount > 0)
                        Text(' (${item.ordersCount}+)',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(money(item.finalPrice, state.currency),
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900)),
                            if (item.hasDiscount)
                              Text(money(item.price, state.currency),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                      decoration:
                                          TextDecoration.lineThrough)),
                          ],
                        ),
                      ),
                      AddButton(onTap: () {
                        state.addToCart(item);
                        showAddedSnack(context, item);
                      }),
                    ],
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

/// صف صنف أفقي (للمنيو والبحث).
class FoodTile extends StatelessWidget {
  const FoodTile({super.key, required this.item});
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final qty = state.quantityOf(item);
    return GestureDetector(
      onTap: () => openItem(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: softShadow(),
        ),
        child: Row(
          children: [
            NetImage(item.imageUrl, width: 100, height: 100, radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      if (item.badge != null) Tag(item.badge!),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(money(item.finalPrice, state.currency),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900)),
                      if (item.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(money(item.price, state.currency),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                                decoration: TextDecoration.lineThrough)),
                      ],
                      const Spacer(),
                      qty == 0
                          ? AddButton(onTap: () {
                              state.addToCart(item);
                              showAddedSnack(context, item);
                            })
                          : QtyStepper(
                              compact: true,
                              value: qty,
                              onPlus: () => state.addToCart(item),
                              onMinus: () {
                                final line = state.cart
                                    .firstWhere((l) => l.item.id == item.id);
                                state.changeQuantity(line, -1);
                              },
                            ),
                    ],
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

/// دائرة تصنيف (الكل، دجاج، برجر...).
class CategoryBubble extends StatelessWidget {
  const CategoryBubble({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.imageUrl,
    this.emoji,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? imageUrl;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 66,
              height: 66,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: softShadow(),
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? NetImage(imageUrl!)
                    : Container(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : const Color(0xFFFFF3EA),
                        alignment: Alignment.center,
                        child: Text(emoji ?? '🍗',
                            style: const TextStyle(fontSize: 28)),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

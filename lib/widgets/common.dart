import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../data/demo_menu.dart';
import '../screens/cart_screen.dart';
import '../screens/item_details_screen.dart';
import '../state/app_state.dart';
import 'animations.dart';
import 'icon3d.dart';

/// صورة (من assets أو الإنترنت) مع حالة تحميل وخطأ لطيفة.
class NetImage extends StatelessWidget {
  const NetImage(this.url,
      {super.key,
      this.fit = BoxFit.cover,
      this.radius = 0,
      this.height,
      this.width});

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
          color: AppColors.cream,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary.withValues(alpha: 0.35)),
        );
    final Widget img;
    if (url.isEmpty) {
      img = placeholder(Icons.fastfood_rounded);
    } else if (url.startsWith('assets/')) {
      img = Image.asset(
        url,
        fit: fit,
        height: height,
        width: width,
        errorBuilder: (context, error, stack) =>
            placeholder(Icons.fastfood_rounded),
      );
    } else {
      img = Image.network(
        url,
        fit: fit,
        height: height,
        width: width,
        frameBuilder: (context, child, frame, sync) => sync
            ? child
            : AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 350),
                child: child,
              ),
        errorBuilder: (context, error, stack) =>
            placeholder(Icons.fastfood_rounded),
      );
    }
    return radius == 0
        ? img
        : ClipRRect(borderRadius: BorderRadius.circular(radius), child: img);
  }
}

/// زر مربّع أبيض بزوايا ناعمة (إشعارات، سلة، رجوع...).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = 0,
    this.size = 46,
    this.color = AppColors.text,
    this.background = Colors.white,
    this.image,
  });

  /// اسم أيقونة 3D (من assets/icons) تُعرض بدل [icon].
  final String? image;
  final IconData icon;
  final VoidCallback onTap;
  final int badge;
  final double size;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(size * 0.36),
              boxShadow: softShadow(),
            ),
            alignment: Alignment.center,
            child: image != null
                ? Icon3D(image!, size: size * 0.56)
                : Icon(icon, color: color, size: 22),
          ),
          if (badge > 0)
            Positioned(
              top: -5,
              left: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: AppColors.fire,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                child: Text(
                  '$badge',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// زر السلة مع عدد الأصناف — ينبض عند كل إضافة.
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PulseOnChange(
      trigger: state.cartPulse,
      child: CircleIconButton(
        icon: Icons.shopping_bag_outlined,
        image: 'cart',
        badge: state.cartCount,
        onTap: () => openCart(context),
      ),
    );
  }
}

void openCart(BuildContext context) => Navigator.push(
    context, RevealRoute<void>(builder: (_) => const CartScreen()));

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
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// زر الإضافة الأحمر.
class AddButton extends StatelessWidget {
  const AddButton({super.key, required this.onTap, this.size = 36});
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.85,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppColors.fire,
          borderRadius: BorderRadius.circular(size * 0.38),
          boxShadow: glowShadow(),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

/// عداد الكمية (+ 2 -).
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
    final s = compact ? 30.0 : 42.0;
    Widget btn(IconData icon, VoidCallback onTap, bool filled) => Pressable(
          scale: 0.85,
          onTap: onTap,
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              gradient: filled ? AppColors.fire : null,
              color: filled ? null : Colors.white,
              borderRadius: BorderRadius.circular(s * 0.36),
              border: filled ? null : Border.all(color: AppColors.border),
            ),
            child: Icon(icon,
                size: compact ? 16 : 20,
                color: filled ? Colors.white : AppColors.text),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.add_rounded, onPlus, true),
        SizedBox(
          width: compact ? 30 : 42,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text(
              '$value',
              key: ValueKey(value),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: compact ? 14 : 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        btn(Icons.remove_rounded, onMinus, false),
      ],
    );
  }
}

/// عنوان قسم مع "عرض الكل".
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title,
      {super.key, this.subtitle, this.onSeeAll, this.icon});
  final String title;
  final String? subtitle;

  /// اسم أيقونة 3D بجانب العنوان.
  final String? icon;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon3D(icon!, size: 26),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text)),
                    ),
                  ],
                ),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          if (onSeeAll != null)
            Pressable(
              onTap: onSeeAll,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text('عرض الكل',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_back_rounded,
                        color: AppColors.primary, size: 16),
                  ],
                ),
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
    RevealRoute<void>(builder: (_) => ItemDetailsScreen(item: item)),
  );
}

void showAddedSnack(BuildContext context, MenuItem item) {
  HapticFeedback.mediumImpact();
  final nav = Navigator.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(
        children: [
          NetImage(item.imageUrl, width: 34, height: 34, radius: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Text('أُضيف «${item.name}» للسلة',
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      action: SnackBarAction(
        label: 'السلة',
        textColor: AppColors.accent,
        onPressed: () => nav
            .push(SmoothRoute<void>(builder: (_) => const CartScreen())),
      ),
    ));
}

/// إضافة سريعة: الأصناف التي لها خيارات تفتح صفحة التفاصيل.
void quickAdd(BuildContext context, MenuItem item) {
  final hasOptions = ItemOptions.sizesFor(item).isNotEmpty ||
      ItemOptions.extrasFor(item).isNotEmpty;
  if (hasOptions) {
    openItem(context, item);
  } else {
    AppScope.read(context).addToCart(item);
    showAddedSnack(context, item);
  }
}

/// بطاقة "الطبق العائم": صورة دائرية تخرج من أعلى البطاقة.
class FoodCard extends StatelessWidget {
  const FoodCard({super.key, required this.item, this.width = 180});
  final MenuItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final fav = state.isFavorite(item);
    final plate = width * 0.74;
    return Pressable(
      onTap: () => openItem(context, item),
      child: SizedBox(
        width: width,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // جسم البطاقة
            Positioned.fill(
              top: plate * 0.42,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: softShadow(),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الطبق العائم
                Center(
                  child: Container(
                    width: plate,
                    height: plate,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(child: NetImage(item.imageUrl)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon3D('star', size: 15),
                          Text(' ${item.rating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          const Icon3D('stopwatch', size: 14),
                          Text(' ${item.prepMinutes}د',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.hasDiscount)
                              Text(money(item.price, state.currency),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                      decoration: TextDecoration.lineThrough)),
                            Text(money(item.finalPrice, state.currency),
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                    // زر الإضافة في الزاوية
                    Pressable(
                      scale: 0.88,
                      onTap: () => quickAdd(context, item),
                      child: Container(
                        width: 48,
                        height: 46,
                        decoration: const BoxDecoration(
                          gradient: AppColors.fire,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(22),
                            bottomLeft: Radius.circular(28),
                          ),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (item.badge != null)
              Positioned(
                top: plate * 0.36,
                right: 6,
                child: Transform.rotate(angle: -0.08, child: Tag(item.badge!)),
              ),
            Positioned(
              top: plate * 0.47,
              left: 10,
              child: Pressable(
                scale: 0.8,
                onTap: () => state.toggleFavorite(item),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                  child: fav
                      ? const Icon3D('heart', size: 24, key: ValueKey(true))
                      : const Icon(Icons.favorite_border_rounded,
                          key: ValueKey(false),
                          size: 22,
                          color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// صف صنف أفقي (للمنيو والبحث والمفضلة).
class FoodTile extends StatelessWidget {
  const FoodTile({super.key, required this.item});
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final qty = state.quantityOf(item);
    final hasOptions = ItemOptions.sizesFor(item).isNotEmpty ||
        ItemOptions.extrasFor(item).isNotEmpty;
    return Pressable(
      scale: 0.98,
      onTap: () => openItem(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: softShadow(),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                NetImage(item.imageUrl, width: 108, height: 108, radius: 20),
                if (item.hasDiscount)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Tag('-${item.discountPercent}%'),
                  ),
              ],
            ),
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
                                fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                      if (item.badge != null && !item.hasDiscount)
                        Tag(item.badge!, color: AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12, height: 1.45)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon3D('star', size: 14),
                      Text(' ${item.rating.toStringAsFixed(1)}',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      const Icon3D('fire', size: 14),
                      Text(' ${item.ordersCount}+',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(money(item.finalPrice, state.currency),
                          style: const TextStyle(
                              fontSize: 17,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900)),
                      if (item.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(money(item.price, state.currency),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                                decoration: TextDecoration.lineThrough)),
                      ],
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (c, a) =>
                            ScaleTransition(scale: a, child: c),
                        child: qty == 0 || hasOptions
                            ? Row(
                                key: const ValueKey('add'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (qty > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Text('×$qty',
                                          style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w900)),
                                    ),
                                  AddButton(
                                      onTap: () => quickAdd(context, item)),
                                ],
                              )
                            : QtyStepper(
                                key: const ValueKey('stepper'),
                                compact: true,
                                value: qty,
                                onPlus: () => state.addToCart(item),
                                onMinus: () => state.decrementItem(item),
                              ),
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

/// تصنيف بصورة حقيقية دائرية.
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
    // دائماً صورة حقيقية: صورة التصنيف أو صورة مناسبة لاسمه
    final photo = (imageUrl != null && imageUrl!.isNotEmpty)
        ? imageUrl!
        : (label == 'الكل' ? img('family_box') : categoryPhoto(label));
    final icon = label == 'الكل' ? 'dinein' : categoryIcon(label);
    return Pressable(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: selected ? 74 : 68,
              height: selected ? 74 : 68,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? AppColors.fire : null,
                color: selected ? null : Colors.white,
                boxShadow: selected ? glowShadow() : softShadow(),
              ),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetImage(photo),
                    Align(
                      alignment: const Alignment(0.62, 0.62),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon3D(icon, size: 18),
                      ),
                    ),
                  ],
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
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// حالة فارغة أنيقة.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.action,
    this.onAction,
  });

  final String image;
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 6),
              boxShadow: softShadow(),
            ),
            child: image.startsWith('icon:')
                ? Container(
                    decoration: const BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon3D(image.substring(5), size: 90),
                  )
                : ClipOval(child: NetImage(image)),
          ),
          const SizedBox(height: 20),
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.5)),
          if (action != null) ...[
            const SizedBox(height: 22),
            SizedBox(
              width: 210,
              child: ElevatedButton(onPressed: onAction, child: Text(action!)),
            ),
          ],
        ],
      ),
    );
  }
}

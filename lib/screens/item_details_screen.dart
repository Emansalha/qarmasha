import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/animations.dart';
import '../widgets/common.dart';

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key, required this.item});
  final MenuItem item;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _qty = 1;
  int _image = 0;
  ItemOption? _size;
  final List<ItemOption> _extras = [];
  int? _spice;
  final _note = TextEditingController();
  final _scroll = ScrollController();

  late final List<ItemOption> _sizes = ItemOptions.sizesFor(widget.item);
  late final List<ItemOption> _extraOptions =
      ItemOptions.extrasFor(widget.item);
  late final bool _hasSpice = ItemOptions.hasSpice(widget.item);

  @override
  void initState() {
    super.initState();
    if (_sizes.isNotEmpty) _size = _sizes.first;
    if (_hasSpice) _spice = 2;
    _scroll.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _note.dispose();
    _scroll.dispose();
    super.dispose();
  }

  double get _unit =>
      widget.item.finalPrice +
      (_size?.price ?? 0) +
      _extras.fold(0.0, (s, e) => s + e.price);

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final item = widget.item;
    final images = item.allImages.isEmpty ? [''] : item.allImages;
    final fav = state.isFavorite(item);
    final offset = _scroll.hasClients ? _scroll.offset : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              // صورة بتأثير Parallax
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 360,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.translate(
                        offset: Offset(0, offset * 0.45),
                        child: Transform.scale(
                          scale: 1 + (offset < 0 ? -offset / 400 : 0),
                          child: PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (i) => setState(() => _image = i),
                            itemBuilder: (_, i) => NetImage(images[i]),
                          ),
                        ),
                      ),
                      const IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x66000000),
                                Colors.transparent,
                                Colors.transparent,
                                Color(0x33000000),
                              ],
                              stops: [0, 0.25, 0.7, 1],
                            ),
                          ),
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 44,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < images.length; i++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  width: i == _image ? 20 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: i == _image
                                        ? Colors.white
                                        : Colors.white54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -30, 0),
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 140),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(34)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.categoryName != null)
                                    Text(item.categoryName!,
                                        style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800)),
                                  Text(item.name,
                                      style: const TextStyle(
                                          fontSize: 26,
                                          height: 1.25,
                                          fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (item.hasDiscount)
                                  Text(money(item.price, state.currency),
                                      style: const TextStyle(
                                          color: AppColors.muted,
                                          decoration:
                                              TextDecoration.lineThrough)),
                                Text(money(item.finalPrice, state.currency),
                                    style: const TextStyle(
                                        fontSize: 24,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      FadeSlideIn(
                        index: 1,
                        child: Row(
                          children: [
                            _Info(
                                icon: Icons.star_rounded,
                                color: AppColors.accent,
                                text: item.rating.toStringAsFixed(1)),
                            _Info(
                                icon: Icons.timer_outlined,
                                color: AppColors.primary,
                                text: '${item.prepMinutes} دقيقة'),
                            if (item.ordersCount > 0)
                              _Info(
                                  icon: Icons.local_fire_department_rounded,
                                  color: AppColors.primary,
                                  text: '${item.ordersCount}+ طلب'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      FadeSlideIn(
                        index: 2,
                        child: Text(
                          item.description.isEmpty
                              ? 'وجبة طازجة تُحضَّر عند الطلب.'
                              : item.description,
                          style: const TextStyle(
                              color: AppColors.muted,
                              height: 1.75,
                              fontSize: 14),
                        ),
                      ),

                      // ===== الحجم =====
                      if (_sizes.isNotEmpty) ...[
                        const _Title('اختر الحجم'),
                        FadeSlideIn(
                          index: 3,
                          child: Row(
                            children: [
                              for (final s in _sizes)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: _SizeCard(
                                      option: s,
                                      selected: _size?.id == s.id,
                                      currency: state.currency,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _size = s);
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      // ===== درجة الحرارة =====
                      if (_hasSpice) ...[
                        const _Title('درجة الحرارة 🌶️'),
                        FadeSlideIn(
                          index: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: softShadow(),
                            ),
                            child: Row(
                              children: [
                                for (var i = 0;
                                    i < ItemOptions.spiceLevels.length;
                                    i++)
                                  Expanded(
                                    child: Pressable(
                                      scale: 0.9,
                                      onTap: () => setState(() => _spice = i),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _spice == i
                                              ? Color.lerp(
                                                  AppColors.accent,
                                                  AppColors.primary,
                                                  i / 4)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Text(
                                          ItemOptions.spiceLevels[i],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: _spice == i
                                                ? Colors.white
                                                : AppColors.muted,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // ===== الإضافات =====
                      if (_extraOptions.isNotEmpty) ...[
                        const _Title('أضف لمستك'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final e in _extraOptions)
                              _ExtraChip(
                                option: e,
                                selected: _extras.any((x) => x.id == e.id),
                                currency: state.currency,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    final i = _extras
                                        .indexWhere((x) => x.id == e.id);
                                    if (i >= 0) {
                                      _extras.removeAt(i);
                                    } else {
                                      _extras.add(e);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      ],

                      const _Title('ملاحظات للمطبخ'),
                      TextField(
                        controller: _note,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'مثال: بدون مخلل، صوص زيادة...',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // أزرار علوية عائمة
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            left: 16,
            child: Row(
              children: [
                CircleIconButton(
                  icon: Icons.arrow_forward_rounded,
                  size: 44,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                CircleIconButton(
                  icon: fav ? Icons.favorite_rounded : Icons.favorite_border,
                  color: AppColors.primary,
                  size: 44,
                  onTap: () => state.toggleFavorite(item),
                ),
                const SizedBox(width: 10),
                const CartButton(),
              ],
            ),
          ),
        ],
      ),

      // شريط الإضافة السفلي
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(26),
            boxShadow: glowShadow(AppColors.ink),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: QtyStepper(
                  value: _qty,
                  compact: true,
                  onPlus: () => setState(() => _qty++),
                  onMinus: () =>
                      setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Pressable(
                  onTap: () {
                    state.addToCart(
                      item,
                      quantity: _qty,
                      note: _note.text.trim(),
                      size: _size,
                      extras: List.of(_extras),
                      spice: _spice,
                    );
                    showAddedSnack(context, item);
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.fire,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text('أضف للسلة',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15)),
                        const SizedBox(width: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (c, a) =>
                              FadeTransition(opacity: a, child: c),
                          child: Text(
                            money(_unit * _qty, state.currency),
                            key: ValueKey(_unit * _qty),
                            style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w900,
                                fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(text,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
      );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: softShadow(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SizeCard extends StatelessWidget {
  const _SizeCard({
    required this.option,
    required this.selected,
    required this.currency,
    required this.onTap,
  });

  final ItemOption option;
  final bool selected;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.94,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.fire : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? glowShadow() : softShadow(),
        ),
        child: Column(
          children: [
            Icon(Icons.lunch_dining_rounded,
                size: option.id == 'regular'
                    ? 22
                    : (option.id == 'large' ? 28 : 34),
                color: selected ? Colors.white : AppColors.primary),
            const SizedBox(height: 4),
            Text(option.label,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: selected ? Colors.white : AppColors.text)),
            Text(option.price == 0 ? 'أساسي' : '+${money(option.price, currency)}',
                style: TextStyle(
                    fontSize: 11,
                    color: selected ? Colors.white70 : AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _ExtraChip extends StatelessWidget {
  const _ExtraChip({
    required this.option,
    required this.selected,
    required this.currency,
    required this.onTap,
  });

  final ItemOption option;
  final bool selected;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.93,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                key: ValueKey(selected),
                size: 18,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
            ),
            const SizedBox(width: 6),
            Text(option.label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Text('+${money(option.price, currency)}',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

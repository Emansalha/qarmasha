import 'dart:async';

import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../data/demo_menu.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/animations.dart';
import '../widgets/common.dart';
import '../widgets/flame_logo.dart';
import '../widgets/icon3d.dart';
import '../widgets/table_picker.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenMenu});

  /// يفتح تبويب المنيو على تصنيف معيّن (null = الكل).
  final void Function(int? categoryId) onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final firstName = (state.user?.name ?? '').split(' ').first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'صباح الخير'
        : (hour < 18 ? 'نهارك سعيد' : 'مساء الخير');
    final deal = state.items.where((i) => i.hasDiscount).toList()
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    final chef = state.featured.take(3).toList();
    var i = 0;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: state.loadMenu,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 170),
          children: [
            // ===== الشريط العلوي =====
            FadeSlideIn(
              index: i++,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: AppColors.fire,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: glowShadow(),
                      ),
                      child: CustomPaint(painter: FlamePainter()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstName.isEmpty
                                ? '$greeting 👋'
                                : '$greeting، $firstName 👋',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.muted),
                          ),
                          const Text(AppConfig.appName,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.text,
                                  height: 1.2)),
                        ],
                      ),
                    ),
                    CircleIconButton(
                      icon: Icons.notifications_none_rounded,
                      image: 'bell',
                      badge: state.orders
                          .where((o) =>
                              o.status == OrderStatus.preparing ||
                              o.status == OrderStatus.pending)
                          .length,
                      onTap: () => _showStatus(context, state),
                    ),
                    const SizedBox(width: 10),
                    const CartButton(),
                  ],
                ),
              ),
            ),

            // ===== العنوان الكبير =====
            FadeSlideIn(
              index: i++,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                        fontSize: 30,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text),
                    children: [
                      TextSpan(text: 'شو نفسك تاكل\n'),
                      TextSpan(
                          text: 'اليوم',
                          style: TextStyle(color: AppColors.primary)),
                      TextSpan(text: '؟ 🍗'),
                    ],
                  ),
                ),
              ),
            ),

            // ===== البحث =====
            FadeSlideIn(
              index: i++,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Pressable(
                        scale: 0.98,
                        onTap: () => Navigator.push(
                            context,
                            SmoothRoute<void>(
                                builder: (_) => const SearchScreen())),
                        child: Container(
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: softShadow(),
                          ),
                          child: const Row(
                            children: [
                              Icon3D('search', size: 24),
                              SizedBox(width: 10),
                              Text('ابحث عن وجبة، برجر، حلويات...',
                                  style: TextStyle(color: AppColors.muted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleIconButton(
                      icon: Icons.tune_rounded,
                      size: 54,
                      color: Colors.white,
                      background: AppColors.ink,
                      onTap: () => onOpenMenu(null),
                    ),
                  ],
                ),
              ),
            ),

            // ===== طريقة الطلب =====
            FadeSlideIn(
              index: i++,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: OrderModeSwitch(),
              ),
            ),

            if (state.loadingMenu)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: LinearProgressIndicator(
                    color: AppColors.primary, minHeight: 2),
              ),

            const SizedBox(height: 18),
            FadeSlideIn(
              index: i++,
              child: _BannerCarousel(
                banners: state.banners,
                onOrder: () => onOpenMenu(null),
              ),
            ),

            // ===== التصنيفات =====
            SectionHeader('التصنيفات',
                icon: 'menu', onSeeAll: () => onOpenMenu(null)),
            SizedBox(
              height: 112,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (var k = 0; k < state.categories.length; k++)
                    FadeSlideIn(
                      index: k,
                      horizontal: true,
                      child: CategoryBubble(
                        label: state.categories[k].name,
                        emoji: state.categories[k].emoji,
                        imageUrl: state.categories[k].imageUrl,
                        selected: false,
                        onTap: () => onOpenMenu(state.categories[k].id),
                      ),
                    ),
                ],
              ),
            ),

            // ===== عرض اليوم بعدّاد =====
            if (deal.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: _FlashDeal(item: deal.first, until: state.flashDealEnds),
              ),

            // ===== المميزة =====
            SectionHeader('الأطباق المميزة',
                subtitle: 'اختارها الشيف لك اليوم',
                icon: 'star',
                onSeeAll: () => onOpenMenu(null)),
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: state.featured.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, k) => FadeSlideIn(
                  index: k,
                  horizontal: true,
                  child: FoodCard(item: state.featured[k]),
                ),
              ),
            ),

            // ===== لوحة الشيف (Bento) =====
            if (chef.length == 3) ...[
              const SectionHeader('توصيات الشيف', icon: 'cook'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 260,
                  child: Row(
                    children: [
                      Expanded(child: _BentoTile(item: chef[0], big: true)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(child: _BentoTile(item: chef[1])),
                            const SizedBox(height: 12),
                            Expanded(child: _BentoTile(item: chef[2])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ===== الأكثر طلباً =====
            const SectionHeader('الأكثر طلباً',
                subtitle: 'الأصناف اللي الكل بيحبها', icon: 'fire'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  for (var k = 0; k < state.popular.take(5).length; k++)
                    FadeSlideIn(
                        index: k, child: FoodTile(item: state.popular[k])),
                ],
              ),
            ),

            if (state.usingDemoMenu)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  'ℹ️ يُعرض الآن المنيو التجريبي — سيظهر منيو المطعم الحقيقي فور تفعيل المتجر على دوري.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showStatus(BuildContext context, AppState state) {
    final active = state.orders
        .where((o) =>
            o.status == OrderStatus.preparing ||
            o.status == OrderStatus.pending)
        .toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الإشعارات',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              if (active.isEmpty)
                const Text('لا توجد طلبات نشطة حالياً 🍗',
                    style: TextStyle(color: AppColors.muted))
              else
                for (final o in active)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const IconTile('cook'),
                    title: Text('طلب #${o.code} — ${o.status.label}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(o.destination),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// مفتاح منزلق: داخل المطعم (طاولة) / توصيل — مع تفاصيل الوجهة.
class OrderModeSwitch extends StatelessWidget {
  const OrderModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final dineIn = state.orderMode == OrderType.dineIn;
    Widget option(OrderType type, String image, String label) {
      final sel = state.orderMode == type;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => state.setOrderMode(type),
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: sel ? 1.15 : 0.95,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Icon3D(image, size: 24, grayscale: !sel),
                ),
                const SizedBox(width: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: kFont,
                    fontWeight: FontWeight.w800,
                    color: sel ? Colors.white : AppColors.muted,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow(),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                alignment:
                    dineIn ? Alignment.centerRight : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppColors.fire,
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: glowShadow(),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  option(OrderType.dineIn, 'dinein', 'داخل المطعم'),
                  option(OrderType.delivery, 'delivery', 'توصيل'),
                ],
              ),
            ],
          ),
          Pressable(
            scale: 0.98,
            onTap: () async {
              if (dineIn) {
                final t =
                    await showTablePicker(context, current: state.tableNumber);
                if (t != null) state.setTable(t);
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Row(
                  key: ValueKey('$dineIn-${state.tableNumber}'),
                  children: [
                    Icon3D(dineIn ? 'table' : 'pin', size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dineIn
                            ? (state.tableNumber == null
                                ? 'اختر رقم طاولتك لنقدّم طلبك عليها'
                                : 'طاولتك: رقم ${state.tableNumber}')
                            : (state.savedAddress.isEmpty
                                ? 'التوصيل خلال 30-45 دقيقة • تُدخل العنوان عند الدفع'
                                : 'التوصيل إلى: ${state.savedAddress}'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text),
                      ),
                    ),
                    if (dineIn)
                      Text(state.tableNumber == null ? 'اختيار' : 'تغيير',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({required this.banners, required this.onOrder});
  final List<PromoBanner> banners;
  final VoidCallback onOrder;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

/// بطاقات إعلانات تنقلب بحركة ثلاثية الأبعاد (3D flip) وتدور تلقائياً بلا نهاية.
class _BannerCarouselState extends State<_BannerCarousel> {
  static const _loopBase = 1000;
  late final PageController _controller =
      PageController(viewportFraction: 0.86, initialPage: _loopBase * 3);
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      _controller.nextPage(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners =
        widget.banners.isEmpty ? DemoMenu.banners : widget.banners;
    final count = banners.length;
    return Column(
      children: [
        SizedBox(
          height: 205,
          child: Listener(
            // إيقاف التشغيل التلقائي أثناء السحب ثم استئنافه
            onPointerDown: (_) => _timer?.cancel(),
            onPointerUp: (_) => _startAutoPlay(),
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (p) => setState(() => _page = p % count),
              itemBuilder: (_, i) {
                final b = banners[i % count];
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double delta = 0;
                    if (_controller.hasClients &&
                        _controller.position.haveDimensions) {
                      delta = (_controller.page ?? i.toDouble()) - i;
                    } else {
                      delta = (_loopBase * 3 - i).toDouble();
                    }
                    delta = delta.clamp(-1.0, 1.0);
                    // دوران حول المحور الرأسي + تصغير بسيط = قلب البطاقة
                    final angle = delta * 1.15;
                    final scale = 1 - delta.abs() * 0.12;
                    final m = Matrix4.identity()
                      ..setEntry(3, 2, 0.0013)
                      ..rotateY(angle);
                    m.multiply(Matrix4.diagonal3Values(scale, scale, 1));
                    return Opacity(
                      opacity: (1 - delta.abs() * 0.45).clamp(0.0, 1.0),
                      child: Transform(
                        alignment: delta > 0
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        transform: m,
                        child: child,
                      ),
                    );
                  },
                  child: _BannerCard(banner: b, onOrder: widget.onOrder),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onOrder});
  final PromoBanner banner;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetImage(banner.imageUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Color(0xF27A0F0F), Color(0x00000000)],
                    stops: [0.35, 0.95],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(banner.tag,
                          style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 10,
                              fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 6),
                    Text(banner.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            height: 1.15,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(banner.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: onOrder,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 7, 16, 7),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('اطلب الآن',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.arrow_back,
                                  size: 14, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// بطاقة عرض اليوم: خلفية داكنة، صورة مائلة، وعدّاد تنازلي حي.
class _FlashDeal extends StatelessWidget {
  const _FlashDeal({required this.item, required this.until});
  final MenuItem item;
  final DateTime until;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Pressable(
      scale: 0.98,
      onTap: () => openItem(context, item),
      child: Container(
        height: 176,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(28),
          boxShadow: glowShadow(AppColors.ink),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // توهج ناري في الخلفية
            Positioned(
              left: -30,
              top: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.primary.withValues(alpha: 0.55),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Positioned(
              left: -6,
              top: -18,
              child: Transform.rotate(
                angle: -0.12,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipOval(child: NetImage(item.imageUrl)),
                ),
              ),
            ),
            Positioned(
              left: 112,
              top: 6,
              child: Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: glowShadow(AppColors.accent),
                ),
                child: Text('-${item.discountPercent}%',
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 15)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon3D('lightning', size: 18),
                            SizedBox(width: 4),
                            Text('عرض اليوم ينتهي خلال',
                                style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CountdownBoxes(
                          until: until,
                          boxColor: Colors.white,
                          textColor: AppColors.ink,
                        ),
                        const Spacer(),
                        Text(item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900)),
                        Row(
                          children: [
                            Text(money(item.finalPrice, state.currency),
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(width: 8),
                            Text(money(item.price, state.currency),
                                style: const TextStyle(
                                    color: Colors.white54,
                                    decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بلاطة صورة كبيرة بنص فوق تدرّج (تخطيط Bento).
class _BentoTile extends StatelessWidget {
  const _BentoTile({required this.item, this.big = false});
  final MenuItem item;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Pressable(
      onTap: () => openItem(context, item),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: softShadow(),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetImage(item.imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD1C1210)],
                  stops: [0.4, 1],
                ),
              ),
            ),
            Positioned(
              right: 12,
              left: 12,
              bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.name,
                            maxLines: 2,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: big ? 18 : 13,
                                height: 1.2,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text(money(item.finalPrice, state.currency),
                            style: TextStyle(
                                color: AppColors.accent,
                                fontSize: big ? 16 : 13,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  AddButton(
                      size: big ? 38 : 30, onTap: () => quickAdd(context, item)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

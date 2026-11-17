import 'dart:async';

import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../data/demo_menu.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/flame_logo.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenMenu});

  /// يفتح تبويب المنيو على تصنيف معيّن (null = الكل).
  final void Function(int? categoryId) onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final firstName = (state.user?.name ?? '').split(' ').first;
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: state.loadMenu,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // الشريط العلوي
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName.isEmpty
                              ? 'أهلاً يا عاشق القرمشة 👋'
                              : 'أهلاً $firstName 👋',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.muted),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            SizedBox(
                              width: 26,
                              height: 26,
                              child: CustomPaint(
                                painter: FlamePainter(
                                    outerColor: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(AppConfig.appName,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    height: 1.1)),
                          ],
                        ),
                        const Text(AppConfig.tagline,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  CircleIconButton(
                    icon: Icons.notifications_none_rounded,
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

            // البحث
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SearchScreen())),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: softShadow(),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search_rounded, color: AppColors.text),
                            SizedBox(width: 10),
                            Text('ابحث عن وجبتك المفضّلة...',
                                style: TextStyle(color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleIconButton(
                    icon: Icons.tune_rounded,
                    size: 52,
                    onTap: () => onOpenMenu(null),
                  ),
                ],
              ),
            ),

            if (state.loadingMenu)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(
                    color: AppColors.primary, minHeight: 2),
              ),

            const SizedBox(height: 18),
            _BannerCarousel(
              banners: state.banners,
              onOrder: () => onOpenMenu(null),
            ),

            // التصنيفات
            const SizedBox(height: 18),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  CategoryBubble(
                    label: 'الكل',
                    emoji: '🍽️',
                    selected: true,
                    onTap: () => onOpenMenu(null),
                  ),
                  for (final c in state.categories)
                    CategoryBubble(
                      label: c.name,
                      emoji: c.emoji,
                      imageUrl: c.imageUrl,
                      selected: false,
                      onTap: () => onOpenMenu(c.id),
                    ),
                ],
              ),
            ),

            SectionHeader('وجبات مميزة', onSeeAll: () => onOpenMenu(null)),
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: state.featured.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => FoodCard(item: state.featured[i]),
              ),
            ),

            // بطاقة العرض الحصري
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: _OfferStrip(onTap: () => onOpenMenu(null)),
            ),

            const SectionHeader('الأكثر طلباً 🔥'),
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: state.popular.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) =>
                    FoodCard(item: state.popular[i], width: 170),
              ),
            ),

            // طريقة الطلب
            const SectionHeader('كيف تحب تطلب؟'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _HowCard(
                      icon: Icons.table_restaurant_rounded,
                      title: 'داخل المطعم',
                      subtitle: 'اختر رقم طاولتك ونجهّز طلبك عليها',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _HowCard(
                      icon: Icons.delivery_dining_rounded,
                      title: 'توصيل',
                      subtitle: 'نوصل طلبك ساخن لباب البيت',
                    ),
                  ),
                ],
              ),
            ),
            if (state.usingDemoMenu)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'ℹ️ يُعرض الآن المنيو التجريبي — سيظهر منيو المطعم الحقيقي فور تفعيل المتجر على دوري.',
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
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الإشعارات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (active.isEmpty)
                const Text('لا توجد طلبات نشطة حالياً 🍗',
                    style: TextStyle(color: AppColors.muted))
              else
                for (final o in active)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEDE6),
                      child: Icon(Icons.local_fire_department,
                          color: AppColors.primary),
                    ),
                    title: Text('طلب #${o.code} — ${o.status.label}'),
                    subtitle: Text(o.destination),
                  ),
            ],
          ),
        ),
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

class _OfferStrip extends StatelessWidget {
  const _OfferStrip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE9DA), Color(0xFFFFF6EE)],
          ),
          boxShadow: softShadow(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('عرض حصري',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const Text('خصم حتى 30%',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900)),
                    const Text('على الوجبات المختارة',
                        style:
                            TextStyle(color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('اطلب الآن',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  NetImage(img('burger_fries'), width: 150, height: 130),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('30%\nخصم',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.1,
                              fontWeight: FontWeight.w900)),
                    ),
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

class _HowCard extends StatelessWidget {
  const _HowCard(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFEDE6),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}

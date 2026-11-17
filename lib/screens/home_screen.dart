import 'dart:async';

import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../data/demo_menu.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
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
                            const Text('🔥 ', style: TextStyle(fontSize: 22)),
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

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients || widget.banners.length < 2) return;
      final next = (_page + 1) % widget.banners.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
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
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (_, i) {
              final b = banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetImage(b.imageUrl),
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
                            Text(b.tag,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(b.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    height: 1.15,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text(b.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: widget.onOrder,
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
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 20 : 7,
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
                  NetImage(pexels(2271107, w: 600), width: 150, height: 130),
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

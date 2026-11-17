import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/animations.dart';
import '../widgets/common.dart';
import '../widgets/icon3d.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: state.refreshOrders,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 170),
          children: [
            const Text('طلباتي',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            if (state.orders.isEmpty)
              const EmptyState(
                image: 'icon:orders',
                title: 'لا توجد طلبات بعد',
                subtitle: 'اطلب وجبتك الأولى وتابعها من هنا خطوة بخطوة',
              )
            else
              for (var k = 0; k < state.orders.length; k++)
              FadeSlideIn(index: k, child: _OrderCard(order: state.orders[k])),
          ],
        ),
      ),
    );
  }
}

Color statusColor(OrderStatus s) => switch (s) {
      OrderStatus.pending => AppColors.accent,
      OrderStatus.preparing || OrderStatus.onTheWay => AppColors.primary,
      OrderStatus.served || OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.muted,
    };

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final first = order.lines.isNotEmpty ? order.lines.first.item : null;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SmoothRoute<void>(builder: (_) => OrderDetailsScreen(order: order)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: softShadow(),
        ),
        child: Row(
          children: [
            NetImage(first?.imageUrl ?? '', width: 70, height: 70, radius: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('#${order.code}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Tag(order.status.label,
                          color: statusColor(order.status)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon3D(
                          order.type == OrderType.dineIn ? 'table' : 'delivery',
                          size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(order.destination,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            '${order.lines.fold<int>(0, (s, l) => s + l.quantity)} صنف • ${money(order.total, state.currency)}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      if (order.status != OrderStatus.cancelled &&
                          order.remaining > Duration.zero)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                              'يصل خلال ${order.remaining.inMinutes + 1} د',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900)),
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

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});
  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final dineIn = order.type == OrderType.dineIn;
    final steps = dineIn
        ? const ['تم استلام الطلب', 'قيد التحضير', 'تم التقديم على الطاولة']
        : const ['تم استلام الطلب', 'قيد التحضير', 'في الطريق', 'تم التوصيل'];
    final int current = switch (order.status) {
      OrderStatus.pending => 0,
      OrderStatus.preparing => 1,
      OrderStatus.onTheWay => 2,
      OrderStatus.served || OrderStatus.delivered => steps.length - 1,
      OrderStatus.cancelled => -1,
    };

    return Scaffold(
      appBar: AppBar(title: Text('طلب #${order.code}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (current >= 0 && current < steps.length - 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EtaRing(order: order),
            ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: softShadow(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconTile(dineIn ? 'dinein' : 'delivery', size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.type.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(order.destination,
                              style: const TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (current < 0)
                  const Text('تم إلغاء هذا الطلب',
                      style: TextStyle(color: AppColors.muted))
                else
                  for (var i = 0; i < steps.length; i++)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Icon(
                              i <= current
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: i <= current
                                  ? AppColors.success
                                  : AppColors.border,
                            ),
                            if (i < steps.length - 1)
                              Container(
                                width: 2,
                                height: 22,
                                color: i < current
                                    ? AppColors.success
                                    : AppColors.border,
                              ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(steps[i],
                              style: TextStyle(
                                  fontWeight: i == current
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: i <= current
                                      ? AppColors.text
                                      : AppColors.muted)),
                        ),
                      ],
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: softShadow(),
            ),
            child: Column(
              children: [
                for (final l in order.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        NetImage(l.item.imageUrl,
                            width: 46, height: 46, radius: 12),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('${l.quantity}× ${l.item.name}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Text(money(l.total, state.currency)),
                      ],
                    ),
                  ),
                const Divider(),
                _row('المجموع الفرعي', money(order.subtotal, state.currency)),
                _row(
                    'التوصيل',
                    order.deliveryFee == 0
                        ? 'مجاناً'
                        : money(order.deliveryFee, state.currency)),
                _row('الإجمالي', money(order.total, state.currency),
                    bold: true),
                _row('الدفع',
                    order.paymentMethod == 'cash' ? 'نقداً' : 'بطاقة'),
                if (order.notes.isNotEmpty) _row('ملاحظات', order.notes),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: () {
              for (final l in order.lines) {
                final match = state.items.where((i) => i.id == l.item.id);
                state.addToCart(match.isNotEmpty ? match.first : l.item,
                    quantity: l.quantity, note: l.note);
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('تمت إضافة نفس الطلب إلى السلة 🛒'),
              ));
            },
            icon: const Icon(Icons.replay),
            label: const Text('اطلبه مرة ثانية',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _row(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(a, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(b,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
                      color: bold ? AppColors.primary : AppColors.text)),
            ),
          ],
        ),
      );
}

/// حلقة متحركة تعرض الوقت المتبقي التقريبي لتجهيز/توصيل الطلب.
class EtaRing extends StatefulWidget {
  const EtaRing({super.key, required this.order});
  final PlacedOrder order;

  @override
  State<EtaRing> createState() => _EtaRingState();
}

class _EtaRingState extends State<EtaRing> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
      vsync: this, duration: const Duration(seconds: 3))
    ..repeat();
  Timer? _timer;

  int get _totalMinutes => widget.order.etaMinutes;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed =
        DateTime.now().difference(widget.order.createdAt).inSeconds / 60.0;
    final progress = (elapsed / _totalMinutes).clamp(0.03, 0.97);
    final left = math.max(1, (_totalMinutes - elapsed).ceil());
    final dineIn = widget.order.type == OrderType.dineIn;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: glowShadow(AppColors.ink),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => AnimatedBuilder(
                animation: _spin,
                builder: (context, _) => CustomPaint(
                  painter: _RingPainter(value, _spin.value),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$left',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                height: 1,
                                fontWeight: FontWeight.w900)),
                        const Text('دقيقة',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dineIn ? 'طلبك على النار 🔥' : 'طلبك قيد التجهيز 🛵',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  dineIn
                      ? 'سيصل طلبك إلى الطاولة رقم ${widget.order.tableNumber} خلال دقائق.'
                      : 'الوقت المتوقع للوصول إلى عنوانك.',
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.spin);
  final double progress;
  final double spin;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..color = Colors.white12);
    final sweep = math.pi * 2 * progress;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [AppColors.accent, AppColors.primary, AppColors.accent],
        ).createShader(rect),
    );
    // شرارة تدور على طرف الحلقة
    final a = -math.pi / 2 + sweep;
    final tip = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
    final glow = 6 + 3 * math.sin(spin * math.pi * 2);
    canvas.drawCircle(
        tip,
        glow + 4,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(tip, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.spin != spin;
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/animations.dart';
import '../widgets/icon3d.dart';
import 'orders_screen.dart';

/// شاشة تأكيد الطلب: «طلبك يصلك خلال X دقيقة» مع عدّاد تنازلي حي
/// ووقت الوصول المتوقع.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});
  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final dineIn = order.type == OrderType.dineIn;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          children: [
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3CC37A), AppColors.success],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: glowShadow(AppColors.success),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 60),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const FadeSlideIn(
              index: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('تم تأكيد طلبك!',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                  SizedBox(width: 8),
                  Icon3D('party', size: 34),
                ],
              ),
            ),
            const SizedBox(height: 6),
            FadeSlideIn(
              index: 2,
              child: Text(
                dineIn
                    ? 'المطبخ بدأ يجهّز طلبك الآن 👨‍🍳'
                    : 'المطبخ بدأ يجهّز طلبك وسيخرج مع المندوب فور جاهزيته 🛵',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.6),
              ),
            ),
            const SizedBox(height: 22),

            // ===== بطاقة الوقت المتبقي =====
            FadeSlideIn(index: 3, child: _EtaCountdownCard(order: order)),

            const SizedBox(height: 16),
            FadeSlideIn(
              index: 4,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    _row('رقم الطلب', '#${order.code}'),
                    _row('نوع الطلب', order.type.label),
                    _row(dineIn ? 'الطاولة' : 'العنوان', order.destination),
                    _row('الإجمالي', money(order.total, state.currency),
                        highlight: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                SmoothRoute<void>(
                    builder: (_) => OrderDetailsScreen(order: order)),
              ),
              child: const Text('تتبّع الطلب مباشرة'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة للرئيسية',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String a, String b, {bool highlight = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(b,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: highlight ? AppColors.primary : AppColors.text)),
            ),
          ],
        ),
      );
}

/// بطاقة كبيرة: «يصلك طلبك خلال» + عدّاد دقائق:ثواني + وقت الوصول + شريط تقدّم.
class _EtaCountdownCard extends StatefulWidget {
  const _EtaCountdownCard({required this.order});
  final PlacedOrder order;

  @override
  State<_EtaCountdownCard> createState() => _EtaCountdownCardState();
}

class _EtaCountdownCardState extends State<_EtaCountdownCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final dineIn = o.type == OrderType.dineIn;
    final left = o.remaining;
    final arrived = left == Duration.zero;
    final total = o.etaMinutes * 60;
    final progress =
        total == 0 ? 1.0 : (1 - left.inSeconds / total).clamp(0.0, 1.0);
    String two(int v) => v.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF3A2116), AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: glowShadow(AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon3D(dineIn ? 'dinein' : 'delivery', size: 30),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  arrived
                      ? (dineIn
                          ? 'طلبك في طريقه لطاولتك الآن!'
                          : 'المندوب على وشك الوصول!')
                      : (dineIn
                          ? 'يصل طلبك إلى الطاولة رقم ${o.tableNumber} خلال'
                          : 'يصلك طلبك خلال'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!arrived)
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${two(left.inMinutes)}:${two(left.inSeconds % 60)}',
                style: const TextStyle(
                  fontSize: 56,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            )
          else
            const BounceIn(active: true, child: Icon3D('dinein', size: 60)),
          const SizedBox(height: 4),
          Text(
            arrived ? 'بالهناء والشفاء 😋' : 'دقيقة : ثانية',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: AppColors.primary,
              backgroundColor: AppColors.surface2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon3D('stopwatch', size: 22),
              const SizedBox(width: 6),
              Text('الوقت المتوقع: ${o.etaMinutes} دقيقة',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const Spacer(),
              const Icon(Icons.schedule_rounded,
                  size: 16, color: AppColors.muted),
              const SizedBox(width: 4),
              Text('الوصول ≈ ${PlacedOrder.clock(o.eta)}',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

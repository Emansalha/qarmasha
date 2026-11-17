import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import 'orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});
  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final dineIn = order.type == OrderType.dineIn;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 80),
              ),
              const SizedBox(height: 24),
              const Text('تم استلام طلبك! 🎉',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(
                dineIn
                    ? 'المطبخ بدأ يجهّز طلبك، وسيصلك على الطاولة رقم ${order.tableNumber}.'
                    : 'المطبخ بدأ يجهّز طلبك، وسيصلك خلال 30-45 دقيقة.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.6),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: softShadow(),
                ),
                child: Column(
                  children: [
                    _row('رقم الطلب', '#${order.code}'),
                    _row('نوع الطلب', order.type.label),
                    _row(dineIn ? 'الطاولة' : 'العنوان', order.destination),
                    _row('الإجمالي', money(order.total, state.currency)),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => OrderDetailsScreen(order: order)),
                ),
                child: const Text('تتبّع الطلب'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('العودة للرئيسية',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String a, String b) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(b,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
}

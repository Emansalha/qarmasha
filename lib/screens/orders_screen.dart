import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          children: [
            const Text('طلباتي',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            if (state.orders.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Text('🧾', style: TextStyle(fontSize: 60)),
                    SizedBox(height: 10),
                    Text('لا توجد طلبات بعد',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('اطلب وجبتك الأولى وتابعها من هنا',
                        style: TextStyle(color: AppColors.muted)),
                  ],
                ),
              )
            else
              for (final o in state.orders) _OrderCard(order: o),
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
        MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
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
                      Icon(
                        order.type == OrderType.dineIn
                            ? Icons.table_restaurant_rounded
                            : Icons.delivery_dining_rounded,
                        size: 16,
                        color: AppColors.muted,
                      ),
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
                  Text(
                      '${order.lines.fold<int>(0, (s, l) => s + l.quantity)} صنف • ${money(order.total, state.currency)}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
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
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: softShadow(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFFFEDE6),
                      child: Icon(
                          dineIn
                              ? Icons.table_restaurant_rounded
                              : Icons.delivery_dining_rounded,
                          color: AppColors.primary),
                    ),
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
              color: Colors.white,
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

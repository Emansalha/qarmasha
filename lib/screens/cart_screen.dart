import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../widgets/animations.dart';
import '../widgets/icon3d.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cart = state.cart;
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة الطلبات'),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: state.clearCart,
              child: const Text('إفراغ',
                  style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: EmptyState(
                image: 'icon:empty_cart',
                title: 'سلتك فاضية',
                subtitle: 'أضف وجباتك المفضّلة وارجع لهون 🍔',
                action: 'تصفّح المنيو',
                onAction: () => Navigator.pop(context),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                for (final line in cart)
                  Dismissible(
                    key: ObjectKey(line),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => state.removeLine(line),
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      alignment: AlignmentDirectional.centerEnd,
                      decoration: BoxDecoration(
                        gradient: AppColors.fire,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon3D('trash', size: 32),
                    ),
                    child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: softShadow(),
                    ),
                    child: Row(
                      children: [
                        NetImage(line.item.imageUrl,
                            width: 84, height: 84, radius: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(line.item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  GestureDetector(
                                    onTap: () => state.removeLine(line),
                                    child: const Icon(Icons.delete_outline,
                                        color: AppColors.muted, size: 20),
                                  ),
                                ],
                              ),
                              if (line.optionsSummary.isNotEmpty)
                                Text(line.optionsSummary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700)),
                              if (line.note.isNotEmpty)
                                Text('📝 ${line.note}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(money(line.total, state.currency),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900)),
                                  const Spacer(),
                                  QtyStepper(
                                    compact: true,
                                    value: line.quantity,
                                    onPlus: () =>
                                        state.changeQuantity(line, 1),
                                    onMinus: () =>
                                        state.changeQuantity(line, -1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: softShadow(),
                  ),
                  child: Column(
                    children: [
                      _row('المجموع الفرعي',
                          money(state.cartSubtotal, state.currency)),
                      const SizedBox(height: 8),
                      _row('التوصيل',
                          'حسب نوع الطلب (${money(AppConfig.deliveryFee, state.currency)} للتوصيل)',
                          muted: true),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    SmoothRoute<void>(builder: (_) => const CheckoutScreen()),
                  ),
                  child: Text(
                      'متابعة الطلب • ${money(state.cartSubtotal, state.currency)}'),
                ),
              ),
            ),
    );
  }

  Widget _row(String a, String b, {bool muted = false}) => Row(
        children: [
          Text(a, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(b,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: muted ? 12 : 16,
                    color: muted ? AppColors.muted : AppColors.text,
                    fontWeight: muted ? FontWeight.normal : FontWeight.bold)),
          ),
        ],
      );
}

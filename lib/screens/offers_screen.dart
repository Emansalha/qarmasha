import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final offers = state.items.where((i) => i.hasDiscount).toList()
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 170),
        children: [
          const Text('العروض',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('وفّر أكثر على وجباتك المفضّلة 🔥',
              style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          if (offers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(
                child: Text('لا توجد عروض حالياً، ترقّبوا!',
                    style: TextStyle(color: AppColors.muted)),
              ),
            )
          else
            for (final item in offers)
              GestureDetector(
                onTap: () => openItem(context, item),
                child: Container(
                  height: 170,
                  margin: const EdgeInsets.only(bottom: 16),
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
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [Color(0xE6000000), Color(0x00000000)],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tag('خصم ${item.discountPercent}%'),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 200,
                              child: Text(item.name,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(money(item.finalPrice, state.currency),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Text(money(item.price, state.currency),
                                    style: const TextStyle(
                                        color: Colors.white60,
                                        decoration:
                                            TextDecoration.lineThrough)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 14,
                        child: AddButton(
                          size: 40,
                          onTap: () {
                            state.addToCart(item);
                            showAddedSnack(context, item);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

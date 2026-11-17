import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
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
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final item = widget.item;
    final images = item.allImages;
    final fav = state.isFavorite(item);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            backgroundColor: AppColors.background,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: CircleIconButton(
                icon: Icons.arrow_forward,
                size: 42,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: CircleIconButton(
                  icon: fav ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.primary,
                  size: 42,
                  onTap: () => state.toggleFavorite(item),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: images.isEmpty ? 1 : images.length,
                    onPageChanged: (i) => setState(() => _image = i),
                    itemBuilder: (_, i) =>
                        NetImage(images.isEmpty ? '' : images[i]),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 28,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < images.length; i++)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _image ? 18 : 7,
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
              transform: Matrix4.translationValues(0, -18, 0),
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.badge != null) ...[
                    Tag(item.badge!),
                    const SizedBox(height: 10),
                  ],
                  Text(item.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Row(
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
                            icon: Icons.local_fire_department_outlined,
                            color: AppColors.primary,
                            text: '${item.ordersCount}+ طلب'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('الوصف',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    item.description.isEmpty
                        ? 'وجبة طازجة تُحضَّر عند الطلب.'
                        : item.description,
                    style: const TextStyle(
                        color: AppColors.muted, height: 1.7, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  const Text('ملاحظات للمطبخ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _note,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'مثال: بدون مخلل، صوص زيادة...',
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: softShadow(),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            children: [
              QtyStepper(
                value: _qty,
                onPlus: () => setState(() => _qty++),
                onMinus: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    state.addToCart(item,
                        quantity: _qty, note: _note.text.trim());
                    showAddedSnack(context, item);
                    Navigator.pop(context);
                  },
                  child: Text(
                      'أضف للسلة • ${money(item.finalPrice * _qty, state.currency)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

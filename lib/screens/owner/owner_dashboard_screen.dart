import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import 'add_item_screen.dart';

/// أصناف المطعم على دوري (GET /owner/services) مع زر إضافة صنف.
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late Future<List<MenuItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppScope.read(context).api.ownerItems();
  }

  void _reload() {
    setState(() => _future = AppScope.read(context).api.ownerItems());
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('منيو المطعم'),
        actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('صنف جديد'),
        onPressed: () async {
          final appState = AppScope.read(context);
          final added = await Navigator.push<bool>(context,
              MaterialPageRoute(builder: (_) => const AddItemScreen()));
          if (added == true && mounted) {
            _reload();
            appState.loadMenu();
          }
        },
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted)),
              ),
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(
              child: Text('لا توجد أصناف بعد — أضف أول وجبة 🍗',
                  style: TextStyle(color: AppColors.muted)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final it = items[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: softShadow(),
                ),
                child: Row(
                  children: [
                    NetImage(it.imageUrl, width: 64, height: 64, radius: 14),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              '${money(it.finalPrice, state.currency)} • ${it.categoryName ?? 'بدون تصنيف'}',
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (it.isFeatured)
                      const Icon(Icons.star_rounded, color: AppColors.accent),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

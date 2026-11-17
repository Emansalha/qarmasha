import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/config.dart';
import '../core/theme.dart';
import 'animations.dart';

/// شبكة اختيار رقم الطاولة (تشبه مخطط صالة المطعم).
class TableGrid extends StatelessWidget {
  const TableGrid({super.key, required this.selected, required this.onSelect});
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: AppConfig.tablesCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final n = i + 1;
        final sel = selected == n;
        return Pressable(
          scale: 0.9,
          onTap: () => onSelect(n),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            decoration: BoxDecoration(
              gradient: sel ? AppColors.fire : null,
              color: sel ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: sel ? Colors.transparent : AppColors.border),
              boxShadow: sel ? glowShadow() : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.table_restaurant_rounded,
                    size: 18,
                    color: sel ? Colors.white : AppColors.muted),
                Text('$n',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: sel ? Colors.white : AppColors.text)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// نافذة سفلية لاختيار الطاولة. تُرجع رقم الطاولة أو null.
Future<int?> showTablePicker(BuildContext context, {int? current}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (ctx) {
      int? picked = current;
      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setSheet) => SafeArea(
            child: SingleChildScrollView(
             child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('اختر طاولتك 🍽️',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const Text('الرقم مكتوب على طاولتك داخل المطعم',
                      style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 16),
                  TableGrid(
                    selected: picked,
                    onSelect: (n) {
                      HapticFeedback.selectionClick();
                      setSheet(() => picked = n);
                    },
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: picked == null
                        ? null
                        : () => Navigator.pop(ctx, picked),
                    child: Text(picked == null
                        ? 'اختر رقماً'
                        : 'تأكيد الطاولة رقم $picked'),
                  ),
                ],
              ),
             ),
            ),
          ),
        ),
      );
    },
  );
}

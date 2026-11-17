import 'package:flutter/material.dart';

import '../core/theme.dart';

/// أيقونة صورة ثلاثية الأبعاد من assets/icons (Microsoft Fluent Emoji — MIT).
/// إن لم تتوفر الصورة تظهر أيقونة Material بديلة.
class Icon3D extends StatelessWidget {
  const Icon3D(this.name, {super.key, this.size = 24, this.grayscale = false});

  final String name;
  final double size;

  /// رمادي (للحالة غير المحددة في شريط التنقل مثلاً).
  final bool grayscale;

  static const Map<String, IconData> _fallback = {
    'home': Icons.home_rounded,
    'menu': Icons.grid_view_rounded,
    'orders': Icons.receipt_long_rounded,
    'offers': Icons.local_offer_rounded,
    'profile': Icons.person_rounded,
    'user': Icons.person_rounded,
    'bell': Icons.notifications_rounded,
    'cart': Icons.shopping_bag_rounded,
    'empty_cart': Icons.shopping_cart_rounded,
    'search': Icons.search_rounded,
    'heart': Icons.favorite_rounded,
    'fire': Icons.local_fire_department_rounded,
    'star': Icons.star_rounded,
    'stopwatch': Icons.timer_rounded,
    'hourglass': Icons.hourglass_bottom_rounded,
    'pepper': Icons.whatshot_rounded,
    'dinein': Icons.restaurant_rounded,
    'delivery': Icons.delivery_dining_rounded,
    'pin': Icons.location_on_rounded,
    'table': Icons.event_seat_rounded,
    'cash': Icons.payments_rounded,
    'card': Icons.credit_card_rounded,
    'party': Icons.celebration_rounded,
    'check': Icons.check_circle_rounded,
    'store': Icons.storefront_rounded,
    'gear': Icons.settings_rounded,
    'door': Icons.logout_rounded,
    'info': Icons.info_rounded,
    'note': Icons.edit_note_rounded,
    'phone': Icons.phone_iphone_rounded,
    'mail': Icons.mail_rounded,
    'lock': Icons.lock_rounded,
    'refresh': Icons.sync_rounded,
    'lightning': Icons.bolt_rounded,
    'sparkles': Icons.auto_awesome_rounded,
    'trash': Icons.delete_rounded,
  };

  @override
  Widget build(BuildContext context) {
    Widget img = Image.asset(
      'assets/icons/$name.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stack) => Icon(
        _fallback[name] ?? Icons.fastfood_rounded,
        size: size * 0.9,
        color: AppColors.primary,
      ),
    );
    if (grayscale) {
      img = Opacity(
        opacity: 0.55,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.2126, 0.7152, 0.0722, 0, 0, //
            0.2126, 0.7152, 0.0722, 0, 0, //
            0.2126, 0.7152, 0.0722, 0, 0, //
            0, 0, 0, 1, 0,
          ]),
          child: img,
        ),
      );
    }
    return SizedBox(width: size, height: size, child: img);
  }
}

/// أيقونة 3D داخل مربع ناعم ملوّن (للقوائم والبطاقات).
class IconTile extends StatelessWidget {
  const IconTile(this.name,
      {super.key, this.size = 44, this.color = AppColors.cream});
  final String name;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.17),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      child: Icon3D(name, size: size * 0.66),
    );
  }
}

/// أيقونة مناسبة لتصنيف حسب اسمه.
String categoryIcon(String name) {
  if (name.contains('برجر') || name.contains('ساندو')) return 'burger';
  if (name.contains('مشروب') || name.contains('عصير')) return 'drink';
  if (name.contains('حلو') || name.contains('تحلية')) return 'dessert';
  if (name.contains('بطاط') || name.contains('جانب')) return 'fries';
  if (name.contains('سلط')) return 'salad';
  if (name.contains('وجب') || name.contains('كومبو')) return 'menu';
  return 'chicken';
}

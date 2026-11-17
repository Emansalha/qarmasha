import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/animations.dart';
import '../widgets/icon3d.dart';
import 'auth/login_screen.dart';
import 'owner/owner_login_screen.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.user;
    final favs = state.items.where(state.isFavorite).toList();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 170),
        children: [
          const Text('حسابي',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: softShadow(),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.surface2,
                  child: Text(
                    user == null || user.name.isEmpty
                        ? '👤'
                        : user.name.characters.first,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'ضيف',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(
                          user == null
                              ? 'سجّل دخولك لحفظ طلباتك'
                              : (user.email.isNotEmpty
                                  ? user.email
                                  : user.phone),
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                if (user == null)
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: AppColors.surface2,
                        foregroundColor: AppColors.primary),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const LoginScreen(popOnSuccess: true))),
                    child: const Text('دخول'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Stat(icon: 'orders', value: '${state.orders.length}', label: 'طلب'),
              const SizedBox(width: 12),
              _Stat(icon: 'heart', value: '${favs.length}', label: 'مفضّلة'),
              const SizedBox(width: 12),
              _Stat(icon: 'cart', value: '${state.cartCount}', label: 'في السلة'),
            ],
          ),
          if (favs.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Row(
              children: [
                Icon3D('heart', size: 24),
                SizedBox(width: 6),
                Text('المفضّلة',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 12),
            for (final f in favs) FoodTile(item: f),
          ],
          const SizedBox(height: 14),
          _Tile(
            icon: 'store',
            title: 'لوحة صاحب المطعم',
            subtitle: 'إضافة أصناف بالصور عبر Dori API',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const OwnerLoginScreen())),
          ),
          _Tile(
            icon: 'refresh',
            title: 'تحديث المنيو',
            subtitle: state.usingDemoMenu
                ? 'المنيو الحالي تجريبي (${AppConfig.placeSlug})'
                : 'متصل بمتجر ${AppConfig.placeSlug} على دوري',
            onTap: state.loadMenu,
          ),
          _Tile(
            icon: 'info',
            title: 'عن التطبيق',
            subtitle: '${AppConfig.appName} — ${AppConfig.tagline}',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppConfig.appName,
              applicationVersion: '1.0.0',
              children: const [
                Text('صور الأطعمة من Pexels (رخصة مجانية للاستخدام التجاري).'),
              ],
            ),
          ),
          if (user != null)
            _Tile(
              icon: 'door',
              title: 'تسجيل الخروج',
              color: AppColors.primary,
              onTap: () async {
                await state.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (_) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});
  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: softShadow(),
          ),
          child: Column(
            children: [
              BounceIn(active: true, child: Icon3D(icon, size: 30)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
              Text(label, style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.color = AppColors.text,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: softShadow(),
        ),
        child: ListTile(
          onTap: onTap,
          leading: IconTile(icon, size: 44),
          title: Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_left),
        ),
      );
}

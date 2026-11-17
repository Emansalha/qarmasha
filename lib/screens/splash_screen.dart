import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../data/demo_menu.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'auth/login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final state = AppScope.read(context);
    // نبدأ التحميل ولا ننتظر المنيو كاملاً أكثر من ثانيتين
    final init = state.init();
    await Future.any([
      init,
      Future<void>.delayed(const Duration(milliseconds: 2200)),
    ]);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            state.isLoggedIn ? const MainShell() : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(child: AppLogo(light: true, size: 44)),
    );
  }
}

/// شعار نصي أصلي للتطبيق.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.light = false, this.size = 28});
  final bool light;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : AppColors.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔥', style: TextStyle(fontSize: size * 0.8)),
            const SizedBox(width: 6),
            Text(
              AppConfig.appName,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w900,
                color: color,
                height: 1.1,
              ),
            ),
          ],
        ),
        Text(
          AppConfig.tagline,
          style: TextStyle(
            fontSize: size * 0.38,
            color: light ? Colors.white70 : AppColors.muted,
          ),
        ),
      ],
    );
  }
}

/// شاشة الترحيب (مثل البداية في مشروع سطر).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(pexels(1059943, w: 1400)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xEE1A0A08)],
                stops: [0.25, 0.75],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Tag('دجاج طازج 100%', color: AppColors.primary),
                  const SizedBox(height: 14),
                  const Text(
                    'جوعان؟\nخلّي القرمشة توصلك 🔥',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'اطلب من طاولتك داخل المطعم برقم الطاولة،\nأو خلّي الطلب يوصلك لباب البيت.',
                    style: TextStyle(color: Colors.white70, height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('تسجيل الدخول'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    ),
                    child: const Text('تصفّح المنيو أولاً',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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

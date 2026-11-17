import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../data/demo_menu.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/flame_logo.dart';
import 'auth/login_screen.dart';
import 'main_shell.dart';

/// شاشة البداية: شعار لهب متحرك (ينمو ويتراقص مع جمرات متصاعدة)
/// ثم يظهر اسم المطعم حرفاً حرفاً قبل الانتقال للتطبيق.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  late final Animation<double> _ring = CurvedAnimation(
      parent: _intro, curve: const Interval(0.0, 0.45, curve: Curves.easeOut));
  late final Animation<double> _outer = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.05, 0.45, curve: Curves.elasticOut));
  late final Animation<double> _inner = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.28, 0.6, curve: Curves.easeOutBack));
  late final Animation<double> _title = CurvedAnimation(
      parent: _intro, curve: const Interval(0.45, 0.8, curve: Curves.easeOut));
  late final Animation<double> _tagline = CurvedAnimation(
      parent: _intro, curve: const Interval(0.7, 0.95, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final state = AppScope.read(context);
    final init = state.init();
    await _intro.forward();
    // ننتظر التحميل قليلاً إن لم ينتهِ (بحد أقصى ثانية إضافية)
    await Future.any([
      init,
      Future<void>.delayed(const Duration(milliseconds: 1000)),
    ]);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, __, ___) =>
            state.isLoggedIn ? const MainShell() : const WelcomeScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 1.06, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const name = AppConfig.appName;
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _loop]),
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.1,
                colors: [Color(0xFFE63E2E), AppColors.primary, Color(0xFF7A1010)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // جمرات متصاعدة
                Positioned.fill(
                  child: CustomPaint(
                    painter: EmbersPainter(
                        _loop.value + _intro.value, _outer.value.clamp(0.0, 1.0)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // حلقات توهج تتسع حول الشعار
                          for (final k in const [0.0, 0.35])
                            Builder(builder: (_) {
                              final t = ((_loop.value + k) % 1.0);
                              final show = _ring.value;
                              return Container(
                                width: 120 + 100 * t,
                                height: 120 + 100 * t,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                        alpha: (1 - t) * 0.35 * show),
                                    width: 2,
                                  ),
                                ),
                              );
                            }),
                          // دائرة خلفية للشعار
                          Transform.scale(
                            scale: _ring.value,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CustomPaint(
                              painter: FlamePainter(
                                outerProgress: _outer.value.clamp(0.0, 1.2),
                                innerProgress: _inner.value.clamp(0.0, 1.1),
                                flicker: _loop.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // اسم المطعم يظهر حرفاً حرفاً
                    Opacity(
                      opacity: _title.value,
                      child: Transform.translate(
                        offset: Offset(0, 24 * (1 - _title.value)),
                        child: ShaderMask(
                          shaderCallback: (rect) => LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: const [
                              Colors.white,
                              Colors.white,
                              Colors.transparent
                            ],
                            stops: [
                              0.0,
                              _title.value,
                              (_title.value + 0.15).clamp(0.0, 1.0),
                            ],
                          ).createShader(rect),
                          child: const Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                    color: Color(0x55000000),
                                    blurRadius: 12,
                                    offset: Offset(0, 4)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Opacity(
                      opacity: _tagline.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          AppConfig.tagline,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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
            SizedBox(
              width: size * 0.95,
              height: size * 0.95,
              child: CustomPaint(
                painter: FlamePainter(
                  outerColor: light ? Colors.white : AppColors.primary,
                ),
              ),
            ),
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
          NetImage(img('strips')),
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

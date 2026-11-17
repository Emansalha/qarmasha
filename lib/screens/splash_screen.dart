import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../data/demo_menu.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/animations.dart';
import '../widgets/flame_logo.dart';
import '../widgets/icon3d.dart';
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
        pageBuilder: (_, __, ___) => state.isLoggedIn || state.onboardingSeen
            ? const MainShell()
            : const WelcomeScreen(),
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
                colors: [Color(0xFF3B1E12), AppColors.background, Color(0xFF080808)],
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
                                    color: AppColors.primary.withValues(
                                        alpha: (1 - t) * 0.5 * show),
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
                                color: AppColors.primary.withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CustomPaint(
                              painter: FlamePainter(
                                outerColor: AppColors.primary,
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

/// شاشة البداية: صورة كاملة، عنوان ضخم متدرّج، بطاقة صورة مائلة،
/// وزر «اسحب للبدء».
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
      vsync: this, duration: const Duration(seconds: 4))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  void _finish(Widget next) {
    AppScope.read(context).markOnboardingSeen();
    Navigator.pushReplacement(context, RevealRoute<void>(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // الصورة الرئيسية مع حركة طفو بطيئة
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) => Transform.scale(
              scale: 1.08 + 0.04 * _float.value,
              child: child,
            ),
            child: SizedBox(
              height: h * 0.62,
              width: double.infinity,
              child: NetImage(img('spicy_chicken')),
            ),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x88000000),
                    Colors.transparent,
                    Color(0xDD1A1A1C),
                    AppColors.background,
                  ],
                  stops: [0, 0.22, 0.5, 0.62],
                ),
              ),
              child: SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppLogo(light: true, size: 20),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _finish(const LoginScreen()),
                        child: const Text('تسجيل الدخول',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 175,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // العنوان الضخم مع إيموجي داخل السطر
                        const FadeSlideIn(
                          index: 1,
                          offset: 40,
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                              ),
                              children: [
                                TextSpan(text: 'قرمِش.\n'),
                                TextSpan(text: 'كُل. '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon3D('yum', size: 46),
                                ),
                                TextSpan(text: '\n'),
                                TextSpan(
                                  text: 'استمتع!',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // بطاقة صورة مائلة في المساحة الفارغة يسار السطرين الأولين
                        Positioned(
                          left: 0,
                          top: 30,
                          child: AnimatedBuilder(
                            animation: _float,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(0, -5 * _float.value),
                              child: Transform.rotate(
                                  angle: -0.1 + 0.04 * _float.value,
                                  child: child),
                            ),
                            child: Container(
                              width: 104,
                              height: 116,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: NetImage(img('wings'), radius: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const FadeSlideIn(
                    index: 3,
                    child: Text(
                      'دجاج مقرمش وبرجر طازج يُحضَّر لحظة طلبك.\nاطلب من طاولتك أو خلّيه يوصلك. سهل. سريع. لذيذ.',
                      style: TextStyle(
                          color: AppColors.muted, height: 1.7, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    index: 5,
                    child: SwipeToStart(
                      label: 'اسحب للبدء',
                      onDone: () => _finish(const MainShell()),
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

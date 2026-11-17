import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

/// آخر نقطة لمس على الشاشة — تبدأ منها حركة الكشف الدائري للشاشة التالية.
class TapTracker {
  TapTracker._();
  static Offset? last;
}

/// يصغّر العنصر قليلاً عند الضغط مع اهتزاز خفيف — إحساس احترافي باللمس.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null
          ? null
          : (d) {
              TapTracker.last = d.globalPosition;
              _set(true);
            },
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// ظهور تدريجي مع انزلاق للأعلى، بتأخير حسب الترتيب [index].
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 28,
    this.horizontal = false,
  });

  final Widget child;
  final int index;
  final double offset;
  final bool horizontal;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 550));
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = widget.index.clamp(0, 10).toInt() * 70;
    _timer = Timer(Duration(milliseconds: delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      child: widget.child,
      builder: (context, child) {
        final d = widget.offset * (1 - _a.value);
        return Opacity(
          opacity: _a.value,
          child: Transform.translate(
            offset: widget.horizontal ? Offset(-d, 0) : Offset(0, d),
            child: child,
          ),
        );
      },
    );
  }
}

/// ينبض (يكبر ثم يرجع) كلما تغيّرت قيمة [trigger].
class PulseOnChange extends StatefulWidget {
  const PulseOnChange({super.key, required this.trigger, required this.child});
  final int trigger;
  final Widget child;

  @override
  State<PulseOnChange> createState() => _PulseOnChangeState();
}

class _PulseOnChangeState extends State<PulseOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 450));

  @override
  void didUpdateWidget(PulseOnChange old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value;
        final s = 1 + 0.28 * (t < 0.4 ? t / 0.4 : (1 - t) / 0.6);
        return Transform.scale(scale: _c.isAnimating ? s : 1, child: child);
      },
    );
  }
}

/// عدّاد تنازلي (ساعات:دقائق:ثواني) في مربعات.
class CountdownBoxes extends StatefulWidget {
  const CountdownBoxes({
    super.key,
    required this.until,
    this.boxColor = Colors.white,
    this.textColor = AppColors.primary,
  });

  final DateTime until;
  final Color boxColor;
  final Color textColor;

  @override
  State<CountdownBoxes> createState() => _CountdownBoxesState();
}

class _CountdownBoxesState extends State<CountdownBoxes> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var left = widget.until.difference(DateTime.now());
    if (left.isNegative) left = Duration.zero;
    String two(int v) => v.toString().padLeft(2, '0');
    final parts = [
      two(left.inHours),
      two(left.inMinutes % 60),
      two(left.inSeconds % 60),
    ];
    Widget box(String v) => Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.boxColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween(begin: const Offset(0, -0.6), end: Offset.zero)
                  .animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Text(
              v,
              key: ValueKey(v),
              style: TextStyle(
                color: widget.textColor,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          box(parts[0]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(':',
                style: TextStyle(
                    color: widget.boxColor, fontWeight: FontWeight.bold)),
          ),
          box(parts[1]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(':',
                style: TextStyle(
                    color: widget.boxColor, fontWeight: FontWeight.bold)),
          ),
          box(parts[2]),
        ],
      ),
    );
  }
}

/// انتقال احترافي بين الشاشات (تلاشي + انزلاق خفيف).
class SmoothRoute<T> extends PageRouteBuilder<T> {
  SmoothRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (context, _, __) => builder(context),
          transitionsBuilder: (context, anim, _, child) {
            final curved =
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// انتقال إبداعي: الشاشة الجديدة تنكشف بدائرة تتسع من نقطة اللمس
/// مع تكبير خفيف للمحتوى.
class RevealRoute<T> extends PageRouteBuilder<T> {
  RevealRoute({required WidgetBuilder builder, Offset? center})
      : super(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 620),
          reverseTransitionDuration: const Duration(milliseconds: 420),
          pageBuilder: (context, _, __) => builder(context),
          transitionsBuilder: (context, anim, _, child) {
            final size = MediaQuery.of(context).size;
            final origin = center ??
                TapTracker.last ??
                Offset(size.width / 2, size.height / 2);
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeInOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return AnimatedBuilder(
              animation: curved,
              child: child,
              builder: (context, child) {
                final maxR = _farthest(origin, size);
                return ClipPath(
                  clipper: _CircleClipper(origin, maxR * curved.value),
                  child: Transform.scale(
                    scale: 0.92 + 0.08 * curved.value,
                    alignment: Alignment(
                      (origin.dx / size.width) * 2 - 1,
                      (origin.dy / size.height) * 2 - 1,
                    ),
                    child: child,
                  ),
                );
              },
            );
          },
        );

  static double _farthest(Offset o, Size s) {
    final corners = [
      Offset.zero,
      Offset(s.width, 0),
      Offset(0, s.height),
      Offset(s.width, s.height),
    ];
    return corners.map((c) => (c - o).distance).reduce(math.max) + 8;
  }
}

class _CircleClipper extends CustomClipper<Path> {
  _CircleClipper(this.center, this.radius);
  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  bool shouldReclip(_CircleClipper old) =>
      old.radius != radius || old.center != center;
}

/// مُبدّل تبويبات: الصفحة الجديدة تظهر بتكبير وتلاشٍ وانزلاق خفيف
/// مع إبقاء حالة كل صفحة (مثل IndexedStack).
class AnimatedIndexedStack extends StatefulWidget {
  const AnimatedIndexedStack(
      {super.key, required this.index, required this.children});
  final int index;
  final List<Widget> children;

  @override
  State<AnimatedIndexedStack> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 480))
    ..value = 1;
  late int _current = widget.index;
  int _previous = -1;
  bool _forward = true;

  @override
  void didUpdateWidget(AnimatedIndexedStack old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _forward = widget.index > old.index;
      _previous = old.index;
      _current = widget.index;
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_c.value);
        final animating = _c.isAnimating;
        return Stack(
          children: [
            for (var i = 0; i < widget.children.length; i++)
              _buildChild(i, t, animating),
          ],
        );
      },
    );
  }

  Widget _buildChild(int i, double t, bool animating) {
    final isCurrent = i == _current;
    final isPrevious = animating && i == _previous;
    final visible = isCurrent || isPrevious;
    double opacity = 0;
    double scale = 1;
    double dx = 0;
    // الاتجاه في RTL: التبويب التالي يأتي من اليسار
    final dir = _forward ? -1.0 : 1.0;
    if (isCurrent) {
      opacity = t;
      scale = 0.94 + 0.06 * t;
      dx = dir * 40 * (1 - t);
    } else if (isPrevious) {
      opacity = 1 - t;
      scale = 1 - 0.04 * t;
      dx = -dir * 30 * t;
    }
    return Positioned.fill(
      child: Offstage(
        offstage: !visible,
        child: TickerMode(
          enabled: visible,
          child: IgnorePointer(
            ignoring: !isCurrent,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.scale(scale: scale, child: widget.children[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// أيقونة تقفز وتدور قليلاً عند تفعيلها.
class BounceIn extends StatelessWidget {
  const BounceIn({super.key, required this.active, required this.child});
  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(active),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: active ? 650 : 250),
      curve: active ? Curves.elasticOut : Curves.easeOut,
      builder: (context, v, child) {
        final s = active ? 0.7 + 0.45 * v : 1.0;
        final r = active ? (1 - v) * 0.5 : 0.0;
        return Transform.rotate(
          angle: r,
          child: Transform.scale(scale: s, child: child),
        );
      },
      child: child,
    );
  }
}

/// زر «اسحب للبدء»: مقبض دائري تسحبه حتى نهاية الشريط.
class SwipeToStart extends StatefulWidget {
  const SwipeToStart({super.key, required this.label, required this.onDone});
  final String label;
  final VoidCallback onDone;

  @override
  State<SwipeToStart> createState() => _SwipeToStartState();
}

class _SwipeToStartState extends State<SwipeToStart>
    with SingleTickerProviderStateMixin {
  double _drag = 0;
  bool _done = false;
  late final AnimationController _hint = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();

  @override
  void dispose() {
    _hint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const h = 64.0;
    const knob = 54.0;
    return LayoutBuilder(builder: (context, c) {
      final max = c.maxWidth - knob - 10;
      final p = (_drag / max).clamp(0.0, 1.0);
      return Container(
        height: h,
        decoration: BoxDecoration(
          gradient: AppColors.fire,
          borderRadius: BorderRadius.circular(h / 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // النص والأسهم المتحركة
            Opacity(
              opacity: 1 - p,
              child: AnimatedBuilder(
                animation: _hint,
                builder: (context, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(width: 10),
                    for (var i = 0; i < 3; i++)
                      Opacity(
                        opacity: (((_hint.value * 3) - i) % 3 < 1) ? 1.0 : 0.35,
                        child: const Icon(Icons.chevron_right_rounded,
                            color: Colors.white, size: 22),
                      ),
                  ],
                ),
              ),
            ),
            // المقبض (يبدأ من اليمين في RTL)
            PositionedDirectional(
              start: 5 + _drag.clamp(0.0, max),
              top: 5,
              child: GestureDetector(
                onHorizontalDragUpdate: (d) {
                  if (_done) return;
                  // في RTL السحب لليسار = تقدّم
                  final rtl = Directionality.of(context) == TextDirection.rtl;
                  setState(() => _drag =
                      (_drag + (rtl ? -d.delta.dx : d.delta.dx)).clamp(0.0, max));
                  if (_drag >= max * 0.98) {
                    _done = true;
                    HapticFeedback.heavyImpact();
                    widget.onDone();
                  }
                },
                onHorizontalDragEnd: (_) {
                  if (!_done) setState(() => _drag = 0);
                },
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _drag = max * 0.25);
                  Future<void>.delayed(const Duration(milliseconds: 250), () {
                    if (mounted && !_done) setState(() => _drag = 0);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: knob,
                  height: knob,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    p > 0.9 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

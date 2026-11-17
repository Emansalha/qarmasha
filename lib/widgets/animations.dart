import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

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
      onTapDown: widget.onTap == null ? null : (_) => _set(true),
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

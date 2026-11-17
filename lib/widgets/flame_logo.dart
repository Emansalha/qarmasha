import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// يرسم شعار اللهب (نفس شكل أيقونة التطبيق).
/// [outerProgress] و [innerProgress] من 0 إلى 1 لنمو اللهب من الأسفل.
class FlamePainter extends CustomPainter {
  FlamePainter({
    this.outerProgress = 1,
    this.innerProgress = 1,
    this.flicker = 0,
    this.outerColor = Colors.white,
    this.innerColor = AppColors.accent,
  });

  final double outerProgress;
  final double innerProgress;
  final double flicker;
  final Color outerColor;
  final Color innerColor;

  Path _outer(Size s) {
    Offset p(double x, double y) => Offset(x * s.width, y * s.height);
    final o = p(.50, .98);
    return Path()
      ..moveTo(o.dx, o.dy)
      ..cubicTo(p(.18, .98).dx, p(.18, .98).dy, p(.10, .70).dx, p(.10, .70).dy,
          p(.20, .52).dx, p(.20, .52).dy)
      ..cubicTo(p(.26, .42).dx, p(.26, .42).dy, p(.30, .46).dx, p(.30, .46).dy,
          p(.32, .50).dx, p(.32, .50).dy)
      ..cubicTo(p(.30, .30).dx, p(.30, .30).dy, p(.42, .18).dx, p(.42, .18).dy,
          p(.52, .02).dx, p(.52, .02).dy)
      ..cubicTo(p(.58, .20).dx, p(.58, .20).dy, p(.68, .26).dx, p(.68, .26).dy,
          p(.72, .40).dx, p(.72, .40).dy)
      ..cubicTo(p(.75, .34).dx, p(.75, .34).dy, p(.78, .30).dx, p(.78, .30).dy,
          p(.80, .26).dx, p(.80, .26).dy)
      ..cubicTo(p(.94, .46).dx, p(.94, .46).dy, p(.92, .98).dx, p(.92, .98).dy,
          o.dx, o.dy)
      ..close();
  }

  Path _inner(Size s) {
    Offset p(double x, double y) => Offset(x * s.width, y * s.height);
    final o = p(.50, .95);
    return Path()
      ..moveTo(o.dx, o.dy)
      ..cubicTo(p(.34, .95).dx, p(.34, .95).dy, p(.30, .80).dx, p(.30, .80).dy,
          p(.36, .70).dx, p(.36, .70).dy)
      ..cubicTo(p(.40, .62).dx, p(.40, .62).dy, p(.46, .58).dx, p(.46, .58).dy,
          p(.48, .46).dx, p(.48, .46).dy)
      ..cubicTo(p(.58, .56).dx, p(.58, .56).dy, p(.60, .60).dx, p(.60, .60).dy,
          p(.62, .66).dx, p(.62, .66).dy)
      ..cubicTo(p(.64, .62).dx, p(.64, .62).dy, p(.66, .60).dx, p(.66, .60).dy,
          p(.67, .58).dx, p(.67, .58).dy)
      ..cubicTo(p(.74, .72).dx, p(.74, .72).dy, p(.70, .95).dx, p(.70, .95).dy,
          o.dx, o.dy)
      ..close();
  }

  void _drawGrowing(Canvas canvas, Size size, Path path, double t, Paint paint,
      {double sway = 0}) {
    if (t <= 0) return;
    canvas.save();
    final base = Offset(size.width / 2, size.height * 0.97);
    canvas.translate(base.dx, base.dy);
    // نمو من القاعدة + اهتزاز خفيف للهب
    canvas.scale(0.6 + 0.4 * t, t * (1 + sway));
    canvas.translate(-base.dx, -base.dy);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sway = math.sin(flicker * math.pi * 2) * 0.035;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.18 * outerProgress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.save();
    canvas.translate(0, size.height * 0.03);
    _drawGrowing(canvas, size, _outer(size), outerProgress, shadow, sway: sway);
    canvas.restore();
    _drawGrowing(canvas, size, _outer(size), outerProgress,
        Paint()..color = outerColor,
        sway: sway);
    _drawGrowing(canvas, size, _inner(size), innerProgress,
        Paint()..color = innerColor,
        sway: -sway * 1.6);
  }

  @override
  bool shouldRepaint(FlamePainter old) =>
      old.outerProgress != outerProgress ||
      old.innerProgress != innerProgress ||
      old.flicker != flicker;
}

/// جمرات صغيرة تتصاعد حول الشعار.
class EmbersPainter extends CustomPainter {
  EmbersPainter(this.t, this.opacity);
  final double t;
  final double opacity;

  static final _seeds = List.generate(
    18,
    (i) => (
      x: (math.sin(i * 12.9898) * 43758.5453) % 1,
      speed: 0.4 + ((math.sin(i * 78.233) * 12345.678) % 1).abs() * 0.6,
      size: 2.0 + (i % 4),
      phase: i / 18,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    for (final s in _seeds) {
      final progress = (t * s.speed + s.phase) % 1;
      final x = size.width * (0.2 + 0.6 * s.x.abs()) +
          math.sin((progress + s.phase) * math.pi * 4) * 10;
      final y = size.height * (0.85 - progress * 0.75);
      final fade = (1 - progress) * opacity;
      canvas.drawCircle(
        Offset(x, y),
        s.size * (1 - progress * 0.5),
        Paint()
          ..color = Color.lerp(AppColors.accent, Colors.white, progress)!
              .withValues(alpha: fade.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(EmbersPainter old) =>
      old.t != t || old.opacity != opacity;
}

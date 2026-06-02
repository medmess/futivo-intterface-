import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CinematicBackground extends StatefulWidget {
  final Widget child;
  final double darkness;

  const CinematicBackground({
    super.key,
    required this.child,
    this.darkness = 0.78,
  });

  @override
  State<CinematicBackground> createState() => _CinematicBackgroundState();
}

class _CinematicBackgroundState extends State<CinematicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final drift = math.sin(t * math.pi * 2);
        final lift = math.cos(t * math.pi * 2);

        return Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(drift * 18, lift * 12),
              child: Transform.scale(
                scale: 1.10 + (t * 0.035),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    AppColors.background.withValues(alpha: 0.28),
                    BlendMode.color,
                  ),
                  child: Image.asset(
                    'assets/login_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment(0.12 * drift, -0.22 + 0.08 * lift),
                  ),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xBB18070B),
                    Color(0x889F102C),
                    Color(0x5539FF88),
                  ],
                ),
              ),
            ),
            CustomPaint(
              painter: _CinematicLightPainter(
                progress: t,
                darkness: widget.darkness,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.08),
                    AppColors.background.withValues(
                      alpha: widget.darkness * 0.72,
                    ),
                    AppColors.background.withValues(alpha: widget.darkness),
                  ],
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _CinematicLightPainter extends CustomPainter {
  final double progress;
  final double darkness;

  const _CinematicLightPainter({
    required this.progress,
    required this.darkness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stadiumPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.cupRed.withValues(alpha: 0.20),
              AppColors.cupGreen.withValues(alpha: 0.14),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.18, size.height * 0.12),
              radius: size.width * 0.72,
            ),
          );
    canvas.drawRect(Offset.zero & size, stadiumPaint);

    _drawTriondaRibbon(
      canvas,
      size,
      progress,
      color: AppColors.white,
      alpha: 0.34,
      y: 0.22,
      thickness: 0.020,
      phase: 0.0,
    );
    _drawTriondaRibbon(
      canvas,
      size,
      progress,
      color: AppColors.cupRed,
      alpha: 0.54,
      y: 0.48,
      thickness: 0.024,
      phase: 0.38,
    );
    _drawTriondaRibbon(
      canvas,
      size,
      progress,
      color: AppColors.cupGreen,
      alpha: 0.44,
      y: 0.72,
      thickness: 0.020,
      phase: 0.72,
    );

    _drawStar(
      canvas,
      Offset(size.width * 0.78, size.height * 0.32),
      size.shortestSide * 0.034,
      progress,
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025 + (1 - darkness) * 0.03)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 7) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.10);
    for (var i = 0; i < 18; i++) {
      final x =
          (size.width * ((i * 37) % 100) / 100) +
          math.sin(progress * math.pi * 2 + i) * 10;
      final y = size.height * ((i * 19) % 100) / 100;
      canvas.drawCircle(Offset(x, y), i.isEven ? 1.4 : 0.9, dotPaint);
    }
  }

  void _drawTriondaRibbon(
    Canvas canvas,
    Size size,
    double progress, {
    required Color color,
    required double alpha,
    required double y,
    required double thickness,
    required double phase,
  }) {
    final shift =
        math.sin((progress + phase) * math.pi * 2) * size.width * 0.035;
    final path = Path()
      ..moveTo(size.width * -0.18 + shift, size.height * y)
      ..cubicTo(
        size.width * 0.18 + shift,
        size.height * (y - 0.16),
        size.width * 0.50 + shift,
        size.height * (y + 0.16),
        size.width * 1.18 + shift,
        size.height * (y - 0.03),
      );

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * (thickness * 2.4)
      ..color = color.withValues(alpha: alpha * 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * thickness
      ..color = color.withValues(alpha: alpha);
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2
      ..color = AppColors.white.withValues(alpha: alpha * 0.55);

    canvas.drawPath(path, glow);
    canvas.drawPath(path, stroke);
    canvas.drawPath(path, hairline);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, double progress) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5 + progress * 0.24;
      final r = i.isEven ? radius : radius * 0.42;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.cupRed.withValues(
          alpha: 0.44 + math.sin(progress * math.pi * 2).abs() * 0.28,
        )
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _CinematicLightPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.darkness != darkness;
  }
}

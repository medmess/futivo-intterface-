import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AnimatedTriondaBall extends StatefulWidget {
  final double size;
  final double opacity;

  const AnimatedTriondaBall({super.key, this.size = 170, this.opacity = 1});

  @override
  State<AnimatedTriondaBall> createState() => _AnimatedTriondaBallState();
}

class _AnimatedTriondaBallState extends State<AnimatedTriondaBall>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
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
        return Opacity(
          opacity: widget.opacity,
          child: Transform.translate(
            offset: Offset(0, math.sin(t * math.pi * 2) * 7),
            child: Transform.rotate(
              angle: t * math.pi * 2,
              child: CustomPaint(
                size: Size.square(widget.size),
                painter: _TriondaBallPainter(progress: t),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TriondaBallPainter extends CustomPainter {
  final double progress;

  const _TriondaBallPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final ballRect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center.translate(0, radius * 0.12),
      radius * 0.92,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(ballRect));

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.34, -0.44),
          colors: [
            AppColors.white,
            const Color(0xFFFFF4F6),
            const Color(0xFFE9ECE8),
          ],
          stops: const [0.0, 0.58, 1.0],
        ).createShader(ballRect),
    );

    _drawPanel(
      canvas,
      size,
      angle: -math.pi / 2,
      color: AppColors.cupRed,
      widthFactor: 0.34,
    );
    _drawPanel(
      canvas,
      size,
      angle: math.pi * 0.18,
      color: AppColors.cupGreen,
      widthFactor: 0.30,
    );
    _drawPanel(
      canvas,
      size,
      angle: math.pi * 0.88,
      color: AppColors.cupRed,
      widthFactor: 0.26,
    );
    _drawPanel(
      canvas,
      size,
      angle: math.pi * 1.42,
      color: AppColors.cupGreen,
      widthFactor: 0.22,
    );

    final seamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.025
      ..strokeCap = StrokeCap.round
      ..color = AppColors.background.withValues(alpha: 0.24);
    for (var i = 0; i < 3; i++) {
      final angle = i * math.pi * 2 / 3 + progress * math.pi * 2;
      final path = Path()
        ..moveTo(
          center.dx + math.cos(angle) * radius * 0.12,
          center.dy + math.sin(angle) * radius * 0.12,
        )
        ..quadraticBezierTo(
          center.dx + math.cos(angle + 0.58) * radius * 0.56,
          center.dy + math.sin(angle + 0.58) * radius * 0.56,
          center.dx + math.cos(angle + 1.18) * radius * 0.92,
          center.dy + math.sin(angle + 1.18) * radius * 0.92,
        );
      canvas.drawPath(path, seamPaint);
    }

    canvas.drawCircle(
      center.translate(-radius * 0.24, -radius * 0.30),
      radius * 0.24,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                AppColors.white.withValues(alpha: 0.70),
                AppColors.white.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromCircle(
                center: center.translate(-radius * 0.24, -radius * 0.30),
                radius: radius * 0.30,
              ),
            ),
    );

    canvas.restore();

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.025
        ..color = AppColors.white.withValues(alpha: 0.72),
    );
  }

  void _drawPanel(
    Canvas canvas,
    Size size, {
    required double angle,
    required Color color,
    required double widthFactor,
  }) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final path = Path();
    final start = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    final end =
        center +
        Offset(math.cos(angle + math.pi), math.sin(angle + math.pi)) * radius;
    final c1 =
        center +
        Offset(math.cos(angle + 0.85), math.sin(angle + 0.85)) *
            radius *
            widthFactor;
    final c2 =
        center +
        Offset(
              math.cos(angle + math.pi - 0.85),
              math.sin(angle + math.pi - 0.85),
            ) *
            radius *
            widthFactor;
    path
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = radius * 0.32
        ..color = color.withValues(alpha: 0.82),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = radius * 0.055
        ..color = AppColors.white.withValues(alpha: 0.62),
    );
  }

  @override
  bool shouldRepaint(covariant _TriondaBallPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

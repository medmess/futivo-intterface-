import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/player.dart';
import '../player/player_ui_helpers.dart';
import 'captain_badge.dart';

class PlayerShirtCard extends StatelessWidget {
  final Player player;
  final double width;
  final bool selected;
  final bool isCaptain;
  final bool isViceCaptain;
  final VoidCallback? onTap;

  const PlayerShirtCard({
    super.key,
    required this.player,
    required this.width,
    this.selected = false,
    this.isCaptain = false,
    this.isViceCaptain = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shirtSize = (width * 0.82).clamp(40.0, 58.0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  width: shirtSize,
                  height: shirtSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.teal],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: selected ? 0.58 : 0.28,
                        ),
                        blurRadius: selected ? 24 : 14,
                        spreadRadius: selected ? 2 : 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _ShirtPainter(),
                    child: Center(
                      child: Text(
                        playerInitials(player),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: shirtSize * 0.23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -7,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      playerRating(player),
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -6,
                  bottom: -5,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppColors.teal,
                      size: 11,
                    ),
                  ),
                ),
                if (isCaptain || isViceCaptain)
                  Positioned(
                    top: -9,
                    left: -9,
                    child: CaptainBadge(
                      label: isCaptain ? 'C' : 'VC',
                      compact: isViceCaptain,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              player.position,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.teal,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              player.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShirtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.20)
      ..lineTo(size.width * 0.37, size.height * 0.10)
      ..lineTo(size.width * 0.63, size.height * 0.10)
      ..lineTo(size.width * 0.78, size.height * 0.20)
      ..moveTo(size.width * 0.22, size.height * 0.20)
      ..lineTo(size.width * 0.14, size.height * 0.42)
      ..moveTo(size.width * 0.78, size.height * 0.20)
      ..lineTo(size.width * 0.86, size.height * 0.42);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

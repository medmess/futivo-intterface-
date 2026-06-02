import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';

class EmptyPitchSlot extends StatelessWidget {
  final double width;
  final String positionLabel;

  const EmptyPitchSlot({
    super.key,
    required this.width,
    required this.positionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final shirtSize = (width * 0.78).clamp(36.0, 54.0);

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: shirtSize,
            height: shirtSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white.withValues(alpha: 0.45),
              size: shirtSize * 0.42,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            positionLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.48),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.t('slot'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

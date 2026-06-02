import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CaptainBadge extends StatelessWidget {
  final String label;
  final bool compact;

  const CaptainBadge({super.key, required this.label, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 20 : 24,
      height: compact ? 20 : 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.teal,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.42),
            blurRadius: 12,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

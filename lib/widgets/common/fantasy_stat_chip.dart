import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/player.dart';
import '../player/player_ui_helpers.dart';

class FantasyStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const FantasyStatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.48),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerFormBadge extends StatelessWidget {
  final Player player;

  const PlayerFormBadge({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return FantasyStatChip(
      icon: Icons.trending_up_rounded,
      label: 'FORM',
      value: playerForm(player),
    );
  }
}

class OwnershipBadge extends StatelessWidget {
  final Player player;

  const OwnershipBadge({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return FantasyStatChip(
      icon: Icons.groups_rounded,
      label: 'OWN',
      value: playerOwnership(player),
      color: const Color(0xFFFFFFFF),
    );
  }
}

class PriceChangeBadge extends StatelessWidget {
  final Player player;

  const PriceChangeBadge({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final value = playerPriceChange(player);
    final isDown = value.startsWith('-');
    final color = isDown ? AppColors.cupRed : AppColors.teal;

    return FantasyStatChip(
      icon: isDown ? Icons.south_rounded : Icons.north_rounded,
      label: 'VAL',
      value: value,
      color: color,
    );
  }
}

class AvailabilityStatusBadge extends StatelessWidget {
  final Player player;

  const AvailabilityStatusBadge({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final availability = playerAvailability(player);
    final color = availabilityColor(availability);
    return FantasyStatChip(
      icon: availabilityIcon(availability),
      label: 'STAT',
      value: availabilityLabel(availability),
      color: color,
    );
  }
}

class LastFivePointsMiniRow extends StatelessWidget {
  final Player player;
  final double size;

  const LastFivePointsMiniRow({
    super.key,
    required this.player,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final points = playerLastFive(player);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: points.map((point) {
        final strong = point >= 7;
        return Container(
          width: size,
          height: size,
          margin: const EdgeInsets.only(right: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: strong
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: strong
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            '$point',
            style: TextStyle(
              color: strong ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      }).toList(),
    );
  }
}

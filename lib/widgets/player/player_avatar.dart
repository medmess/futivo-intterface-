import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/player.dart';
import 'player_ui_helpers.dart';

class PlayerAvatar extends StatelessWidget {
  final Player player;
  final double size;
  final String? imageUrl;

  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 48,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = imageUrl ?? playerPhotoUrl(player);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.teal],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: resolvedUrl == null || resolvedUrl.isEmpty
          ? _InitialsAvatar(player: player)
          : Image.network(
              resolvedUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _InitialsAvatar(player: player);
              },
              errorBuilder: (context, error, stackTrace) {
                return _InitialsAvatar(player: player);
              },
            ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final Player player;

  const _InitialsAvatar({required this.player});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        playerInitials(player),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }
}

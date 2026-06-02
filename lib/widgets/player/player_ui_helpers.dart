import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/player.dart';

enum PlayerAvailability { available, injured, suspended }

int _seed(Player player) {
  return player.id.codeUnits.fold<int>(
    player.name.length + player.club.length,
    (value, unit) => value + unit,
  );
}

String playerInitials(Player player) {
  final parts = player.name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return player.position;
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String? playerPhotoUrl(Player player) {
  // The current Player model has no image field yet. Keeping this centralized
  // makes the UI ready for real image URLs without changing backend data flow.
  return null;
}

String playerRating(Player player) {
  final rating = 6.4 + (_seed(player) % 22) / 10;
  return rating.clamp(6.4, 8.6).toStringAsFixed(1);
}

String playerForm(Player player) {
  final form = 5.8 + (_seed(player) % 28) / 10;
  return form.clamp(5.8, 8.6).toStringAsFixed(1);
}

String playerOwnership(Player player) {
  final ownership = 7 + (_seed(player) % 36);
  return '$ownership%';
}

String playerPriceChange(Player player) {
  final delta = ((_seed(player) % 7) - 3) / 10;
  if (delta == 0) return '0.0M';
  return '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)}M';
}

List<int> playerLastFive(Player player) {
  final base = _seed(player);
  return List.generate(5, (index) => 2 + ((base + index * 3) % 9));
}

PlayerAvailability playerAvailability(Player player) {
  final value = _seed(player) % 17;
  if (value == 0) return PlayerAvailability.suspended;
  if (value == 1 || value == 2) return PlayerAvailability.injured;
  return PlayerAvailability.available;
}

IconData availabilityIcon(PlayerAvailability availability) {
  switch (availability) {
    case PlayerAvailability.available:
      return Icons.check_circle_rounded;
    case PlayerAvailability.injured:
      return Icons.healing_rounded;
    case PlayerAvailability.suspended:
      return Icons.block_rounded;
  }
}

Color availabilityColor(PlayerAvailability availability) {
  switch (availability) {
    case PlayerAvailability.available:
      return AppColors.teal;
    case PlayerAvailability.injured:
      return const Color(0xFFFFB020);
    case PlayerAvailability.suspended:
      return const Color(0xFFFF4D4D);
  }
}

String availabilityLabel(PlayerAvailability availability) {
  switch (availability) {
    case PlayerAvailability.available:
      return 'OK';
    case PlayerAvailability.injured:
      return 'INJ';
    case PlayerAvailability.suspended:
      return 'SUS';
  }
}

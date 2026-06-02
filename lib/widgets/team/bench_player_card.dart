import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/player.dart';
import '../common/fantasy_stat_chip.dart';
import '../player/player_avatar.dart';
import 'squad_drag_data.dart';

class BenchPlayerCard extends StatelessWidget {
  final Player player;
  final int squadIndex;
  final VoidCallback? onRemove;
  final ValueChanged<SquadDragData>? onPlayerDropped;

  const BenchPlayerCard({
    super.key,
    required this.player,
    required this.squadIndex,
    this.onRemove,
    this.onPlayerDropped,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<SquadDragData>(
      onWillAcceptWithDetails: (details) => details.data.index != squadIndex,
      onAcceptWithDetails: (details) => onPlayerDropped?.call(details.data),
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        final card = _BenchCardBody(
          player: player,
          onRemove: onRemove,
          hovering: hovering,
        );

        return LongPressDraggable<SquadDragData>(
          data: SquadDragData(player: player, index: squadIndex),
          feedback: Material(color: Colors.transparent, child: card),
          childWhenDragging: Opacity(opacity: 0.30, child: card),
          child: card,
        );
      },
    );
  }
}

class _BenchCardBody extends StatelessWidget {
  const _BenchCardBody({
    required this.player,
    required this.onRemove,
    required this.hovering,
  });

  final Player player;
  final VoidCallback? onRemove;
  final bool hovering;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hovering
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.08),
          width: hovering ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hovering
                ? AppColors.primary.withValues(alpha: 0.20)
                : Colors.black.withValues(alpha: 0.20),
            blurRadius: hovering ? 28 : 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlayerAvatar(player: player, size: 42),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${player.position}  •  ${player.price.toStringAsFixed(1)}M',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.52),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.remove_circle_rounded,
                  color: Color(0xFFFF4D4D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: PlayerFormBadge(player: player)),
              const SizedBox(width: 6),
              AvailabilityStatusBadge(player: player),
            ],
          ),
          const SizedBox(height: 10),
          LastFivePointsMiniRow(player: player, size: 21),
        ],
      ),
    );
  }
}

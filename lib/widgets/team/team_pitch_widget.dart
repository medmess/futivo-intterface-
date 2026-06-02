import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/player.dart';
import 'empty_pitch_slot.dart';
import 'player_shirt_card.dart';
import 'squad_drag_data.dart';

class TeamPitchWidget extends StatelessWidget {
  final List<Player> players;
  final List<int> formation;
  final String formationLabel;
  final String? captainId;
  final String? viceCaptainId;
  final void Function(
    SquadDragData data,
    int targetIndex,
    String targetPosition,
  )?
  onPlayerDropped;

  const TeamPitchWidget({
    super.key,
    required this.players,
    required this.formation,
    required this.formationLabel,
    this.captainId,
    this.viceCaptainId,
    this.onPlayerDropped,
  });

  @override
  Widget build(BuildContext context) {
    final slots = _buildSlots();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Container(
        key: ValueKey(formationLabel),
        height: 540,
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0FA35B), Color(0xFF12351F)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _PremiumPitchPainter()),
            ),
            Positioned(
              top: 0,
              left: 8,
              child: _FormationPill(label: formationLabel),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),
                _PlayerLine(
                  slots: slots.where((slot) => slot.position == 'FWD').toList(),
                  fallbackPosition: 'FWD',
                  captainId: captainId,
                  viceCaptainId: viceCaptainId,
                  onPlayerDropped: onPlayerDropped,
                ),
                _PlayerLine(
                  slots: slots.where((slot) => slot.position == 'MID').toList(),
                  fallbackPosition: 'MID',
                  captainId: captainId,
                  viceCaptainId: viceCaptainId,
                  onPlayerDropped: onPlayerDropped,
                ),
                _PlayerLine(
                  slots: slots.where((slot) => slot.position == 'DEF').toList(),
                  fallbackPosition: 'DEF',
                  captainId: captainId,
                  viceCaptainId: viceCaptainId,
                  onPlayerDropped: onPlayerDropped,
                ),
                _PlayerLine(
                  slots: slots.where((slot) => slot.position == 'GK').toList(),
                  fallbackPosition: 'GK',
                  captainId: captainId,
                  viceCaptainId: viceCaptainId,
                  onPlayerDropped: onPlayerDropped,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_PitchSlot> _buildSlots() {
    final slots = <_PitchSlot>[];
    var index = 0;

    Player? playerAt(int squadIndex) {
      if (squadIndex < players.length) return players[squadIndex];
      return null;
    }

    slots.add(
      _PitchSlot(index: index, position: 'GK', player: playerAt(index)),
    );
    index++;

    for (var i = 0; i < formation[0]; i++) {
      slots.add(
        _PitchSlot(index: index, position: 'DEF', player: playerAt(index)),
      );
      index++;
    }
    for (var i = 0; i < formation[1]; i++) {
      slots.add(
        _PitchSlot(index: index, position: 'MID', player: playerAt(index)),
      );
      index++;
    }
    for (var i = 0; i < formation[2]; i++) {
      slots.add(
        _PitchSlot(index: index, position: 'FWD', player: playerAt(index)),
      );
      index++;
    }

    return slots;
  }
}

class _PlayerLine extends StatelessWidget {
  final List<_PitchSlot> slots;
  final String fallbackPosition;
  final String? captainId;
  final String? viceCaptainId;
  final void Function(
    SquadDragData data,
    int targetIndex,
    String targetPosition,
  )?
  onPlayerDropped;

  const _PlayerLine({
    required this.slots,
    required this.fallbackPosition,
    required this.captainId,
    required this.viceCaptainId,
    required this.onPlayerDropped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gapBudget = (slots.length - 1) * 4.0;
        final slotWidth = ((constraints.maxWidth - gapBudget) / slots.length)
            .clamp(40.0, 64.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: slots.map((slot) {
            final player = slot.player;
            if (player == null) {
              return _PitchDragTarget(
                slot: slot,
                width: slotWidth,
                onPlayerDropped: onPlayerDropped,
                child: EmptyPitchSlot(
                  width: slotWidth,
                  positionLabel: fallbackPosition,
                ),
              );
            }
            return _PitchDragTarget(
              slot: slot,
              width: slotWidth,
              onPlayerDropped: onPlayerDropped,
              child: LongPressDraggable<SquadDragData>(
                data: SquadDragData(player: player, index: slot.index),
                feedback: Material(
                  color: Colors.transparent,
                  child: PlayerShirtCard(
                    player: player,
                    width: slotWidth,
                    selected: true,
                    isCaptain: player.id == captainId,
                    isViceCaptain: player.id == viceCaptainId,
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.28,
                  child: PlayerShirtCard(
                    player: player,
                    width: slotWidth,
                    selected: false,
                    isCaptain: player.id == captainId,
                    isViceCaptain: player.id == viceCaptainId,
                  ),
                ),
                child: PlayerShirtCard(
                  player: player,
                  width: slotWidth,
                  selected: player.id == captainId,
                  isCaptain: player.id == captainId,
                  isViceCaptain: player.id == viceCaptainId,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _PitchDragTarget extends StatelessWidget {
  const _PitchDragTarget({
    required this.slot,
    required this.width,
    required this.child,
    required this.onPlayerDropped,
  });

  final _PitchSlot slot;
  final double width;
  final Widget child;
  final void Function(
    SquadDragData data,
    int targetIndex,
    String targetPosition,
  )?
  onPlayerDropped;

  @override
  Widget build(BuildContext context) {
    return DragTarget<SquadDragData>(
      onWillAcceptWithDetails: (details) => details.data.index != slot.index,
      onAcceptWithDetails: (details) {
        onPlayerDropped?.call(details.data, slot.index, slot.position);
      },
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: width,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hovering ? AppColors.primary : Colors.transparent,
              width: 1.4,
            ),
            boxShadow: [
              if (hovering)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.24),
                  blurRadius: 18,
                ),
            ],
          ),
          child: Center(
            child: FittedBox(fit: BoxFit.scaleDown, child: child),
          ),
        );
      },
    );
  }
}

class _PitchSlot {
  const _PitchSlot({
    required this.index,
    required this.position,
    required this.player,
  });

  final int index;
  final String position;
  final Player? player;
}

class _FormationPill extends StatelessWidget {
  final String label;

  const _FormationPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.teal,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PremiumPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final stripePaint = Paint()..color = Colors.white.withValues(alpha: 0.025);
    for (var i = 0; i < 6; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(0, size.height / 6 * i, size.width, size.height / 6),
          stripePaint,
        );
      }
    }

    final centerY = size.height / 2;
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), linePaint);
    canvas.drawCircle(Offset(size.width / 2, centerY), 48, linePaint);
    canvas.drawCircle(Offset(size.width / 2, centerY), 3, linePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.20, 0, size.width * 0.60, 62),
        const Radius.circular(8),
      ),
      linePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.20,
          size.height - 62,
          size.width * 0.60,
          62,
        ),
        const Radius.circular(8),
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

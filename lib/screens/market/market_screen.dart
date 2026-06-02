import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../data/players_data.dart' as data;
import '../../models/player.dart';
import '../../providers/squad_provider.dart';
import '../../widgets/common/fantasy_stat_chip.dart';
import '../../widgets/player/player_avatar.dart';
import '../../widgets/player/player_ui_helpers.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String selectedPosition = "ALL";

  final bool isMarketOpen = true;

  List<Player> get filteredPlayers {
    if (selectedPosition == "ALL") return data.allPlayers;

    return data.allPlayers
        .where((player) => player.position == selectedPosition)
        .toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.surface),
    );
  }

  @override
  Widget build(BuildContext context) {
    final squadProvider = context.watch<SquadProvider>();
    final players = filteredPlayers;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          _MarketStatusCard(
            isMarketOpen: isMarketOpen,
            selectedPlayers: squadProvider.squad.length,
            remainingBudget: squadProvider.remainingBudget,
          ),

          const SizedBox(height: 14),

          _SquadRulesCard(
            gk: squadProvider.countByPosition('GK'),
            def: squadProvider.countByPosition('DEF'),
            mid: squadProvider.countByPosition('MID'),
            fwd: squadProvider.countByPosition('FWD'),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: ["ALL", "GK", "DEF", "MID", "FWD"].map((position) {
                return _PositionFilter(
                  label: position,
                  selected: selectedPosition == position,
                  onTap: () {
                    setState(() {
                      selectedPosition = position;
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          if (players.isEmpty)
            const _MarketEmptyState()
          else
            ...players.map((player) {
              final isSelected = squadProvider.isSelected(player);
              final canAdd = squadProvider.canAdd(player);

              return _PlayerMarketCard(
                player: player,
                isSelected: isSelected,
                isMarketOpen: isMarketOpen,
                onTap: () {
                  if (!isMarketOpen) {
                    _showMessage(context.t('marketClosedSubtitle'));
                    return;
                  }

                  if (isSelected) {
                    squadProvider.removePlayer(player);
                    _showMessage(
                      trReplace(context.t('playerRemoved'), {
                        'player': player.name,
                      }),
                    );
                    return;
                  }

                  if (!canAdd) {
                    final reason = squadProvider.reasonCannotAdd(player);

                    _showMessage(reason ?? context.t('cannotAdd'));

                    return;
                  }

                  squadProvider.addPlayer(player);
                  _showMessage(
                    trReplace(context.t('playerAdded'), {
                      'player': player.name,
                    }),
                  );
                },
              );
            }),
        ],
      ),
    );
  }
}

class _MarketStatusCard extends StatelessWidget {
  final bool isMarketOpen;
  final int selectedPlayers;
  final double remainingBudget;

  const _MarketStatusCard({
    required this.isMarketOpen,
    required this.selectedPlayers,
    required this.remainingBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: isMarketOpen
              ? const [Color(0xFF8B1026), AppColors.background]
              : const [Color(0xFF2A1515), AppColors.background],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isMarketOpen ? Icons.shopping_bag_rounded : Icons.lock_rounded,
                color: isMarketOpen ? AppColors.teal : const Color(0xFFFF4D4D),
              ),
              const SizedBox(width: 10),
              Text(
                isMarketOpen
                    ? context.t('marketOpen')
                    : context.t('marketClosed'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isMarketOpen
                ? context.t('marketOpenSubtitle')
                : context.t('marketClosedSubtitle'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _MiniStat(
                title: context.t('players'),
                value: "$selectedPlayers/16",
              ),
              const SizedBox(width: 12),
              _MiniStat(
                title: context.t('budget'),
                value: "${remainingBudget.toStringAsFixed(1)}M",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.48),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquadRulesCard extends StatelessWidget {
  final int gk;
  final int def;
  final int mid;
  final int fwd;

  const _SquadRulesCard({
    required this.gk,
    required this.def,
    required this.mid,
    required this.fwd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('squadRules'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('squadRulesSubtitle'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _RuleChip(label: "GK", value: "$gk/2", complete: gk == 2),
              _RuleChip(label: "DEF", value: "$def/5", complete: def == 5),
              _RuleChip(label: "MID", value: "$mid/5", complete: mid == 5),
              _RuleChip(label: "FWD", value: "$fwd/4", complete: fwd == 4),
            ],
          ),
        ],
      ),
    );
  }
}

class _RuleChip extends StatelessWidget {
  final String label;
  final String value;
  final bool complete;

  const _RuleChip({
    required this.label,
    required this.value,
    required this.complete,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: complete
              ? AppColors.primary.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: complete
                ? AppColors.primary.withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: complete ? AppColors.teal : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionFilter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PositionFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 17),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PlayerMarketCard extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final bool isMarketOpen;
  final VoidCallback onTap;

  const _PlayerMarketCard({
    required this.player,
    required this.isSelected,
    required this.isMarketOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final actionColor = isSelected ? const Color(0xFFFF4D4D) : AppColors.teal;
    final availability = playerAvailability(player);
    final availabilityTint = availabilityColor(availability);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.32)
              : Colors.white.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: (isSelected ? AppColors.primary : Colors.black).withValues(
              alpha: isSelected ? 0.20 : 0.18,
            ),
            blurRadius: isSelected ? 26 : 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlayerAvatar(player: player, size: 54),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            player.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        _RatingPill(value: playerRating(player)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      player.club,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _Tag(text: player.position),
                        AvailabilityStatusBadge(player: player),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.92, end: isSelected ? 1.0 : 0.96),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: actionColor.withValues(alpha: 0.28),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: isMarketOpen ? onTap : null,
                    icon: Icon(
                      isSelected
                          ? Icons.remove_circle_rounded
                          : Icons.add_circle_rounded,
                      color: isMarketOpen ? actionColor : Colors.white24,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ValueBlock(
                  label: context.t('price').toUpperCase(),
                  value: '${player.price.toStringAsFixed(1)}M',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ValueBlock(
                  label: context.t('points').toUpperCase(),
                  value: '${player.points}',
                  valueColor: AppColors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ValueBlock(
                  label: context.t('status').toUpperCase(),
                  value: availabilityLabel(availability),
                  valueColor: availabilityTint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PlayerFormBadge(player: player),
              OwnershipBadge(player: player),
              PriceChangeBadge(player: player),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'L5',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.48),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 7),
                    LastFivePointsMiniRow(player: player, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _ValueBlock({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final String value;

  const _RatingPill({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.teal, size: 12),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.teal,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketEmptyState extends StatelessWidget {
  const _MarketEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.manage_search_rounded,
            color: AppColors.teal,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            context.t('noPlayers'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('changeFilterLater'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.teal,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

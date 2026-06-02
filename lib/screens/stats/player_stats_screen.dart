import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/world_cup_2026_data.dart';

class PlayerStatsScreen extends StatefulWidget {
  const PlayerStatsScreen({super.key});

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> {
  String metric = 'Goals';

  @override
  Widget build(BuildContext context) {
    final players = [...worldCupPlayerStats]
      ..sort((a, b) {
        switch (metric) {
          case 'Assists':
            return b.assists.compareTo(a.assists);
          case 'Chances':
            return b.chances.compareTo(a.chances);
          default:
            return b.goals.compareTo(a.goals);
        }
      });

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientTop, AppColors.gradientBottom],
        ),
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          const _StatsHeader(),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final item in ['Goals', 'Assists', 'Chances'])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _MetricButton(
                      text: item,
                      selected: metric == item,
                      onTap: () => setState(() => metric = item),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < players.length; i++)
            _AnimatedStatItem(
              index: i,
              child: _PlayerStatRow(player: players[i], rank: i + 1),
            ),
        ],
      ),
    );
  }
}

class _AnimatedStatItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedStatItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + (index.clamp(0, 10) * 35)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B1026), Color(0xFF1A2F20)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Row(
        children: [
          Icon(Icons.query_stats_rounded, color: Color(0xFFFFFFFF), size: 34),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall player statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Goals, assists and creative output for WC 2026 fantasy scouting.',
                  style: TextStyle(
                    color: Colors.white60,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _MetricButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF12E875) : const Color(0xFF1A2F20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PlayerStatRow extends StatelessWidget {
  final WorldCupPlayerStat player;
  final int rank;

  const _PlayerStatRow({required this.player, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Text(
            '#$rank',
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          _TeamLogo(team: worldCupTeamByName(player.team)),
          const SizedBox(width: 12),
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
                Text(
                  player.team,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _MiniStat(label: 'G', value: player.goals),
          _MiniStat(label: 'A', value: player.assists),
          _MiniStat(label: 'CH', value: player.chances),
        ],
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  final WorldCupTeam? team;

  const _TeamLogo({required this.team});

  @override
  Widget build(BuildContext context) {
    final team = this.team;
    return Container(
      width: 44,
      height: 34,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.22)),
      ),
      child: team == null
          ? const Icon(Icons.flag_rounded, color: Color(0xFFFFFFFF))
          : Image.network(
              team.logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    team.code,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

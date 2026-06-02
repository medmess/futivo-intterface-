import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/world_cup_2026_data.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  String selectedGroup = 'A';

  @override
  Widget build(BuildContext context) {
    final rows = standingsForGroup(selectedGroup);
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
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          const _LogicCard(),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: worldCupGroups.keys.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final group = worldCupGroups.keys.elementAt(index);
                return _GroupChip(
                  group: group,
                  selected: selectedGroup == group,
                  onTap: () => setState(() => selectedGroup = group),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Group $selectedGroup classement',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const _HeaderRow(),
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++)
            _AnimatedStandingRow(
              index: i,
              child: _StandingRow(row: rows[i], rank: i + 1),
            ),
        ],
      ),
    );
  }
}

class _AnimatedStandingRow extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedStandingRow({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 240 + index * 45),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(16 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _LogicCard extends StatelessWidget {
  const _LogicCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B1026), Color(0xFF1A2F20)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_tree_rounded, color: Color(0xFFFFFFFF), size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Official logic: 12 groups of 4. Win = 3 pts, draw = 1 pt. Top two in every group qualify, plus the 8 best third-placed teams. Ties sort by points, goal difference, goals scored, fair play, then draw.',
              style: TextStyle(
                color: Colors.white70,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String group;
  final bool selected;
  final VoidCallback onTap;

  const _GroupChip({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF12E875) : const Color(0xFF1A2F20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF12E875)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Text(
          group,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final teamHeader = const Text('Team', style: _head);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rankWidth = compact ? 20.0 : 28.0;
          final statWidth = _standingStatWidth(constraints.maxWidth, compact);
          final teamWidth = constraints.maxWidth - rankWidth - (statWidth * 6);

          return Row(
            children: [
              SizedBox(
                width: rankWidth,
                child: const Text('#', style: _head),
              ),
              SizedBox(
                width: teamWidth.clamp(0, double.infinity),
                child: teamHeader,
              ),
              _HeadCell('P', width: statWidth),
              _HeadCell('W', width: statWidth),
              _HeadCell('D', width: statWidth),
              _HeadCell('L', width: statWidth),
              _HeadCell('GD', width: statWidth),
              _HeadCell('Pts', width: statWidth),
            ],
          );
        },
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final WorldCupStanding row;
  final int rank;

  const _StandingRow({required this.row, required this.rank});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final qualified = rank <= 2;
    final thirdRoute = rank == 3;
    final accent = qualified
        ? const Color(0xFF42D392)
        : thirdRoute
        ? const Color(0xFFFFFFFF)
        : Colors.white54;

    final teamCell = Row(
      children: [
        Container(
          width: compact ? 28 : 34,
          height: compact ? 22 : 26,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent.withOpacity(0.20)),
          ),
          child: Image.network(
            row.team.logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  row.team.code,
                  style: TextStyle(
                    color: accent,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: compact ? 6 : 9),
        SizedBox(
          width: compact ? 27 : 34,
          child: Text(
            row.team.code,
            maxLines: 1,
            style: TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: Text(
            row.team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(qualified ? 0.28 : 0.10)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rankWidth = compact ? 20.0 : 28.0;
          final statWidth = _standingStatWidth(constraints.maxWidth, compact);
          final teamWidth = constraints.maxWidth - rankWidth - (statWidth * 6);

          return Row(
            children: [
              SizedBox(
                width: rankWidth,
                child: Text(
                  '$rank',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900),
                ),
              ),
              SizedBox(
                width: teamWidth.clamp(0, double.infinity),
                child: teamCell,
              ),
              _Cell('${row.played}', width: statWidth),
              _Cell('${row.wins}', width: statWidth),
              _Cell('${row.draws}', width: statWidth),
              _Cell('${row.losses}', width: statWidth),
              _Cell(
                row.goalDifference > 0
                    ? '+${row.goalDifference}'
                    : '${row.goalDifference}',
                width: statWidth,
              ),
              _Cell('${row.points}', width: statWidth, strong: true),
            ],
          );
        },
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  final String text;
  final double width;

  const _HeadCell(this.text, {required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(text, textAlign: TextAlign.center, style: _head),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final double width;
  final bool strong;

  const _Cell(this.text, {required this.width, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: strong ? const Color(0xFFFFFFFF) : Colors.white70,
          fontSize: 12,
          fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    );
  }
}

const _head = TextStyle(
  color: Colors.white38,
  fontSize: 11,
  fontWeight: FontWeight.w900,
);

double _standingStatWidth(double availableWidth, bool compact) {
  if (!compact) return 31;
  if (availableWidth < 310) return 20;
  if (availableWidth < 350) return 22;
  return 24;
}

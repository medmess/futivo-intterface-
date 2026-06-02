import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../models/fantasy_scoring.dart';
import '../../models/player.dart';
import '../../providers/fantasy_score_provider.dart';
import '../../providers/squad_provider.dart';
import '../../widgets/team/bench_player_card.dart';
import '../../widgets/team/team_pitch_widget.dart';

class MyTeamScreen extends StatefulWidget {
  const MyTeamScreen({super.key});

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> {
  String selectedFormation = '4-3-3';

  final Map<String, List<int>> formations = const {
    '4-4-2': [4, 4, 2],
    '4-3-3': [4, 3, 3],
    '3-5-2': [3, 5, 2],
    '3-4-3': [3, 4, 3],
    '5-3-2': [5, 3, 2],
  };

  @override
  Widget build(BuildContext context) {
    final squadProvider = context.watch<SquadProvider>();
    final scoreProvider = context.watch<FantasyScoreProvider>();
    final squad = squadProvider.squad;
    final starters = squad.take(11).toList();
    final bench = squad.skip(11).toList();
    final captainId = squadProvider.captainId;
    final viceCaptainId = squadProvider.viceCaptainId;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _ScoreSummaryCard(
            currentScore: scoreProvider.currentScore,
            overallScore: scoreProvider.overallScore,
            currentRound: scoreProvider.currentRound,
            canCalculate: starters.isNotEmpty,
            onCalculate: () {
              scoreProvider.calculateForSquad(
                squad: squad,
                captainId: captainId,
                viceCaptainId: viceCaptainId,
              );
            },
          ),
          const SizedBox(height: 14),
          if (scoreProvider.weeklyScores.isNotEmpty) ...[
            _WeeklyScoresCard(scores: scoreProvider.weeklyScores),
            const SizedBox(height: 14),
          ],
          if (scoreProvider.currentScore != null) ...[
            _CurrentRoundBreakdown(score: scoreProvider.currentScore!),
            const SizedBox(height: 14),
          ],
          _BudgetCard(
            selectedPlayers: squad.length,
            usedBudget: squadProvider.usedBudget,
            remainingBudget: squadProvider.remainingBudget,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t('startingXi'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                selectedFormation,
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _FormationSelector(
            formations: formations.keys.toList(),
            selectedFormation: selectedFormation,
            onFormationChanged: (formation) {
              setState(() {
                selectedFormation = formation;
              });
            },
          ),
          const SizedBox(height: 14),
          if (starters.isNotEmpty) ...[
            _CaptainSelector(
              starters: starters,
              captainId: captainId,
              viceCaptainId: viceCaptainId,
              onCaptainSelected: squadProvider.setCaptain,
              onViceCaptainSelected: squadProvider.setViceCaptain,
            ),
            const SizedBox(height: 14),
          ],
          TeamPitchWidget(
            players: squad,
            formation: formations[selectedFormation]!,
            formationLabel: selectedFormation,
            captainId: captainId,
            viceCaptainId: viceCaptainId,
            onPlayerDropped: (data, targetIndex, targetPosition) {
              if (data.player.position != targetPosition) {
                _showMoveError(
                  context,
                  '${data.player.name} is ${data.player.position}. Drop him on a $targetPosition slot.',
                );
                return;
              }
              squadProvider.movePlayer(
                fromIndex: data.index,
                toIndex: targetIndex,
              );
            },
          ),
          const SizedBox(height: 10),
          const _DragHint(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t('substitutes'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${bench.length}/5',
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (bench.isEmpty)
            const _EmptyBench()
          else
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: bench.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final player = bench[index];
                  return BenchPlayerCard(
                    player: player,
                    squadIndex: index + 11,
                    onRemove: () => squadProvider.removePlayer(player),
                    onPlayerDropped: (data) {
                      squadProvider.movePlayer(
                        fromIndex: data.index,
                        toIndex: index + 11,
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showMoveError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFB3261E),
      ),
    );
  }
}

class _ScoreSummaryCard extends StatelessWidget {
  const _ScoreSummaryCard({
    required this.currentScore,
    required this.overallScore,
    required this.currentRound,
    required this.canCalculate,
    required this.onCalculate,
  });

  final FantasyRoundScore? currentScore;
  final int overallScore;
  final int currentRound;
  final bool canCalculate;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    final roundPoints = currentScore?.totalPoints ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B1026), AppColors.background],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.26)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trReplace(context.t('fantasyPointsRound'), {
                    'round': '$currentRound',
                  }),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                currentScore?.label ?? context.t('realDataPending'),
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ScoreMetric(
                  label: context.t('overall'),
                  value: '$overallScore',
                  icon: Icons.leaderboard_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScoreMetric(
                  label: context.t('thisRound'),
                  value: '$roundPoints',
                  icon: Icons.sports_score_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (currentScore?.playerScores.isNotEmpty ?? false)
            _TopScorerLine(
              score: currentScore!.playerScores.reduce(
                (a, b) => a.finalPoints >= b.finalPoints ? a : b,
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canCalculate ? onCalculate : null,
              icon: const Icon(Icons.calculate_rounded),
              label: Text(context.t('syncRealPoints')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t('scoringInfo'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.50),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreMetric extends StatelessWidget {
  const _ScoreMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
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

class _TopScorerLine extends StatelessWidget {
  const _TopScorerLine({required this.score});

  final PlayerFantasyScore score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.gold,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Best: ${score.player.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '${score.finalPoints} pts',
            style: const TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyScoresCard extends StatelessWidget {
  const _WeeklyScoresCard({required this.scores});

  final List<FantasyRoundScore> scores;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('previousWeeklyScores'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: scores.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final round = scores[index];
                return Container(
                  width: 92,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: index == scores.length - 1
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: index == scores.length - 1
                          ? AppColors.primary.withValues(alpha: 0.40)
                          : Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        round.label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${round.totalPoints}',
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentRoundBreakdown extends StatelessWidget {
  const _CurrentRoundBreakdown({required this.score});

  final FantasyRoundScore score;

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = [...score.playerScores]
      ..sort((a, b) => b.finalPoints.compareTo(a.finalPoints));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t('currentRoundPlayerPoints'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${score.totalPoints} pts',
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final playerScore in sortedPlayers.take(11))
            _PlayerScoreRow(score: playerScore),
        ],
      ),
    );
  }
}

class _PlayerScoreRow extends StatelessWidget {
  const _PlayerScoreRow({required this.score});

  final PlayerFantasyScore score;

  @override
  Widget build(BuildContext context) {
    final tags = score.breakdown
        .take(3)
        .map((item) {
          final sign = item.points > 0 ? '+' : '';
          return '${item.label} $sign${item.points}';
        })
        .join(' • ');

    return Container(
      margin: const EdgeInsets.only(top: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: score.isCaptain
              ? AppColors.gold.withValues(alpha: 0.35)
              : score.isViceCaptain
              ? AppColors.teal.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: score.isCaptain
                  ? AppColors.gold
                  : AppColors.primary.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(
              score.isCaptain
                  ? 'C'
                  : score.isViceCaptain
                  ? 'VC'
                  : score.player.position,
              style: TextStyle(
                color: score.isCaptain ? Colors.black : AppColors.teal,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tags.isEmpty ? context.t('noPointsEvent') : tags,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.52),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${score.finalPoints}',
            style: const TextStyle(
              color: AppColors.teal,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptainSelector extends StatelessWidget {
  const _CaptainSelector({
    required this.starters,
    required this.captainId,
    required this.viceCaptainId,
    required this.onCaptainSelected,
    required this.onViceCaptainSelected,
  });

  final List<Player> starters;
  final String? captainId;
  final String? viceCaptainId;
  final ValueChanged<Player> onCaptainSelected;
  final ValueChanged<Player> onViceCaptainSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('captainRoles'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: starters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 9),
              itemBuilder: (context, index) {
                final player = starters[index];
                final isCaptain = player.id == captainId;
                final isVice = player.id == viceCaptainId;

                return Container(
                  width: 138,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCaptain
                          ? AppColors.gold
                          : isVice
                          ? AppColors.teal
                          : Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: _RoleButton(
                              label: 'C',
                              selected: isCaptain,
                              onTap: () => onCaptainSelected(player),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _RoleButton(
                              label: 'VC',
                              selected: isVice,
                              onTap: () => onViceCaptainSelected(player),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _DragHint extends StatelessWidget {
  const _DragHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_rounded, color: AppColors.teal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.t('dragHint'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.70),
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormationSelector extends StatelessWidget {
  final List<String> formations;
  final String selectedFormation;
  final Function(String) onFormationChanged;

  const _FormationSelector({
    required this.formations,
    required this.selectedFormation,
    required this.onFormationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: formations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final formation = formations[index];
          final isSelected = formation == selectedFormation;

          return GestureDetector(
            onTap: () => onFormationChanged(formation),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                formation,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final int selectedPlayers;
  final double usedBudget;
  final double remainingBudget;

  const _BudgetCard({
    required this.selectedPlayers,
    required this.usedBudget,
    required this.remainingBudget,
  });

  @override
  Widget build(BuildContext context) {
    final progress = usedBudget / 100;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B1026), AppColors.background],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('myFantasySquad'),
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$selectedPlayers/16 ${context.t('players').toLowerCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            trReplace(context.t('remainingBudget'), {
              'budget': remainingBudget.toStringAsFixed(1),
            }),
            style: const TextStyle(
              color: AppColors.teal,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            trReplace(context.t('usedBudget'), {
              'budget': usedBudget.toStringAsFixed(1),
            }),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBench extends StatelessWidget {
  const _EmptyBench();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Center(
        child: Text(
          context.t('noSubstitutes'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

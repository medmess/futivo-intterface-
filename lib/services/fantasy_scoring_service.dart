import '../models/fantasy_scoring.dart';
import '../models/player.dart';

class FantasyScoringService {
  const FantasyScoringService({this.rules = const FantasyScoringRules()});

  final FantasyScoringRules rules;

  FantasyRoundScore calculateRound({
    required int roundNumber,
    required List<Player> starters,
    required String? captainId,
    required String? viceCaptainId,
    Map<String, PlayerMatchStats> statsByPlayerId = const {},
  }) {
    final playerScores = starters
        .where((player) => statsByPlayerId.containsKey(player.id))
        .map((player) {
          final stats = statsByPlayerId[player.id]!;
          return calculatePlayer(
            player: player,
            stats: stats,
            isCaptain: player.id == captainId,
            isViceCaptain: player.id == viceCaptainId,
          );
        })
        .toList();

    final total = playerScores.fold<int>(
      0,
      (sum, score) => sum + score.finalPoints,
    );

    return FantasyRoundScore(
      roundNumber: roundNumber,
      label: 'Tour $roundNumber',
      playerScores: playerScores,
      totalPoints: total,
      calculatedAt: DateTime.now(),
    );
  }

  PlayerFantasyScore calculatePlayer({
    required Player player,
    required PlayerMatchStats stats,
    required bool isCaptain,
    required bool isViceCaptain,
  }) {
    final items = <ScoreBreakdownItem>[];

    void add(String label, int points) {
      if (points != 0) {
        items.add(ScoreBreakdownItem(label: label, points: points));
      }
    }

    if (stats.minutes > 0) add('Played', rules.appearance);
    if (stats.minutes >= 60) add('60+ minutes', rules.played60Minutes);

    if (stats.goals > 0) {
      final goalPoints = switch (player.position) {
        'GK' || 'DEF' => rules.goalkeeperDefenderGoal,
        'MID' => rules.midfielderGoal,
        _ => rules.forwardGoal,
      };
      add('Goals x${stats.goals}', goalPoints * stats.goals);
    }

    add('Assists x${stats.assists}', rules.assist * stats.assists);

    if (stats.cleanSheet) {
      if (player.position == 'GK' || player.position == 'DEF') {
        add('Clean sheet', rules.goalkeeperDefenderCleanSheet);
      } else if (player.position == 'MID') {
        add('Mid clean sheet', rules.midfielderCleanSheet);
      }
    }

    if ((player.position == 'GK' || player.position == 'DEF') &&
        stats.goalsConceded >= 2) {
      add(
        'Goals conceded',
        (stats.goalsConceded ~/ 2) * rules.twoGoalsConceded,
      );
    }

    if (player.position == 'GK') {
      add('Saves', (stats.saves ~/ 3) * rules.threeSaves);
      add('Penalty save', stats.penaltiesSaved * rules.penaltySave);
    }

    add('Yellow card', stats.yellowCards * rules.yellowCard);
    add('Red card', stats.redCards * rules.redCard);
    add('Own goal', stats.ownGoals * rules.ownGoal);
    add('Penalty miss', stats.penaltiesMissed * rules.penaltyMiss);

    final base = items.fold<int>(0, (sum, item) => sum + item.points);
    final multiplier = isCaptain
        ? rules.captainMultiplier
        : isViceCaptain
        ? rules.viceCaptainMultiplier
        : 1.0;
    final finalPoints = (base * multiplier).round();

    if (isCaptain) {
      add(
        'Captain x${rules.captainMultiplier.toStringAsFixed(0)}',
        finalPoints - base,
      );
    }
    if (isViceCaptain) {
      add(
        'Vice x${rules.viceCaptainMultiplier.toStringAsFixed(1)}',
        finalPoints - base,
      );
    }

    return PlayerFantasyScore(
      player: player,
      stats: stats,
      basePoints: base,
      finalPoints: finalPoints,
      isCaptain: isCaptain,
      isViceCaptain: isViceCaptain,
      breakdown: items,
    );
  }
}

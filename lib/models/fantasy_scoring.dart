import 'player.dart';

class FantasyScoringRules {
  const FantasyScoringRules({
    this.appearance = 2,
    this.played60Minutes = 2,
    this.goalkeeperDefenderGoal = 6,
    this.midfielderGoal = 5,
    this.forwardGoal = 4,
    this.assist = 3,
    this.goalkeeperDefenderCleanSheet = 4,
    this.midfielderCleanSheet = 1,
    this.yellowCard = -1,
    this.redCard = -3,
    this.ownGoal = -2,
    this.penaltyMiss = -2,
    this.penaltySave = 5,
    this.threeSaves = 1,
    this.twoGoalsConceded = -1,
    this.captainMultiplier = 2.0,
    this.viceCaptainMultiplier = 1.5,
  });

  final int appearance;
  final int played60Minutes;
  final int goalkeeperDefenderGoal;
  final int midfielderGoal;
  final int forwardGoal;
  final int assist;
  final int goalkeeperDefenderCleanSheet;
  final int midfielderCleanSheet;
  final int yellowCard;
  final int redCard;
  final int ownGoal;
  final int penaltyMiss;
  final int penaltySave;
  final int threeSaves;
  final int twoGoalsConceded;
  final double captainMultiplier;
  final double viceCaptainMultiplier;
}

class PlayerMatchStats {
  const PlayerMatchStats({
    required this.playerId,
    required this.roundNumber,
    required this.minutes,
    this.goals = 0,
    this.assists = 0,
    this.cleanSheet = false,
    this.goalsConceded = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.ownGoals = 0,
    this.penaltiesMissed = 0,
    this.penaltiesSaved = 0,
    this.saves = 0,
  });

  final String playerId;
  final int roundNumber;
  final int minutes;
  final int goals;
  final int assists;
  final bool cleanSheet;
  final int goalsConceded;
  final int yellowCards;
  final int redCards;
  final int ownGoals;
  final int penaltiesMissed;
  final int penaltiesSaved;
  final int saves;
}

class PlayerFantasyScore {
  const PlayerFantasyScore({
    required this.player,
    required this.stats,
    required this.basePoints,
    required this.finalPoints,
    required this.isCaptain,
    required this.isViceCaptain,
    required this.breakdown,
  });

  final Player player;
  final PlayerMatchStats stats;
  final int basePoints;
  final int finalPoints;
  final bool isCaptain;
  final bool isViceCaptain;
  final List<ScoreBreakdownItem> breakdown;
}

class ScoreBreakdownItem {
  const ScoreBreakdownItem({required this.label, required this.points});

  final String label;
  final int points;
}

class FantasyRoundScore {
  const FantasyRoundScore({
    required this.roundNumber,
    required this.label,
    required this.playerScores,
    required this.totalPoints,
    required this.calculatedAt,
  });

  final int roundNumber;
  final String label;
  final List<PlayerFantasyScore> playerScores;
  final int totalPoints;
  final DateTime calculatedAt;
}

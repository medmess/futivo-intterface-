import 'package:flutter/foundation.dart';

import '../models/fantasy_scoring.dart';
import '../models/player.dart';
import '../services/fantasy_scoring_service.dart';

class FantasyScoreProvider extends ChangeNotifier {
  FantasyScoreProvider({FantasyScoringService? scoringService})
    : _scoringService = scoringService ?? const FantasyScoringService();

  final FantasyScoringService _scoringService;

  int currentRound = 29;
  FantasyRoundScore? currentScore;
  final List<FantasyRoundScore> weeklyScores = [];

  int get overallScore {
    return weeklyScores.fold<int>(0, (sum, round) => sum + round.totalPoints);
  }

  void calculateForSquad({
    required List<Player> squad,
    required String? captainId,
    required String? viceCaptainId,
    Map<String, PlayerMatchStats> statsByPlayerId = const {},
  }) {
    final starters = squad.take(11).toList();
    final score = _scoringService.calculateRound(
      roundNumber: currentRound,
      starters: starters,
      captainId: captainId,
      viceCaptainId: viceCaptainId,
      statsByPlayerId: statsByPlayerId,
    );

    currentScore = score;
    if (score.playerScores.isNotEmpty) {
      weeklyScores.removeWhere((round) => round.roundNumber == currentRound);
      weeklyScores.add(score);
      weeklyScores.sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
    }
    notifyListeners();
  }

  void clearScores() {
    currentScore = FantasyRoundScore(
      roundNumber: currentRound,
      label: 'Tour $currentRound',
      playerScores: const [],
      totalPoints: 0,
      calculatedAt: DateTime.now(),
    );
    weeklyScores.clear();
    notifyListeners();
  }

  void setCurrentRound(int round) {
    currentRound = round.clamp(1, 38);
    notifyListeners();
  }
}

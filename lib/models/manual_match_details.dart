class ManualMatchDetails {
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final String? homeFormation;
  final String? awayFormation;
  final List<MatchLineupPlayer> homeLineup;
  final List<MatchLineupPlayer> awayLineup;
  final List<MatchEventData> events;
  final DateTime? updatedAt;

  const ManualMatchDetails({
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeLineup,
    required this.awayLineup,
    required this.events,
    this.homeFormation,
    this.awayFormation,
    this.updatedAt,
  });

  bool get hasLineups => homeLineup.isNotEmpty || awayLineup.isNotEmpty;
  bool get hasEvents => events.isNotEmpty;

  factory ManualMatchDetails.empty(String matchId) {
    return ManualMatchDetails(
      matchId: matchId,
      homeTeam: '',
      awayTeam: '',
      homeLineup: const [],
      awayLineup: const [],
      events: const [],
    );
  }

  factory ManualMatchDetails.fromJson(Map<String, dynamic> json) {
    return ManualMatchDetails(
      matchId: json['matchId'] as String? ?? '',
      homeTeam: json['homeTeam'] as String? ?? '',
      awayTeam: json['awayTeam'] as String? ?? '',
      homeFormation: json['homeFormation'] as String?,
      awayFormation: json['awayFormation'] as String?,
      homeLineup: _list(
        json['homeLineup'],
      ).map(MatchLineupPlayer.fromJson).toList(),
      awayLineup: _list(
        json['awayLineup'],
      ).map(MatchLineupPlayer.fromJson).toList(),
      events: _list(json['events']).map(MatchEventData.fromJson).toList(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  static List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }
}

class MatchLineupPlayer {
  final String name;
  final String? position;
  final int? shirtNumber;
  final bool starter;

  const MatchLineupPlayer({
    required this.name,
    this.position,
    this.shirtNumber,
    this.starter = true,
  });

  factory MatchLineupPlayer.fromJson(Map<String, dynamic> json) {
    return MatchLineupPlayer(
      name: json['name'] as String? ?? '',
      position: json['position'] as String?,
      shirtNumber: json['shirtNumber'] as int?,
      starter: json['starter'] as bool? ?? true,
    );
  }
}

class MatchEventData {
  final int minute;
  final String team;
  final String player;
  final String type;
  final String? detail;
  final String? assist;
  final bool? scored;

  const MatchEventData({
    required this.minute,
    required this.team,
    required this.player,
    required this.type,
    this.detail,
    this.assist,
    this.scored,
  });

  factory MatchEventData.fromJson(Map<String, dynamic> json) {
    return MatchEventData(
      minute: json['minute'] as int? ?? 0,
      team: json['team'] as String? ?? '',
      player: json['player'] as String? ?? '',
      type: json['type'] as String? ?? 'goal',
      detail: json['detail'] as String?,
      assist: json['assist'] as String?,
      scored: json['scored'] as bool?,
    );
  }
}

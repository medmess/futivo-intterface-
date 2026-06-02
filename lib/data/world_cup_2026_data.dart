class WorldCupTeam {
  final String name;
  final String code;
  final String group;

  const WorldCupTeam({
    required this.name,
    required this.code,
    required this.group,
  });

  String get logoUrl => 'https://flagcdn.com/w80/${_teamFlagCodes[code]}.png';
}

const Map<String, String> _teamFlagCodes = {
  'MEX': 'mx',
  'RSA': 'za',
  'KOR': 'kr',
  'CZE': 'cz',
  'CAN': 'ca',
  'BIH': 'ba',
  'QAT': 'qa',
  'SUI': 'ch',
  'BRA': 'br',
  'MAR': 'ma',
  'HAI': 'ht',
  'SCO': 'gb-sct',
  'USA': 'us',
  'PAR': 'py',
  'AUS': 'au',
  'TUR': 'tr',
  'GER': 'de',
  'CUW': 'cw',
  'CIV': 'ci',
  'ECU': 'ec',
  'NED': 'nl',
  'JPN': 'jp',
  'SWE': 'se',
  'TUN': 'tn',
  'BEL': 'be',
  'EGY': 'eg',
  'IRN': 'ir',
  'NZL': 'nz',
  'ESP': 'es',
  'CPV': 'cv',
  'KSA': 'sa',
  'URU': 'uy',
  'FRA': 'fr',
  'SEN': 'sn',
  'IRQ': 'iq',
  'NOR': 'no',
  'ARG': 'ar',
  'ALG': 'dz',
  'AUT': 'at',
  'JOR': 'jo',
  'POR': 'pt',
  'COD': 'cd',
  'UZB': 'uz',
  'COL': 'co',
  'ENG': 'gb-eng',
  'CRO': 'hr',
  'GHA': 'gh',
  'PAN': 'pa',
};

class WorldCupStanding {
  final WorldCupTeam team;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int fairPlay;

  const WorldCupStanding({
    required this.team,
    this.played = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.fairPlay = 0,
  });

  int get goalDifference => goalsFor - goalsAgainst;
  int get points => wins * 3 + draws;
}

class WorldCupFixture {
  final String group;
  final String home;
  final String away;
  final String venue;
  final DateTime kickoff;

  const WorldCupFixture({
    required this.group,
    required this.home,
    required this.away,
    required this.venue,
    required this.kickoff,
  });

  String get matchId {
    final raw =
        '${home}_${away}_${kickoff.year}_${kickoff.month}_${kickoff.day}_${kickoff.hour}';
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

class WorldCupPlayerStat {
  final String name;
  final String team;
  final String position;
  final int goals;
  final int assists;
  final int shots;
  final int chances;
  final double price;

  const WorldCupPlayerStat({
    required this.name,
    required this.team,
    required this.position,
    required this.goals,
    required this.assists,
    required this.shots,
    required this.chances,
    required this.price,
  });

  int get attackingPoints => goals * 5 + assists * 3 + chances;
}

const Map<String, List<WorldCupTeam>> worldCupGroups = {
  'A': [
    WorldCupTeam(name: 'Mexico', code: 'MEX', group: 'A'),
    WorldCupTeam(name: 'South Africa', code: 'RSA', group: 'A'),
    WorldCupTeam(name: 'Korea Republic', code: 'KOR', group: 'A'),
    WorldCupTeam(name: 'Czechia', code: 'CZE', group: 'A'),
  ],
  'B': [
    WorldCupTeam(name: 'Canada', code: 'CAN', group: 'B'),
    WorldCupTeam(name: 'Bosnia and Herzegovina', code: 'BIH', group: 'B'),
    WorldCupTeam(name: 'Qatar', code: 'QAT', group: 'B'),
    WorldCupTeam(name: 'Switzerland', code: 'SUI', group: 'B'),
  ],
  'C': [
    WorldCupTeam(name: 'Brazil', code: 'BRA', group: 'C'),
    WorldCupTeam(name: 'Morocco', code: 'MAR', group: 'C'),
    WorldCupTeam(name: 'Haiti', code: 'HAI', group: 'C'),
    WorldCupTeam(name: 'Scotland', code: 'SCO', group: 'C'),
  ],
  'D': [
    WorldCupTeam(name: 'United States', code: 'USA', group: 'D'),
    WorldCupTeam(name: 'Paraguay', code: 'PAR', group: 'D'),
    WorldCupTeam(name: 'Australia', code: 'AUS', group: 'D'),
    WorldCupTeam(name: 'Turkiye', code: 'TUR', group: 'D'),
  ],
  'E': [
    WorldCupTeam(name: 'Germany', code: 'GER', group: 'E'),
    WorldCupTeam(name: 'Curacao', code: 'CUW', group: 'E'),
    WorldCupTeam(name: "Cote d'Ivoire", code: 'CIV', group: 'E'),
    WorldCupTeam(name: 'Ecuador', code: 'ECU', group: 'E'),
  ],
  'F': [
    WorldCupTeam(name: 'Netherlands', code: 'NED', group: 'F'),
    WorldCupTeam(name: 'Japan', code: 'JPN', group: 'F'),
    WorldCupTeam(name: 'Sweden', code: 'SWE', group: 'F'),
    WorldCupTeam(name: 'Tunisia', code: 'TUN', group: 'F'),
  ],
  'G': [
    WorldCupTeam(name: 'Belgium', code: 'BEL', group: 'G'),
    WorldCupTeam(name: 'Egypt', code: 'EGY', group: 'G'),
    WorldCupTeam(name: 'IR Iran', code: 'IRN', group: 'G'),
    WorldCupTeam(name: 'New Zealand', code: 'NZL', group: 'G'),
  ],
  'H': [
    WorldCupTeam(name: 'Spain', code: 'ESP', group: 'H'),
    WorldCupTeam(name: 'Cabo Verde', code: 'CPV', group: 'H'),
    WorldCupTeam(name: 'Saudi Arabia', code: 'KSA', group: 'H'),
    WorldCupTeam(name: 'Uruguay', code: 'URU', group: 'H'),
  ],
  'I': [
    WorldCupTeam(name: 'France', code: 'FRA', group: 'I'),
    WorldCupTeam(name: 'Senegal', code: 'SEN', group: 'I'),
    WorldCupTeam(name: 'Iraq', code: 'IRQ', group: 'I'),
    WorldCupTeam(name: 'Norway', code: 'NOR', group: 'I'),
  ],
  'J': [
    WorldCupTeam(name: 'Argentina', code: 'ARG', group: 'J'),
    WorldCupTeam(name: 'Algeria', code: 'ALG', group: 'J'),
    WorldCupTeam(name: 'Austria', code: 'AUT', group: 'J'),
    WorldCupTeam(name: 'Jordan', code: 'JOR', group: 'J'),
  ],
  'K': [
    WorldCupTeam(name: 'Portugal', code: 'POR', group: 'K'),
    WorldCupTeam(name: 'DR Congo', code: 'COD', group: 'K'),
    WorldCupTeam(name: 'Uzbekistan', code: 'UZB', group: 'K'),
    WorldCupTeam(name: 'Colombia', code: 'COL', group: 'K'),
  ],
  'L': [
    WorldCupTeam(name: 'England', code: 'ENG', group: 'L'),
    WorldCupTeam(name: 'Croatia', code: 'CRO', group: 'L'),
    WorldCupTeam(name: 'Ghana', code: 'GHA', group: 'L'),
    WorldCupTeam(name: 'Panama', code: 'PAN', group: 'L'),
  ],
};

final List<WorldCupFixture> worldCupFixtures = [
  WorldCupFixture(
    group: 'A',
    home: 'Mexico',
    away: 'South Africa',
    venue: 'Mexico City Stadium',
    kickoff: DateTime(2026, 6, 11, 20),
  ),
  WorldCupFixture(
    group: 'B',
    home: 'Canada',
    away: 'Bosnia and Herzegovina',
    venue: 'Toronto Stadium',
    kickoff: DateTime(2026, 6, 12, 19),
  ),
  WorldCupFixture(
    group: 'D',
    home: 'United States',
    away: 'Paraguay',
    venue: 'Los Angeles Stadium',
    kickoff: DateTime(2026, 6, 12, 22),
  ),
  WorldCupFixture(
    group: 'C',
    home: 'Brazil',
    away: 'Morocco',
    venue: 'Miami Stadium',
    kickoff: DateTime(2026, 6, 13, 18),
  ),
  WorldCupFixture(
    group: 'J',
    home: 'Argentina',
    away: 'Algeria',
    venue: 'New York New Jersey Stadium',
    kickoff: DateTime(2026, 6, 15, 21),
  ),
  WorldCupFixture(
    group: 'I',
    home: 'France',
    away: 'Senegal',
    venue: 'Boston Stadium',
    kickoff: DateTime(2026, 6, 16, 20),
  ),
  WorldCupFixture(
    group: 'K',
    home: 'Portugal',
    away: 'Colombia',
    venue: 'Houston Stadium',
    kickoff: DateTime(2026, 6, 17, 21),
  ),
  WorldCupFixture(
    group: 'H',
    home: 'Spain',
    away: 'Uruguay',
    venue: 'Miami Stadium',
    kickoff: DateTime(2026, 6, 18, 22),
  ),
];

const List<WorldCupPlayerStat> worldCupPlayerStats = [
  WorldCupPlayerStat(
    name: 'Kylian Mbappe',
    team: 'France',
    position: 'FWD',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 13.0,
  ),
  WorldCupPlayerStat(
    name: 'Lionel Messi',
    team: 'Argentina',
    position: 'FWD',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 12.5,
  ),
  WorldCupPlayerStat(
    name: 'Erling Haaland',
    team: 'Norway',
    position: 'FWD',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 12.0,
  ),
  WorldCupPlayerStat(
    name: 'Vinicius Junior',
    team: 'Brazil',
    position: 'FWD',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 11.5,
  ),
  WorldCupPlayerStat(
    name: 'Jude Bellingham',
    team: 'England',
    position: 'MID',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 11.0,
  ),
  WorldCupPlayerStat(
    name: 'Lamine Yamal',
    team: 'Spain',
    position: 'FWD',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 10.5,
  ),
  WorldCupPlayerStat(
    name: 'Mohamed Salah',
    team: 'Egypt',
    position: 'FWD',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 10.5,
  ),
  WorldCupPlayerStat(
    name: 'Cristiano Ronaldo',
    team: 'Portugal',
    position: 'FWD',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 10.0,
  ),
  WorldCupPlayerStat(
    name: 'Riyad Mahrez',
    team: 'Algeria',
    position: 'MID',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 9.5,
  ),
  WorldCupPlayerStat(
    name: 'Achraf Hakimi',
    team: 'Morocco',
    position: 'DEF',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 7.0,
  ),
  WorldCupPlayerStat(
    name: 'Manuel Neuer',
    team: 'Germany',
    position: 'GK',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 6.0,
  ),
  WorldCupPlayerStat(
    name: 'Alisson Becker',
    team: 'Brazil',
    position: 'GK',
    goals: 0,
    assists: 0,
    shots: 0,
    chances: 0,
    price: 6.0,
  ),
];

List<WorldCupStanding> standingsForGroup(String group) {
  final rows = worldCupGroups[group]!
      .map((team) => WorldCupStanding(team: team))
      .toList();
  rows.sort(_officialStandingSort);
  return rows;
}

int _officialStandingSort(WorldCupStanding a, WorldCupStanding b) {
  final byPoints = b.points.compareTo(a.points);
  if (byPoints != 0) return byPoints;
  final byGoalDifference = b.goalDifference.compareTo(a.goalDifference);
  if (byGoalDifference != 0) return byGoalDifference;
  final byGoalsFor = b.goalsFor.compareTo(a.goalsFor);
  if (byGoalsFor != 0) return byGoalsFor;
  final byFairPlay = b.fairPlay.compareTo(a.fairPlay);
  if (byFairPlay != 0) return byFairPlay;
  return a.team.name.compareTo(b.team.name);
}

WorldCupTeam? worldCupTeamByName(String name) {
  for (final group in worldCupGroups.values) {
    for (final team in group) {
      if (team.name == name) return team;
    }
  }
  return null;
}

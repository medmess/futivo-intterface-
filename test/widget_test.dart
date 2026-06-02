import 'package:flutter_test/flutter_test.dart';
import 'package:futivo/data/world_cup_2026_data.dart';

void main() {
  test('World Cup group standings follow the official first tiebreakers', () {
    const mexico = WorldCupTeam(name: 'Mexico', code: 'MEX', group: 'A');
    const korea = WorldCupTeam(name: 'Korea Republic', code: 'KOR', group: 'A');

    const mexicoRow = WorldCupStanding(
      team: mexico,
      wins: 1,
      draws: 1,
      goalsFor: 3,
      goalsAgainst: 1,
    );
    const koreaRow = WorldCupStanding(
      team: korea,
      wins: 1,
      draws: 1,
      goalsFor: 2,
      goalsAgainst: 1,
    );

    expect(mexicoRow.points, koreaRow.points);
    expect(mexicoRow.goalDifference, greaterThan(koreaRow.goalDifference));
  });

  test('Every World Cup team has a logo url', () {
    final teams = worldCupGroups.values.expand((group) => group);

    for (final team in teams) {
      expect(team.logoUrl, startsWith('https://flagcdn.com/w80/'));
      expect(team.logoUrl, isNot(contains('null')));
    }
  });
}

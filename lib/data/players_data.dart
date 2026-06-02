import '../models/player.dart';
import 'world_cup_2026_data.dart';

Player _fromStat(WorldCupPlayerStat stat, int index) {
  return Player(
    id: 'wc26-${stat.team.toLowerCase().replaceAll(' ', '-')}-${index + 1}',
    name: stat.name,
    club: stat.team,
    position: stat.position,
    price: stat.price,
    points: stat.attackingPoints,
  );
}

final List<Player> allPlayers = [
  for (var i = 0; i < worldCupPlayerStats.length; i++)
    _fromStat(worldCupPlayerStats[i], i),
  const Player(
    id: 'wc26-france-keeper',
    name: 'Mike Maignan',
    club: 'France',
    position: 'GK',
    price: 5.8,
    points: 0,
  ),
  const Player(
    id: 'wc26-england-def',
    name: 'John Stones',
    club: 'England',
    position: 'DEF',
    price: 6.2,
    points: 0,
  ),
  const Player(
    id: 'wc26-portugal-def',
    name: 'Ruben Dias',
    club: 'Portugal',
    position: 'DEF',
    price: 6.3,
    points: 0,
  ),
  const Player(
    id: 'wc26-argentina-mid',
    name: 'Enzo Fernandez',
    club: 'Argentina',
    position: 'MID',
    price: 8.0,
    points: 0,
  ),
];

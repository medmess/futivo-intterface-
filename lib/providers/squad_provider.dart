import 'package:flutter/material.dart';

import '../models/player.dart';

class SquadProvider extends ChangeNotifier {
  final List<Player> _squad = [];
  String? _captainId;
  String? _viceCaptainId;

  final double budget = 100.0;

  List<Player> get squad => _squad;
  String? get captainId =>
      _captainId ?? (_squad.isNotEmpty ? _squad.first.id : null);
  String? get viceCaptainId =>
      _viceCaptainId ?? (_squad.length > 1 ? _squad[1].id : null);

  double get usedBudget {
    return _squad.fold<double>(0, (total, player) => total + player.price);
  }

  double get remainingBudget {
    return budget - usedBudget;
  }

  bool isSelected(Player player) {
    return _squad.any((p) => p.id == player.id);
  }

  int countByPosition(String position) {
    return _squad.where((p) => p.position == position).length;
  }

  int maxByPosition(String position) {
    switch (position) {
      case 'GK':
        return 2;
      case 'DEF':
        return 5;
      case 'MID':
        return 5;
      case 'FWD':
        return 4;
      default:
        return 0;
    }
  }

  bool canAdd(Player player) {
    if (_squad.length >= 16) return false;
    if (isSelected(player)) return false;
    if (remainingBudget < player.price) return false;

    final positionCount = countByPosition(player.position);
    final positionMax = maxByPosition(player.position);

    if (positionCount >= positionMax) return false;

    return true;
  }

  String? reasonCannotAdd(Player player) {
    if (isSelected(player)) {
      return "This player is already in your squad.";
    }

    if (_squad.length >= 16) {
      return "Your squad is full. Maximum 16 players.";
    }

    if (remainingBudget < player.price) {
      return "Not enough budget.";
    }

    final positionCount = countByPosition(player.position);
    final positionMax = maxByPosition(player.position);

    if (positionCount >= positionMax) {
      return "You already selected maximum ${player.position} players.";
    }

    return null;
  }

  void addPlayer(Player player) {
    if (!canAdd(player)) return;

    _squad.add(player);
    _ensureCaptainRoles();
    notifyListeners();
  }

  void removePlayer(Player player) {
    _squad.removeWhere((p) => p.id == player.id);
    if (_captainId == player.id) _captainId = null;
    if (_viceCaptainId == player.id) _viceCaptainId = null;
    _ensureCaptainRoles();
    notifyListeners();
  }

  void movePlayer({required int fromIndex, required int toIndex}) {
    if (fromIndex == toIndex) return;
    if (fromIndex < 0 || fromIndex >= _squad.length) return;
    if (toIndex < 0 || toIndex >= _squad.length) return;

    final movingPlayer = _squad[fromIndex];
    _squad[fromIndex] = _squad[toIndex];
    _squad[toIndex] = movingPlayer;
    notifyListeners();
  }

  void setCaptain(Player player) {
    if (!isSelected(player)) return;
    _captainId = player.id;
    if (_viceCaptainId == player.id) _viceCaptainId = null;
    _ensureCaptainRoles();
    notifyListeners();
  }

  void setViceCaptain(Player player) {
    if (!isSelected(player)) return;
    _viceCaptainId = player.id;
    if (_captainId == player.id) _captainId = null;
    _ensureCaptainRoles();
    notifyListeners();
  }

  void _ensureCaptainRoles() {
    if (_squad.isEmpty) {
      _captainId = null;
      _viceCaptainId = null;
      return;
    }

    final captainStillExists =
        _captainId != null && _squad.any((p) => p.id == _captainId);
    if (!captainStillExists) _captainId = _squad.first.id;

    final viceStillExists =
        _viceCaptainId != null &&
        _viceCaptainId != _captainId &&
        _squad.any((p) => p.id == _viceCaptainId);
    if (!viceStillExists) {
      _viceCaptainId = _squad
          .firstWhere(
            (player) => player.id != _captainId,
            orElse: () => _squad.first,
          )
          .id;
    }
  }

  bool get isSquadComplete {
    return _squad.length == 16 &&
        countByPosition('GK') == 2 &&
        countByPosition('DEF') == 5 &&
        countByPosition('MID') == 5 &&
        countByPosition('FWD') == 4;
  }
}

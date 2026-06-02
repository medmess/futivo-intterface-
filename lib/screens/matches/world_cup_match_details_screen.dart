import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../data/world_cup_2026_data.dart';
import '../../models/manual_match_details.dart';
import '../../services/backend_api_service.dart';

class WorldCupMatchDetailsScreen extends StatefulWidget {
  final WorldCupFixture fixture;

  const WorldCupMatchDetailsScreen({super.key, required this.fixture});

  @override
  State<WorldCupMatchDetailsScreen> createState() =>
      _WorldCupMatchDetailsScreenState();
}

class _WorldCupMatchDetailsScreenState
    extends State<WorldCupMatchDetailsScreen> {
  final _backend = BackendApiService();
  late Future<ManualMatchDetails> _future;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ManualMatchDetails> _load() {
    return _backend.getManualMatchDetails(widget.fixture.matchId);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final fixture = widget.fixture;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.t('matchDetails'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: context.t('refresh'),
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _refresh,
        child: FutureBuilder<ManualMatchDetails>(
          future: _future,
          builder: (context, snapshot) {
            final details =
                snapshot.data ?? ManualMatchDetails.empty(fixture.matchId);
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              children: [
                _MatchHero(fixture: fixture, details: details),
                const SizedBox(height: 16),
                _TabSelector(
                  selected: _tab,
                  onChanged: (value) => setState(() => _tab = value),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.only(top: 44),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  _EmptyPanel(
                    icon: Icons.cloud_off_rounded,
                    title: context.t('manualDataUnavailable'),
                    message: context.t('manualDataUnavailableMessage'),
                  )
                else if (_tab == 0)
                  _OverviewTab(fixture: fixture, details: details)
                else if (_tab == 1)
                  _LineupsTab(fixture: fixture, details: details)
                else
                  _EventsTab(details: details),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MatchHero extends StatelessWidget {
  final WorldCupFixture fixture;
  final ManualMatchDetails details;

  const _MatchHero({required this.fixture, required this.details});

  @override
  Widget build(BuildContext context) {
    final score = _score(details.events, fixture);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceLight, AppColors.background],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Pill(text: '${context.t('group')} ${fixture.group}'),
              const Spacer(),
              Text(
                _formatDate(fixture.kickoff),
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _TeamSide(team: fixture.home)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  score,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(child: _TeamSide(team: fixture.away)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            fixture.venue,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _score(List<MatchEventData> events, WorldCupFixture fixture) {
    final goals = events.where((event) {
      final type = event.type.toLowerCase();
      final detail = (event.detail ?? '').toLowerCase();
      return type == 'goal' || detail.contains('penalty scored');
    });
    final home = goals.where((event) => event.team == fixture.home).length;
    final away = goals.where((event) => event.team == fixture.away).length;
    if (goals.isEmpty) return 'VS';
    return '$home - $away';
  }
}

class _TeamSide extends StatelessWidget {
  final String team;

  const _TeamSide({required this.team});

  @override
  Widget build(BuildContext context) {
    final data = worldCupTeamByName(team);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            data?.logoUrl ?? '',
            width: 52,
            height: 38,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.flag_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          team,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TabSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _TabSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.t('overview'),
      context.t('lineups'),
      context.t('events'),
    ];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: selected == i
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected == i
                          ? AppColors.background
                          : Colors.white60,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final WorldCupFixture fixture;
  final ManualMatchDetails details;

  const _OverviewTab({required this.fixture, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoPanel(
          title: context.t('matchInformation'),
          children: [
            _InfoRow(label: context.t('venue'), value: fixture.venue),
            _InfoRow(
              label: context.t('kickoff'),
              value: _formatDate(fixture.kickoff),
            ),
            _InfoRow(label: context.t('matchId'), value: fixture.matchId),
          ],
        ),
        const SizedBox(height: 14),
        _InfoPanel(
          title: context.t('manualDataStatus'),
          children: [
            _InfoRow(
              label: context.t('lineups'),
              value: details.hasLineups
                  ? context.t('available')
                  : context.t('pending'),
            ),
            _InfoRow(
              label: context.t('events'),
              value: details.hasEvents
                  ? context.t('available')
                  : context.t('pending'),
            ),
          ],
        ),
      ],
    );
  }
}

class _LineupsTab extends StatelessWidget {
  final WorldCupFixture fixture;
  final ManualMatchDetails details;

  const _LineupsTab({required this.fixture, required this.details});

  @override
  Widget build(BuildContext context) {
    if (!details.hasLineups) {
      return _EmptyPanel(
        icon: Icons.groups_rounded,
        title: context.t('lineupsPending'),
        message: context.t('lineupsPendingMessage'),
      );
    }

    return Column(
      children: [
        _LineupPanel(
          team: fixture.home,
          formation: details.homeFormation,
          players: details.homeLineup,
        ),
        const SizedBox(height: 14),
        _LineupPanel(
          team: fixture.away,
          formation: details.awayFormation,
          players: details.awayLineup,
        ),
      ],
    );
  }
}

class _EventsTab extends StatelessWidget {
  final ManualMatchDetails details;

  const _EventsTab({required this.details});

  @override
  Widget build(BuildContext context) {
    if (!details.hasEvents) {
      return _EmptyPanel(
        icon: Icons.timeline_rounded,
        title: context.t('eventsPending'),
        message: context.t('eventsPendingMessage'),
      );
    }

    return Column(
      children: details.events
          .map((event) => _ManualEventRow(event: event))
          .toList(),
    );
  }
}

class _LineupPanel extends StatelessWidget {
  final String team;
  final String? formation;
  final List<MatchLineupPlayer> players;

  const _LineupPanel({
    required this.team,
    required this.formation,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoPanel(
      title: formation == null ? team : '$team - $formation',
      children: [
        for (final player in players)
          _InfoRow(
            label: player.shirtNumber == null ? '-' : '#${player.shirtNumber}',
            value: [
              player.name,
              if (player.position != null) player.position!,
              if (!player.starter) context.t('substitute'),
            ].join('  '),
          ),
      ],
    );
  }
}

class _ManualEventRow extends StatelessWidget {
  final MatchEventData event;

  const _ManualEventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _color(event);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Text(
            "${event.minute}'",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 14),
          Icon(_icon(event), color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.player,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle(context, event),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(BuildContext context, MatchEventData event) {
    final parts = [
      event.team,
      _label(context, event),
      if (event.assist?.trim().isNotEmpty == true)
        '${context.t('assist')}: ${event.assist}',
    ];
    return parts.join(' - ');
  }

  String _label(BuildContext context, MatchEventData event) {
    final type = event.type.toLowerCase();
    final detail = (event.detail ?? '').toLowerCase();
    if (detail.contains('penalty') && event.scored == true) {
      return context.t('penaltyScored');
    }
    if (detail.contains('penalty') && event.scored == false) {
      return context.t('penaltyMissed');
    }
    if (detail.contains('red')) return context.t('redCard');
    if (detail.contains('yellow')) return context.t('yellowCard');
    if (type == 'goal') return context.t('goal');
    return event.detail ?? event.type;
  }

  IconData _icon(MatchEventData event) {
    final type = event.type.toLowerCase();
    final detail = (event.detail ?? '').toLowerCase();
    if (detail.contains('red')) return Icons.stop_rounded;
    if (detail.contains('yellow')) return Icons.style_rounded;
    if (detail.contains('penalty')) return Icons.adjust_rounded;
    if (type == 'goal') return Icons.sports_soccer_rounded;
    return Icons.timeline_rounded;
  }

  Color _color(MatchEventData event) {
    final detail = (event.detail ?? '').toLowerCase();
    if (detail.contains('red')) return AppColors.red;
    if (detail.contains('yellow')) return AppColors.gold;
    if (detail.contains('penalty') && event.scored == false) {
      return AppColors.cupRed;
    }
    return AppColors.primaryGlow;
  }
}

class _InfoPanel extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoPanel({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryGlow,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:00';
}

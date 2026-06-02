import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../data/world_cup_2026_data.dart';
import 'world_cup_match_details_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = worldCupFixtures.first;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientTop, AppColors.gradientBottom],
        ),
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          _FeaturedFixture(
            fixture: featured,
            onTap: () => _openDetails(context, featured),
          ),
          const SizedBox(height: 22),
          Text(
            context.t('worldCupMatches'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < worldCupFixtures.length; i++)
            _AnimatedListItem(
              index: i,
              child: _FixtureCard(
                fixture: worldCupFixtures[i],
                onTap: () => _openDetails(context, worldCupFixtures[i]),
              ),
            ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context, WorldCupFixture fixture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorldCupMatchDetailsScreen(fixture: fixture),
      ),
    );
  }
}

class _AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (index.clamp(0, 10) * 30)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _FeaturedFixture extends StatelessWidget {
  final WorldCupFixture fixture;
  final VoidCallback onTap;

  const _FeaturedFixture({required this.fixture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surfaceLight, AppColors.background],
          ),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.32)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _GoldPill(text: context.t('openingMatch')),
                const Spacer(),
                Text(
                  '${context.t('group')} ${fixture.group}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: _TeamBlock(team: worldCupTeamByName(fixture.home)),
                ),
                const Text(
                  'VS',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Expanded(
                  child: _TeamBlock(team: worldCupTeamByName(fixture.away)),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              '${_formatDate(fixture.kickoff)} - ${fixture.venue}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FixtureCard extends StatelessWidget {
  final WorldCupFixture fixture;
  final VoidCallback onTap;

  const _FixtureCard({required this.fixture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 360;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Row(
              children: [
                Container(
                  width: compact ? 40 : 48,
                  height: compact ? 40 : 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    fixture.group,
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: compact ? 17 : 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: compact ? 9 : 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _MiniLogo(team: worldCupTeamByName(fixture.home)),
                          SizedBox(width: compact ? 5 : 8),
                          Expanded(
                            child: Text(
                              fixture.home,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: compact ? 12.5 : 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 3 : 6,
                            ),
                            child: const Text(
                              'vs',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          _MiniLogo(team: worldCupTeamByName(fixture.away)),
                          SizedBox(width: compact ? 5 : 8),
                          Expanded(
                            child: Text(
                              fixture.away,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: compact ? 12.5 : 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        fixture.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 10),
                  Text(
                    _formatShort(fixture.kickoff),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamBlock extends StatelessWidget {
  final WorldCupTeam? team;

  const _TeamBlock({required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: _TeamLogo(team: team, size: 46),
        ),
        const SizedBox(height: 10),
        Text(
          team?.name ?? '',
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

class _MiniLogo extends StatelessWidget {
  final WorldCupTeam? team;

  const _MiniLogo({required this.team});

  @override
  Widget build(BuildContext context) {
    return _TeamLogo(team: team, size: 24);
  }
}

class _TeamLogo extends StatelessWidget {
  final WorldCupTeam? team;
  final double size;

  const _TeamLogo({required this.team, required this.size});

  @override
  Widget build(BuildContext context) {
    final team = this.team;
    if (team == null) return _fallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.network(
        team.logoUrl,
        width: size,
        height: size * 0.72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Icon(Icons.flag_rounded, color: AppColors.gold, size: size * 0.85);
  }
}

class _GoldPill extends StatelessWidget {
  final String text;

  const _GoldPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.gold,
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

String _formatShort(DateTime date) {
  return '${date.day}/${date.month}\n${date.hour.toString().padLeft(2, '0')}:00';
}

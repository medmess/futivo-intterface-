import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../fantasy/fantasy_hub_screen.dart';
import '../matches/matches_screen.dart';
import '../news/news_screen.dart';
import '../profile/profile_screen.dart';
import '../standings/standings_screen.dart';
import '../stats/player_stats_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int currentIndex;

  final pages = const [
    NewsScreen(),
    MatchesScreen(),
    StandingsScreen(),
    PlayerStatsScreen(),
    FantasyHubScreen(),
  ];

  final titleKeys = const [
    'news',
    'matches',
    'standings',
    'players',
    'fantasy',
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex.clamp(0, pages.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 18,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: Row(
            children: const [
              const Expanded(
                child: ColoredBox(
                  color: AppColors.cupGreen,
                  child: SizedBox(height: 5),
                ),
              ),
              const Expanded(
                child: ColoredBox(
                  color: AppColors.white,
                  child: SizedBox(height: 5),
                ),
              ),
              const Expanded(
                child: ColoredBox(
                  color: AppColors.cupRed,
                  child: SizedBox(height: 5),
                ),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                'assets/futivo_logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('appName'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    context.t(titleKeys[currentIndex]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.025, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: pages[currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.navBar,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cupRed.withValues(alpha: 0.22),
              blurRadius: 22,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.navBar,
          selectedItemColor: AppColors.cupRed,
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.article_rounded),
              label: context.t('news'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.sports_soccer_rounded),
              label: context.t('matches'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.leaderboard_rounded),
              label: context.t('groups'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.query_stats_rounded),
              label: context.t('stats'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome_rounded),
              label: context.t('fantasy'),
            ),
          ],
        ),
      ),
    );
  }
}

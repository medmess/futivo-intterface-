import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../groups/groups_screen.dart';
import '../market/market_screen.dart';
import '../team/my_team_screen.dart';
import '../../widgets/common/animated_trionda_ball.dart';

class FantasyHubScreen extends StatefulWidget {
  final int initialIndex;

  const FantasyHubScreen({super.key, this.initialIndex = 0});

  @override
  State<FantasyHubScreen> createState() => _FantasyHubScreenState();
}

class _FantasyHubScreenState extends State<FantasyHubScreen> {
  late int index;

  final pages = const [MyTeamScreen(), GroupsScreen(), MarketScreen()];

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex.clamp(0, pages.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const _FantasyAuthGate();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientTop, AppColors.gradientBottom],
        ),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 780),
            curve: Curves.easeOutExpo,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 18 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.cupGreen,
                    AppColors.surfaceLight,
                    AppColors.background,
                    AppColors.cupRed,
                  ],
                  stops: [0.0, 0.60, 0.82, 1.0],
                ),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cupGreen.withValues(alpha: 0.30),
                    blurRadius: 32,
                    offset: const Offset(-14, 10),
                  ),
                  BoxShadow(
                    color: AppColors.cupGreen.withValues(alpha: 0.24),
                    blurRadius: 34,
                    offset: const Offset(14, 16),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const AnimatedTriondaBall(size: 66),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('fantasyControlCenter'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.t('fantasyControlSubtitle'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.cupGreen.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.34)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.white.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _TabButton(
                  label: context.t('myTeam'),
                  icon: Icons.shield_rounded,
                  selected: index == 0,
                  onTap: () => setState(() => index = 0),
                ),
                _TabButton(
                  label: context.t('groups'),
                  icon: Icons.groups_rounded,
                  selected: index == 1,
                  onTap: () => setState(() => index = 1),
                ),
                _TabButton(
                  label: context.t('market'),
                  icon: Icons.storefront_rounded,
                  selected: index == 2,
                  onTap: () => setState(() => index = 2),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FantasyAuthGate extends StatelessWidget {
  const _FantasyAuthGate();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surfaceLight, AppColors.background],
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AnimatedTriondaBall(size: 118),
              const SizedBox(height: 22),
              Text(
                context.t('fantasyAccountRequired'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.t('fantasyAccountRequiredSubtitle'),
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: Text(context.t('login')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_rounded),
                  label: Text(context.t('createAccount')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.cupGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.background : AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AppColors.background
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

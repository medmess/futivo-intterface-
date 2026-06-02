import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/localization/app_language.dart';
import '../../data/world_cup_2026_data.dart';
import '../main/main_navigation_screen.dart';

class FavoriteTeamScreen extends StatefulWidget {
  const FavoriteTeamScreen({super.key});

  @override
  State<FavoriteTeamScreen> createState() => _FavoriteTeamScreenState();
}

class _FavoriteTeamScreenState extends State<FavoriteTeamScreen> {
  String? selectedTeam;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentFavoriteTeam();
  }

  Future<void> _loadCurrentFavoriteTeam() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('favorite_team')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        selectedTeam = profile?['favorite_team'] as String?;
      });
    } catch (_) {
      // Keep the screen usable even if the profile read fails.
    }
  }

  Future<void> _saveFavoriteTeam() async {
    if (selectedTeam == null) return;

    setState(() => isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      await Supabase.instance.client
          .from('profiles')
          .update({'favorite_team': selectedTeam})
          .eq('id', user.id);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('couldNotSaveTeam')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12070A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.t('chooseClub'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.t('chooseClubSubtitle'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: worldCupGroups.values
                      .expand((group) => group)
                      .length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.08,
                  ),
                  itemBuilder: (context, index) {
                    final teams = worldCupGroups.values
                        .expand((group) => group)
                        .toList();
                    final team = teams[index];
                    final isSelected = selectedTeam == team.name;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTeam = team.name;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFFFFF).withOpacity(0.16)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFFFFF)
                                : Colors.white.withOpacity(0.10),
                            width: isSelected ? 1.8 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFFFFF,
                                    ).withOpacity(0.20),
                                    blurRadius: 22,
                                    offset: const Offset(0, 12),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    team.logoUrl,
                                    width: 72,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return const Icon(
                                        Icons.flag_rounded,
                                        color: Color(0xFFFFFFFF),
                                        size: 58,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              team.code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              team.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.62),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: selectedTeam == null || isSaving
                      ? null
                      : _saveFavoriteTeam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFFFF),
                    disabledBackgroundColor: Colors.white.withOpacity(0.12),
                    foregroundColor: const Color(0xFF06120B),
                    disabledForegroundColor: Colors.white38,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Color(0xFF06120B),
                          ),
                        )
                      : Text(
                          context.t('continue'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

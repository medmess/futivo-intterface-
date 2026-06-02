import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../widgets/common/animated_trionda_ball.dart';
import '../../widgets/common/cinematic_background.dart';
import '../main/main_navigation_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _responsiveTitleSize(double width) {
    if (width < 360) return 36;
    if (width < 420) return 40;
    return 44;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final titleSize = _responsiveTitleSize(size.width);

    return Scaffold(
      body: CinematicBackground(
        darkness: 0.82,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      isSmallScreen ? 14 : 20,
                      24,
                      isSmallScreen ? 20 : 32,
                    ),
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  ScaleTransition(
                                    scale: Tween<double>(begin: 0.96, end: 1.04)
                                        .animate(
                                          CurvedAnimation(
                                            parent: _controller,
                                            curve: Curves.easeInOutBack,
                                          ),
                                        ),
                                    child: Image.asset(
                                      'assets/futivo_logo.png',
                                      width: isSmallScreen ? 42 : 48,
                                      height: isSmallScreen ? 42 : 48,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    context.t('appName'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 34 : 70),

                            Column(
                              children: [
                                AnimatedTriondaBall(
                                  size: isSmallScreen ? 124 : 168,
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 22),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 1200),
                                  curve: Curves.easeOutExpo,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 14 * (1 - value)),
                                      child: Opacity(
                                        opacity: value,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(
                                        color: AppColors.cupRed.withOpacity(
                                          0.46,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      context.t('heroBadge'),
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: isSmallScreen ? 14 : 18),

                                Text(
                                  context.t('heroTitle'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: titleSize,
                                    height: 1.02,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.2,
                                  ),
                                ),

                                SizedBox(height: isSmallScreen ? 12 : 14),

                                Text(
                                  context.t('heroSubtitle'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.74),
                                    fontSize: isSmallScreen ? 14.5 : 15.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isSmallScreen ? 34 : 70),

                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: isSmallScreen ? 56 : 60,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const MainNavigationScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.cupRed,
                                      foregroundColor: AppColors.white,
                                      elevation: 18,
                                      shadowColor: AppColors.cupRed.withValues(
                                        alpha: 0.58,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: AppColors.white.withValues(
                                            alpha: 0.55,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.sports_soccer_rounded,
                                          size: 23,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          context.t('getStarted'),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: isSmallScreen ? 14 : 18),

                                FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: AppColors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.t('heroFooter'),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.62),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

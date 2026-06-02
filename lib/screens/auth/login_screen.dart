import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../widgets/common/animated_trionda_ball.dart';
import '../../widgets/common/cinematic_background.dart';
import 'register_screen.dart';
import '../onboarding/favorite_team_screen.dart';
import '../main/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  String? loginError;
  String? passwordError;

  String _clean(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), '');
  }

  bool _isPhone(String value) {
    final phone = _clean(value);
    return RegExp(r'^(05|06|07)[0-9]{8}$').hasMatch(phone);
  }

  Future<void> _handlePostAuthNavigation() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) return;

    final profile = await client
        .from('profiles')
        .select('favorite_team')
        .eq('id', user.id)
        .maybeSingle();

    final favoriteTeam = profile?['favorite_team'];

    if (!mounted) return;

    if (favoriteTeam == null || favoriteTeam.toString().trim().isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FavoriteTeamScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _login() async {
    setState(() {
      loginError = null;
      passwordError = null;
    });

    final login = _clean(loginController.text);
    final password = passwordController.text.trim();

    bool hasError = false;

    if (login.isEmpty) {
      loginError = context.t('enterLogin');
      hasError = true;
    }

    if (password.isEmpty) {
      passwordError = context.t('enterPassword');
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => isLoading = true);

    try {
      String? email;

      if (_isPhone(login)) {
        email = "$login@fantasydz.demo";
      } else {
        final result = await Supabase.instance.client.rpc(
          'get_login_email',
          params: {'login_input': login},
        );

        email = result as String?;
      }

      if (email == null) {
        setState(() {
          loginError = context.t('noAccount');
        });
        return;
      }

      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await _handlePostAuthNavigation();
    } on AuthException {
      setState(() {
        passwordError = context.t('wrongPassword');
      });
    } catch (_) {
      _showMessage(context.t('loginFailed'));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CinematicBackground(
        darkness: 0.88,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                Row(
                  children: [
                    Image.asset(
                      'assets/futivo_logo.png',
                      width: 44,
                      height: 44,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.t('appName'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                const Center(
                  child: AnimatedTriondaBall(size: 116, opacity: 0.96),
                ),
                const SizedBox(height: 28),
                Text(
                  context.t('welcomeBack'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.t('loginSubtitle'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 15.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 34),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 850),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.94 + value * 0.06,
                      child: Opacity(opacity: value.clamp(0, 1), child: child),
                    );
                  },
                  child: _glassCard(
                    child: Column(
                      children: [
                        _inputField(
                          controller: loginController,
                          hint: context.t('phoneOrNickname'),
                          icon: Icons.account_circle_rounded,
                          errorText: loginError,
                        ),
                        const SizedBox(height: 16),
                        _inputField(
                          controller: passwordController,
                          hint: context.t('password'),
                          icon: Icons.lock_rounded,
                          obscureText: hidePassword,
                          errorText: passwordError,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => hidePassword = !hidePassword);
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cupRed,
                              foregroundColor: Colors.white,
                              elevation: 16,
                              shadowColor: AppColors.cupRed.withValues(
                                alpha: 0.58,
                              ),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: AppColors.white.withValues(
                                    alpha: 0.48,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(19),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    context.t('login'),
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
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 0,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        context.t('newToFantasy'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.68),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                      child: Text(
                        context.t('createAccount'),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.72),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cupRed.withOpacity(0.20),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.16),
            blurRadius: 50,
            offset: const Offset(-16, -12),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.10),
        hintText: hint,
        errorText: errorText,
        errorStyle: const TextStyle(
          color: Color(0xFFFF6B6B),
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.48),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: AppColors.white),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.4),
        ),
      ),
    );
  }
}

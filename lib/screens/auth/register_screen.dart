import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../widgets/common/animated_trionda_ball.dart';
import '../../widgets/common/cinematic_background.dart';
import '../onboarding/favorite_team_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final nicknameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  Timer? nicknameDebounce;
  bool isCheckingNickname = false;
  bool? isNicknameAvailable;

  String? fullNameError;
  String? nicknameError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;

  String _cleanPhone(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), '');
  }

  String _cleanNickname(String value) {
    return value.trim().toLowerCase();
  }

  String _phoneToEmail(String phone) {
    return '$phone@fantasydz.demo';
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^(05|06|07)[0-9]{8}$').hasMatch(phone);
  }

  bool _isValidNickname(String nickname) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(nickname);
  }

  Future<bool> _alreadyUsed(String value) async {
    final result = await Supabase.instance.client.rpc(
      'get_login_email',
      params: {'login_input': value},
    );

    return result != null;
  }

  void _onNicknameChanged(String value) {
    nicknameDebounce?.cancel();

    final nickname = _cleanNickname(value);

    setState(() {
      nicknameError = null;
      isNicknameAvailable = null;
    });

    if (nickname.isEmpty) return;

    if (!_isValidNickname(nickname)) {
      setState(() {
        nicknameError = "Use 3-20 letters, numbers, or _ only";
      });
      return;
    }

    nicknameDebounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        isCheckingNickname = true;
      });

      try {
        final used = await _alreadyUsed(nickname);

        if (!mounted) return;

        setState(() {
          isNicknameAvailable = !used;
          nicknameError = used ? "This nickname is already used" : null;
        });
      } catch (_) {
        if (!mounted) return;

        setState(() {
          isNicknameAvailable = null;
        });
      } finally {
        if (mounted) {
          setState(() {
            isCheckingNickname = false;
          });
        }
      }
    });
  }

  Future<void> _register() async {
    setState(() {
      fullNameError = null;
      nicknameError = null;
      phoneError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    final fullName = fullNameController.text.trim();
    final nickname = _cleanNickname(nicknameController.text);
    final phone = _cleanPhone(phoneController.text);
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    bool hasError = false;

    if (fullName.isEmpty) {
      fullNameError = "Full name is required";
      hasError = true;
    }

    if (nickname.isEmpty) {
      nicknameError = "Nickname is required";
      hasError = true;
    } else if (!_isValidNickname(nickname)) {
      nicknameError = "Use 3-20 letters, numbers, or _ only";
      hasError = true;
    }

    if (phone.isEmpty) {
      phoneError = "Phone number is required";
      hasError = true;
    } else if (!_isValidPhone(phone)) {
      phoneError = "Phone must start with 05, 06, or 07 and contain 10 digits";
      hasError = true;
    }

    if (password.isEmpty) {
      passwordError = "Password is required";
      hasError = true;
    } else if (password.length < 6) {
      passwordError = "Password must be at least 6 characters";
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError = "Confirm your password";
      hasError = true;
    } else if (password != confirmPassword) {
      confirmPasswordError = "Passwords do not match";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => isLoading = true);

    try {
      final phoneUsed = await _alreadyUsed(phone);
      if (phoneUsed) {
        setState(() {
          phoneError = "This phone number is already used";
        });
        return;
      }

      final nicknameUsed = await _alreadyUsed(nickname);
      if (nicknameUsed) {
        setState(() {
          nicknameError = "This nickname is already used";
        });
        return;
      }

      final email = _phoneToEmail(phone);

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'nickname': nickname, 'phone': phone},
      );

      final user = response.user;

      if (user == null) {
        _showMessage(context.t('login'));
        if (mounted) Navigator.pop(context);
        return;
      }

      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'nickname': nickname,
        'phone': phone,
        'role': 'user',
        'favorite_team': null,
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FavoriteTeamScreen()),
        (route) => false,
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
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
    nicknameDebounce?.cancel();
    fullNameController.dispose();
    nicknameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CinematicBackground(
        darkness: 0.90,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.10),
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: AnimatedTriondaBall(size: 112, opacity: 0.96),
                ),
                const SizedBox(height: 24),
                Text(
                  context.t('registerTitle'),
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
                  context.t('registerSubtitle'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 15.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 950),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 28 * (1 - value)),
                      child: Transform.scale(
                        scale: 0.96 + value * 0.04,
                        child: Opacity(
                          opacity: value.clamp(0, 1),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _glassCard(
                    child: Column(
                      children: [
                        _inputField(
                          controller: fullNameController,
                          hint: context.t('fullName'),
                          icon: Icons.person_rounded,
                          errorText: fullNameError,
                        ),
                        const SizedBox(height: 16),
                        _inputField(
                          controller: nicknameController,
                          hint: context.t('nickname'),
                          icon: Icons.sports_soccer_rounded,
                          errorText: nicknameError,
                          onChanged: _onNicknameChanged,
                          suffixIcon: isCheckingNickname
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  ),
                                )
                              : isNicknameAvailable == true
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.white,
                                )
                              : isNicknameAvailable == false
                              ? const Icon(
                                  Icons.cancel_rounded,
                                  color: Color(0xFFFF6B6B),
                                )
                              : null,
                        ),
                        if (isNicknameAvailable == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                context.t('nicknameAvailable'),
                                style: const TextStyle(
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        _inputField(
                          controller: phoneController,
                          hint: context.t('phoneNumber'),
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          errorText: phoneError,
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
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _inputField(
                          controller: confirmPasswordController,
                          hint: context.t('confirmPassword'),
                          icon: Icons.verified_user_rounded,
                          obscureText: hideConfirmPassword,
                          errorText: confirmPasswordError,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hideConfirmPassword = !hideConfirmPassword;
                              });
                            },
                            icon: Icon(
                              hideConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _register,
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
                                    context.t('createAccount'),
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
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.10),
        hintText: hint,
        errorText: errorText,
        prefixIcon: Icon(icon, color: AppColors.white),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

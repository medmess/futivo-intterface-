import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/localization/app_language.dart';
import 'core/theme/app_theme.dart';
import 'providers/fantasy_score_provider.dart';
import 'providers/squad_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/fantasy/fantasy_hub_screen.dart';
import 'screens/main/main_navigation_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/profile/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const SponsorCaptureApp());
}

class SponsorCaptureApp extends StatelessWidget {
  const SponsorCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = Uri.base.queryParameters['screen'] ?? 'news';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SquadProvider()),
        ChangeNotifierProvider(create: (_) => FantasyScoreProvider()),
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
      ],
      child: Consumer<AppLanguageProvider>(
        builder: (context, languageProvider, _) {
          return AppLanguageScope(
            language: languageProvider.language,
            textDirection: languageProvider.textDirection,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: "Futivo",
              theme: AppTheme.darkTheme,
              locale: languageProvider.locale,
              supportedLocales: const [
                Locale('fr'),
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: _SponsorCaptureHome(screen: screen),
            ),
          );
        },
      ),
    );
  }
}

class _SponsorCaptureHome extends StatefulWidget {
  final String screen;

  const _SponsorCaptureHome({required this.screen});

  @override
  State<_SponsorCaptureHome> createState() => _SponsorCaptureHomeState();
}

class _SponsorCaptureHomeState extends State<_SponsorCaptureHome> {
  late final Future<void> _sessionFuture = _applySession();

  Future<void> _applySession() async {
    final params = Uri.base.queryParameters;
    final refreshToken = params['refresh_token'];
    if (refreshToken == null || refreshToken.isEmpty) {
      return;
    }

    await Supabase.instance.client.auth.setSession(refreshToken);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFF120006),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF1F4B)),
            ),
          );
        }

        return _screenFor(widget.screen);
      },
    );
  }

  Widget _screenFor(String screen) {
    return switch (screen) {
      'welcome' => const WelcomeScreen(),
      'matches' => const MainNavigationScreen(initialIndex: 1),
      'groups' => const MainNavigationScreen(initialIndex: 2),
      'stats' => const MainNavigationScreen(initialIndex: 3),
      'fantasy' => const MainNavigationScreen(initialIndex: 4),
      'fantasy_groups' => const _FantasyOnlyScreen(initialIndex: 1),
      'fantasy_market' => const _FantasyOnlyScreen(initialIndex: 2),
      'profile' => const ProfileScreen(),
      'login' => const LoginScreen(),
      _ => const MainNavigationScreen(initialIndex: 0),
    };
  }
}

class _FantasyOnlyScreen extends StatelessWidget {
  final int initialIndex;

  const _FantasyOnlyScreen({required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120006),
      body: SafeArea(child: FantasyHubScreen(initialIndex: initialIndex)),
    );
  }
}

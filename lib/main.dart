import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/localization/app_language.dart';
import 'core/theme/app_theme.dart';
import 'providers/fantasy_score_provider.dart';
import 'providers/squad_provider.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const FutivoApp());
}

class FutivoApp extends StatelessWidget {
  const FutivoApp({super.key});

  @override
  Widget build(BuildContext context) {
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
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: mediaQuery.textScaler.clamp(
                      minScaleFactor: 0.90,
                      maxScaleFactor: 1.16,
                    ),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}

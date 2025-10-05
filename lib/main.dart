import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/localization_service.dart';

void main() {
  runApp(const SpaceTestApp());
}

/// Dil Durumu Yönetimi
class LanguageProvider with ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.turkish;
  
  AppLanguage get currentLanguage => _currentLanguage;
  Locale get locale => _currentLanguage.locale;
  
  void changeLanguage(AppLanguage language) {
    _currentLanguage = language;
    notifyListeners();
  }
}

class SpaceTestApp extends StatelessWidget {
  const SpaceTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'ImpactSim',
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr'),
              Locale('en'),
            ],
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFF0A0E27),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1A1F3A),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
                headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

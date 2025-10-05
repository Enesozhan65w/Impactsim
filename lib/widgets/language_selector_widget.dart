import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../main.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return PopupMenuButton<AppLanguage>(
      icon: const Icon(Icons.language, color: Colors.white),
      tooltip: localizations?.changeLanguage ?? 'Change Language',
      onSelected: (AppLanguage language) {
        languageProvider.changeLanguage(language);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<AppLanguage>(
          value: AppLanguage.turkish,
          child: Row(
            children: [
              const Text('🇹🇷', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(AppLanguage.turkish.name),
              if (languageProvider.currentLanguage == AppLanguage.turkish) ...[
                const Spacer(),
                const Icon(Icons.check, color: Colors.green),
              ],
            ],
          ),
        ),
        PopupMenuItem<AppLanguage>(
          value: AppLanguage.english,
          child: Row(
            children: [
              const Text('🇺🇸', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(AppLanguage.english.name),
              if (languageProvider.currentLanguage == AppLanguage.english) ...[
                const Spacer(),
                const Icon(Icons.check, color: Colors.green),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Dil seçimi dialog'u
class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F3A),
      title: Text(
        localizations?.languageSelection ?? 'Language Selection',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localizations?.selectLanguage ?? 'Select Language',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          
          // Türkçe seçeneği
          ListTile(
            leading: const Text('🇹🇷', style: TextStyle(fontSize: 24)),
            title: Text(
              AppLanguage.turkish.name,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: languageProvider.currentLanguage == AppLanguage.turkish
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              languageProvider.changeLanguage(AppLanguage.turkish);
              Navigator.of(context).pop();
            },
          ),
          
          // İngilizce seçeneği
          ListTile(
            leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
            title: Text(
              AppLanguage.english.name,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: languageProvider.currentLanguage == AppLanguage.english
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              languageProvider.changeLanguage(AppLanguage.english);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            localizations?.close ?? 'Close',
            style: const TextStyle(color: Color(0xFF4A90E2)),
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectionDialog(),
    );
  }
}

import 'package:flutter/material.dart';
import 'scenario_selection_screen.dart';
import 'about_screen.dart';
import 'test_history_screen.dart';
import 'asteroid_scenario_intro_screen.dart';
import 'impactor_2025_screen.dart';
import 'mitigation_strategies_screen.dart';
import '../services/localization_service.dart';
import '../widgets/language_selector_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const LanguageSelectorWidget(),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2A2F4A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Logo ve Başlık
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    size: 80,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  localizations?.appTitle ?? 'ImpactSim',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 36,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations?.welcomeSubtitle ?? 'NASA-standard realistic rocket and asteroid simulations',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Ana Senaryo Butonları
                _buildScenarioCard(
                  context,
                  title: localizations?.rocketSimulation ?? 'Rocket Simulation',
                  subtitle: localizations?.isTurkish == true 
                    ? 'Roket tasarla, test et ve optimize et'
                    : 'Design, test and optimize rockets',
                  icon: Icons.rocket_launch,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScenarioSelectionScreen(),
                      ),
                    );
                  },
                  color: const Color(0xFF4A90E2),
                ),
                const SizedBox(height: 16),
                
                _buildScenarioCard(
                  context,
                  title: localizations?.asteroidSimulation ?? 'Asteroid Simulation',
                  subtitle: localizations?.isTurkish == true 
                    ? 'Dünya\'yı koru! Çarpma simülasyonu ve savunma'
                    : 'Protect Earth! Impact simulation and defense',
                  icon: Icons.public,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AsteroidScenarioIntroScreen(),
                      ),
                    );
                  },
                  color: const Color(0xFFE17055),
                ),
                const SizedBox(height: 20),
                
                // Hızlı Erişim Butonları
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAccessButton(
                        context,
                        'IMPACTOR-2025',
                        Icons.warning,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Impactor2025Screen(),
                            ),
                          );
                        },
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAccessButton(
                        context,
                        localizations?.isTurkish == true ? 'Saptırma Stratejileri' : 'Deflection Strategies',
                        Icons.shield,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MitigationStrategiesScreen(),
                            ),
                          );
                        },
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMainButton(
                  context,
                  localizations?.testHistory ?? 'Test History',
                  Icons.history,
                  () {
                    _navigateToTestHistory(context);
                  },
                  color: const Color(0xFF4A90E2),
                ),
                const SizedBox(height: 16),
                _buildMainButton(
                  context,
                  localizations?.about ?? 'About',
                  Icons.info_outline,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                  color: const Color(0xFF4A90E2),
                ),
                
                const SizedBox(height: 40),
                
                // Alt bilgi
                Text(
                  localizations?.isTurkish == true 
                    ? 'Roketinizi tasarlayın, test edin ve Dünya\'yı koruyun!'
                    : 'Design your rockets, test them and protect Earth!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.7),
            color.withOpacity(0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    final buttonColor = color ?? const Color(0xFF4A90E2);
    
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: buttonColor.withOpacity(0.3),
        ),
      ),
    );
  }

  void _navigateToTestHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TestHistoryScreen(),
      ),
    );
  }
}

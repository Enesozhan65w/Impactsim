import 'package:flutter/material.dart';
import '../models/impactor_2025_scenario.dart';

/// Oyunlaştırma widget'ı - "Dünya'yı Savun" oyunu
class GamificationWidget extends StatefulWidget {
  final int score;
  final int attemptsLeft;
  final Impactor2025Scenario scenario;
  final VoidCallback? onRestart;
  final VoidCallback? onNewChallenge;

  const GamificationWidget({
    super.key,
    required this.score,
    required this.attemptsLeft,
    required this.scenario,
    this.onRestart,
    this.onNewChallenge,
  });

  @override
  State<GamificationWidget> createState() => _GamificationWidgetState();
}

class _GamificationWidgetState extends State<GamificationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late AnimationController _badgeAnimationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _badgeAnimation;

  @override
  void initState() {
    super.initState();
    
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _badgeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.elasticOut),
    );
    
    _badgeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeAnimationController, curve: Curves.bounceOut),
    );
    
    _scoreAnimationController.forward();
    
    if (_shouldShowBadge()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _badgeAnimationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _badgeAnimationController.dispose();
    super.dispose();
  }

  bool _shouldShowBadge() {
    return widget.scenario.isDeflectionSuccessful || widget.score >= 1000;
  }

  GameBadge _getCurrentBadge() {
    if (widget.scenario.isDeflectionSuccessful) {
      if (widget.attemptsLeft >= 2) {
        return GameBadge.perfectDefender;
      } else if (widget.attemptsLeft >= 1) {
        return GameBadge.skillfulDefender;
      } else {
        return GameBadge.lastChanceHero;
      }
    } else if (widget.score >= 500) {
      return GameBadge.strategist;
    } else {
      return GameBadge.rookie;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F3A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildScoreSection(),
            const SizedBox(height: 20),
            _buildProgressSection(),
            const SizedBox(height: 20),
            if (_shouldShowBadge()) _buildBadgeSection(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.green.withOpacity(0.8),
                Colors.blue.withOpacity(0.6),
              ],
            ),
          ),
          child: const Icon(
            Icons.shield,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DÜNYA\'YI SAVUN!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Asteroit Savunma Simülasyonu',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        _buildGameStatus(),
      ],
    );
  }

  Widget _buildGameStatus() {
    final isSuccess = widget.scenario.isDeflectionSuccessful;
    final isGameOver = widget.attemptsLeft <= 0;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (isSuccess) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'BAŞARILI';
    } else if (isGameOver) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'BAŞARISIZ';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.play_circle_filled;
      statusText = 'DEVAM';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: _buildScoreCard(
                'SKOR',
                (widget.score * _scoreAnimation.value).toInt().toString(),
                Icons.stars,
                Colors.yellow,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildScoreCard(
                'KALAN DENEME',
                widget.attemptsLeft.toString(),
                Icons.favorite,
                Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildScoreCard(
                'ZAMAN',
                _getTimeRemaining(),
                Icons.timer,
                Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = widget.scenario.appliedStrategy != null ? 1.0 : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Görev İlerlemesi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white12,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.scenario.isDeflectionSuccessful ? Colors.green : Colors.orange,
          ),
          minHeight: 8,
        ),
        const SizedBox(height: 12),
        _buildMissionSteps(),
      ],
    );
  }

  Widget _buildMissionSteps() {
    final steps = [
      MissionStep('Asteroit Analizi', true, Icons.search),
      MissionStep('Strateji Seçimi', widget.scenario.appliedStrategy != null, Icons.settings),
      MissionStep('Saptırma İşlemi', widget.scenario.appliedStrategy != null, Icons.rocket_launch),
      MissionStep('Sonuç Değerlendirmesi', widget.scenario.isDeflectionSuccessful, Icons.assessment),
    ];
    
    return Column(
      children: steps.map((step) => _buildMissionStepItem(step)).toList(),
    );
  }

  Widget _buildMissionStepItem(MissionStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step.isCompleted ? Colors.green : Colors.white12,
              border: Border.all(
                color: step.isCompleted ? Colors.green : Colors.white30,
              ),
            ),
            child: Icon(
              step.isCompleted ? Icons.check : step.icon,
              size: 14,
              color: step.isCompleted ? Colors.white : Colors.white60,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            step.title,
            style: TextStyle(
              color: step.isCompleted ? Colors.white : Colors.white60,
              fontSize: 14,
              fontWeight: step.isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeSection() {
    final badge = _getCurrentBadge();
    
    return AnimatedBuilder(
      animation: _badgeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _badgeAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  badge.color.withOpacity(0.2),
                  badge.color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: badge.color.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        badge.color.withOpacity(0.8),
                        badge.color.withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: Icon(
                    badge.icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  badge.title,
                  style: TextStyle(
                    color: badge.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    final results = widget.scenario.results;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detaylı İstatistikler',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatRow('Uygulanan Strateji', results.appliedStrategy?.name ?? 'Yok'),
        _buildStatRow('Iskalama Mesafesi', '${results.missDistance.toStringAsFixed(0)} km'),
        _buildStatRow('Kurtarılan Can', '${results.livesaved} kişi'),
        _buildStatRow('Ekonomik Tasarruf', '\$${results.economicSavings.toStringAsFixed(1)}M'),
        if (widget.scenario.appliedStrategy != null)
          _buildStatRow('Başarı Oranı', '${(widget.scenario.appliedStrategy!.successRate * 100).toInt()}%'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onNewChallenge,
            icon: const Icon(Icons.add_circle),
            label: const Text('Yeni Meydan Okuma'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _getTimeRemaining() {
    final timeUntilImpact = widget.scenario.impactDate.difference(DateTime.now());
    if (timeUntilImpact.isNegative) return '0g';
    return '${timeUntilImpact.inDays}g';
  }
}

/// Görev adımı modeli
class MissionStep {
  final String title;
  final bool isCompleted;
  final IconData icon;

  MissionStep(this.title, this.isCompleted, this.icon);
}

/// Oyun rozeti modeli
class GameBadge {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const GameBadge({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  static const perfectDefender = GameBadge(
    title: 'Mükemmel Savunucu',
    description: 'İlk denemede asteroiti başarıyla saptırdın!',
    icon: Icons.shield,
    color: GameColors.gold,
  );

  static const skillfulDefender = GameBadge(
    title: 'Yetenekli Savunucu',
    description: 'Az denemede büyük başarı!',
    icon: Icons.military_tech,
    color: GameColors.silver,
  );

  static const lastChanceHero = GameBadge(
    title: 'Son Şans Kahramanı',
    description: 'Son anda Dünya\'yı kurtardın!',
    icon: Icons.emoji_events,
    color: GameColors.bronze,
  );

  static const strategist = GameBadge(
    title: 'Strateji Uzmanı',
    description: 'Akıllı planlama ile yüksek skor!',
    icon: Icons.psychology,
    color: Colors.purple,
  );

  static const rookie = GameBadge(
    title: 'Acemi Savunucu',
    description: 'İlk adımları attın, devam et!',
    icon: Icons.school,
    color: Colors.grey,
  );
}

/// Renk sabitleri
class GameColors {
  static const gold = Color(0xFFFFD700);
  static const silver = Color(0xFFC0C0C0);
  static const bronze = Color(0xFFCD7F32);
}

/// Leaderboard widget'ı
class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const LeaderboardWidget({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F3A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.leaderboard, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Liderlik Tablosu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...entries.take(10).map((entry) => _buildLeaderboardItem(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    Color rankColor;
    IconData rankIcon;
    
    switch (entry.rank) {
      case 1:
        rankColor = GameColors.gold;
        rankIcon = Icons.looks_one;
        break;
      case 2:
        rankColor = GameColors.silver;
        rankIcon = Icons.looks_two;
        break;
      case 3:
        rankColor = GameColors.bronze;
        rankIcon = Icons.looks_3;
        break;
      default:
        rankColor = Colors.white60;
        rankIcon = Icons.person;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rankColor.withOpacity(0.2),
              border: Border.all(color: rankColor.withOpacity(0.5)),
            ),
            child: Icon(rankIcon, color: rankColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  entry.achievement,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: TextStyle(
              color: rankColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// Liderlik tablosu girişi
class LeaderboardEntry {
  final int rank;
  final String playerName;
  final int score;
  final String achievement;

  LeaderboardEntry({
    required this.rank,
    required this.playerName,
    required this.score,
    required this.achievement,
  });
}

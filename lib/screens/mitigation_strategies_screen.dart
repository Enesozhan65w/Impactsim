import 'package:flutter/material.dart';
import '../services/localization_service.dart';

/// Educational screen showing asteroid deflection strategies
class MitigationStrategiesScreen extends StatefulWidget {
  const MitigationStrategiesScreen({super.key});

  @override
  State<MitigationStrategiesScreen> createState() => _MitigationStrategiesScreenState();
}

class _MitigationStrategiesScreenState extends State<MitigationStrategiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedStrategyIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.isTurkish == true ? 'Asteroit Saptırma Stratejileri' : 'Asteroid Deflection Strategies'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.list), text: localizations?.isTurkish == true ? 'Strateji Listesi' : 'Strategy List'),
            Tab(icon: Icon(Icons.compare), text: localizations?.isTurkish == true ? 'Karşılaştırma' : 'Comparison'),
          ],
        ),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStrategiesList(),
            _buildComparisonChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategiesList() {
    final strategies = _getStrategies();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: strategies.length,
      itemBuilder: (context, index) {
        final strategy = strategies[index];
        return _buildStrategyCard(strategy, index);
      },
    );
  }

  Widget _buildStrategyCard(MitigationStrategy strategy, int index) {
    final isSelected = _selectedStrategyIndex == index;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isSelected
          ? const Color(0xFF4A90E2).withOpacity(0.2)
          : Colors.white.withOpacity(0.1),
      child: ExpansionTile(
        leading: Text(
          strategy.icon,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          strategy.name,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          strategy.description,
          style: const TextStyle(color: Colors.white70),
        ),
        onExpansionChanged: (expanded) {
          if (expanded) {
            setState(() {
              _selectedStrategyIndex = index;
            });
          }
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Etkinlik', '${strategy.effectiveness}%', 
                    _getEffectivenessColor(strategy.effectiveness)),
                _buildInfoRow('Süre', strategy.timeRequired, Colors.white),
                _buildInfoRow('Maliyet', strategy.cost, _getCostColor(strategy.cost)),
                
                const SizedBox(height: 16),
                
                _buildAdvantagesDisadvantages(strategy),
                
                const SizedBox(height: 16),
                
                _buildTechnicalDetails(strategy),
                
                const SizedBox(height: 16),
                
                _buildRealWorldExample(strategy),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantagesDisadvantages(MitigationStrategy strategy) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Avantajlar',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...strategy.advantages.map((advantage) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        advantage,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dezavantajlar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...strategy.disadvantages.map((disadvantage) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.close, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        disadvantage,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalDetails(MitigationStrategy strategy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Teknik Detaylar',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...strategy.technicalDetails.map((detail) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.info, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detail,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRealWorldExample(MitigationStrategy strategy) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.public, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Gerçek Dünya Örneği',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            strategy.realWorldExample,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart() {
    final localizations = AppLocalizations.of(context);
    final strategies = _getStrategies();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            localizations?.isTurkish == true ? 'Strateji Karşılaştırması' : 'Strategy Comparison',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          // Effectiveness Comparison
          _buildComparisonSection(localizations?.isTurkish == true ? 'Etkinlik Oranı' : 'Effectiveness Rate', (strategy) => strategy.effectiveness.toDouble()),
          
          const SizedBox(height: 20),
          
          // Time Comparison
          _buildTimeComparisonTable(),
          
          const SizedBox(height: 20),
          
          // Cost Comparison
          _buildCostComparison(),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(String title, double Function(MitigationStrategy) getValue) {
    final strategies = _getStrategies();
    return Column(
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
        const SizedBox(height: 12),
        ...strategies.map((strategy) {
          final value = getValue(strategy);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(strategy.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strategy.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    value: value / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getEffectivenessColor(value.toInt()),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${value.toInt()}%',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeComparisonTable() {
    final strategies = _getStrategies();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zaman Gereksinimleri',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: strategies.map((strategy) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(strategy.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strategy.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Text(
                      strategy.timeRequired,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCostComparison() {
    final localizations = AppLocalizations.of(context);
    final strategies = _getStrategies();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.isTurkish == true ? 'Maliyet Karşılaştırması' : 'Cost Comparison',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: strategies.map((strategy) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getCostColor(strategy.cost).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getCostColor(strategy.cost)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(strategy.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    '${strategy.name}: ${strategy.cost}',
                    style: TextStyle(
                      color: _getCostColor(strategy.cost),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<MitigationStrategy> _getStrategies() {
    final localizations = AppLocalizations.of(context);
    return [
      MitigationStrategy(
        name: localizations?.isTurkish == true ? 'Kinetik Çarpıcı' : 'Kinetic Impactor',
        icon: '🚀',
        description: localizations?.isTurkish == true ? 'Yüksek hızda bir uzay aracını asteroide çarptırarak yörüngesini değiştirme' : 'Changing asteroid orbit by impacting a spacecraft at high speed',
        effectiveness: 85,
        timeRequired: localizations?.isTurkish == true ? 'Minimum 5 yıl' : 'Minimum 5 years',
        cost: localizations?.isTurkish == true ? 'Orta' : 'Medium',
        advantages: localizations?.isTurkish == true ? [
          'Mevcut teknoloji ile uygulanabilir',
          'Test edilmiş yöntem (DART misyonu)',
          'Doğrudan ve etkili',
          'Kısa sürede sonuç verir',
        ] : [
          'Applicable with current technology',
          'Tested method (DART mission)',
          'Direct and effective',
          'Quick results',
        ],
        disadvantages: localizations?.isTurkish == true ? [
          'Asteroit parçalanabilir',
          'Tek kullanımlık sistem',
          'Büyük asteroidler için yetersiz kalabilir',
        ] : [
          'Asteroid may fragment',
          'Single-use system',
          'May be insufficient for large asteroids',
        ],
        realWorldExample: localizations?.isTurkish == true ? 'NASA DART misyonu (2022) - Dimorphos asteroidi başarıyla saptırıldı' : 'NASA DART mission (2022) - Dimorphos asteroid successfully deflected',
        technicalDetails: localizations?.isTurkish == true ? [
          'Çarpıcı hızı: 6-10 km/s',
          'Momentum transferi: Δv = m₁v₁/m₂',
          'Etkileme süresi: Saniyeler',
          'Optimal hedef: 100-500m çaplı asteroidler',
        ] : [
          'Impact velocity: 6-10 km/s',
          'Momentum transfer: Δv = m₁v₁/m₂',
          'Impact duration: Seconds',
          'Optimal target: 100-500m diameter asteroids',
        ],
      ),
      MitigationStrategy(
        name: localizations?.isTurkish == true ? 'Yerçekimi Traktörü' : 'Gravity Tractor',
        icon: '🛸',
        description: localizations?.isTurkish == true ? 'Uzun süre asteroitin yanında kalarak yerçekimi ile yavaşça saptırma' : 'Slow deflection by staying near asteroid for long periods using gravity',
        effectiveness: 75,
        timeRequired: localizations?.isTurkish == true ? 'Minimum 10 yıl' : 'Minimum 10 years',
        cost: localizations?.isTurkish == true ? 'Yüksek' : 'High',
        advantages: localizations?.isTurkish == true ? [
          'Güvenli ve kontrollü',
          'Asteroit parçalanmaz',
          'Uzun süreli etki',
        ] : [
          'Safe and controlled',
          'Asteroid does not fragment',
          'Long-term effect',
        ],
        disadvantages: localizations?.isTurkish == true ? [
          'Çok uzun süre gerektirir',
          'Yüksek maliyet',
          'Karmaşık navigasyon',
        ] : [
          'Requires very long time',
          'High cost',
          'Complex navigation',
        ],
        realWorldExample: localizations?.isTurkish == true ? 'Henüz uygulanmadı, teorik konsept' : 'Not yet implemented, theoretical concept',
        technicalDetails: localizations?.isTurkish == true ? [
          'Yerçekimi kuvveti: F = Gm₁m₂/r²',
          'Sürekli itme gerekli',
          'Yakın mesafe navigasyonu',
        ] : [
          'Gravitational force: F = Gm₁m₂/r²',
          'Continuous thrust required',
          'Close-range navigation',
        ],
      ),
    ];
  }

  Color _getEffectivenessColor(int effectiveness) {
    if (effectiveness >= 90) return Colors.green;
    if (effectiveness >= 70) return Colors.orange;
    if (effectiveness >= 50) return Colors.yellow;
    return Colors.red;
  }

  Color _getCostColor(String cost) {
    switch (cost.toLowerCase()) {
      case 'düşük':
      case 'low': return Colors.green;
      case 'orta':
      case 'medium': return Colors.orange;
      case 'yüksek':
      case 'high': return Colors.red;
      default: return Colors.white;
    }
  }
}

class MitigationStrategy {
  final String name;
  final String icon;
  final String description;
  final int effectiveness;
  final String timeRequired;
  final String cost;
  final List<String> advantages;
  final List<String> disadvantages;
  final String realWorldExample;
  final List<String> technicalDetails;

  MitigationStrategy({
    required this.name,
    required this.icon,
    required this.description,
    required this.effectiveness,
    required this.timeRequired,
    required this.cost,
    required this.advantages,
    required this.disadvantages,
    required this.realWorldExample,
    required this.technicalDetails,
  });
}
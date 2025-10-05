import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/asteroid.dart';
import '../models/impactor_2025_scenario.dart';
import '../models/impact_calculation.dart';
import 'educational_tooltip_widget.dart';

/// Etkileşimli kontrol paneli widget'ı
/// Kullanıcıların asteroit parametrelerini gerçek zamanlı değiştirmesini sağlar
class InteractiveControlPanelWidget extends StatefulWidget {
  final Impactor2025Scenario scenario;
  final Function(Impactor2025Scenario) onScenarioChanged;
  final bool educationalMode;

  const InteractiveControlPanelWidget({
    super.key,
    required this.scenario,
    required this.onScenarioChanged,
    this.educationalMode = true,
  });

  @override
  State<InteractiveControlPanelWidget> createState() => _InteractiveControlPanelWidgetState();
}

class _InteractiveControlPanelWidgetState extends State<InteractiveControlPanelWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Asteroit parametreleri
  late double _diameter;
  late double _velocity;
  late double _density;
  late double _impactAngle;
  
  // Çarpma konumu
  late double _impactLatitude;
  late double _impactLongitude;
  
  // Delta-V parametreleri
  double _deltaV = 0.0;
  int _daysBeforeImpact = 100;
  String _selectedStrategy = 'kinetic';
  
  // Gerçek zamanlı hesaplamalar
  late ImpactCalculation _currentImpactCalc;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Başlangıç değerlerini ayarla
    _diameter = widget.scenario.asteroid.diameter;
    _velocity = widget.scenario.asteroid.velocity / 1000; // km/s cinsine çevir
    _density = widget.scenario.asteroid.density;
    _impactAngle = 45.0; // Varsayılan açı
    _impactLatitude = widget.scenario.impactLatitude;
    _impactLongitude = widget.scenario.impactLongitude;
    
    _updateImpactCalculation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateImpactCalculation() {
    // Kütle hesapla
    final volume = (4/3) * 3.14159 * math.pow(_diameter/2, 3);
    final mass = volume * _density;
    
    final updatedAsteroid = Asteroid.fromLegacyData(
      id: widget.scenario.asteroid.id,
      name: widget.scenario.asteroid.name,
      diameter: _diameter * 1000, // Convert km to meters for legacy format
      velocity: _velocity * 1000, // Convert km/s to m/s
      impactAngle: _impactAngle,
      density: _density, // Already in kg/m³
      composition: widget.scenario.asteroid.composition,
      orbitalPeriod: widget.scenario.asteroid.orbitalPeriodDays,
      distanceFromSun: widget.scenario.asteroid.distanceFromSun,
    );
    
    _currentImpactCalc = ImpactCalculation(
      asteroid: updatedAsteroid, 
      latitude: _impactLatitude, 
      longitude: _impactLongitude,
      locationName: _getLocationName(_impactLatitude, _impactLongitude),
      impactTime: DateTime.now().add(const Duration(days: 180)),
    );
    
    // Senaryo güncelleme  
    final updatedScenario = Impactor2025Scenario.custom(
      asteroid: updatedAsteroid,
      impactLatitude: _impactLatitude,
      impactLongitude: _impactLongitude,
      impactLocation: _getLocationName(_impactLatitude, _impactLongitude),
      daysUntilImpact: 180, // varsayılan değer
    );
    
    widget.onScenarioChanged(updatedScenario);
    
    setState(() {});
  }

  String _getLocationName(double lat, double lng) {
    // Basit konum belirleme (gerçek uygulamada reverse geocoding kullanılabilir)
    if (lat > 35 && lat < 45 && lng > 25 && lng < 45) return 'Türkiye';
    if (lat > 40 && lat < 50 && lng > -10 && lng < 10) return 'Avrupa';
    if (lat > 25 && lat < 50 && lng > -130 && lng < -65) return 'Kuzey Amerika';
    if (lat > -10 && lat < 10 && lng > -180 && lng < 180) return 'Ekvator Bölgesi';
    if (lat.abs() > 60) return 'Kutup Bölgesi';
    return 'Okyanus';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F3A),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          SizedBox(
            height: 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAsteroidParametersTab(),
                _buildImpactLocationTab(),
                _buildMitigationTab(),
              ],
            ),
          ),
          _buildResultsPanel(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: Colors.orange, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Etkileşimli Kontrol Paneli',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Asteroit parametrelerini değiştirin ve sonuçları gerçek zamanlı görün',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (widget.educationalMode)
            EducationalTooltip(
              message: 'Bu panel ile asteroit özelliklerini, çarpma konumunu ve saptırma stratejilerini değiştirebilirsiniz.',
              child: const Icon(Icons.help_outline, color: Colors.white60, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.orange,
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      tabs: const [
        Tab(text: 'Asteroit', icon: Icon(Icons.circle, size: 16)),
        Tab(text: 'Konum', icon: Icon(Icons.location_on, size: 16)),
        Tab(text: 'Saptırma', icon: Icon(Icons.shield, size: 16)),
      ],
    );
  }

  Widget _buildAsteroidParametersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParameterSlider(
            'Çap (metre)',
            _diameter,
            10.0,
            2000.0,
            'Asteroitin çapı. Büyük asteroidler daha fazla hasar verir.',
            (value) {
              setState(() {
                _diameter = value;
              });
              _updateImpactCalculation();
            },
            suffix: 'm',
          ),
          const SizedBox(height: 20),
          _buildParameterSlider(
            'Hız (km/s)',
            _velocity,
            5.0,
            50.0,
            'Asteroitin Dünya\'ya yaklaşma hızı. Yüksek hız = büyük enerji.',
            (value) {
              setState(() {
                _velocity = value;
              });
              _updateImpactCalculation();
            },
            suffix: 'km/s',
          ),
          const SizedBox(height: 20),
          _buildParameterSlider(
            'Yoğunluk (kg/m³)',
            _density,
            1000.0,
            8000.0,
            'Asteroitin yoğunluğu. Metalik asteroidler daha yoğundur.',
            (value) {
              setState(() {
                _density = value;
              });
              _updateImpactCalculation();
            },
            suffix: 'kg/m³',
          ),
          const SizedBox(height: 20),
          _buildParameterSlider(
            'Çarpma Açısı (derece)',
            _impactAngle,
            15.0,
            90.0,
            'Asteroitin yüzeye çarpma açısı. Dik açılar daha etkilidir.',
            (value) {
              setState(() {
                _impactAngle = value;
              });
              _updateImpactCalculation();
            },
            suffix: '°',
          ),
          const SizedBox(height: 20),
          _buildCompositionSelector(),
        ],
      ),
    );
  }

  Widget _buildImpactLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Çarpma Konumu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildLocationMap(),
          const SizedBox(height: 20),
          _buildParameterSlider(
            'Enlem',
            _impactLatitude,
            -90.0,
            90.0,
            'Çarpma noktasının enlemi. Ekvator = 0°, Kuzey Kutbu = 90°',
            (value) {
              setState(() {
                _impactLatitude = value;
              });
              _updateImpactCalculation();
            },
            suffix: '°',
          ),
          const SizedBox(height: 20),
          _buildParameterSlider(
            'Boylam',
            _impactLongitude,
            -180.0,
            180.0,
            'Çarpma noktasının boylamı. Greenwich = 0°, Batı = negatif',
            (value) {
              setState(() {
                _impactLongitude = value;
              });
              _updateImpactCalculation();
            },
            suffix: '°',
          ),
          const SizedBox(height: 20),
          _buildLocationInfo(),
        ],
      ),
    );
  }

  Widget _buildMitigationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saptırma Stratejisi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildStrategySelector(),
          const SizedBox(height: 20),
          _buildParameterSlider(
            'Delta-V (m/s)',
            _deltaV,
            0.0,
            100.0,
            'Asteroite uygulanacak hız değişikliği. Küçük değerler bile etkili olabilir.',
            (value) {
              setState(() {
                _deltaV = value;
              });
            },
            suffix: 'm/s',
          ),
          const SizedBox(height: 20),
          _buildParameterSlider(
            'Uygulama Zamanı (gün önce)',
            _daysBeforeImpact.toDouble(),
            10.0,
            1000.0,
            'Saptırma işleminin çarpma tarihinden kaç gün önce yapılacağı.',
            (value) {
              setState(() {
                _daysBeforeImpact = value.toInt();
              });
            },
            suffix: 'gün',
            isInteger: true,
          ),
          const SizedBox(height: 20),
          _buildMitigationEffectiveness(),
        ],
      ),
    );
  }

  Widget _buildParameterSlider(
    String label,
    double value,
    double min,
    double max,
    String tooltip,
    Function(double) onChanged, {
    String suffix = '',
    bool isInteger = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.educationalMode) ...[
              const SizedBox(width: 8),
              EducationalTooltip(
                message: tooltip,
                child: const Icon(Icons.help_outline, color: Colors.white60, size: 16),
              ),
            ],
            const Spacer(),
            Text(
              isInteger ? '${value.toInt()}$suffix' : '${value.toStringAsFixed(1)}$suffix',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.orange,
            overlayColor: Colors.orange.withOpacity(0.2),
            trackHeight: 4.0,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildCompositionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Kompozisyon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.educationalMode) ...[
              const SizedBox(width: 8),
              EducationalTooltip(
                message: 'Asteroitin mineral kompozisyonu etkisini belirler.',
                child: const Icon(Icons.help_outline, color: Colors.white60, size: 16),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCompositionChip('Taşlı (S-tip)', 'stone'),
            _buildCompositionChip('Metalik (M-tip)', 'metallic'),
            _buildCompositionChip('Karbonlu (C-tip)', 'carbonaceous'),
            _buildCompositionChip('Buz (Komet)', 'ice'),
          ],
        ),
      ],
    );
  }

  Widget _buildCompositionChip(String label, String type) {
    final isSelected = widget.scenario.asteroid.composition.toLowerCase().contains(type);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            // Kompozisyon değişikliği yoğunluğu da etkiler
            switch (type) {
              case 'metallic':
                _density = 7800;
                break;
              case 'stone':
                _density = 3000;
                break;
              case 'carbonaceous':
                _density = 1500;
                break;
              case 'ice':
                _density = 900;
                break;
            }
          });
          _updateImpactCalculation();
        }
      },
      selectedColor: Colors.orange.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
      ),
    );
  }

  Widget _buildLocationMap() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: CustomPaint(
        painter: SimpleWorldMapPainter(
          impactLat: _impactLatitude,
          impactLng: _impactLongitude,
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    final locationName = _getLocationName(_impactLatitude, _impactLongitude);
    final isOcean = locationName == 'Okyanus';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isOcean ? Colors.blue : Colors.green).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isOcean ? Colors.blue : Colors.green).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOcean ? Icons.water : Icons.landscape,
                color: isOcean ? Colors.blue : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                'Çarpma Bölgesi: $locationName',
                style: TextStyle(
                  color: isOcean ? Colors.blue : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isOcean 
              ? 'Okyanus çarpması tsunami riski yaratabilir.' 
              : 'Kara çarpması doğrudan etki yaratır.',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStrategyChip('Kinetik Çarpıcı', 'kinetic', Icons.rocket_launch),
            _buildStrategyChip('Nükleer', 'nuclear', Icons.flash_on),
            _buildStrategyChip('Yerçekimi Çekici', 'gravity', Icons.public),
            _buildStrategyChip('İyon Işını', 'ion', Icons.emoji_objects),
          ],
        ),
      ],
    );
  }

  Widget _buildStrategyChip(String label, String strategy, IconData icon) {
    final isSelected = _selectedStrategy == strategy;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white70),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStrategy = strategy;
          });
        }
      },
      selectedColor: Colors.orange.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
      ),
    );
  }

  Widget _buildMitigationEffectiveness() {
    // Basit etkililik hesaplaması
    final timeFactorBonus = (_daysBeforeImpact / 365.0).clamp(0.1, 2.0);
    final strategyMultiplier = _getStrategyMultiplier(_selectedStrategy);
    final effectiveness = (_deltaV * timeFactorBonus * strategyMultiplier).clamp(0.0, 100.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saptırma Etkililiği',
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: effectiveness / 100.0,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              effectiveness > 50 ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${effectiveness.toStringAsFixed(1)}% başarı olasılığı',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            _getEffectivenessMessage(effectiveness),
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  double _getStrategyMultiplier(String strategy) {
    switch (strategy) {
      case 'kinetic': return 1.0;
      case 'nuclear': return 2.5;
      case 'gravity': return 0.8;
      case 'ion': return 1.2;
      default: return 1.0;
    }
  }

  String _getEffectivenessMessage(double effectiveness) {
    if (effectiveness > 80) return 'Mükemmel! Asteroit büyük olasılıkla saptırılacak.';
    if (effectiveness > 60) return 'İyi! Yüksek başarı şansı var.';
    if (effectiveness > 40) return 'Orta düzey. Ek önlemler gerekebilir.';
    if (effectiveness > 20) return 'Düşük şans. Farklı strategi deneyin.';
    return 'Çok düşük etkililik. Parametreleri gözden geçirin.';
  }

  Widget _buildResultsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1629),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gerçek Zamanlı Sonuçlar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  'Kinetik Enerji',
                  '${(_currentImpactCalc.asteroid.tntEquivalent / 1e6).toStringAsFixed(1)} MT',
                  Icons.flash_on,
                  Colors.yellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultCard(
                  'Krater Çapı',
                  '${_currentImpactCalc.craterDiameter.toStringAsFixed(1)} km',
                  Icons.circle,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultCard(
                  'Etkilenen Alan',
                  '${(_currentImpactCalc.craterDiameter * 5).toStringAsFixed(0)} km²',
                  Icons.scatter_plot,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Basit dünya haritası çizici
class SimpleWorldMapPainter extends CustomPainter {
  final double impactLat;
  final double impactLng;

  SimpleWorldMapPainter({
    required this.impactLat,
    required this.impactLng,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final oceanPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    // Okyanus arka planı
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), oceanPaint);
    
    // Basit kıtalar (çok basitleştirilmiş)
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Kuzey Amerika
    final northAmerica = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX * 0.2, centerY * 0.3, centerX * 0.4, centerY * 0.8),
      const Radius.circular(20),
    );
    canvas.drawRRect(northAmerica, paint);
    
    // Avrupa-Asya
    final eurasia = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX * 0.8, centerY * 0.2, centerX * 1.0, centerY * 0.9),
      const Radius.circular(15),
    );
    canvas.drawRRect(eurasia, paint);
    
    // Afrika
    final africa = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX * 0.9, centerY * 0.7, centerX * 0.3, centerY * 0.8),
      const Radius.circular(10),
    );
    canvas.drawRRect(africa, paint);
    
    // Çarpma noktası
    final impactX = (impactLng + 180) / 360 * size.width;
    final impactY = (90 - impactLat) / 180 * size.height;
    
    final impactPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(impactX, impactY), 8, impactPaint);
    
    // Çarpma noktası pulse efekti
    final pulsePaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(impactX, impactY), 16, pulsePaint);
    final outerPulsePaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(impactX, impactY), 24, outerPulsePaint);
  }

  @override
  bool shouldRepaint(SimpleWorldMapPainter oldDelegate) {
    return oldDelegate.impactLat != impactLat ||
           oldDelegate.impactLng != impactLng;
  }
}

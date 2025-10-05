import 'package:flutter/material.dart';
import 'dart:async';
import '../models/asteroid.dart';
import '../models/impact_calculation.dart';
import '../services/localization_service.dart';
// Unity widget kaldırıldı

class AsteroidSimulationScreen extends StatefulWidget {
  final Asteroid asteroid;
  final double latitude;
  final double longitude;
  final String locationName;

  const AsteroidSimulationScreen({
    super.key,
    required this.asteroid,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<AsteroidSimulationScreen> createState() => _AsteroidSimulationScreenState();
}

class _AsteroidSimulationScreenState extends State<AsteroidSimulationScreen>
    with TickerProviderStateMixin {
  late AnimationController _impactAnimationController;
  late AnimationController _shockwaveAnimationController;
  late Animation<double> _impactAnimation;
  late Animation<double> _shockwaveAnimation;

  Timer? _simulationTimer;
  int _simulationTime = 0;
  bool _isSimulationRunning = false;
  bool _impactOccurred = false;

  late ImpactCalculation _impactCalculation;
  
  // Simülasyon aşamaları
  String _currentPhase = 'Preparation';
  List<String> _phases = [];
  int _currentPhaseIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeImpactCalculation();
  }

  void _initializeAnimations() {
    _impactAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _shockwaveAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _impactAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _impactAnimationController,
      curve: Curves.easeInQuart,
    ));

    _shockwaveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shockwaveAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _initializeImpactCalculation() {
    _impactCalculation = ImpactCalculation(
      asteroid: widget.asteroid,
      latitude: widget.latitude,
      longitude: widget.longitude,
      locationName: widget.locationName,
      impactTime: DateTime.now().add(const Duration(seconds: 15)),
    );
  }

  void _startSimulation() {
    setState(() {
      _isSimulationRunning = true;
      _currentPhaseIndex = 0;
      _currentPhase = _phases[0];
    });

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isSimulationRunning) return;

      setState(() {
        _simulationTime += 2000;
        
        if (_currentPhaseIndex < _phases.length - 1) {
          _currentPhaseIndex++;
          _currentPhase = _phases[_currentPhaseIndex];
          
          // Özel animasyonlar
          if (_currentPhase == 'Impact!') {
            _impactOccurred = true;
            _impactAnimationController.forward();
          } else if (_currentPhase == 'Shockwave') {
            _shockwaveAnimationController.forward();
          }
        } else {
          _endSimulation();
        }
      });
    });
  }

  void _endSimulation() {
    _isSimulationRunning = false;
    _simulationTimer?.cancel();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _impactAnimationController.dispose();
    _shockwaveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    // Initialize phases if not done
    if (_phases.isEmpty) {
      _phases = [
        localizations?.asteroidApproaching ?? 'Asteroid Approaching',
        localizations?.atmosphereEntry ?? 'Atmosphere Entry',
        localizations?.impact ?? 'Impact!',
        localizations?.shockwave ?? 'Shockwave',
        localizations?.thermalEffect ?? 'Thermal Effect',
        localizations?.seismicWave ?? 'Seismic Wave',
        localizations?.impactResults ?? 'Results'
      ];
      _currentPhase = localizations?.preparation ?? 'Preparation';
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.asteroidImpactSimulation ?? 'Asteroid Impact Simulation'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _isSimulationRunning ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
        child: SafeArea(
          child: _isSimulationRunning
              ? _buildSimulationView()
              : _buildPreSimulationView(),
        ),
      ),
    );
  }

  Widget _buildPreSimulationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asteroit bilgileri
          _buildAsteroidInfoCard(),
          const SizedBox(height: 16),
          
          // Konum bilgileri
          _buildLocationInfoCard(),
          const SizedBox(height: 16),
          
          // Tahmin edilen etkiler
          _buildImpactPredictionCard(),
          const SizedBox(height: 32),
          
          // Başlat butonu
          Center(
            child: ElevatedButton.icon(
              onPressed: _startSimulation,
              icon: const Icon(Icons.play_arrow, size: 32),
              label: Text(
                AppLocalizations.of(context)?.startSimulation ?? 'Start Simulation',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationView() {
    return Column(
      children: [
        // Phase indicator
        _buildPhaseIndicator(),
        
        // Unity 3D Asteroid Simulation
        Expanded(
          flex: 3,
          child: _buildUnityAsteroidSimulation(),
        ),
        
        // Gerçek zamanlı veriler
        Expanded(
          flex: 2,
          child: _buildRealTimeData(),
        ),
      ],
    );
  }

  Widget _buildAsteroidInfoCard() {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.circle, color: Color(0xFF4A90E2), size: 24),
                const SizedBox(width: 12),
                Text(
                  widget.asteroid.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoItem(AppLocalizations.of(context)?.diameter ?? 'Diameter', '${widget.asteroid.diameter.round()} m')),
                Expanded(child: _buildInfoItem(AppLocalizations.of(context)?.velocity ?? 'Velocity', '${(widget.asteroid.velocity/1000).round()} km/s')),
                Expanded(child: _buildInfoItem(AppLocalizations.of(context)?.mass ?? 'Mass', '${(widget.asteroid.mass/1e6).toStringAsFixed(1)} ${AppLocalizations.of(context)?.mTons ?? 'M tons'}')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoItem(AppLocalizations.of(context)?.composition ?? 'Composition', widget.asteroid.composition)),
                Expanded(child: _buildInfoItem(AppLocalizations.of(context)?.category ?? 'Category', widget.asteroid.category)),
                Expanded(child: _buildInfoItem(AppLocalizations.of(context)?.riskLevel ?? 'Risk', widget.asteroid.riskLevel)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Text(
                '${AppLocalizations.of(context)?.energy ?? 'Energy'}: ${widget.asteroid.tntEquivalent.toStringAsExponential(2)} ${AppLocalizations.of(context)?.tntEquivalent ?? 'tons TNT equivalent'}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard() {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)?.impactSite ?? 'Impact Site',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.locationName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)?.coordinates ?? 'Coordinates'}: ${widget.latitude.toStringAsFixed(4)}°, ${widget.longitude.toStringAsFixed(4)}°',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactPredictionCard() {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)?.predictedEffects ?? 'Predicted Effects',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildPredictionItem(AppLocalizations.of(context)?.craterDiameter ?? 'Crater Diameter', '${(_impactCalculation.craterDiameter/1000).toStringAsFixed(1)} km')),
                Expanded(child: _buildPredictionItem(AppLocalizations.of(context)?.shockRadius ?? 'Shock Radius', '${_impactCalculation.shockwaveRadius.toStringAsFixed(1)} km')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPredictionItem(AppLocalizations.of(context)?.earthquake ?? 'Earthquake', '${_impactCalculation.earthquakeMagnitude.toStringAsFixed(1)} ${AppLocalizations.of(context)?.richter ?? 'Richter'}')),
                Expanded(child: _buildPredictionItem(AppLocalizations.of(context)?.estimatedCasualties ?? 'Estimated Casualties', '${_impactCalculation.totalCasualties} ${AppLocalizations.of(context)?.people ?? 'people'}')),
              ],
            ),
            const SizedBox(height: 12),
            if (_impactCalculation.tsunamiRisk) 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${AppLocalizations.of(context)?.tsunamiRisk ?? 'TSUNAMI RISK'}: ${_impactCalculation.tsunamiWaveHeight.toStringAsFixed(1)}m ${AppLocalizations.of(context)?.waveHeight ?? 'wave height'}',
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPredictionItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.red, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUnityAsteroidSimulation() {
    // Unity widget kaldırıldığı için basit animasyon
    return _buildSimulationAnimation();
  }

  Widget _buildPhaseIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _currentPhase,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentPhaseIndex + 1) / _phases.length,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _impactOccurred ? Colors.red : const Color(0xFF4A90E2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationAnimation() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dünya
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withOpacity(0.8),
                  Colors.green.withOpacity(0.6),
                  Colors.brown.withOpacity(0.4),
                ],
              ),
            ),
          ),
          
          // Asteroit
          if (!_impactOccurred)
            AnimatedBuilder(
              animation: _impactAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 50 + (200 * _impactAnimation.value),
                  child: Container(
                    width: 20 + (10 * _impactAnimation.value),
                    height: 20 + (10 * _impactAnimation.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 10 + (20 * _impactAnimation.value),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          
          // Çarpma efekti
          if (_impactOccurred)
            AnimatedBuilder(
              animation: _shockwaveAnimation,
              builder: (context, child) {
                return Container(
                  width: 120 + (200 * _shockwaveAnimation.value),
                  height: 120 + (200 * _shockwaveAnimation.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withOpacity(1 - _shockwaveAnimation.value),
                      width: 3,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRealTimeData() {
    if (_currentPhaseIndex < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            AppLocalizations.of(context)?.asteroidIsApproaching ?? 'Asteroid is approaching...',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDataCard(AppLocalizations.of(context)?.craterDiameter ?? 'Crater Diameter', '${(_impactCalculation.craterDiameter/1000).toStringAsFixed(2)} km', Icons.circle_outlined, Colors.brown)),
              const SizedBox(width: 12),
              Expanded(child: _buildDataCard(AppLocalizations.of(context)?.shockRadius ?? 'Shock Radius', '${_impactCalculation.shockwaveRadius.toStringAsFixed(1)} km', Icons.waves, Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDataCard(AppLocalizations.of(context)?.earthquake ?? 'Earthquake', '${_impactCalculation.earthquakeMagnitude.toStringAsFixed(1)} M', Icons.vibration, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildDataCard(AppLocalizations.of(context)?.casualties ?? 'Casualties', '${_formatNumber(_impactCalculation.totalCasualties)}', Icons.people, Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          if (_impactCalculation.tsunamiRisk)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.waves, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '${AppLocalizations.of(context)?.tsunami ?? 'Tsunami'}: ${_impactCalculation.tsunamiWaveHeight.toStringAsFixed(1)}m',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

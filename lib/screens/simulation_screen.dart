import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'result_screen.dart';
import '../models/physics_calculator.dart';
import '../services/web_physics_service.dart';
import '../services/test_storage_service.dart';
import '../models/test_result.dart';
import '../models/rocket_types.dart';
import '../services/localization_service.dart';
// Unity widget kaldırıldı

class SimulationScreen extends StatefulWidget {
  final Map<String, dynamic> rocketData;
  final String environment;
  
  const SimulationScreen({
    super.key,
    required this.rocketData,
    required this.environment,
  });

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> with TickerProviderStateMixin {
  late AnimationController _rocketAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _rocketAnimation;
  late Animation<double> _progressAnimation;
  
  Timer? _simulationTimer;
  int _simulationTime = 0;
  bool _isSimulationRunning = true;
  
  // Simülasyon verileri
  double _speed = 0.0;
  double _temperature = 20.0;
  double _fuelLevel = 100.0;
  double _damage = 0.0;
  List<String> _warnings = [];
  
  // Ortam faktörleri
  Map<String, dynamic> _environmentFactors = {};
  
  // Web fizik servisi
  final WebPhysicsService _physicsService = WebPhysicsService.instance;
  bool _useWebPhysics = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeEnvironmentFactors();
    _initializeWebPhysics();
    _startSimulation();
  }
  
  void _initializeAnimations() {
    _rocketAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    
    _rocketAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rocketAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.linear,
    ));
    
    _rocketAnimationController.repeat(reverse: true);
    _progressAnimationController.forward();
  }
  
  void _initializeEnvironmentFactors() {
    _environmentFactors = PhysicsCalculator.calculateEnvironmentFactors(widget.environment);
  }
  
  void _initializeWebPhysics() async {
    try {
      await _physicsService.initialize();
      _physicsService.initializeEnvironment(widget.environment);
      _physicsService.createRocket(widget.rocketData);
      _physicsService.setupRenderer();
      
      setState(() {
        _useWebPhysics = true;
      });
      
      print('Web physics engine started successfully');
      print('Debug info: ${_physicsService.getDebugInfo()}');
    } catch (e) {
      print('Web physics engine could not be started: $e');
      setState(() {
        _useWebPhysics = false;
      });
    }
  }
  
  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isSimulationRunning) return;
      
      setState(() {
        _simulationTime += 500;
        _updateSimulationData();
        
        // Simülasyon 30 saniye sonra bitir
        if (_simulationTime >= 30000) {
          _endSimulation();
        }
      });
    });
  }
  
  void _updateSimulationData() {
    final progress = _simulationTime / 30000.0;
    final deltaTime = 0.5; // 500ms = 0.5 saniye
    
    if (_useWebPhysics && _physicsService.isReady) {
      // Web fizik motorunu kullan
      try {
        // İtki uygula (motor çalışıyorsa)
        if (_fuelLevel > 0) {
          _physicsService.applyThrust(intensity: 0.8);
        }
        
        // Simülasyon verilerini güncelle
        final webData = _physicsService.updateSimulation(
          progress, 
          deltaTime, 
          isEngineRunning: _fuelLevel > 0
        );
        
        _speed = webData['speed'] ?? _speed;
        _temperature = webData['temperature'] ?? _temperature;
        _fuelLevel = webData['fuel'] ?? _fuelLevel;
        _damage = webData['damage'] ?? _damage;
        _warnings = webData['warnings'] ?? _warnings;
        
        print('Web fizik verileri: Hız=${_speed.round()}, Sıcaklık=${_temperature.round()}, Yakıt=${_fuelLevel.round()}');
      } catch (e) {
        print('Web fizik güncelleme hatası: $e');
        // Fallback olarak Dart hesaplamalarını kullan
        _updateWithDartPhysics(progress, deltaTime);
      }
    } else {
      // Dart fizik hesaplamalarını kullan
      _updateWithDartPhysics(progress, deltaTime);
    }
  }
  
  void _updateWithDartPhysics(double progress, double deltaTime) {
    // GERÇEKÇİ ROKET TİPİ KONTROLÜ VE FİZİK
    
    // Use real rocket type if preset model is selected
    RocketType? rocketType;
    if (widget.rocketData['type'] == 'preset') {
      final modelName = widget.rocketData['model'] as String;
      rocketType = _getRocketTypeFromModel(modelName);
    }
    
    // Gerçek fizik hesaplamalarını kullan
    _speed = _calculateRealisticSpeed(progress, deltaTime, rocketType);
    
    _temperature = PhysicsCalculator.calculateTemperature(
      _environmentFactors,
      progress,
      _fuelLevel > 0, // Motor çalışıyor mu?
    );
    
    // Yakıt tüketimi
    double fuelConsumption = PhysicsCalculator.calculateFuelConsumption(
      widget.rocketData,
      _environmentFactors,
      progress,
      deltaTime,
    );
    _fuelLevel -= fuelConsumption;
    _fuelLevel = _fuelLevel.clamp(0, 100);
    
    // Hasar hesaplama
    double damageIncrease = PhysicsCalculator.calculateDamage(
      widget.rocketData,
      _environmentFactors,
      _temperature,
      progress,
      deltaTime,
    );
    _damage += damageIncrease;
    _damage = _damage.clamp(0, 100);
    
    // Uyarılar
    _warnings = PhysicsCalculator.generateWarnings(
      _temperature,
      _fuelLevel,
      _damage,
      _speed,
      _environmentFactors,
    );
  }
  
  /// Model adından roket tipini belirle
  RocketType? _getRocketTypeFromModel(String modelName) {
    switch (modelName) {
      case 'SLS (NASA)':
        return RocketType.sls;
      case 'Falcon 9 (SpaceX)':
        return RocketType.falcon9;
      case 'Falcon Heavy (SpaceX)':
        return RocketType.falconHeavy;
      case 'Atlas V (ULA)':
        return RocketType.atlasV;
      case 'Electron (Rocket Lab)':
        return RocketType.electron;
      default:
        return null;
    }
  }

  /// Gerçekçi hız hesaplaması - roket tipine göre
  double _calculateRealisticSpeed(double progress, double deltaTime, RocketType? rocketType) {
    if (rocketType == null) {
      // Hazır model değilse eski hesaplama yöntemi
      return PhysicsCalculator.calculateSpeed(
        widget.rocketData,
        _environmentFactors,
        progress,
        deltaTime,
      );
    }

    // GERÇEKÇİ ROKET FİZİĞİ!
    final rocketData = RocketPerformanceData.getForType(rocketType);
    final currentTime = _simulationTime / 1000.0; // saniye cinsinden

    // Gerçek roket hızlanma profili
    double baseSpeed = rocketData.getSpeedAtTime(currentTime);
    
    // Çevresel faktörler (atmosfer, yerçekimi vs.)
    double environmentMultiplier = 1.0;
    switch (widget.environment) {
      case 'LEO':
        environmentMultiplier = 0.95; // Atmosfer direnci
        break;
      case 'Mars':
        environmentMultiplier = 1.1; // Düşük yerçekimi
        break;
      case 'Ay':
        environmentMultiplier = 1.2; // Çok düşük yerçekimi
        break;
      case 'Boşluk':
        environmentMultiplier = 1.3; // Direnç yok
        break;
    }

    // Yakıt durumuna göre performans
    double fuelMultiplier = 1.0;
    if (_fuelLevel < 20) {
      fuelMultiplier = 0.8; // Düşük yakıtta performans düşer
    } else if (_fuelLevel < 50) {
      fuelMultiplier = 0.9; // Orta yakıtta hafif düşüş
    }

    // Hasar durumuna göre performans
    double damageMultiplier = 1.0;
    if (_damage > 30) {
      damageMultiplier = 0.85; // Hasarlı roket yavaş
    }

    final finalSpeed = baseSpeed * environmentMultiplier * fuelMultiplier * damageMultiplier;
    
    // Debug için yazdır
    print('🚀 GERÇEK FİZİK: ${rocketType.displayName} - ${currentTime.toStringAsFixed(1)}s: ${finalSpeed.toStringAsFixed(1)} m/s (Base: ${baseSpeed.toStringAsFixed(1)})');
    
    return finalSpeed;
  }

  void _endSimulation() async {
    _isSimulationRunning = false;
    _simulationTimer?.cancel();
    _rocketAnimationController.stop();
    _progressAnimationController.stop();
    
    // Sonuç hesaplama
    bool isSuccessful = _damage < 80 && _fuelLevel > 0;
    double successPercentage = ((100 - _damage) * (_fuelLevel / 100)).clamp(0, 100);
    
    final finalStats = {
      'speed': _speed,
      'temperature': _temperature,
      'fuelLevel': _fuelLevel,
      'damage': _damage,
      'warnings': _warnings,
    };
    
    // Test sonucunu kaydet
    try {
      final testResult = TestResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        rocketData: widget.rocketData,
        environment: widget.environment,
        isSuccessful: isSuccessful,
        successPercentage: successPercentage,
        finalStats: finalStats,
        duration: _simulationTime ~/ 1000, // milisaniyeden saniyeye çevir
      );
      
      await TestStorageService.instance.saveTestResult(testResult);
      print('Test sonucu kaydedildi: ${testResult.id}');
    } catch (e) {
      print('Test sonucu kaydetme hatası: $e');
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          rocketData: widget.rocketData,
          environment: widget.environment,
          isSuccessful: isSuccessful,
          successPercentage: successPercentage,
          finalStats: finalStats,
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _simulationTimer?.cancel();
    _rocketAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations?.simulation ?? 'Simulation'} - ${widget.environment}'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // İlerleme çubuğu
                _buildProgressBar(),
                
                const SizedBox(height: 24),
                
                // Unity 3D Roket Simülasyonu
                Expanded(
                  flex: 2,
                  child: _buildUnityRocketSimulation(),
                ),
                
                const SizedBox(height: 24),
                
                // Simülasyon verileri
                Expanded(
                  flex: 3,
                  child: _buildSimulationData(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressBar() {
    final localizations = AppLocalizations.of(context);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations?.simulationRunning ?? 'Simulation Running...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${(_simulationTime / 1000).round()}s / 30s',
              style: const TextStyle(color: Color(0xFF4A90E2), fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildUnityRocketSimulation() {
    // Unity widget kaldırıldığı için basit animasyon
    return _buildRocketAnimation();
  }

  Widget _buildRocketAnimation() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.black.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          // Yıldızlar arka plan - daha çok ve daha gerçekçi
          ...List.generate(50, (index) {
            final random = Random(index);
            final size = 1.0 + random.nextDouble() * 2;
            return Positioned(
              left: random.nextDouble() * 400,
              top: random.nextDouble() * 400,
              child: AnimatedBuilder(
                animation: _rocketAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: (0.4 + _rocketAnimation.value * 0.6) * random.nextDouble(),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: size * 2,
                            spreadRadius: size / 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          
          // Uzay arka planında bulutsu efekti
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rocketAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: SpaceBackgroundPainter(
                    animationValue: _rocketAnimation.value,
                  ),
                );
              },
            ),
          ),
          
          // Ana roket - CustomPainter ile çizilmiş
          Center(
            child: AnimatedBuilder(
              animation: _rocketAnimation,
              builder: (context, child) {
                final progress = _progressAnimation.value;
                final scale = 0.7 + (progress * 0.5);
                final yOffset = 80 - (progress * 130);
                
                return Transform.translate(
                  offset: Offset(
                    sin(_rocketAnimation.value * 2 * pi) * 3,
                    yOffset + (sin(_rocketAnimation.value * pi) * 8),
                  ),
                  child: Transform.scale(
                    scale: scale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateX(sin(_rocketAnimation.value * pi) * 0.08)
                        ..rotateY(cos(_rocketAnimation.value * pi) * 0.05)
                        ..rotateZ(sin(_rocketAnimation.value * 2 * pi) * 0.03),
                      child: CustomPaint(
                        size: const Size(100, 200),
                        painter: RealisticRocketPainter(
                          animationValue: _rocketAnimation.value,
                          fuelLevel: _fuelLevel,
                          temperature: _temperature,
                          isDamaged: _damage > 50,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Ortam göstergesi
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getEnvironmentIcon(),
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.environment,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Hız çizgileri efekti
          if (_speed > 100)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _rocketAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SpeedLinesPainter(
                      speed: _speed,
                      animationValue: _rocketAnimation.value,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
  
  IconData _getEnvironmentIcon() {
    switch (widget.environment) {
      case 'LEO':
        return Icons.public;
      case 'GEO':
        return Icons.satellite;
      case 'Lunar':
        return Icons.nightlight_round;
      case 'Mars':
        return Icons.circle;
      default:
        return Icons.rocket_launch;
    }
  }
  
  Widget _buildSimulationData() {
    final localizations = AppLocalizations.of(context);
    
    return Column(
      children: [
        // Ana veriler
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildDataCard(localizations?.speed ?? 'Speed', '${_speed.round()} m/s', Icons.speed, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildDataCard(localizations?.temperature ?? 'Temperature', '${_temperature.round()}°C', Icons.thermostat, Colors.orange)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildDataCard(localizations?.fuel ?? 'Fuel', '${_fuelLevel.round()}%', Icons.local_gas_station, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildDataCard(localizations?.damage ?? 'Damage', '${_damage.round()}%', Icons.warning, Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Uyarılar
        if (_warnings.isNotEmpty) _buildWarningsSection(),
      ],
    );
  }
  
  Widget _buildDataCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWarningsSection() {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                localizations?.systemWarnings ?? 'System Warnings',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._warnings.map((warning) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $warning',
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          )).toList(),
        ],
      ),
    );
  }
}

/// Gerçekçi roket çizimi için CustomPainter
class RealisticRocketPainter extends CustomPainter {
  final double animationValue;
  final double fuelLevel;
  final double temperature;
  final bool isDamaged;

  RealisticRocketPainter({
    required this.animationValue,
    required this.fuelLevel,
    required this.temperature,
    required this.isDamaged,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    
    // Ana roket gövdesi - silindirik ve 3D görünümlü
    _drawRocketBody(canvas, size, centerX, paint);
    
    // Roket burnu (koni)
    _drawRocketNose(canvas, size, centerX, paint);
    
    // Kanatlar
    _drawFins(canvas, size, centerX, paint);
    
    // Pencere/Kapsül
    _drawWindow(canvas, size, centerX, paint);
    
    // Detaylar ve çıkartmalar
    _drawDetails(canvas, size, centerX, paint);
    
    // Motor bölümü
    _drawEngine(canvas, size, centerX, paint);
    
    // Alev efekti
    _drawFlames(canvas, size, centerX, paint);
    
    // Hasar efekti
    if (isDamaged) {
      _drawDamageEffects(canvas, size, centerX, paint);
    }
  }

  void _drawRocketBody(Canvas canvas, Size size, double centerX, Paint paint) {
    // Ana gövde - gradient ile 3D efekti
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 25, 40, 50, 80),
      const Radius.circular(8),
    );
    
    // Gölgeleme için koyu taraf
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFF1A3A6B),
        const Color(0xFF4A90E2),
        const Color(0xFF2E5FA3),
        const Color(0xFF0D1F3D),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ).createShader(Rect.fromLTWH(centerX - 25, 40, 50, 80));
    
    canvas.drawRRect(bodyRect, paint);
    
    // Metalik parlama efekti
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.3),
        Colors.transparent,
        Colors.transparent,
        Colors.white.withOpacity(0.1),
      ],
    ).createShader(Rect.fromLTWH(centerX - 25, 40, 50, 80));
    canvas.drawRRect(bodyRect, paint);
    
    // Gövde çizgileri (panel hatları)
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white.withOpacity(0.2);
    paint.strokeWidth = 1;
    
    canvas.drawLine(
      Offset(centerX - 22, 60),
      Offset(centerX - 22, 115),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 22, 60),
      Offset(centerX + 22, 115),
      paint,
    );
    
    // Yatay hatlar
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(centerX - 25, 60 + (i * 15)),
        Offset(centerX + 25, 60 + (i * 15)),
        paint,
      );
    }
    
    paint.style = PaintingStyle.fill;
  }

  void _drawRocketNose(Canvas canvas, Size size, double centerX, Paint paint) {
    // Koni şekilli burun
    final nosePath = Path();
    nosePath.moveTo(centerX, 15);
    nosePath.quadraticBezierTo(
      centerX - 25, 40,
      centerX - 25, 45,
    );
    nosePath.lineTo(centerX + 25, 45);
    nosePath.quadraticBezierTo(
      centerX + 25, 40,
      centerX, 15,
    );
    nosePath.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.9),
        const Color(0xFFE0E0E0),
        const Color(0xFF9E9E9E),
      ],
    ).createShader(Rect.fromLTWH(centerX - 25, 15, 50, 30));
    
    canvas.drawPath(nosePath, paint);
    
    // Burun parlama efekti
    paint.shader = RadialGradient(
      center: Alignment.topCenter,
      radius: 1.5,
      colors: [
        Colors.white.withOpacity(0.6),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(centerX - 15, 15, 30, 20));
    canvas.drawPath(nosePath, paint);
  }

  void _drawFins(Canvas canvas, Size size, double centerX, Paint paint) {
    paint.shader = null;
    
    // Sol kanat
    final leftFinPath = Path();
    leftFinPath.moveTo(centerX - 25, 95);
    leftFinPath.lineTo(centerX - 45, 105);
    leftFinPath.lineTo(centerX - 45, 125);
    leftFinPath.lineTo(centerX - 25, 120);
    leftFinPath.close();
    
    paint.color = const Color(0xFFD32F2F);
    canvas.drawPath(leftFinPath, paint);
    
    // Sol kanat gölgesi
    paint.color = const Color(0xFF8B0000);
    final leftFinShadow = Path();
    leftFinShadow.moveTo(centerX - 25, 95);
    leftFinShadow.lineTo(centerX - 38, 100);
    leftFinShadow.lineTo(centerX - 38, 120);
    leftFinShadow.lineTo(centerX - 25, 120);
    leftFinShadow.close();
    canvas.drawPath(leftFinShadow, paint);
    
    // Sağ kanat
    final rightFinPath = Path();
    rightFinPath.moveTo(centerX + 25, 95);
    rightFinPath.lineTo(centerX + 45, 105);
    rightFinPath.lineTo(centerX + 45, 125);
    rightFinPath.lineTo(centerX + 25, 120);
    rightFinPath.close();
    
    paint.color = const Color(0xFFD32F2F);
    canvas.drawPath(rightFinPath, paint);
    
    // Sağ kanat highlight
    paint.color = const Color(0xFFFF6B6B);
    final rightFinHighlight = Path();
    rightFinHighlight.moveTo(centerX + 25, 95);
    rightFinHighlight.lineTo(centerX + 35, 100);
    rightFinHighlight.lineTo(centerX + 35, 115);
    rightFinHighlight.lineTo(centerX + 25, 115);
    rightFinHighlight.close();
    canvas.drawPath(rightFinHighlight, paint);
    
    // Kanat kenarları
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white.withOpacity(0.3);
    paint.strokeWidth = 1;
    canvas.drawPath(leftFinPath, paint);
    canvas.drawPath(rightFinPath, paint);
    paint.style = PaintingStyle.fill;
  }

  void _drawWindow(Canvas canvas, Size size, double centerX, Paint paint) {
    // Cam pencere
    final windowRect = Rect.fromCircle(
      center: Offset(centerX, 65),
      radius: 12,
    );
    
    // Pencere çerçevesi
    paint.shader = null;
    paint.color = const Color(0xFF757575);
    canvas.drawCircle(Offset(centerX, 65), 13, paint);
    
    // Cam - parlak mavi
    paint.shader = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [
        Colors.lightBlueAccent.withOpacity(0.9),
        Colors.blue.withOpacity(0.7),
        Colors.blue.withOpacity(0.5),
      ],
    ).createShader(windowRect);
    canvas.drawCircle(Offset(centerX, 65), 12, paint);
    
    // Cam yansıması
    paint.shader = null;
    paint.color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(Offset(centerX - 4, 62), 4, paint);
    paint.color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(Offset(centerX + 3, 67), 2, paint);
  }

  void _drawDetails(Canvas canvas, Size size, double centerX, Paint paint) {
    paint.shader = null;
    
    // NASA/logo bölgesi
    paint.color = Colors.red;
    final logoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 15, 85, 30, 8),
      const Radius.circular(2),
    );
    canvas.drawRRect(logoRect, paint);
    
    // Küçük detaylar (vidalar/paneller)
    paint.color = const Color(0xFF424242);
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(centerX - 20, 100 + (i * 10)), 1.5, paint);
      canvas.drawCircle(Offset(centerX + 20, 100 + (i * 10)), 1.5, paint);
    }
    
    // Sıcaklık göstergesi (kızarma)
    if (temperature > 60) {
      paint.color = Colors.orange.withOpacity((temperature - 60) / 100);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(centerX - 25, 40, 50, 80),
          const Radius.circular(8),
        ),
        paint,
      );
    }
  }

  void _drawEngine(Canvas canvas, Size size, double centerX, Paint paint) {
    // Motor gövdesi
    final engineRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 20, 120, 40, 15),
      const Radius.circular(4),
    );
    
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF424242),
        const Color(0xFF212121),
        const Color(0xFF000000),
      ],
    ).createShader(Rect.fromLTWH(centerX - 20, 120, 40, 15));
    canvas.drawRRect(engineRect, paint);
    
    // Motor nozul detayları
    paint.shader = null;
    paint.color = const Color(0xFF757575);
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(centerX - 10 + (i * 10), 127), 3, paint);
    }
    
    // Nozul içi (koyu)
    paint.color = Colors.black;
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(centerX - 10 + (i * 10), 127), 2, paint);
    }
  }

  void _drawFlames(Canvas canvas, Size size, double centerX, Paint paint) {
    if (fuelLevel <= 0) return;
    
    final flameIntensity = (sin(animationValue * 2 * pi) + 1) / 2;
    final flameHeight = 40 + (flameIntensity * 30);
    
    // Ana alev - merkez
    final mainFlamePath = Path();
    mainFlamePath.moveTo(centerX - 8, 135);
    mainFlamePath.quadraticBezierTo(
      centerX - 12, 135 + flameHeight / 2,
      centerX - 6, 135 + flameHeight * 0.7,
    );
    mainFlamePath.quadraticBezierTo(
      centerX - 3, 135 + flameHeight * 0.9,
      centerX, 135 + flameHeight,
    );
    mainFlamePath.quadraticBezierTo(
      centerX + 3, 135 + flameHeight * 0.9,
      centerX + 6, 135 + flameHeight * 0.7,
    );
    mainFlamePath.quadraticBezierTo(
      centerX + 12, 135 + flameHeight / 2,
      centerX + 8, 135,
    );
    mainFlamePath.close();
    
    // Alev renkleri - gradient
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        const Color(0xFFFFF176),
        const Color(0xFFFFB74D),
        const Color(0xFFFF6F00),
        Colors.red.withOpacity(0.8),
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.4, 0.6, 0.85, 1.0],
    ).createShader(Rect.fromLTWH(centerX - 12, 135, 24, flameHeight));
    
    canvas.drawPath(mainFlamePath, paint);
    
    // Yan alevler
    _drawSideFlame(canvas, centerX - 10, 135, flameHeight * 0.6, paint, -1);
    _drawSideFlame(canvas, centerX + 10, 135, flameHeight * 0.6, paint, 1);
    
    // İç alev (beyaz-sarı)
    final innerFlamePath = Path();
    innerFlamePath.moveTo(centerX - 4, 135);
    innerFlamePath.quadraticBezierTo(
      centerX - 5, 135 + flameHeight * 0.3,
      centerX, 135 + flameHeight * 0.5,
    );
    innerFlamePath.quadraticBezierTo(
      centerX + 5, 135 + flameHeight * 0.3,
      centerX + 4, 135,
    );
    innerFlamePath.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        const Color(0xFFFFFDE7),
        Colors.yellow.withOpacity(0.8),
      ],
    ).createShader(Rect.fromLTWH(centerX - 5, 135, 10, flameHeight * 0.5));
    
    canvas.drawPath(innerFlamePath, paint);
    
    // Kıvılcımlar
    paint.shader = null;
    final random = Random((animationValue * 100).toInt());
    for (int i = 0; i < 8; i++) {
      final sparkX = centerX + (random.nextDouble() - 0.5) * 20;
      final sparkY = 135 + flameHeight + random.nextDouble() * 20;
      final sparkSize = 1 + random.nextDouble() * 2;
      
      paint.color = [
        Colors.yellow,
        Colors.orange,
        Colors.red,
      ][random.nextInt(3)].withOpacity(0.6 + random.nextDouble() * 0.4);
      
      canvas.drawCircle(Offset(sparkX, sparkY), sparkSize, paint);
    }
  }

  void _drawSideFlame(Canvas canvas, double x, double y, double height, Paint paint, int direction) {
    final sideFlamePath = Path();
    sideFlamePath.moveTo(x, y);
    sideFlamePath.quadraticBezierTo(
      x + (direction * 4), y + height / 2,
      x + (direction * 2), y + height,
    );
    sideFlamePath.quadraticBezierTo(
      x, y + height * 0.8,
      x, y,
    );
    sideFlamePath.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFB74D),
        const Color(0xFFFF6F00),
        Colors.red.withOpacity(0.6),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(x - 5, y, 10, height));
    
    canvas.drawPath(sideFlamePath, paint);
  }

  void _drawDamageEffects(Canvas canvas, Size size, double centerX, Paint paint) {
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    
    // Çatlaklar
    paint.color = Colors.black.withOpacity(0.6);
    final crackPath = Path();
    crackPath.moveTo(centerX - 15, 70);
    crackPath.lineTo(centerX - 10, 80);
    crackPath.lineTo(centerX - 5, 75);
    canvas.drawPath(crackPath, paint);
    
    // Yanık izleri
    paint.style = PaintingStyle.fill;
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawOval(
      Rect.fromLTWH(centerX + 10, 90, 8, 12),
      paint,
    );
  }

  @override
  bool shouldRepaint(RealisticRocketPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.fuelLevel != fuelLevel ||
        oldDelegate.temperature != temperature ||
        oldDelegate.isDamaged != isDamaged;
  }
}

/// Uzay arka plan efekti
class SpaceBackgroundPainter extends CustomPainter {
  final double animationValue;

  SpaceBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Uzak bulutsu efekti
    paint.shader = RadialGradient(
      center: Alignment(
        sin(animationValue * pi) * 0.3,
        cos(animationValue * pi) * 0.3,
      ),
      radius: 0.8,
      colors: [
        Colors.purple.withOpacity(0.05),
        Colors.blue.withOpacity(0.03),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(SpaceBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Hız çizgileri efekti
class SpeedLinesPainter extends CustomPainter {
  final double speed;
  final double animationValue;

  SpeedLinesPainter({required this.speed, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    final random = Random(42);
    final lineCount = (speed / 50).clamp(5, 20).toInt();
    
    for (int i = 0; i < lineCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animationValue * size.height * 2) % size.height;
      final length = 20 + random.nextDouble() * 40;
      
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.3 + random.nextDouble() * 0.3),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(x, y - length, 2, length));
      
      canvas.drawLine(
        Offset(x, y - length),
        Offset(x, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SpeedLinesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.speed != speed;
  }
}

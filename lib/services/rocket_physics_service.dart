import 'dart:async';
import 'dart:math' as math;
import '../models/rocket_model.dart';
import '../models/rocket_types.dart';

/// Roket fizik sistemi
/// Unity'deki RocketController, FuelSystem ve DamageSystem'in Flutter karşılığı
class RocketPhysicsService {
  static final RocketPhysicsService instance = RocketPhysicsService._internal();
  factory RocketPhysicsService() => instance;
  RocketPhysicsService._internal();

  late RocketModel _rocket;
  Timer? _physicsTimer;
  RocketState _state = RocketState.idle;
  
  // GERÇEKÇİ FİZİK SABİTLERİ (SpaceX Falcon 9 tabanlı)
  static const double gravity = -9.81; // m/s²
  static const double seaLevelThrust = 7607000; // N (9 engine × 845 kN)
  static const double vacuumThrust = 8227000; // N (9 engine × 914 kN) 
  static const double dryMass = 27000; // kg (empty mass)
  static const double wetMass = 549000; // kg (full fuel mass)
  static const double specificImpulse = 282; // seconds (sea level)
  static const double fixedTimestep = 0.02; // 50 FPS
  static const double fuelConsumptionRate = 3.5; // %/saniye (gerçekçi)
  static const double maxTemperature = 1500.0; // °C (gerçek roket)
  static const double leoVelocity = 7800.0; // m/s (LEO orbital velocity)
  static const double damageThreshold = 3000.0; // m/s (daha gerçekçi)
  static const double damageRate = 1.0; // %/saniye
  static const double drag = 0.005; // Gerçekçi atmosferik drag katsayısı

  // Telemetri
  final List<TelemetryData> _telemetryHistory = [];
  final StreamController<RocketModel> _rocketStateController = StreamController<RocketModel>.broadcast();
  final StreamController<TelemetryData> _telemetryController = StreamController<TelemetryData>.broadcast();

  Stream<RocketModel> get rocketStateStream => _rocketStateController.stream;
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  RocketModel get rocket => _rocket;
  RocketState get state => _state;
  List<TelemetryData> get telemetryHistory => List.unmodifiable(_telemetryHistory);

  /// Fizik sistemini başlat
  void initialize() {
    _rocket = RocketModel();
    _startPhysicsLoop();
  }

  /// Fizik döngüsünü başlat
  void _startPhysicsLoop() {
    _physicsTimer?.cancel();
    _physicsTimer = Timer.periodic(
      Duration(milliseconds: (fixedTimestep * 1000).round()),
      (timer) => _physicsUpdate(),
    );
  }

  /// Ana fizik güncelleme döngüsü
  void _physicsUpdate() {
    if (_state == RocketState.paused) return;

    final deltaTime = fixedTimestep * _rocket.simTimeScale;
    
    // Misyon zamanını güncelle
    if (_state != RocketState.idle) {
      _rocket.updateMissionTime(deltaTime);
    }
    
    // Yakıt kontrolü
    _updateFuelSystem(deltaTime);
    
    // Fizik hesaplamaları - GERÇEKÇİ ROKET VERİLERİYLE
    _updateRealisticPhysics(deltaTime);
    
    // Sıcaklık hesaplaması
    _updateTemperature(deltaTime);
    
    // Hasar hesaplaması
    _updateDamage(deltaTime);
    
    // Telemetri kaydet
    _recordTelemetry();
    
    // State yayını
    _rocketStateController.add(_rocket);
  }

  /// Yakıt sistemini güncelle
  void _updateFuelSystem(double deltaTime) {
    if (_rocket.isEmpty) {
      _rocket.throttle = 0.0;
      return;
    }
    
    if (_rocket.throttle > 0.0) {
      final consumption = _rocket.throttle * fuelConsumptionRate * deltaTime;
      _rocket.fuelPercent = math.max(0.0, _rocket.fuelPercent - consumption);
    }
  }

  /// GERÇEKÇİ roket verilerine dayalı fizik hesaplamaları
  void _updateRealisticPhysics(double deltaTime) {
    // Seçilen roket tipinin gerçek verilerini kullan
    final currentThrust = _rocket.throttle > 0 ? _rocket.thrust : 0.0;
    final thrustForce = Vector2(0, currentThrust * _rocket.throttle);
    
    // Yerçekimi kuvveti - dinamik kütle
    final gravityForce = Vector2(0, gravity * _rocket.currentMass);
    
    // Minimal atmosferik sürüklenme
    final dragCoeff = 0.0001;
    final dragForce = _rocket.velocity * (-dragCoeff * _rocket.velocity.magnitude);
    
    // Toplam kuvvet
    final totalForce = thrustForce + gravityForce + dragForce;
    
    // İvme hesaplaması (F = ma)
    final acceleration = totalForce / _rocket.currentMass;
    
    // Hız güncellemesi
    _rocket.velocity = _rocket.velocity + (acceleration * deltaTime);
    
    // GERÇEK ROKET VERİLERİNE DAYALI HIZ KONTROLÜ
    final targetSpeed = _rocket.getTargetSpeedForCurrentTime();
    final currentSpeed = _rocket.velocity.magnitude;
    
    // Gerçek roket profiline yakınlaştır
    if (currentSpeed < targetSpeed) {
      final speedDiff = targetSpeed - currentSpeed;
      _rocket.velocity = _rocket.velocity.normalized * (currentSpeed + speedDiff * 0.1);
    } else if (currentSpeed > targetSpeed * 1.2) {
      // Çok hızlı artıyorsa yavaşlat
      _rocket.velocity = _rocket.velocity.normalized * (targetSpeed * 1.1);
    }
    
    // Pozisyon güncellemesi
    _rocket.position = _rocket.position + (_rocket.velocity * deltaTime);
    
    // Hız büyüklüğünü güncelle
    _rocket.speedMps = _rocket.velocity.magnitude;
    
    // Debug: Gerçek vs hedeflenen hız
    if (_rocket.missionTime > 0 && _rocket.missionTime.remainder(5.0) < deltaTime) {
      print('🚀 ${_rocket.rocketName}: T+${_rocket.missionTime.toStringAsFixed(1)}s');
      print('   Hedef: ${targetSpeed.toStringAsFixed(1)} m/s');
      print('   Gerçek: ${_rocket.speedMps.toStringAsFixed(1)} m/s');
    }
    
    // LEO kontrolü
    if (_rocket.speedMps >= leoVelocity && _rocket.throttle > 0.5) {
      _rocket.speedMps = leoVelocity + (_rocket.speedMps - leoVelocity) * 0.95;
    }
    
    // Zemin kontrolü
    if (_rocket.position.y < 0) {
      _rocket.position.y = 0;
      _rocket.velocity.y = math.max(0, _rocket.velocity.y);
    }
  }

  /// Eski fizik hesaplamaları (yedek)
  void _updatePhysics(double deltaTime) {
    // Bu metod artık kullanılmıyor, _updateRealisticPhysics kullanılıyor
    _updateRealisticPhysics(deltaTime);
  }

  /// Sıcaklık hesaplamasını güncelle
  void _updateTemperature(double deltaTime) {
    final targetTemperature = _calculateTargetTemperature();
    
    // Lerp ile yumuşak geçiş
    _rocket.temperatureC = _lerpDouble(
      _rocket.temperatureC,
      targetTemperature,
      0.12 * deltaTime * 50, // 50 FPS normalize
    );
  }

  /// Hedef sıcaklığı hesapla (throttle'a bağlı)
  double _calculateTargetTemperature() {
    const baseTemp = 20.0;
    return baseTemp + (_rocket.throttle * (maxTemperature - baseTemp));
  }

  /// Hasar sistemini güncelle
  void _updateDamage(double deltaTime) {
    if (_rocket.speedMps > damageThreshold) {
      final damageIncrease = damageRate * deltaTime;
      _rocket.damagePercent = math.min(100.0, _rocket.damagePercent + damageIncrease);
    }
  }

  /// Telemetri verilerini kaydet
  void _recordTelemetry() {
    final telemetry = TelemetryData(
      timestamp: DateTime.now(),
      speed: _rocket.speedMps,
      altitude: math.max(0, _rocket.position.y),
      fuel: _rocket.fuelPercent,
      temperature: _rocket.temperatureC,
      damage: _rocket.damagePercent,
    );
    
    _telemetryHistory.add(telemetry);
    
    // Sadece son 1000 veriyi tut
    if (_telemetryHistory.length > 1000) {
      _telemetryHistory.removeAt(0);
    }
    
    _telemetryController.add(telemetry);
  }

  /// Throttle ayarla (0.0 - 1.0)
  void setThrottle(double throttle) {
    _rocket.throttle = throttle.clamp(0.0, 1.0);
  }

  /// Simülasyon hızını ayarla (0.5 - 2.0)
  void setSimulationSpeed(double speed) {
    _rocket.simTimeScale = speed.clamp(0.5, 2.0);
  }

  /// Kamera modunu ayarla
  void setCameraMode(CameraMode mode) {
    _rocket.cameraMode = mode;
  }

  /// Oynat/Duraklat
  void togglePlayPause() {
    if (_state == RocketState.paused) {
      resume();
    } else {
      pause();
    }
  }

  /// Simülasyonu duraklat
  void pause() {
    _state = RocketState.paused;
  }

  /// Simülasyonu devam ettir
  void resume() {
    if (_state == RocketState.paused) {
      _state = RocketState.cruise;
    }
  }

  /// Kalkış sekansını başlat
  void startLaunchSequence() {
    if (_state == RocketState.idle) {
      _state = RocketState.launch;
      _animateThrottleToValue(1.0, 1.0); // 1 saniyede throttle 1.0'a çık
      
      // 3 saniye sonra cruise moda geç
      Timer(const Duration(seconds: 3), () {
        if (_state == RocketState.launch) {
          _state = RocketState.cruise;
          _animateThrottleToValue(0.7, 1.0); // 1 saniyede throttle 0.7'ye düş
        }
      });
    }
  }

  /// Throttle'ı animasyonlu olarak ayarla
  void _animateThrottleToValue(double targetValue, double duration) {
    final startValue = _rocket.throttle;
    final startTime = DateTime.now();
    
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      final progress = (elapsed / duration).clamp(0.0, 1.0);
      
      _rocket.throttle = _lerpDouble(startValue, targetValue, _easeInOut(progress));
      
      if (progress >= 1.0) {
        timer.cancel();
      }
    });
  }

  /// Simülasyonu sıfırla
  void reset() {
    _rocket = RocketModel();
    _state = RocketState.idle;
    _telemetryHistory.clear();
    _rocketStateController.add(_rocket);
  }

  /// Kaynakları temizle
  void dispose() {
    _physicsTimer?.cancel();
    _rocketStateController.close();
    _telemetryController.close();
  }

  // Yardımcı fonksiyonlar

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t.clamp(0.0, 1.0);
  }

  double _easeInOut(double t) {
    return t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  /// Hız birimi dönüşümleri
  double mpsToKmh(double mps) => mps * 3.6;
  double mpsToMach(double mps) => mps / 343.0; // Ses hızı yaklaşık 343 m/s

  /// Yükseklik birimi dönüşümleri  
  double metersToKm(double meters) => meters / 1000.0;
  double metersToFeet(double meters) => meters * 3.28084;

  /// Roket durumu kontrolü
  bool get isLaunched => _state != RocketState.idle;
  bool get isRunning => _state != RocketState.paused;
  bool get isDestroyed => _rocket.damagePercent >= 100.0;
  bool get isOutOfFuel => _rocket.isEmpty;
  
  /// Performans metrikleri
  double get maxSpeedAchieved {
    if (_telemetryHistory.isEmpty) return 0.0;
    return _telemetryHistory.map((t) => t.speed).reduce(math.max);
  }
  
  double get maxAltitudeAchieved {
    if (_telemetryHistory.isEmpty) return 0.0;
    return _telemetryHistory.map((t) => t.altitude).reduce(math.max);
  }

  double get totalFlightTime {
    if (_telemetryHistory.isEmpty) return 0.0;
    return _telemetryHistory.length * fixedTimestep;
  }
  
  /// LEO Mission Status
  bool get hasReachedLEO => _rocket.speedMps >= leoVelocity;
  double get leoProgressPercent => (_rocket.speedMps / leoVelocity * 100).clamp(0.0, 100.0);
  String get missionStatus {
    if (hasReachedLEO) return 'LEO ORBİT BAŞARILI! 🚀';
    if (_rocket.speedMps > leoVelocity * 0.8) return 'LEO\'ya yaklaşıyor... 🎯';
    if (_rocket.speedMps > leoVelocity * 0.5) return 'Hızlanıyor... ⬆️';
    if (_rocket.speedMps > 100) return 'Kalkış başarılı ✈️';
    return 'Hazır, kalkış bekleniyor 🚀';
  }
}

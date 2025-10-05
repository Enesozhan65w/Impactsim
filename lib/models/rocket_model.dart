import 'dart:math' as math;
import 'rocket_types.dart';

/// Roket veri modeli
class RocketModel {
  double speedMps = 0.0;
  double temperatureC = 20.0;
  double fuelPercent = 100.0;
  double damagePercent = 0.0;
  double simTimeScale = 1.0;
  CameraMode cameraMode = CameraMode.isometric;
  double throttle = 0.0;

  // ROKETİN TİPİ VE DİNAMİK ÖZELLİKLER
  RocketType _rocketType = RocketType.falcon9; // Varsayılan Falcon 9
  late RocketPerformanceData _performanceData;
  Vector2 velocity = Vector2(0, 0);
  Vector2 position = Vector2(0, 0);
  double _missionTime = 0.0; // Saniye cinsinden
  
  // DİNAMİK ROKET ÖZELLİKLERİ (seçilen tipe göre)
  double get thrust => _performanceData.thrust;
  double get mass => _performanceData.wetMass; // wet mass
  double get dryMass => _performanceData.dryMass;
  double get specificImpulse => _performanceData.specificImpulse;
  RocketType get rocketType => _rocketType;
  double get missionTime => _missionTime;
  
  // HESAPLANAN ÖZELLİKLER
  double get currentMass => dryMass + ((fuelPercent / 100.0) * (mass - dryMass));
  double get thrustToWeightRatio => thrust / (currentMass * 9.81);
  double get deltaV => 9.81 * specificImpulse * math.log(mass / dryMass);
  String get rocketName => _rocketType.displayName;
  String get manufacturer => _rocketType.manufacturer;

  RocketModel({RocketType? type}) {
    setRocketType(type ?? RocketType.falcon9);
  }

  /// Roket tipini değiştir ve performans verilerini güncelle
  void setRocketType(RocketType type) {
    _rocketType = type;
    _performanceData = RocketPerformanceData.getForType(type);
    print('🚀 Roket değiştirildi: ${type.displayName}');
    print('   Thrust: ${(thrust/1000000).toStringAsFixed(1)} MN');
    print('   Mass: ${(mass/1000).toStringAsFixed(0)} tons');
    print('   Delta-V: ${deltaV.toStringAsFixed(0)} m/s');
  }

  /// Misyon zamanını güncelle
  void updateMissionTime(double deltaTime) {
    _missionTime += deltaTime;
  }

  /// Gerçek roket verilerine göre hız hesapla
  double getTargetSpeedForCurrentTime() {
    return _performanceData.getSpeedAtTime(_missionTime);
  }

  /// Misyon zamanını sıfırla
  void resetMissionTime() {
    _missionTime = 0.0;
  }

  bool get isEmpty => fuelPercent <= 0.01;

  Map<String, dynamic> toJson() => {
    'speed_mps': speedMps,
    'temperature_c': temperatureC,
    'fuel_pct': fuelPercent,
    'damage_pct': damagePercent,
    'sim_time_scale': simTimeScale,
    'camera_mode': cameraMode.name,
    'throttle': throttle,
  };

  factory RocketModel.fromJson(Map<String, dynamic> json) {
    final rocket = RocketModel();
    rocket.speedMps = json['speed_mps']?.toDouble() ?? 0.0;
    rocket.temperatureC = json['temperature_c']?.toDouble() ?? 20.0;
    rocket.fuelPercent = json['fuel_pct']?.toDouble() ?? 100.0;
    rocket.damagePercent = json['damage_pct']?.toDouble() ?? 0.0;
    rocket.simTimeScale = json['sim_time_scale']?.toDouble() ?? 1.0;
    rocket.cameraMode = CameraModeExtension.fromString(json['camera_mode'] ?? 'isometric');
    rocket.throttle = json['throttle']?.toDouble() ?? 0.0;
    return rocket;
  }
}

/// Kamera modları
enum CameraMode { isometric, follow }

extension CameraModeExtension on CameraMode {
  String get name {
    switch (this) {
      case CameraMode.isometric:
        return 'isometric';
      case CameraMode.follow:
        return 'follow';
    }
  }

  static CameraMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'follow':
        return CameraMode.follow;
      case 'isometric':
      default:
        return CameraMode.isometric;
    }
  }
}

/// 2D Vektör sınıfı
class Vector2 {
  double x;
  double y;

  Vector2(this.x, this.y);

  Vector2 operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  Vector2 operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  Vector2 operator *(double scalar) => Vector2(x * scalar, y * scalar);
  Vector2 operator /(double scalar) => Vector2(x / scalar, y / scalar);

  double get magnitude => math.sqrt(x * x + y * y);
  Vector2 get normalized {
    final mag = magnitude;
    return mag == 0 ? Vector2(0, 0) : Vector2(x / mag, y / mag);
  }

  @override
  String toString() => 'Vector2($x, $y)';
}

/// Roket durumları
enum RocketState { idle, launch, cruise, paused }

extension RocketStateExtension on RocketState {
  String get name {
    switch (this) {
      case RocketState.idle:
        return 'Beklemede';
      case RocketState.launch:
        return 'Kalkış';
      case RocketState.cruise:
        return 'Seyir';
      case RocketState.paused:
        return 'Duraklatıldı';
    }
  }
}

/// Telemetri veri yapısı
class TelemetryData {
  final DateTime timestamp;
  final double speed;
  final double altitude;
  final double fuel;
  final double temperature;
  final double damage;

  TelemetryData({
    required this.timestamp,
    required this.speed,
    required this.altitude,
    required this.fuel,
    required this.temperature,
    required this.damage,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'speed': speed,
    'altitude': altitude,
    'fuel': fuel,
    'temperature': temperature,
    'damage': damage,
  };
}

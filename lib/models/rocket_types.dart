import 'dart:math' as math;

/// Gerçek roket tipleri ve performans verileri
enum RocketType {
  sls,        // NASA Space Launch System
  falcon9,    // SpaceX Falcon 9
  falconHeavy,// SpaceX Falcon Heavy
  atlasV,     // ULA Atlas V
  electron,   // Rocket Lab Electron
}

extension RocketTypeExtension on RocketType {
  String get displayName {
    switch (this) {
      case RocketType.sls:
        return 'SLS (NASA)';
      case RocketType.falcon9:
        return 'Falcon 9 (SpaceX)';
      case RocketType.falconHeavy:
        return 'Falcon Heavy (SpaceX)';
      case RocketType.atlasV:
        return 'Atlas V / Vulcan';
      case RocketType.electron:
        return 'Electron (Rocket Lab)';
    }
  }

  String get description {
    switch (this) {
      case RocketType.sls:
        return 'NASA\'nın en güçlü roketi, Artemis programı için geliştirildi';
      case RocketType.falcon9:
        return 'SpaceX\'in işgücü roketi, yeniden kullanılabilir';
      case RocketType.falconHeavy:
        return '3 Falcon 9 birleşimi, en güçlü operasyonel roket';
      case RocketType.atlasV:
        return 'ULA\'nın güvenilir orta ağırlık roketi';
      case RocketType.electron:
        return 'Küçük uydu fırlatma roketi, 3D yazıcı teknolojisi';
    }
  }

  String get manufacturer {
    switch (this) {
      case RocketType.sls:
        return 'NASA/Boeing';
      case RocketType.falcon9:
      case RocketType.falconHeavy:
        return 'SpaceX';
      case RocketType.atlasV:
        return 'ULA (Lockheed/Boeing)';
      case RocketType.electron:
        return 'Rocket Lab';
    }
  }
}

/// Gerçek roket performans verileri
class RocketPerformanceData {
  final RocketType type;
  final double thrust; // Newton
  final double wetMass; // kg (full fuel)
  final double dryMass; // kg (empty)
  final double specificImpulse; // seconds
  final int stages;
  
  // GERÇEKÇİ HIZ PROFİLİ VERİLERİ
  final double speedAt2Seconds; // m/s
  final double speedAt10Seconds; // m/s  
  final double speedAt60Seconds; // m/s
  
  const RocketPerformanceData({
    required this.type,
    required this.thrust,
    required this.wetMass,
    required this.dryMass,
    required this.specificImpulse,
    required this.stages,
    required this.speedAt2Seconds,
    required this.speedAt10Seconds,
    required this.speedAt60Seconds,
  });

  /// Thrust-to-weight ratio hesapla
  double get initialTWR => thrust / (wetMass * 9.81);
  
  /// Maksimum teorik Delta-V hesapla (Tsiolkovsky)
  double get maxDeltaV => 9.81 * specificImpulse * math.log(wetMass / dryMass);

  /// Belirli bir zamandaki hızı hesapla (gerçek verilerle interpolasyon)
  double getSpeedAtTime(double timeSeconds) {
    if (timeSeconds <= 0) return 0;
    if (timeSeconds <= 2) {
      // 0-2 saniye: Doğrusal interpolasyon
      return speedAt2Seconds * (timeSeconds / 2.0);
    } else if (timeSeconds <= 10) {
      // 2-10 saniye: Hızlanan artış
      final t = (timeSeconds - 2) / 8.0; // 0-1 normalize
      final easedT = _easeInOut(t);
      return speedAt2Seconds + (speedAt10Seconds - speedAt2Seconds) * easedT;
    } else if (timeSeconds <= 60) {
      // 10-60 saniye: Yavaşlayan artış (yakıt azaldıkça)
      final t = (timeSeconds - 10) / 50.0; // 0-1 normalize
      final easedT = _easeOut(t);
      return speedAt10Seconds + (speedAt60Seconds - speedAt10Seconds) * easedT;
    } else {
      // 60+ saniye: Yakıt bitmiş, sabit hız veya düşüş
      final t = math.min(1.0, (timeSeconds - 60) / 60.0);
      return speedAt60Seconds * (1.0 - t * 0.1); // Hafif düşüş
    }
  }

  /// Yumuşak geçişler için easing fonksiyonları
  double _easeInOut(double t) {
    return t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }
  
  double _easeOut(double t) {
    return 1 - math.pow(1 - t, 3).toDouble();
  }

  /// Gerçek roket performans verileri
  static const Map<RocketType, RocketPerformanceData> data = {
    RocketType.sls: RocketPerformanceData(
      type: RocketType.sls,
      thrust: 39100000, // N (8.8 million lbs)
      wetMass: 2608000, // kg (5.75 million lbs)  
      dryMass: 188000, // kg
      specificImpulse: 452, // vacuum
      stages: 2,
      // GERÇEKÇİ HIZ PROFİLİ - TWR=1.53 bazlı
      speedAt2Seconds: 30.0, // m/s (TWR*g*t - atmosfer direnci ≈ 15 m/s)
      speedAt10Seconds: 120.0, // m/s (güçlü thrust, kütle azalıyor)
      speedAt60Seconds: 350.0, // m/s (1. kademe yakıt tükeniyor, yüksek hız)
    ),
    
    RocketType.falcon9: RocketPerformanceData(
      type: RocketType.falcon9,
      thrust: 7607000, // N (9 Merlin engines)
      wetMass: 549054, // kg
      dryMass: 25600, // kg
      specificImpulse: 282, // sea level
      stages: 2,
      // GERÇEKÇİ HIZ PROFİLİ - TWR=1.41 bazlı
      speedAt2Seconds: 28.0, // m/s (TWR*g*t - atmosfer ≈ 14 m/s)
      speedAt10Seconds: 110.0, // m/s (sabit thrust, azalan kütle)
      speedAt60Seconds: 320.0, // m/s (MECO - Main Engine Cutoff hızı)
    ),
    
    RocketType.falconHeavy: RocketPerformanceData(
      type: RocketType.falconHeavy,
      thrust: 22819000, // N (27 Merlin engines)
      wetMass: 1420788, // kg
      dryMass: 54400, // kg
      specificImpulse: 282, // sea level
      stages: 2,
      // GERÇEKÇİ HIZ PROFİLİ - TWR=1.64 bazlı
      speedAt2Seconds: 32.0, // m/s (En güçlü TWR, hızlı başlama)
      speedAt10Seconds: 130.0, // m/s (3x Falcon 9 gücü)
      speedAt60Seconds: 380.0, // m/s (En yüksek hız)
    ),
    
    RocketType.atlasV: RocketPerformanceData(
      type: RocketType.atlasV,
      thrust: 3827000, // N (RD-180 engine)
      wetMass: 546700, // kg
      dryMass: 21054, // kg
      specificImpulse: 311, // vacuum
      stages: 2,
      // GERÇEKÇİ HIZ PROFİLİ - TWR=0.71 bazlı
      speedAt2Seconds: 14.0, // m/s (Düşük TWR, yavaş başlama)
      speedAt10Seconds: 85.0, // m/s (orta hızlanma)
      speedAt60Seconds: 280.0, // m/s (ISP yüksek ama thrust düşük)
    ),
    
    RocketType.electron: RocketPerformanceData(
      type: RocketType.electron,
      thrust: 192000, // N (9 Rutherford engines)
      wetMass: 13000, // kg
      dryMass: 950, // kg
      specificImpulse: 303, // vacuum
      stages: 2,
      // GERÇEKÇİ HIZ PROFİLİ - TWR=1.51 bazlı
      speedAt2Seconds: 30.0, // m/s (Küçük ama güçlü TWR)
      speedAt10Seconds: 95.0, // m/s (kütle azalıyor hızla)
      speedAt60Seconds: 220.0, // m/s (küçük payload için yeterli)
    ),
  };

  /// Belirli roket tipi için performans verilerini getir
  static RocketPerformanceData getForType(RocketType type) {
    return data[type]!;
  }
}

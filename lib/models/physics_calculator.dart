import 'dart:math';

class PhysicsCalculator {
  // Gerçek fizik sabitleri
  static const double earthGravity = 9.81; // m/s²
  static const double moonGravity = 1.62; // m/s²
  static const double marsGravity = 3.71; // m/s²
  static const double spaceGravity = 0.0; // m/s²
  
  // Sıcaklık aralıkları (Celsius)
  static const Map<String, List<double>> temperatureRanges = {
    'LEO': [-157, 121], // Gerçek LEO sıcaklık aralığı
    'Ay': [-173, 127], // Ay yüzeyi sıcaklık aralığı
    'Mars': [-87, -5], // Mars atmosferi sıcaklık aralığı
    'Boşluk': [-270, -200], // Derin uzay sıcaklık aralığı
  };
  
  // Radyasyon seviyeleri (0-1 arası)
  static const Map<String, double> radiationLevels = {
    'LEO': 0.3, // Van Allen kuşakları koruması
    'Ay': 0.8, // Atmosfer koruması yok
    'Mars': 0.6, // İnce atmosfer
    'Boşluk': 1.0, // Maksimum radyasyon
  };
  
  // Atmosfer yoğunluğu (kg/m³)
  static const Map<String, double> atmosphereDensity = {
    'LEO': 1e-12, // Çok ince atmosfer
    'Ay': 0.0, // Atmosfer yok
    'Mars': 0.02, // İnce atmosfer
    'Boşluk': 0.0, // Vakum
  };

  static Map<String, dynamic> calculateEnvironmentFactors(String environment) {
    switch (environment) {
      case 'LEO':
        return {
          'gravity': earthGravity * 0.9, // LEO'da biraz daha düşük
          'temperature_range': temperatureRanges['LEO']!,
          'radiation': radiationLevels['LEO']!,
          'atmosphere_density': atmosphereDensity['LEO']!,
          'difficulty_multiplier': 1.0,
          'orbital_velocity': 7800.0, // m/s
        };
      case 'Ay':
        return {
          'gravity': moonGravity,
          'temperature_range': temperatureRanges['Ay']!,
          'radiation': radiationLevels['Ay']!,
          'atmosphere_density': atmosphereDensity['Ay']!,
          'difficulty_multiplier': 1.5,
          'escape_velocity': 2380.0, // m/s
        };
      case 'Mars':
        return {
          'gravity': marsGravity,
          'temperature_range': temperatureRanges['Mars']!,
          'radiation': radiationLevels['Mars']!,
          'atmosphere_density': atmosphereDensity['Mars']!,
          'difficulty_multiplier': 2.0,
          'escape_velocity': 5030.0, // m/s
        };
      case 'Boşluk':
        return {
          'gravity': spaceGravity,
          'temperature_range': temperatureRanges['Boşluk']!,
          'radiation': radiationLevels['Boşluk']!,
          'atmosphere_density': atmosphereDensity['Boşluk']!,
          'difficulty_multiplier': 3.0,
          'cosmic_radiation': true,
        };
      default:
        return calculateEnvironmentFactors('LEO');
    }
  }

  static double calculateSpeed(
    Map<String, dynamic> rocketData,
    Map<String, dynamic> environmentFactors,
    double progress,
    double deltaTime,
  ) {
    double thrust = 0.0;
    double mass = 100.0; // kg varsayılan
    
    if (rocketData['type'] == 'manual') {
      thrust = rocketData['motorPower'].toDouble(); // Newton
      mass = rocketData['weight'].toDouble(); // kg
    } else {
      // Hazır modeller için varsayılan değerler
      switch (rocketData['model']) {
        case 'Mini CubeSat':
          thrust = 0.1; // Çok düşük itki
          mass = 1.3;
          break;
        case 'Deneysel Roket':
          thrust = 1000.0;
          mass = 25.0;
          break;
        case 'İletişim Uydusu':
          thrust = 500.0;
          mass = 150.0;
          break;
      }
    }
    
    // Newton'un ikinci yasası: F = ma, dolayısıyla a = F/m
    double acceleration = thrust / mass;
    
    // Yerçekimi etkisi
    double gravity = environmentFactors['gravity'];
    acceleration -= gravity;
    
    // Atmosfer direnci (basitleştirilmiş)
    double atmosphereDrag = environmentFactors['atmosphere_density'] * 0.1;
    acceleration -= atmosphereDrag;
    
    // Hız hesaplama (v = at)
    double speed = acceleration * (progress * 30); // 30 saniye simülasyon
    
    return speed.clamp(0, 15000); // Maksimum hız sınırı
  }

  static double calculateTemperature(
    Map<String, dynamic> environmentFactors,
    double progress,
    bool isEngineRunning,
  ) {
    List<double> tempRange = environmentFactors['temperature_range'];
    double baseTemp = tempRange[0] + (tempRange[1] - tempRange[0]) * progress;
    
    // Motor ısısı etkisi
    if (isEngineRunning) {
      baseTemp += 50 + (progress * 100); // Motor ısınması
    }
    
    // Güneş radyasyonu etkisi (LEO ve Ay için)
    if (environmentFactors.containsKey('orbital_velocity')) {
      double solarEffect = sin(progress * pi * 4) * 30; // Gündüz/gece döngüsü
      baseTemp += solarEffect;
    }
    
    return baseTemp;
  }

  static double calculateFuelConsumption(
    Map<String, dynamic> rocketData,
    Map<String, dynamic> environmentFactors,
    double progress,
    double deltaTime,
  ) {
    double baseConsumption = 1.0; // %/saniye
    
    if (rocketData['type'] == 'manual') {
      // Motor gücü arttıkça yakıt tüketimi artar
      double motorPower = rocketData['motorPower'].toDouble();
      baseConsumption = (motorPower / 2000.0) * 1.5;
      
      // Yakıt türü etkisi
      switch (rocketData['fuelType']) {
        case 'Katı':
          baseConsumption *= 1.2; // Daha hızlı tüketim
          break;
        case 'Sıvı':
          baseConsumption *= 1.0; // Normal tüketim
          break;
        case 'Hibrit':
          baseConsumption *= 0.9; // Daha verimli
          break;
      }
    }
    
    // Ortam zorluğu etkisi
    baseConsumption *= environmentFactors['difficulty_multiplier'];
    
    return baseConsumption * deltaTime;
  }

  static double calculateDamage(
    Map<String, dynamic> rocketData,
    Map<String, dynamic> environmentFactors,
    double temperature,
    double progress,
    double deltaTime,
  ) {
    double damageRate = 0.0;
    
    // Sıcaklık hasarı
    if (temperature > 150) {
      damageRate += (temperature - 150) * 0.01;
    } else if (temperature < -200) {
      damageRate += (-200 - temperature) * 0.005;
    }
    
    // Radyasyon hasarı
    double radiation = environmentFactors['radiation'];
    damageRate += radiation * 0.1 * progress; // Zamanla artan radyasyon hasarı
    
    // Malzeme direnci
    if (rocketData['type'] == 'manual') {
      switch (rocketData['material']) {
        case 'Karbonfiber':
          damageRate *= 0.6; // En dayanıklı
          break;
        case 'Kompozit':
          damageRate *= 0.8; // Orta dayanıklı
          break;
        case 'Alüminyum':
          damageRate *= 1.0; // Standart
          break;
      }
    }
    
    // Kontrol sistemi varsa hasar azalır
    if (rocketData['type'] == 'manual' && rocketData['hasControlSystem']) {
      damageRate *= 0.7;
    }
    
    return damageRate * deltaTime;
  }

  static List<String> generateWarnings(
    double temperature,
    double fuelLevel,
    double damage,
    double speed,
    Map<String, dynamic> environmentFactors,
  ) {
    List<String> warnings = [];
    
    // Sıcaklık uyarıları
    if (temperature > 200) {
      warnings.add('KRİTİK: Sistem Aşırı Isındı (${temperature.round()}°C)');
    } else if (temperature > 100) {
      warnings.add('UYARI: Motor Yüksek Sıcaklık (${temperature.round()}°C)');
    }
    
    if (temperature < -250) {
      warnings.add('KRİTİK: Sistem Donma Riski (${temperature.round()}°C)');
    } else if (temperature < -200) {
      warnings.add('UYARI: Düşük Sıcaklık Riski (${temperature.round()}°C)');
    }
    
    // Yakıt uyarıları
    if (fuelLevel < 10) {
      warnings.add('KRİTİK: Yakıt Kritik Seviyede (${fuelLevel.round()}%)');
    } else if (fuelLevel < 25) {
      warnings.add('UYARI: Yakıt Seviyesi Düşük (${fuelLevel.round()}%)');
    }
    
    // Hasar uyarıları
    if (damage > 80) {
      warnings.add('KRİTİK: Sistem Arızası Riski (${damage.round()}% hasar)');
    } else if (damage > 50) {
      warnings.add('UYARI: Yüksek Hasar Seviyesi (${damage.round()}%)');
    }
    
    // Hız uyarıları
    if (speed > 10000) {
      warnings.add('UYARI: Yüksek Hız - Kontrol Kaybı Riski');
    }
    
    // Radyasyon uyarıları
    if (environmentFactors['radiation'] > 0.7) {
      warnings.add('UYARI: Yüksek Radyasyon Seviyesi');
    }
    
    // Ortam özel uyarıları
    if (environmentFactors.containsKey('cosmic_radiation')) {
      warnings.add('UYARI: Kozmik Radyasyon Tespit Edildi');
    }
    
    return warnings;
  }
}

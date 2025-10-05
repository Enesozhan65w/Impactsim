import 'dart:math';
import 'asteroid.dart';

class ImpactCalculation {
  final Asteroid asteroid;
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime impactTime;

  ImpactCalculation({
    required this.asteroid,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.impactTime,
  });

  // Krater boyutu hesaplama (USGS formülü)
  double get craterDiameter {
    // D = 1.161 * (E^0.22) * (ρt^-0.165) * (g^-0.22) * sin(θ)^(-1/3)
    // D: krater çapı (m), E: enerji (J), ρt: hedef yoğunluğu, g: yerçekimi, θ: açı
    
    final energy = asteroid.kineticEnergy;
    final targetDensity = 2670.0; // Ortalama kaya yoğunluğu (kg/m³)
    final gravity = 9.81; // m/s²
    final angleRad = asteroid.impactAngle * pi / 180;
    
    final diameter = 1.161 * 
        pow(energy, 0.22) * 
        pow(targetDensity, -0.165) * 
        pow(gravity, -0.22) * 
        pow(sin(angleRad), -1/3);
    
    return diameter;
  }

  // Krater derinliği
  double get craterDepth {
    return craterDiameter * 0.2; // Genellikle çapın %20'si
  }

  // Şok dalgası yarıçapı (km)
  double get shockwaveRadius {
    final tntTons = asteroid.tntEquivalent;
    // R = 0.4 * (TNT)^(1/3) km
    return 0.4 * pow(tntTons, 1/3);
  }

  // Isı etkisi yarıçapı (km)
  double get thermalRadius {
    final tntTons = asteroid.tntEquivalent;
    // Termal radyasyon etkisi
    return 0.6 * pow(tntTons, 0.4);
  }

  // Sismik etki yarıçapı (km)
  double get seismicRadius {
    final magnitude = earthquakeMagnitude;
    // Richter ölçeğine göre hissedilir sarsıntı yarıçapı
    return pow(10, magnitude - 3).toDouble();
  }

  // Deprem büyüklüğü (Richter)
  double get earthquakeMagnitude {
    final energy = asteroid.kineticEnergy;
    // M = (log10(E) - 4.8) / 1.5
    return (log(energy) / ln10 - 4.8) / 1.5;
  }

  // Tsunami riski (kıyı çarpması durumunda)
  bool get tsunamiRisk {
    return _isCoastalImpact() && asteroid.diameter > 100;
  }

  // Tsunami dalgası yüksekliği (m)
  double get tsunamiWaveHeight {
    if (!tsunamiRisk) return 0;
    
    final energy = asteroid.kineticEnergy;
    final depth = _getWaterDepth(); // Ortalama okyanus derinliği
    
    // Basitleştirilmiş tsunami yükseklik formülü
    return sqrt(energy / (1e15 * depth));
  }

  // Atmosferik etki (nükleer kış riski)
  String get atmosphericEffect {
    final tntMegatons = asteroid.tntEquivalent / 1e6;
    
    if (tntMegatons < 1) return 'Yerel toz bulutu';
    if (tntMegatons < 100) return 'Bölgesel atmosfer kirliliği';
    if (tntMegatons < 10000) return 'Küresel iklim etkisi';
    return 'Nükleer kış riski';
  }

  // Risk alanları hesaplama
  List<RiskZone> get riskZones {
    return [
      RiskZone(
        type: 'Kritik',
        radius: craterDiameter / 2000, // km'ye çevir
        description: 'Tam yıkım - %100 ölüm oranı',
        color: 'red',
        casualties: _calculateCasualties(craterDiameter / 2000, 1.0),
      ),
      RiskZone(
        type: 'Ağır Hasar',
        radius: shockwaveRadius * 0.5,
        description: 'Yapısal çöküş - %70 ölüm oranı',
        color: 'orange',
        casualties: _calculateCasualties(shockwaveRadius * 0.5, 0.7),
      ),
      RiskZone(
        type: 'Orta Hasar',
        radius: shockwaveRadius,
        description: 'Ciddi hasar - %30 ölüm oranı',
        color: 'yellow',
        casualties: _calculateCasualties(shockwaveRadius, 0.3),
      ),
      RiskZone(
        type: 'Hafif Hasar',
        radius: thermalRadius,
        description: 'Yanıklar ve cam kırılması - %5 ölüm oranı',
        color: 'lightblue',
        casualties: _calculateCasualties(thermalRadius, 0.05),
      ),
      RiskZone(
        type: 'Sismik Etki',
        radius: seismicRadius,
        description: 'Deprem hissedilir - Yapısal hasar',
        color: 'purple',
        casualties: _calculateCasualties(seismicRadius, 0.01),
      ),
    ];
  }

  // Toplam tahmini can kaybı
  int get totalCasualties {
    return riskZones.fold(0, (sum, zone) => sum + zone.casualties);
  }

  // Ekonomik zarar tahmini (milyar USD)
  double get economicDamage {
    final gdpPerKm2 = _getRegionalGDP(); // Bölgesel GDP/km²
    double totalDamage = 0;
    
    for (final zone in riskZones) {
      final area = pi * zone.radius * zone.radius;
      final damageMultiplier = _getDamageMultiplier(zone.type);
      totalDamage += area * gdpPerKm2 * damageMultiplier;
    }
    
    return totalDamage / 1e9; // Milyar USD'ye çevir
  }

  // Erken uyarı süresi (saat)
  double get warningTime {
    // Asteroit tespit edildiğinde kalan süre
    final now = DateTime.now();
    final timeDiff = impactTime.difference(now);
    return timeDiff.inHours.toDouble();
  }

  // Tahliye süresi gereksinimi (saat)
  double get evacuationTimeNeeded {
    final maxRadius = riskZones.map((z) => z.radius).reduce(max);
    // Ortalama tahliye hızı: 50 km/saat
    return maxRadius / 50 + 2; // +2 saat hazırlık süresi
  }

  // Tahliye edilmesi gereken nüfus
  int get evacuationPopulation {
    final maxRadius = riskZones.take(3).map((z) => z.radius).reduce(max);
    return _calculatePopulation(maxRadius);
  }

  // Yardımcı metodlar
  bool _isCoastalImpact() {
    // Basit kontrol - gerçekte coğrafi veri gerekir
    return latitude.abs() < 60 && longitude.abs() < 170;
  }

  double _getWaterDepth() {
    return 3800; // Ortalama okyanus derinliği (m)
  }

  int _calculateCasualties(double radiusKm, double mortalityRate) {
    final population = _calculatePopulation(radiusKm);
    return (population * mortalityRate).round();
  }

  int _calculatePopulation(double radiusKm) {
    // Basit nüfus yoğunluğu tahmini
    final area = pi * radiusKm * radiusKm;
    final populationDensity = _getPopulationDensity();
    return (area * populationDensity).round();
  }

  double _getPopulationDensity() {
    // Koordinatlara göre nüfus yoğunluğu tahmini (kişi/km²)
    // Gerçekte GIS veri gerekir
    if (_isUrbanArea()) return 5000;
    if (_isSuburbanArea()) return 1000;
    return 50; // Kırsal alan
  }

  bool _isUrbanArea() {
    // Basit şehir kontrolü - gerçekte şehir veritabanı gerekir
    return locationName.toLowerCase().contains('istanbul') ||
           locationName.toLowerCase().contains('ankara') ||
           locationName.toLowerCase().contains('izmir');
  }

  bool _isSuburbanArea() {
    return !_isUrbanArea() && locationName.isNotEmpty;
  }

  double _getRegionalGDP() {
    // Bölgesel GDP/km² tahmini (USD)
    if (_isUrbanArea()) return 50000000; // 50M USD/km²
    if (_isSuburbanArea()) return 10000000; // 10M USD/km²
    return 1000000; // 1M USD/km²
  }

  double _getDamageMultiplier(String zoneType) {
    switch (zoneType) {
      case 'Kritik': return 1.0;
      case 'Ağır Hasar': return 0.8;
      case 'Orta Hasar': return 0.5;
      case 'Hafif Hasar': return 0.2;
      case 'Sismik Etki': return 0.1;
      default: return 0.05;
    }
  }

  // JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'asteroid': asteroid.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'impactTime': impactTime.toIso8601String(),
      'craterDiameter': craterDiameter,
      'craterDepth': craterDepth,
      'shockwaveRadius': shockwaveRadius,
      'thermalRadius': thermalRadius,
      'seismicRadius': seismicRadius,
      'earthquakeMagnitude': earthquakeMagnitude,
      'tsunamiRisk': tsunamiRisk,
      'tsunamiWaveHeight': tsunamiWaveHeight,
      'atmosphericEffect': atmosphericEffect,
      'totalCasualties': totalCasualties,
      'economicDamage': economicDamage,
      'warningTime': warningTime,
      'evacuationTimeNeeded': evacuationTimeNeeded,
      'evacuationPopulation': evacuationPopulation,
      'riskZones': riskZones.map((z) => z.toJson()).toList(),
    };
  }
}

class RiskZone {
  final String type;
  final double radius; // km
  final String description;
  final String color;
  final int casualties;

  RiskZone({
    required this.type,
    required this.radius,
    required this.description,
    required this.color,
    required this.casualties,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'radius': radius,
      'description': description,
      'color': color,
      'casualties': casualties,
    };
  }

  factory RiskZone.fromJson(Map<String, dynamic> json) {
    return RiskZone(
      type: json['type'],
      radius: json['radius'].toDouble(),
      description: json['description'],
      color: json['color'],
      casualties: json['casualties'],
    );
  }
}

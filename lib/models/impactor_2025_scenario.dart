import 'dart:math';
import 'asteroid.dart';
import 'impact_calculation.dart';
import 'orbital_mechanics.dart';

/// NASA Space Apps Challenge - Impactor-2025 Senaryosu
/// Varsayımsal bir asteroit tehdidi ve azaltma simülasyonu
class Impactor2025Scenario {
  final String id;
  final String name;
  final String description;
  final Asteroid asteroid;
  final DateTime discoveryDate;
  final DateTime impactDate;
  final double impactLatitude;
  final double impactLongitude;
  final String impactLocation;
  final List<MitigationStrategy> availableStrategies;
  
  // Simülasyon durumu
  bool isActive;
  MitigationStrategy? appliedStrategy;
  DateTime? strategyApplicationTime;
  ImpactCalculation? originalImpact;
  ImpactCalculation? modifiedImpact;

  Impactor2025Scenario({
    required this.id,
    required this.name,
    required this.description,
    required this.asteroid,
    required this.discoveryDate,
    required this.impactDate,
    required this.impactLatitude,
    required this.impactLongitude,
    required this.impactLocation,
    required this.availableStrategies,
    this.isActive = true,
    this.appliedStrategy,
    this.strategyApplicationTime,
    this.originalImpact,
    this.modifiedImpact,
  });

  /// Varsayılan Impactor-2025 senaryosu
  factory Impactor2025Scenario.createDefault() {
    final discoveryDate = DateTime.now();
    final impactDate = discoveryDate.add(const Duration(days: 180)); // 6 ay sonra
    
    final asteroid = Asteroid(
      id: 'impactor-2025',
      name: 'Impactor-2025',
      mass: 1.5e12, // 1.5 trilyon kg
      diameter: 0.5, // 500 metre -> 0.5 km
      closeApproachVelocity: 25.0, // 25 km/s
      impactAngle: 45,
      density: 3000, // kg/m³ -> g/cm³'ye çevir
      composition: 'Stony',
      orbitalPeriod: 1.2, // years
      semiMajorAxis: 1.1, // AU
      lastObservation: DateTime.now(),
    );

    final strategies = [
      MitigationStrategy.kineticImpactor(
        name: 'DART Benzeri Kinetik Çarpıcı',
        deltaV: 0.5, // m/s hız değişimi
        cost: 500, // Milyon USD
        successRate: 0.85,
        preparationTime: 90, // gün
      ),
      MitigationStrategy.kineticImpactor(
        name: 'Çoklu Kinetik Çarpıcı',
        deltaV: 1.2,
        cost: 1200,
        successRate: 0.95,
        preparationTime: 120,
      ),
      MitigationStrategy.nuclearDeflection(
        name: 'Nükleer Saptırma',
        deltaV: 5.0,
        cost: 2000,
        successRate: 0.90,
        preparationTime: 150,
      ),
      MitigationStrategy.gravitationalTractor(
        name: 'Yerçekimsel Çekici',
        deltaV: 0.1,
        cost: 800,
        successRate: 0.70,
        preparationTime: 200,
      ),
    ];

    return Impactor2025Scenario(
      id: 'impactor-2025-default',
      name: 'Impactor-2025: Küresel Tehdit Senaryosu',
      description: '''
NASA Space Apps Challenge 2025 için varsayımsal asteroit tehdidi.

Senaryo: 500 metre çapında bir asteroit, 6 ay içinde Dünya'ya çarpacak. 
Bu asteroit, şehir boyutunda bir alanı tamamen yok edebilir ve küresel 
iklim değişikliklerine neden olabilir.

Göreviniz: Mevcut teknolojileri kullanarak asteroiti saptırmak veya 
etkisini en aza indirmek için en iyi stratejiyi seçmek.
      ''',
      asteroid: asteroid,
      discoveryDate: discoveryDate,
      impactDate: impactDate,
      impactLatitude: 41.0082, // İstanbul koordinatları (örnek)
      impactLongitude: 28.9784,
      impactLocation: 'İstanbul, Türkiye',
      availableStrategies: strategies,
    );
  }

  /// Özel senaryo oluştur
  factory Impactor2025Scenario.custom({
    required Asteroid asteroid,
    required double impactLatitude,
    required double impactLongitude,
    required String impactLocation,
    int daysUntilImpact = 180,
  }) {
    final discoveryDate = DateTime.now();
    final impactDate = discoveryDate.add(Duration(days: daysUntilImpact));
    
    return Impactor2025Scenario(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Özel Asteroit Senaryosu',
      description: 'Kullanıcı tanımlı asteroit tehdidi senaryosu',
      asteroid: asteroid,
      discoveryDate: discoveryDate,
      impactDate: impactDate,
      impactLatitude: impactLatitude,
      impactLongitude: impactLongitude,
      impactLocation: impactLocation,
      availableStrategies: _generateStrategiesForAsteroid(asteroid, daysUntilImpact),
    );
  }

  /// Azaltma stratejisi uygula
  bool applyMitigationStrategy(MitigationStrategy strategy, DateTime applicationTime) {
    if (!isActive) return false;
    
    final timeUntilImpact = impactDate.difference(applicationTime);
    final daysUntilImpact = timeUntilImpact.inDays;
    
    // Strateji uygulanabilir mi kontrol et
    if (daysUntilImpact < strategy.preparationTime) {
      return false; // Yeterli zaman yok
    }
    
    appliedStrategy = strategy;
    strategyApplicationTime = applicationTime;
    
    // Orijinal çarpma hesapla
    originalImpact = ImpactCalculation(
      asteroid: asteroid,
      latitude: impactLatitude,
      longitude: impactLongitude,
      locationName: impactLocation,
      impactTime: impactDate,
    );
    
    // Modifiye edilmiş yörünge hesapla
    final modifiedAsteroid = _calculateDeflectedAsteroid(strategy, daysUntilImpact);
    
    if (modifiedAsteroid != null) {
      // Yeni çarpma noktası hesapla (saptırma başarılıysa)
      final newImpactCoords = _calculateNewImpactPoint(modifiedAsteroid, strategy.deltaV);
      
      modifiedImpact = ImpactCalculation(
        asteroid: modifiedAsteroid,
        latitude: newImpactCoords['latitude']!,
        longitude: newImpactCoords['longitude']!,
        locationName: newImpactCoords['location']!,
        impactTime: impactDate,
      );
    }
    
    return true;
  }

  /// Saptırma başarılı mı?
  bool get isDeflectionSuccessful {
    if (appliedStrategy == null || modifiedImpact == null) return false;
    
    // Dünya'dan güvenli mesafe kontrolü (>100,000 km)
    final missDistance = _calculateMissDistance();
    return missDistance > 100000; // km
  }

  /// Iskalama mesafesi hesapla
  double _calculateMissDistance() {
    if (modifiedImpact == null) return 0;
    
    // Basitleştirilmiş hesaplama - gerçekte orbital mekanik gerekir
    final deltaLat = modifiedImpact!.latitude - impactLatitude;
    final deltaLon = modifiedImpact!.longitude - impactLongitude;
    final earthRadius = 6371; // km
    
    final distance = sqrt(deltaLat * deltaLat + deltaLon * deltaLon) * earthRadius * pi / 180;
    return distance;
  }

  /// Saptırılmış asteroit hesapla
  Asteroid? _calculateDeflectedAsteroid(MitigationStrategy strategy, int daysUntilImpact) {
    // Başarı oranına göre rastgele başarı/başarısızlık
    final random = Random();
    if (random.nextDouble() > strategy.successRate) {
      return null; // Strateji başarısız
    }
    
    // Erken uygulama daha etkili
    final timeEffectiveness = daysUntilImpact / 180.0; // 180 gün maksimum
    final effectiveDeltaV = strategy.deltaV * timeEffectiveness;
    
    // Yeni hız hesapla
    final newVelocity = asteroid.closeApproachVelocity - (effectiveDeltaV / 1000); // m/s -> km/s
    
    return Asteroid(
      id: '${asteroid.id}_deflected',
      name: '${asteroid.name} (Saptırılmış)',
      mass: asteroid.mass,
      diameter: asteroid.diameter,
      closeApproachVelocity: newVelocity,
      impactAngle: asteroid.impactAngle,
      density: asteroid.density,
      composition: asteroid.composition,
      orbitalPeriod: asteroid.orbitalPeriod,
      semiMajorAxis: asteroid.semiMajorAxis,
      lastObservation: DateTime.now(),
    );
  }

  /// Yeni çarpma noktası hesapla
  Map<String, dynamic> _calculateNewImpactPoint(Asteroid deflectedAsteroid, double deltaV) {
    // Basitleştirilmiş hesaplama - gerçekte orbital mekanik gerekir
    final random = Random();
    
    // Delta-V'ye göre sapma miktarı
    final deviationFactor = deltaV / 10.0; // Normalize et
    
    final newLat = impactLatitude + (random.nextDouble() - 0.5) * deviationFactor * 10;
    final newLon = impactLongitude + (random.nextDouble() - 0.5) * deviationFactor * 10;
    
    // Okyanus çarpması mı kontrol et
    String location;
    if (_isOceanImpact(newLat, newLon)) {
      location = 'Okyanus (Güvenli Bölge)';
    } else {
      location = 'Kara (Risk Devam Ediyor)';
    }
    
    return {
      'latitude': newLat,
      'longitude': newLon,
      'location': location,
    };
  }

  bool _isOceanImpact(double lat, double lon) {
    // Basit okyanus kontrolü - gerçekte coğrafi veri gerekir
    return lat.abs() < 60 && (lon.abs() > 30 && lon.abs() < 150);
  }

  /// Senaryo sonuçları
  ScenarioResults get results {
    return ScenarioResults(
      scenario: this,
      originalImpact: originalImpact,
      modifiedImpact: modifiedImpact,
      isSuccessful: isDeflectionSuccessful,
      appliedStrategy: appliedStrategy,
      missDistance: _calculateMissDistance(),
      livesaved: _calculateLivesSaved(),
      economicSavings: _calculateEconomicSavings(),
    );
  }

  int _calculateLivesSaved() {
    if (originalImpact == null || !isDeflectionSuccessful) return 0;
    return originalImpact!.totalCasualties;
  }

  double _calculateEconomicSavings() {
    if (originalImpact == null || !isDeflectionSuccessful) return 0;
    return originalImpact!.economicDamage;
  }

  /// Asteroit için uygun stratejiler üret
  static List<MitigationStrategy> _generateStrategiesForAsteroid(Asteroid asteroid, int daysUntilImpact) {
    final strategies = <MitigationStrategy>[];
    
    // Asteroit boyutuna göre stratejiler
    if (asteroid.diameter < 100) {
      strategies.add(MitigationStrategy.kineticImpactor(
        name: 'Küçük Kinetik Çarpıcı',
        deltaV: 1.0,
        cost: 200,
        successRate: 0.95,
        preparationTime: 60,
      ));
    } else if (asteroid.diameter < 500) {
      strategies.add(MitigationStrategy.kineticImpactor(
        name: 'DART Benzeri Çarpıcı',
        deltaV: 0.5,
        cost: 500,
        successRate: 0.85,
        preparationTime: 90,
      ));
    } else {
      strategies.add(MitigationStrategy.nuclearDeflection(
        name: 'Nükleer Saptırma',
        deltaV: 5.0,
        cost: 2000,
        successRate: 0.90,
        preparationTime: 150,
      ));
    }
    
    // Zaman durumuna göre ek stratejiler
    if (daysUntilImpact > 200) {
      strategies.add(MitigationStrategy.gravitationalTractor(
        name: 'Yerçekimsel Çekici',
        deltaV: 0.1,
        cost: 800,
        successRate: 0.70,
        preparationTime: 200,
      ));
    }
    
    return strategies;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'asteroid': asteroid.toJson(),
      'discoveryDate': discoveryDate.toIso8601String(),
      'impactDate': impactDate.toIso8601String(),
      'impactLatitude': impactLatitude,
      'impactLongitude': impactLongitude,
      'impactLocation': impactLocation,
      'isActive': isActive,
      'appliedStrategy': appliedStrategy?.toJson(),
      'strategyApplicationTime': strategyApplicationTime?.toIso8601String(),
      'originalImpact': originalImpact?.toJson(),
      'modifiedImpact': modifiedImpact?.toJson(),
      'availableStrategies': availableStrategies.map((s) => s.toJson()).toList(),
    };
  }
}

/// Azaltma stratejisi sınıfı
class MitigationStrategy {
  final String id;
  final String name;
  final String type;
  final String description;
  final double deltaV; // m/s cinsinden hız değişimi
  final double cost; // Milyon USD
  final double successRate; // 0.0 - 1.0
  final int preparationTime; // gün
  final Map<String, dynamic> parameters;

  MitigationStrategy({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.deltaV,
    required this.cost,
    required this.successRate,
    required this.preparationTime,
    this.parameters = const {},
  });

  factory MitigationStrategy.kineticImpactor({
    required String name,
    required double deltaV,
    required double cost,
    required double successRate,
    required int preparationTime,
  }) {
    return MitigationStrategy(
      id: 'kinetic_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: 'Kinetik Çarpıcı',
      description: 'Yüksek hızlı uzay aracı ile asteroite çarparak yörüngesini değiştirme',
      deltaV: deltaV,
      cost: cost,
      successRate: successRate,
      preparationTime: preparationTime,
      parameters: {
        'impactorMass': 500, // kg
        'impactVelocity': 6000, // m/s
      },
    );
  }

  factory MitigationStrategy.nuclearDeflection({
    required String name,
    required double deltaV,
    required double cost,
    required double successRate,
    required int preparationTime,
  }) {
    return MitigationStrategy(
      id: 'nuclear_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: 'Nükleer Saptırma',
      description: 'Nükleer patlayıcı ile asteroitin yüzeyini buharlaştırarak itki oluşturma',
      deltaV: deltaV,
      cost: cost,
      successRate: successRate,
      preparationTime: preparationTime,
      parameters: {
        'yield': 1000, // kiloton
        'standoffDistance': 100, // metre
      },
    );
  }

  factory MitigationStrategy.gravitationalTractor({
    required String name,
    required double deltaV,
    required double cost,
    required double successRate,
    required int preparationTime,
  }) {
    return MitigationStrategy(
      id: 'gravity_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: 'Yerçekimsel Çekici',
      description: 'Uzay aracının yerçekimi ile asteroiti yavaşça saptırma',
      deltaV: deltaV,
      cost: cost,
      successRate: successRate,
      preparationTime: preparationTime,
      parameters: {
        'spacecraftMass': 20000, // kg
        'operationDuration': 365, // gün
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'deltaV': deltaV,
      'cost': cost,
      'successRate': successRate,
      'preparationTime': preparationTime,
      'parameters': parameters,
    };
  }

  factory MitigationStrategy.fromJson(Map<String, dynamic> json) {
    return MitigationStrategy(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      deltaV: json['deltaV'].toDouble(),
      cost: json['cost'].toDouble(),
      successRate: json['successRate'].toDouble(),
      preparationTime: json['preparationTime'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
    );
  }
}

/// Senaryo sonuçları
class ScenarioResults {
  final Impactor2025Scenario scenario;
  final ImpactCalculation? originalImpact;
  final ImpactCalculation? modifiedImpact;
  final bool isSuccessful;
  final MitigationStrategy? appliedStrategy;
  final double missDistance; // km
  final int livesaved;
  final double economicSavings; // milyar USD

  ScenarioResults({
    required this.scenario,
    this.originalImpact,
    this.modifiedImpact,
    required this.isSuccessful,
    this.appliedStrategy,
    required this.missDistance,
    required this.livesaved,
    required this.economicSavings,
  });

  String get successMessage {
    if (isSuccessful) {
      return '''
🎉 BAŞARILI! Asteroit başarıyla saptırıldı!

✅ Iskalama Mesafesi: ${missDistance.toStringAsFixed(0)} km
✅ Kurtarılan Can: ${livesaved.toStringAsFixed(0)} kişi
✅ Ekonomik Tasarruf: \$${economicSavings.toStringAsFixed(1)} milyar
✅ Uygulanan Strateji: ${appliedStrategy?.name ?? 'Bilinmiyor'}
''';
    } else {
      return '''
❌ BAŞARISIZ! Asteroit saptırılamadı.

⚠️ Çarpma devam edecek
⚠️ Tahmini Kayıp: ${originalImpact?.totalCasualties ?? 0} kişi
⚠️ Ekonomik Zarar: \$${originalImpact?.economicDamage.toStringAsFixed(1) ?? '0'} milyar
⚠️ Acil tahliye planları devreye alınmalı!
''';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccessful': isSuccessful,
      'missDistance': missDistance,
      'livesaved': livesaved,
      'economicSavings': economicSavings,
      'appliedStrategy': appliedStrategy?.toJson(),
      'originalImpact': originalImpact?.toJson(),
      'modifiedImpact': modifiedImpact?.toJson(),
    };
  }
}

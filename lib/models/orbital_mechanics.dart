import 'dart:math';
import 'vector3d.dart';
import 'keplerian_elements.dart';

/// Yörünge mekaniği hesaplamaları için sınıf
class OrbitalMechanics {
  // Astronomik sabitler
  static const double gravitationalConstant = 6.67430e-11; // m³/kg⋅s²
  static const double earthMass = 5.972e24; // kg
  static const double earthRadius = 6.371e6; // m
  static const double astronomicalUnit = 1.496e11; // m (1 AU)
  static const double solarMass = 1.989e30; // kg
  
  /// Asteroitin belirli bir zamandaki pozisyonunu hesapla
  static Vector3D calculatePosition(KeplerianElements elements, double julianDay) {
    // Zaman farkı (gün)
    final double deltaTime = julianDay - elements.epoch;
    
    // Ortalama hareket (radyan/gün)
    final double meanMotion = 2 * pi / elements.orbitalPeriod;
    
    // Güncel ortalama anomali
    final double currentMeanAnomaly = elements.meanAnomaly + meanMotion * deltaTime;
    
    // Eksantrik anomaliyi çöz (Newton-Raphson yöntemi)
    final double eccentricAnomaly = solveEccentricAnomaly(currentMeanAnomaly, elements.eccentricity);
    
    // Gerçek anomali
    final double trueAnomaly = calculateTrueAnomaly(eccentricAnomaly, elements.eccentricity);
    
    // Yörünge düzlemindeki pozisyon
    final double r = elements.semiMajorAxis * astronomicalUnit * (1 - elements.eccentricity * cos(eccentricAnomaly));
    final double x_orbital = r * cos(trueAnomaly);
    final double y_orbital = r * sin(trueAnomaly);
    
    // 3D uzaya dönüştür
    return transformToEcliptic(
      Vector3D(x_orbital, y_orbital, 0),
      elements.inclination,
      elements.longitudeOfAscendingNode,
      elements.argumentOfPeriapsis,
    );
  }
  
  /// Eksantrik anomaliyi çöz (Newton-Raphson)
  static double solveEccentricAnomaly(double meanAnomaly, double eccentricity, {int maxIterations = 10}) {
    double E = meanAnomaly; // İlk tahmin
    
    for (int i = 0; i < maxIterations; i++) {
      final double f = E - eccentricity * sin(E) - meanAnomaly;
      final double df = 1 - eccentricity * cos(E);
      
      final double deltaE = f / df;
      E -= deltaE;
      
      if (deltaE.abs() < 1e-12) break;
    }
    
    return E;
  }
  
  /// Gerçek anomaliyi hesapla
  static double calculateTrueAnomaly(double eccentricAnomaly, double eccentricity) {
    final double beta = eccentricity / (1 + sqrt(1 - eccentricity * eccentricity));
    return eccentricAnomaly + 2 * atan(beta * sin(eccentricAnomaly) / (1 - beta * cos(eccentricAnomaly)));
  }
  
  /// Yörünge düzleminden ekliptik koordinatlara dönüştür
  static Vector3D transformToEcliptic(Vector3D orbitalPos, double inclination, double omega, double w) {
    // Dönüşüm matrisleri
    final double cosOmega = cos(omega);
    final double sinOmega = sin(omega);
    final double cosI = cos(inclination);
    final double sinI = sin(inclination);
    final double cosW = cos(w);
    final double sinW = sin(w);
    
    // Dönüşüm matrisi elemanları
    final double p11 = cosOmega * cosW - sinOmega * sinW * cosI;
    final double p12 = -cosOmega * sinW - sinOmega * cosW * cosI;
    final double p21 = sinOmega * cosW + cosOmega * sinW * cosI;
    final double p22 = -sinOmega * sinW + cosOmega * cosW * cosI;
    final double p31 = sinW * sinI;
    final double p32 = cosW * sinI;
    
    return Vector3D(
      p11 * orbitalPos.x + p12 * orbitalPos.y,
      p21 * orbitalPos.x + p22 * orbitalPos.y,
      p31 * orbitalPos.x + p32 * orbitalPos.y,
    );
  }
  
  /// Dünya'nın pozisyonunu hesapla (basitleştirilmiş)
  static Vector3D calculateEarthPosition(double julianDay) {
    // Dünya'nın ortalama yörünge elemanları (J2000.0)
    final double meanLongitude = 280.460 + 0.9856474 * (julianDay - 2451545.0);
    final double meanLongitudeRad = meanLongitude * pi / 180;
    
    // Basitleştirilmiş eliptik yörünge
    final double eccentricity = 0.0167;
    final double meanAnomaly = meanLongitudeRad;
    final double eccentricAnomaly = solveEccentricAnomaly(meanAnomaly, eccentricity);
    final double trueAnomaly = calculateTrueAnomaly(eccentricAnomaly, eccentricity);
    
    final double r = astronomicalUnit * (1 - eccentricity * cos(eccentricAnomaly));
    
    return Vector3D(
      r * cos(trueAnomaly),
      r * sin(trueAnomaly),
      0,
    );
  }
  
  /// Asteroitin Dünya'ya göre relatif pozisyonunu hesapla
  static Vector3D calculateRelativePosition(KeplerianElements elements, double julianDay) {
    final Vector3D asteroidPos = calculatePosition(elements, julianDay);
    final Vector3D earthPos = calculateEarthPosition(julianDay);
    
    return asteroidPos - earthPos;
  }
  
  /// Asteroitin Dünya'ya olan mesafesini hesapla (AU)
  static double calculateDistanceToEarth(KeplerianElements elements, double julianDay) {
    final Vector3D relativePos = calculateRelativePosition(elements, julianDay);
    return relativePos.magnitude / astronomicalUnit;
  }
  
  /// Asteroitin Dünya'ya göre hızını hesapla
  static Vector3D calculateRelativeVelocity(KeplerianElements elements, double julianDay, {double deltaTime = 0.01}) {
    final Vector3D pos1 = calculateRelativePosition(elements, julianDay - deltaTime / 2);
    final Vector3D pos2 = calculateRelativePosition(elements, julianDay + deltaTime / 2);
    
    return (pos2 - pos1) * (1 / deltaTime); // m/gün
  }
  
  /// Çarpma hızını hesapla (m/s)
  static double calculateImpactVelocity(KeplerianElements elements, double julianDay) {
    final Vector3D velocity = calculateRelativeVelocity(elements, julianDay);
    return velocity.magnitude / 86400; // gün/saniye dönüşümü
  }
  
  /// Minimum Orbital Intersection Distance (MOID) hesapla
  static double calculateMOID(KeplerianElements elements) {
    // Basitleştirilmiş MOID hesaplaması
    // Gerçek hesaplama çok karmaşık, burada yaklaşık değer
    
    final double earthOrbitRadius = 1.0; // AU
    final double asteroidPerihelion = elements.perihelionDistance;
    final double asteroidAphelion = elements.aphelionDistance;
    
    if (asteroidAphelion < earthOrbitRadius) {
      // Asteroit Dünya yörüngesinin içinde
      return earthOrbitRadius - asteroidAphelion;
    } else if (asteroidPerihelion > earthOrbitRadius) {
      // Asteroit Dünya yörüngesinin dışında
      return asteroidPerihelion - earthOrbitRadius;
    } else {
      // Yörüngeler kesişiyor
      return 0.0;
    }
  }
  
  /// Yörünge tahminini belirli bir zaman aralığında hesapla
  static List<Vector3D> calculateOrbitTrajectory(
    KeplerianElements elements,
    double startJulianDay,
    double endJulianDay,
    int numberOfPoints,
  ) {
    final List<Vector3D> trajectory = [];
    final double timeStep = (endJulianDay - startJulianDay) / (numberOfPoints - 1);
    
    for (int i = 0; i < numberOfPoints; i++) {
      final double julianDay = startJulianDay + i * timeStep;
      trajectory.add(calculatePosition(elements, julianDay));
    }
    
    return trajectory;
  }
  
  /// Çarpma noktasını hesapla (Dünya yüzeyindeki koordinatlar)
  static Map<String, double> calculateImpactPoint(KeplerianElements elements, double impactJulianDay) {
    final Vector3D relativePos = calculateRelativePosition(elements, impactJulianDay);
    final Vector3D earthCenter = Vector3D(0, 0, 0);
    
    // Dünya merkezinden çarpma noktasına doğru normalize edilmiş vektör
    final Vector3D impactDirection = relativePos.normalized;
    
    // Dünya yüzeyindeki çarpma noktası
    final Vector3D impactPoint = impactDirection * earthRadius;
    
    // Kartezyen koordinatlardan coğrafi koordinatlara dönüştür
    final double latitude = asin(impactPoint.z / earthRadius) * 180 / pi;
    final double longitude = atan2(impactPoint.y, impactPoint.x) * 180 / pi;
    
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
  
  /// Kinetik çarpıcı etkisini simüle et
  static KeplerianElements simulateKineticImpactor(
    KeplerianElements originalElements,
    double impactJulianDay,
    double impactorMass, // kg
    double impactorVelocity, // m/s
    double asteroidMass, // kg
  ) {
    // Momentum değişimi hesapla
    final double momentumChange = impactorMass * impactorVelocity;
    
    // Asteroitin mevcut hızını hesapla
    final Vector3D currentVelocity = calculateRelativeVelocity(originalElements, impactJulianDay);
    final double currentSpeed = currentVelocity.magnitude / 86400; // m/s
    
    // Hız değişimi (basitleştirilmiş)
    final double velocityChange = momentumChange / asteroidMass;
    final double newSpeed = currentSpeed + velocityChange;
    
    // Yeni yörünge elemanlarını hesapla (basitleştirilmiş)
    final double speedRatio = newSpeed / currentSpeed;
    final double newSemiMajorAxis = originalElements.semiMajorAxis / (speedRatio * speedRatio);
    
    return originalElements.copyWith(
      semiMajorAxis: newSemiMajorAxis,
      meanAnomaly: originalElements.meanAnomaly + velocityChange * 1e-6, // Küçük pertürbasyon
    );
  }
  
  /// Çarpma zamanını tahmin et
  static double? estimateImpactTime(KeplerianElements elements, double startJulianDay, {int maxDays = 3650}) {
    const double earthInfluenceRadius = 0.01; // AU (yaklaşık 1.5 milyon km)
    
    for (int day = 0; day < maxDays; day++) {
      final double julianDay = startJulianDay + day;
      final double distance = calculateDistanceToEarth(elements, julianDay);
      
      if (distance < earthInfluenceRadius) {
        // Daha hassas hesaplama için saatlik kontrol
        for (int hour = 0; hour < 24; hour++) {
          final double hourlyJulianDay = julianDay + hour / 24.0;
          final double hourlyDistance = calculateDistanceToEarth(elements, hourlyJulianDay);
          
          if (hourlyDistance < earthRadius / astronomicalUnit) {
            return hourlyJulianDay;
          }
        }
      }
    }
    
    return null; // Çarpma bulunamadı
  }
  
  /// Julian gün sayısını DateTime'dan hesapla
  static double dateTimeToJulianDay(DateTime dateTime) {
    final int a = (14 - dateTime.month) ~/ 12;
    final int y = dateTime.year + 4800 - a;
    final int m = dateTime.month + 12 * a - 3;
    
    final int jdn = dateTime.day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
    
    final double dayFraction = (dateTime.hour - 12) / 24.0 + dateTime.minute / 1440.0 + dateTime.second / 86400.0;
    
    return jdn + dayFraction;
  }
  
  /// Julian gün sayısından DateTime'a dönüştür
  static DateTime julianDayToDateTime(double julianDay) {
    final int jd = julianDay.floor();
    final double fraction = julianDay - jd;
    
    final int a = jd + 32044;
    final int b = (4 * a + 3) ~/ 146097;
    final int c = a - (146097 * b) ~/ 4;
    final int d = (4 * c + 3) ~/ 1461;
    final int e = c - (1461 * d) ~/ 4;
    final int m = (5 * e + 2) ~/ 153;
    
    final int day = e - (153 * m + 2) ~/ 5 + 1;
    final int month = m + 3 - 12 * (m ~/ 10);
    final int year = 100 * b + d - 4800 + m ~/ 10;
    
    final double hours = (fraction + 0.5) * 24;
    final int hour = hours.floor();
    final int minute = ((hours - hour) * 60).floor();
    final int second = (((hours - hour) * 60 - minute) * 60).floor();
    
    return DateTime(year, month, day, hour, minute, second);
  }
  
  /// Yörünge elemanlarını NASA verilerinden oluştur
  static KeplerianElements fromNASAData(Map<String, dynamic> orbitalData) {
    return KeplerianElements(
      semiMajorAxis: double.tryParse(orbitalData['semi_major_axis'] ?? '1.0') ?? 1.0,
      eccentricity: double.tryParse(orbitalData['eccentricity'] ?? '0.0') ?? 0.0,
      inclination: (double.tryParse(orbitalData['inclination'] ?? '0.0') ?? 0.0) * pi / 180,
      longitudeOfAscendingNode: (double.tryParse(orbitalData['ascending_node_longitude'] ?? '0.0') ?? 0.0) * pi / 180,
      argumentOfPeriapsis: (double.tryParse(orbitalData['perihelion_argument'] ?? '0.0') ?? 0.0) * pi / 180,
      meanAnomaly: (double.tryParse(orbitalData['mean_anomaly'] ?? '0.0') ?? 0.0) * pi / 180,
      epoch: double.tryParse(orbitalData['epoch_osculation'] ?? '2451545.0') ?? 2451545.0,
    );
  }
}

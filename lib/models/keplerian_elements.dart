import 'dart:math';

/// Kepler yörünge elemanları
class KeplerianElements {
  final double semiMajorAxis; // a (AU)
  final double eccentricity; // e
  final double inclination; // i (radyan)
  final double longitudeOfAscendingNode; // Ω (radyan)
  final double argumentOfPeriapsis; // ω (radyan)
  final double meanAnomaly; // M (radyan)
  final double epoch; // Referans zamanı (Julian günü)
  
  KeplerianElements({
    required this.semiMajorAxis,
    required this.eccentricity,
    required this.inclination,
    required this.longitudeOfAscendingNode,
    required this.argumentOfPeriapsis,
    required this.meanAnomaly,
    required this.epoch,
  });
  
  /// Yörünge periyodu (gün)
  double get orbitalPeriod {
    return 365.25 * sqrt(pow(semiMajorAxis, 3));
  }
  
  /// Perihelion mesafesi (AU)
  double get perihelionDistance {
    return semiMajorAxis * (1 - eccentricity);
  }
  
  /// Aphelion mesafesi (AU)
  double get aphelionDistance {
    return semiMajorAxis * (1 + eccentricity);
  }
  
  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'semiMajorAxis': semiMajorAxis,
      'eccentricity': eccentricity,
      'inclination': inclination,
      'longitudeOfAscendingNode': longitudeOfAscendingNode,
      'argumentOfPeriapsis': argumentOfPeriapsis,
      'meanAnomaly': meanAnomaly,
      'epoch': epoch,
    };
  }
  
  /// JSON'dan oluştur
  factory KeplerianElements.fromJson(Map<String, dynamic> json) {
    return KeplerianElements(
      semiMajorAxis: json['semiMajorAxis']?.toDouble() ?? 1.0,
      eccentricity: json['eccentricity']?.toDouble() ?? 0.0,
      inclination: json['inclination']?.toDouble() ?? 0.0,
      longitudeOfAscendingNode: json['longitudeOfAscendingNode']?.toDouble() ?? 0.0,
      argumentOfPeriapsis: json['argumentOfPeriapsis']?.toDouble() ?? 0.0,
      meanAnomaly: json['meanAnomaly']?.toDouble() ?? 0.0,
      epoch: json['epoch']?.toDouble() ?? 2451545.0, // J2000.0
    );
  }
  
  /// Kopyala ve değiştir
  KeplerianElements copyWith({
    double? semiMajorAxis,
    double? eccentricity,
    double? inclination,
    double? longitudeOfAscendingNode,
    double? argumentOfPeriapsis,
    double? meanAnomaly,
    double? epoch,
  }) {
    return KeplerianElements(
      semiMajorAxis: semiMajorAxis ?? this.semiMajorAxis,
      eccentricity: eccentricity ?? this.eccentricity,
      inclination: inclination ?? this.inclination,
      longitudeOfAscendingNode: longitudeOfAscendingNode ?? this.longitudeOfAscendingNode,
      argumentOfPeriapsis: argumentOfPeriapsis ?? this.argumentOfPeriapsis,
      meanAnomaly: meanAnomaly ?? this.meanAnomaly,
      epoch: epoch ?? this.epoch,
    );
  }
  
  @override
  String toString() {
    return 'KeplerianElements(a: ${semiMajorAxis.toStringAsFixed(3)} AU, '
           'e: ${eccentricity.toStringAsFixed(3)}, '
           'i: ${(inclination * 180 / pi).toStringAsFixed(1)}°, '
           'period: ${orbitalPeriod.toStringAsFixed(1)} days)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeplerianElements &&
        other.semiMajorAxis == semiMajorAxis &&
        other.eccentricity == eccentricity &&
        other.inclination == inclination &&
        other.longitudeOfAscendingNode == longitudeOfAscendingNode &&
        other.argumentOfPeriapsis == argumentOfPeriapsis &&
        other.meanAnomaly == meanAnomaly &&
        other.epoch == epoch;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      semiMajorAxis,
      eccentricity,
      inclination,
      longitudeOfAscendingNode,
      argumentOfPeriapsis,
      meanAnomaly,
      epoch,
    );
  }
}

import 'dart:math' as math;

/// NASA JPL SBDB Standartlarında Professional Asteroid Model
/// Center for Near Earth Object Studies (CNEOS) compatible data structure
class Asteroid {
  // Basic identification
  final String id; // SPK-ID or provisional designation
  final String name; // Primary designation
  final String? fullName; // Full name if available
  final String? provisionalDesignation; // Provisional designation
  
  // Physical parameters (NASA JPL SBDB format)
  final double diameter; // km (estimated diameter) - BACKWARD COMPAT: was meters, now km
  final double mass; // kg (calculated from diameter + density)
  final double? albedo; // Geometric albedo
  final double? absoluteMagnitude; // H (absolute magnitude)
  final double rotationPeriod; // hours
  final String spectralType; // SMASS spectral classification
  final double density; // g/cm³ (bulk density)
  final String composition; // C, S, X, etc.
  
  // Orbital elements (standard Keplerian elements)
  final double semiMajorAxis; // AU (a)
  final double eccentricity; // (e) 0-1
  final double inclination; // degrees (i)
  final double longitudeAscendingNode; // degrees (Ω)
  final double argumentPeriapsis; // degrees (ω)  
  final double meanAnomaly; // degrees (M)
  final double orbitalPeriod; // years
  final double perihelionDistance; // AU (q)
  final double aphelionDistance; // AU (Q)
  
  // Close approach data (NASA CNEOS format)
  final DateTime? closeApproachDate;
  final double? closeApproachDistance; // AU
  final double closeApproachVelocity; // km/s - BACKWARD COMPAT: main velocity field
  final double? missDistance; // km (lunar distances)
  
  // Impact assessment
  final double? impactProbability; // 0-1 scale
  final int? torinoScale; // 0-10 Torino Impact Hazard Scale
  final double? palermoScale; // Palermo Technical Impact Hazard Scale
  final DateTime? potentialImpactDate;
  final double? impactLatitude; // degrees
  final double? impactLongitude; // degrees
  final double? impactVelocity; // km/s
  final double impactAngle; // degrees from horizontal
  
  // Risk classification
  final bool isPotentiallyHazardous; // PHO status
  final bool isNearEarthObject; // NEO status
  final String? riskClass; // Apollo, Aten, Amor, Atira
  
  // Data provenance
  final DateTime lastObservation;
  final int numberOfObservations;
  final double observationArc; // days
  final String dataSource; // JPL, MPC, etc.
  final double uncertaintyParameter; // 0-9 scale

  // Constructor with all required fields
  Asteroid({
    required this.id,
    required this.name,
    this.fullName,
    this.provisionalDesignation,
    required this.diameter, // km
    required this.mass, // kg
    this.albedo,
    this.absoluteMagnitude,
    this.rotationPeriod = 24.0, // default 24 hours
    this.spectralType = 'S',
    this.density = 2.6, // g/cm³
    this.composition = 'Stony',
    this.semiMajorAxis = 1.5, // AU
    this.eccentricity = 0.1,
    this.inclination = 5.0, // degrees
    this.longitudeAscendingNode = 0.0,
    this.argumentPeriapsis = 0.0,
    this.meanAnomaly = 0.0,
    this.orbitalPeriod = 2.0, // years
    this.perihelionDistance = 1.0, // AU
    this.aphelionDistance = 2.0, // AU
    this.closeApproachDate,
    this.closeApproachDistance,
    required this.closeApproachVelocity, // km/s
    this.missDistance,
    this.impactProbability,
    this.torinoScale,
    this.palermoScale,
    this.potentialImpactDate,
    this.impactLatitude,
    this.impactLongitude,
    this.impactVelocity,
    this.impactAngle = 45.0, // degrees
    this.isPotentiallyHazardous = false,
    this.isNearEarthObject = true,
    this.riskClass,
    required this.lastObservation,
    this.numberOfObservations = 100,
    this.observationArc = 365.0, // days
    this.dataSource = 'JPL',
    this.uncertaintyParameter = 3.0,
  });

  // Backward compatibility getters
  double get velocity => closeApproachVelocity * 1000; // Convert km/s to m/s for backward compatibility
  double? get distanceFromSun => semiMajorAxis; // AU
  double? get orbitalPeriodDays => orbitalPeriod * 365.25; // Convert years to days

  // NASA JPL SBDB API format constructor
  factory Asteroid.fromNASAData(Map<String, dynamic> data) {
    final diameterKm = (data['diameter']?.toDouble() ?? 0.1) / 1000; // Convert m to km
    final velocityKmS = (data['velocity']?.toDouble() ?? 20000.0) / 1000; // Convert m/s to km/s
    
    return Asteroid(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Unknown Asteroid',
      fullName: data['full_name']?.toString(),
      diameter: diameterKm,
      mass: _calculateMassFromDiameter(diameterKm, (data['density']?.toDouble() ?? 2.6) * 1000), // Convert g/cm³ to kg/m³
      albedo: data['albedo']?.toDouble(),
      absoluteMagnitude: data['H']?.toDouble(),
      density: data['density']?.toDouble() ?? 2.6, // g/cm³
      composition: _mapComposition(data['spec_B']?.toString()),
      spectralType: data['spec_B']?.toString() ?? 'S',
      semiMajorAxis: data['a']?.toDouble() ?? 1.5,
      eccentricity: data['e']?.toDouble() ?? 0.1,
      inclination: data['i']?.toDouble() ?? 5.0,
      orbitalPeriod: data['per_y']?.toDouble() ?? 2.0,
      closeApproachVelocity: velocityKmS,
      impactAngle: data['impact_angle']?.toDouble() ?? 45.0,
      isPotentiallyHazardous: data['pha'] == 'Y',
      isNearEarthObject: data['neo'] == 'Y',
      lastObservation: DateTime.tryParse(data['last_obs']?.toString() ?? '') ?? DateTime.now(),
      dataSource: 'NASA JPL',
    );
  }

  // Backward compatibility constructor (old format)
  factory Asteroid.fromLegacyData({
    required String id,
    required String name,
    required double diameter, // meters
    required double velocity, // m/s
    required double impactAngle,
    double density = 2600, // kg/m³
    String composition = 'Stony',
    double? orbitalPeriod,
    double? distanceFromSun,
  }) {
    final diameterKm = diameter / 1000; // Convert m to km
    final velocityKmS = velocity / 1000; // Convert m/s to km/s
    final densityGcm3 = density / 1000; // Convert kg/m³ to g/cm³
    final mass = _calculateMassFromDiameter(diameterKm, density);
    
    return Asteroid(
      id: id,
      name: name,
      diameter: diameterKm,
      mass: mass,
      density: densityGcm3,
      composition: composition,
      closeApproachVelocity: velocityKmS,
      impactAngle: impactAngle,
      semiMajorAxis: distanceFromSun ?? 1.5,
      orbitalPeriod: (orbitalPeriod ?? 730) / 365.25, // Convert days to years
      lastObservation: DateTime.now(),
    );
  }

  // Manual user input constructor
  factory Asteroid.fromUserInput({
    required double diameter, // meters
    required double velocity, // m/s
    required double impactAngle,
    String composition = 'Stony',
    double? customMass,
  }) {
    final diameterKm = diameter / 1000;
    final velocityKmS = velocity / 1000;
    final density = _getDensityByComposition(composition);
    final mass = customMass ?? _calculateMassFromDiameter(diameterKm, density * 1000);
    
    return Asteroid(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'User Asteroid',
      diameter: diameterKm,
      mass: mass,
      density: density,
      composition: composition,
      closeApproachVelocity: velocityKmS,
      impactAngle: impactAngle,
      lastObservation: DateTime.now(),
    );
  }

  // Real NASA catalog asteroids with accurate data
  static List<Asteroid> getPredefinedAsteroids() {
    return [
      // 99942 Apophis - Real NASA data
      Asteroid(
        id: '99942',
        name: '99942 Apophis',
        fullName: '(99942) Apophis',
        diameter: 0.370, // km
        mass: 6.1e10, // kg (~61 million tons)
        albedo: 0.31,
        absoluteMagnitude: 19.7,
        density: 3.2, // g/cm³
        spectralType: 'Sq',
        composition: 'Stony',
        semiMajorAxis: 0.9224, // AU
        eccentricity: 0.1911,
        inclination: 3.331, // degrees
        orbitalPeriod: 0.886, // years
        perihelionDistance: 0.7461, // AU
        aphelionDistance: 1.0988, // AU
        closeApproachVelocity: 12.6, // km/s
        impactAngle: 45.0,
        isPotentiallyHazardous: true,
        isNearEarthObject: true,
        riskClass: 'Aten',
        torinoScale: 0,
        lastObservation: DateTime.now(),
        numberOfObservations: 1963,
        observationArc: 6916, // days
        dataSource: 'NASA JPL SBDB',
      ),

      // 101955 Bennu - OSIRIS-REx target
      Asteroid(
        id: '101955',
        name: '101955 Bennu',
        fullName: '(101955) Bennu',
        diameter: 0.492, // km
        mass: 7.8e10, // kg
        albedo: 0.046,
        absoluteMagnitude: 20.9,
        rotationPeriod: 4.297, // hours
        density: 1.19, // g/cm³ - very low density (rubble pile)
        spectralType: 'B',
        composition: 'Carbonaceous',
        semiMajorAxis: 1.126, // AU
        eccentricity: 0.2037,
        inclination: 6.035,
        orbitalPeriod: 1.195, // years
        perihelionDistance: 0.8968,
        aphelionDistance: 1.356,
        closeApproachVelocity: 11.0, // km/s
        impactAngle: 30.0,
        isPotentiallyHazardous: true,
        isNearEarthObject: true,
        riskClass: 'Apollo',
        torinoScale: 0,
        impactProbability: 1/2700.0, // 1 in 2,700 chance by 2200
        lastObservation: DateTime.now(),
        numberOfObservations: 2156,
        observationArc: 7789,
        dataSource: 'NASA JPL SBDB',
      ),

      // 65803 Didymos - DART mission target
      Asteroid(
        id: '65803',
        name: '65803 Didymos',
        fullName: '(65803) Didymos',
        diameter: 0.780, // km
        mass: 5.3e11, // kg
        density: 2.17, // g/cm³
        spectralType: 'Xk',
        composition: 'Stony',
        semiMajorAxis: 1.644, // AU
        eccentricity: 0.384,
        inclination: 3.408,
        orbitalPeriod: 2.111, // years
        closeApproachVelocity: 15.0, // km/s
        impactAngle: 60.0,
        isPotentiallyHazardous: true,
        isNearEarthObject: true,
        riskClass: 'Apollo',
        lastObservation: DateTime.now(),
        numberOfObservations: 1045,
        observationArc: 8942,
        dataSource: 'NASA JPL SBDB',
      ),

      // Chelyabinsk impactor (historical reconstruction)
      Asteroid(
        id: 'chelyabinsk-2013',
        name: 'Chelyabinsk Impactor',
        fullName: '2013 Chelyabinsk Meteor',
        diameter: 0.020, // km (20 meters)
        mass: 1.3e7, // kg (13,000 tons)
        density: 3.3, // g/cm³ - ordinary chondrite
        spectralType: 'LL',
        composition: 'Stony',
        closeApproachVelocity: 18.3, // km/s
        impactAngle: 18.0, // shallow angle
        impactLatitude: 55.1544,
        impactLongitude: 61.4293,
        isPotentiallyHazardous: false,
        isNearEarthObject: true,
        riskClass: 'Apollo',
        potentialImpactDate: DateTime(2013, 2, 15, 9, 20),
        lastObservation: DateTime(2013, 2, 15),
        dataSource: 'Post-impact analysis',
      ),

      // Tunguska impactor (historical reconstruction)  
      Asteroid(
        id: 'tunguska-1908',
        name: 'Tunguska Impactor',
        fullName: '1908 Tunguska Event Object',
        diameter: 0.060, // km (60 meters)
        mass: 1.2e8, // kg (120,000 tons)
        density: 3.0, // g/cm³ - estimated stony composition
        spectralType: 'S',
        composition: 'Stony',
        closeApproachVelocity: 27.0, // km/s - high velocity
        impactAngle: 30.0,
        impactLatitude: 60.886,
        impactLongitude: 101.896,
        isPotentiallyHazardous: false,
        isNearEarthObject: true,
        riskClass: 'Apollo',
        potentialImpactDate: DateTime(1908, 6, 30, 7, 17),
        lastObservation: DateTime(1908, 6, 30),
        dataSource: 'Historical reconstruction',
      ),
    ];
  }

  // Kinetic energy calculation (Joules)
  double get kineticEnergy {
    final velocityMs = closeApproachVelocity * 1000; // Convert km/s to m/s
    return 0.5 * mass * velocityMs * velocityMs;
  }

  // TNT equivalent (tons)
  double get tntEquivalent {
    return kineticEnergy / 4.184e9; // 1 ton TNT = 4.184 GJ
  }

  // Megaton TNT equivalent
  double get megatonTNT {
    return tntEquivalent / 1e6;
  }

  // Hiroshima bomb equivalent
  double get hiroshimaEquivalent {
    return tntEquivalent / 15000; // Hiroshima ~15 kilotons
  }

  // Asteroid size category (NASA classification)
  String get category {
    final diameterM = diameter * 1000; // Convert km to m
    if (diameterM < 10) return 'Very Small';
    if (diameterM < 50) return 'Small';
    if (diameterM < 200) return 'Medium';
    if (diameterM < 1000) return 'Large';
    return 'Giant';
  }

  // Risk assessment level
  String get riskLevel {
    if (torinoScale != null) {
      if (torinoScale! >= 8) return 'Critical';
      if (torinoScale! >= 5) return 'High';
      if (torinoScale! >= 2) return 'Medium';
      if (torinoScale! >= 1) return 'Low';
      return 'No Risk';
    }
    
    // Fallback based on energy
    final energy = megatonTNT;
    if (energy >= 100) return 'Critical';
    if (energy >= 10) return 'High';
    if (energy >= 0.1) return 'Medium';
    return 'Low';
  }

  // NASA JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'prov_des': provisionalDesignation,
      'diameter_km': diameter,
      'mass_kg': mass,
      'albedo': albedo,
      'H': absoluteMagnitude,
      'rot_per': rotationPeriod,
      'spec_B': spectralType,
      'density_gcm3': density,
      'class': composition,
      'a': semiMajorAxis,
      'e': eccentricity,
      'i': inclination,
      'om': longitudeAscendingNode,
      'w': argumentPeriapsis,
      'ma': meanAnomaly,
      'per_y': orbitalPeriod,
      'q': perihelionDistance,
      'ad': aphelionDistance,
      'cd': closeApproachDate?.toIso8601String(),
      'ca_dist_au': closeApproachDistance,
      'v_rel_kms': closeApproachVelocity,
      'miss_dist_km': missDistance,
      'impact_prob': impactProbability,
      'torino': torinoScale,
      'palermo': palermoScale,
      'impact_date': potentialImpactDate?.toIso8601String(),
      'impact_lat': impactLatitude,
      'impact_lon': impactLongitude,
      'impact_vel_kms': impactVelocity,
      'impact_angle': impactAngle,
      'pha': isPotentiallyHazardous ? 'Y' : 'N',
      'neo': isNearEarthObject ? 'Y' : 'N',
      'orbit_class': riskClass,
      'last_obs': lastObservation.toIso8601String(),
      'n_obs_used': numberOfObservations,
      'arc_length_d': observationArc,
      'data_source': dataSource,
      'condition_code': uncertaintyParameter,
    };
  }

  // JSON deserialization
  factory Asteroid.fromJson(Map<String, dynamic> json) {
    return Asteroid(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      provisionalDesignation: json['prov_des']?.toString(),
      diameter: json['diameter_km']?.toDouble() ?? 0.1,
      mass: json['mass_kg']?.toDouble() ?? 1e6,
      albedo: json['albedo']?.toDouble(),
      absoluteMagnitude: json['H']?.toDouble(),
      rotationPeriod: json['rot_per']?.toDouble() ?? 24.0,
      spectralType: json['spec_B']?.toString() ?? 'S',
      density: json['density_gcm3']?.toDouble() ?? 2.6,
      composition: json['class']?.toString() ?? 'Stony',
      semiMajorAxis: json['a']?.toDouble() ?? 1.5,
      eccentricity: json['e']?.toDouble() ?? 0.1,
      inclination: json['i']?.toDouble() ?? 5.0,
      longitudeAscendingNode: json['om']?.toDouble() ?? 0.0,
      argumentPeriapsis: json['w']?.toDouble() ?? 0.0,
      meanAnomaly: json['ma']?.toDouble() ?? 0.0,
      orbitalPeriod: json['per_y']?.toDouble() ?? 2.0,
      perihelionDistance: json['q']?.toDouble() ?? 1.0,
      aphelionDistance: json['ad']?.toDouble() ?? 2.0,
      closeApproachDate: json['cd'] != null ? DateTime.tryParse(json['cd']) : null,
      closeApproachDistance: json['ca_dist_au']?.toDouble(),
      closeApproachVelocity: json['v_rel_kms']?.toDouble() ?? 20.0,
      missDistance: json['miss_dist_km']?.toDouble(),
      impactProbability: json['impact_prob']?.toDouble(),
      torinoScale: json['torino']?.toInt(),
      palermoScale: json['palermo']?.toDouble(),
      potentialImpactDate: json['impact_date'] != null ? DateTime.tryParse(json['impact_date']) : null,
      impactLatitude: json['impact_lat']?.toDouble(),
      impactLongitude: json['impact_lon']?.toDouble(),
      impactVelocity: json['impact_vel_kms']?.toDouble(),
      impactAngle: json['impact_angle']?.toDouble() ?? 45.0,
      isPotentiallyHazardous: json['pha'] == 'Y',
      isNearEarthObject: json['neo'] == 'Y',
      riskClass: json['orbit_class']?.toString(),
      lastObservation: DateTime.tryParse(json['last_obs']?.toString() ?? '') ?? DateTime.now(),
      numberOfObservations: json['n_obs_used']?.toInt() ?? 100,
      observationArc: json['arc_length_d']?.toDouble() ?? 365.0,
      dataSource: json['data_source']?.toString() ?? 'Unknown',
      uncertaintyParameter: json['condition_code']?.toDouble() ?? 3.0,
    );
  }

  // Helper methods
  static double _calculateMassFromDiameter(double diameterKm, double densityKgM3) {
    final radiusM = (diameterKm * 1000) / 2; // Convert km to m
    final volume = (4 / 3) * math.pi * math.pow(radiusM, 3);
    return volume * densityKgM3;
  }

  static double _getDensityByComposition(String composition) {
    switch (composition.toLowerCase()) {
      case 'iron':
      case 'm':
        return 7.8; // g/cm³
      case 'carbonaceous':
      case 'c':
        return 1.4; // g/cm³
      case 'stony':
      case 's':
      default:
        return 2.6; // g/cm³
    }
  }

  static String _mapComposition(String? spectralType) {
    if (spectralType == null) return 'Stony';
    
    final type = spectralType.toLowerCase();
    if (type.startsWith('c') || type.startsWith('b')) return 'Carbonaceous';
    if (type.startsWith('m') || type.startsWith('x')) return 'Iron';
    return 'Stony'; // S-type and others
  }

  @override
  String toString() {
    return 'Asteroid(name: $name, diameter: ${(diameter * 1000).toStringAsFixed(0)}m, '
           'velocity: ${closeApproachVelocity.toStringAsFixed(1)}km/s, '
           'energy: ${megatonTNT.toStringAsFixed(3)} MT)';
  }
}

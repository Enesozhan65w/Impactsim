import 'dart:convert';
import '../models/asteroid.dart';

class JPLSmallBodyService {
  static JPLSmallBodyService? _instance;
  static JPLSmallBodyService get instance => _instance ??= JPLSmallBodyService._();
  
  JPLSmallBodyService._();

  /// JPL Small-Body Database verilerini parse et
  List<Asteroid> parseJPLData(String jsonData) {
    try {
      // JSON array'i parse et
      final List<dynamic> data = json.decode('[$jsonData]');
      
      return data.map((item) => _parseJPLObject(item)).where((asteroid) => asteroid != null).cast<Asteroid>().toList();
    } catch (e) {
      print('JPL Data parsing error: $e');
      return [];
    }
  }

  Asteroid? _parseJPLObject(Map<String, dynamic> data) {
    try {
      final String name = data['object_name'] ?? data['object'] ?? 'Unknown';
      
      // Orbital elements
      final double eccentricity = double.tryParse(data['e']?.toString() ?? '0') ?? 0.0;
      final double inclination = double.tryParse(data['i_deg']?.toString() ?? '0') ?? 0.0;
      final double perihelionDist = double.tryParse(data['q_au_1']?.toString() ?? '1') ?? 1.0;
      final double aphelionDist = double.tryParse(data['q_au_2']?.toString() ?? '2') ?? 2.0;
      final double orbitalPeriod = double.tryParse(data['p_yr']?.toString() ?? '1') ?? 1.0;
      
      // Semi-major axis hesapla
      final double semiMajorAxis = (perihelionDist + aphelionDist) / 2;
      
      // Estimated diameter based on orbital characteristics
      double estimatedDiameter;
      if (name.contains('P/') || name.toLowerCase().contains('comet')) {
        // Comet için küçük çap
        estimatedDiameter = 2000 + (orbitalPeriod * 100); // 2-20 km range
      } else {
        // Asteroid için çap tahmini
        estimatedDiameter = 500 + (semiMajorAxis * 200); // 0.5-5 km range
      }
      
      // Velocity estimation (km/s -> m/s)
      final double velocity = (30 / sqrt(semiMajorAxis)) * 1000; // Orbital velocity
      
      // Density estimation
      double density;
      if (name.toLowerCase().contains('halley') || name.contains('P/')) {
        density = 500; // Comet density (ice/dust)
      } else if (eccentricity > 0.3) {
        density = 2000; // Rocky asteroid
      } else {
        density = 3000; // Metallic asteroid
      }
      
      // Composition
      String composition;
      if (name.contains('P/') || name.toLowerCase().contains('comet')) {
        composition = 'Ice/Dust (Comet)';
      } else if (density > 2500) {
        composition = 'Metallic';
      } else {
        composition = 'Stony';
      }
      
      print('🌟 Parsed JPL Object: $name');
      print('   📏 Diameter: ${estimatedDiameter.toStringAsFixed(0)}m');
      print('   🚀 Velocity: ${(velocity/1000).toStringAsFixed(1)} km/s');
      print('   ⭕ Orbital Period: ${orbitalPeriod.toStringAsFixed(1)} years');
      print('   📊 Eccentricity: ${eccentricity.toStringAsFixed(3)}');
      
      return Asteroid.fromLegacyData(
        id: 'jpl_${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
        name: name,
        diameter: estimatedDiameter,
        velocity: velocity,
        impactAngle: 45.0, // Default impact angle
        density: density,
        composition: composition,
        orbitalPeriod: orbitalPeriod * 365.25, // Convert years to days
        distanceFromSun: semiMajorAxis,
      );
    } catch (e) {
      print('Error parsing JPL object: $e');
      return null;
    }
  }

  /// Famous asteroids/comets list
  List<Asteroid> getFamousObjects() {
    const String famousObjectsJson = '''[
{"object":"1P/Halley","epoch_tdb":"49400","tp_tdb":"2446467.395","e":"0.9671429085","i_deg":"162.2626906","w_deg":"111.3324851","node_deg":"58.42008098","q_au_1":"0.5859781115","q_au_2":"35.08","p_yr":"75.32","moid_au":"0.063782","object_name":"1P/Halley"},
{"object":"2P/Encke","epoch_tdb":"56870","tp_tdb":"2456618.204","e":"0.8482682514","i_deg":"11.77999525","w_deg":"186.5403463","node_deg":"334.5698056","q_au_1":"0.3360923855","q_au_2":"4.09","p_yr":"3.3","moid_au":"0.173092","object_name":"2P/Encke"},
{"object":"55P/Tempel-Tuttle","epoch_tdb":"51040","tp_tdb":"2450872.598","e":"0.905552721","i_deg":"162.4865754","w_deg":"172.5002737","node_deg":"235.2709891","q_au_1":"0.9764279155","q_au_2":"19.7","p_yr":"33.24","moid_au":"0.008481","object_name":"55P/Tempel-Tuttle"},
{"object":"67P/Churyumov-Gerasimenko","epoch_tdb":"56981","tp_tdb":"2457247.572","e":"0.6409739314","i_deg":"7.040200902","w_deg":"12.78560607","node_deg":"50.14210951","q_au_1":"1.243241683","q_au_2":"5.68","p_yr":"6.44","moid_au":"0.257189","object_name":"67P/Churyumov-Gerasimenko"},
{"object":"96P/Machholz 1","epoch_tdb":"56541","tp_tdb":"2456123.323","e":"0.9592118287","i_deg":"58.31221424","w_deg":"14.7577484","node_deg":"94.32323631","q_au_1":"0.1237488531","q_au_2":"5.94","p_yr":"5.28","moid_au":"0.333731","object_name":"96P/Machholz 1"},
{"object":"109P/Swift-Tuttle","epoch_tdb":"50000","tp_tdb":"2448968.5","e":"0.963225755","i_deg":"113.453817","w_deg":"152.9821676","node_deg":"139.3811921","q_au_1":"0.9595161551","q_au_2":"51.22","p_yr":"133.28","moid_au":"0.000892","object_name":"109P/Swift-Tuttle"}
]''';
    
    return parseJPLData(famousObjectsJson);
  }

  /// Get potentially hazardous objects from JPL data
  List<Asteroid> getPotentiallyHazardousObjects() {
    const String hazardousJson = '''[
{"object":"P/2004 R1 (McNaught)","epoch_tdb":"54629","tp_tdb":"2455248.548","e":"0.682526943","i_deg":"4.894555854","w_deg":"0.626837835","node_deg":"295.9854497","q_au_1":"0.986192006","q_au_2":"5.23","p_yr":"5.48","moid_au":"0.027011","object_name":"P/2004 R1 (McNaught)"},
{"object":"21P/Giacobini-Zinner","epoch_tdb":"56498","tp_tdb":"2455969.126","e":"0.7068178874","i_deg":"31.90810099","w_deg":"172.5844249","node_deg":"195.3970145","q_au_1":"1.030696274","q_au_2":"6","p_yr":"6.59","moid_au":"0.035395","object_name":"21P/Giacobini-Zinner"},
{"object":"73P/Schwassmann-Wachmann 3","epoch_tdb":"50080","tp_tdb":"2449983.39","e":"0.6948269106","i_deg":"11.4234876","w_deg":"198.7699787","node_deg":"69.94634151","q_au_1":"0.9327707926","q_au_2":"5.18","p_yr":"5.34","moid_au":"0.045198","object_name":"73P/Schwassmann-Wachmann 3"},
{"object":"103P/Hartley 2","epoch_tdb":"56981","tp_tdb":"2457863.823","e":"0.693780472","i_deg":"13.60427243","w_deg":"181.3222858","node_deg":"219.7487451","q_au_1":"1.064195154","q_au_2":"5.89","p_yr":"6.48","moid_au":"0.072005","object_name":"103P/Hartley 2"}
]''';
    
    return parseJPLData(hazardousJson);
  }
}

// Helper function for sqrt
double sqrt(double x) {
  if (x < 0) return 0;
  double result = x;
  for (int i = 0; i < 10; i++) {
    result = (result + x / result) / 2;
  }
  return result;
}

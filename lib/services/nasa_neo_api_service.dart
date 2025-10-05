import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/asteroid.dart';
import 'jpl_small_body_service.dart';

class NASANeoApiService {
  static const String _baseUrl = 'https://api.nasa.gov/neo/rest/v1';
  static const String _apiKey = 'VkY68Mn1rfo1un21iATG5b7qQnNM4bCWzZQMBP16'; // NASA API anahtarınız
  
  static NASANeoApiService? _instance;
  static NASANeoApiService get instance => _instance ??= NASANeoApiService._();
  
  NASANeoApiService._();

  /// Yakın Dünya Objelerini (NEO) getir
  Future<List<Asteroid>> getNearEarthObjects({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = _formatDate(startDate);
      final endDateStr = _formatDate(endDate);
      
      final url = '$_baseUrl/feed?start_date=$startDateStr&end_date=$endDateStr&api_key=$_apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseNeoFeedData(data);
      } else {
        throw Exception('NASA API hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('NASA NEO API hatası: $e');
      // Fallback olarak örnek veri döndür
      return _getFallbackAsteroids();
    }
  }

  /// Belirli bir asteroitin detaylarını getir
  Future<Asteroid?> getAsteroidDetails(String asteroidId) async {
    try {
      final url = '$_baseUrl/neo/$asteroidId?api_key=$_apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseAsteroidDetails(data);
      } else {
        throw Exception('NASA API hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('NASA Asteroid Details API hatası: $e');
      return null;
    }
  }

  /// Potansiyel tehlikeli asteroitleri getir
  Future<List<Asteroid>> getPotentiallyHazardousAsteroids({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final url = '$_baseUrl/neo/browse?page=$page&size=$size&api_key=$_apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseBrowseData(data);
      } else {
        throw Exception('NASA API hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('NASA Browse API hatası: $e');
      return _getFallbackHazardousAsteroids();
    }
  }

  /// Bugünün asteroitlerini getir
  Future<List<Asteroid>> getTodaysAsteroids() async {
    final today = DateTime.now();
    return getNearEarthObjects(
      startDate: today,
      endDate: today,
    );
  }

  /// Impactor-2025 senaryosu için varsayımsal asteroit
  Asteroid getImpactor2025Scenario() {
    return Asteroid.fromLegacyData(
      id: 'impactor-2025',
      name: 'IMPACTOR-2025',
      diameter: 200, // meters - orta boy asteroit
      velocity: 25000, // m/s - yüksek hız
      impactAngle: 45.0,
      density: 3200, // kg/m³ - stony asteroit
      composition: 'Stony',
      orbitalPeriod: 550, // days
      distanceFromSun: 1.2, // AU
    );
  }

  // Yardımcı metodlar
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Asteroid> _parseNeoFeedData(Map<String, dynamic> data) {
    final List<Asteroid> asteroids = [];
    
    final nearEarthObjects = data['near_earth_objects'] as Map<String, dynamic>;
    
    for (final dateEntry in nearEarthObjects.entries) {
      final List<dynamic> neoList = dateEntry.value;
      
      for (final neo in neoList) {
        try {
          final asteroid = _parseNeoObject(neo);
          if (asteroid != null) {
            asteroids.add(asteroid);
          }
        } catch (e) {
          print('NEO parsing hatası: $e');
        }
      }
    }
    
    return asteroids;
  }

  Asteroid? _parseNeoObject(Map<String, dynamic> neo) {
    try {
      final id = neo['id'] as String;
      final name = neo['name'] as String;
      
      // Çap bilgisi
      final estimatedDiameter = neo['estimated_diameter']['meters'];
      final diameterMin = estimatedDiameter['estimated_diameter_min'] as double;
      final diameterMax = estimatedDiameter['estimated_diameter_max'] as double;
      final diameter = (diameterMin + diameterMax) / 2;
      
      // Yakın geçiş bilgileri
      final closeApproachData = neo['close_approach_data'] as List;
      if (closeApproachData.isEmpty) return null;
      
      final firstApproach = closeApproachData.first;
      final velocityKmS = double.parse(firstApproach['relative_velocity']['kilometers_per_second']);
      final velocity = velocityKmS * 1000; // m/s'ye çevir
      
      // Tehlikeli mi?
      final isPotentiallyHazardous = neo['is_potentially_hazardous_asteroid'] as bool;
      
      // Yörünge verileri (varsa)
      final orbitalData = neo['orbital_data'];
      double? orbitalPeriod;
      double? semiMajorAxis;
      
      if (orbitalData != null) {
        final orbitalPeriodStr = orbitalData['orbital_period'];
        if (orbitalPeriodStr != null) {
          orbitalPeriod = double.tryParse(orbitalPeriodStr);
        }
        
        final semiMajorAxisStr = orbitalData['semi_major_axis'];
        if (semiMajorAxisStr != null) {
          semiMajorAxis = double.tryParse(semiMajorAxisStr);
        }
      }
      
      return Asteroid.fromLegacyData(
        id: id,
        name: name.replaceAll('(', '').replaceAll(')', ''),
        diameter: diameter, // meters
        velocity: velocity, // m/s
        impactAngle: 45, // Varsayılan açı
        density: isPotentiallyHazardous ? 3200 : 2600, // kg/m³
        composition: isPotentiallyHazardous ? 'Iron' : 'Stony',
        orbitalPeriod: orbitalPeriod,
        distanceFromSun: semiMajorAxis,
      );
    } catch (e) {
      print('NEO object parsing hatası: $e');
      return null;
    }
  }

  Asteroid? _parseAsteroidDetails(Map<String, dynamic> data) {
    return _parseNeoObject(data);
  }

  List<Asteroid> _parseBrowseData(Map<String, dynamic> data) {
    final List<Asteroid> asteroids = [];
    final nearEarthObjects = data['near_earth_objects'] as List;
    
    for (final neo in nearEarthObjects) {
      try {
        final asteroid = _parseNeoObject(neo);
        if (asteroid != null) {
          asteroids.add(asteroid);
        }
      } catch (e) {
        print('Browse data parsing hatası: $e');
      }
    }
    
    return asteroids;
  }

  double _calculateMassFromDiameter(double diameter, [double density = 2600]) {
    final radius = diameter / 2;
    final volume = (4 / 3) * 3.14159 * radius * radius * radius;
    return volume * density;
  }

  // Fallback verileri (API erişimi olmadığında)
  List<Asteroid> _getFallbackAsteroids() {
    return [
      Asteroid.fromLegacyData(
        id: 'fallback-1',
        name: '2023 DW (Simüle)',
        diameter: 150, // meters
        velocity: 18500, // m/s
        impactAngle: 35,
        density: 2800, // kg/m³
        composition: 'Stony',
        orbitalPeriod: 400, // days
        distanceFromSun: 1.3, // AU
      ),
      Asteroid.fromLegacyData(
        id: 'fallback-2',
        name: '2024 PT5 (Simüle)',
        diameter: 120, // meters
        velocity: 22000, // m/s
        impactAngle: 50,
        density: 3100, // kg/m³
        composition: 'Iron',
        orbitalPeriod: 650, // days
        distanceFromSun: 1.8, // AU
      ),
    ];
  }

  List<Asteroid> _getFallbackHazardousAsteroids() {
    // JPL Small-Body Database'den gerçek veriler kullan
    final jplService = JPLSmallBodyService.instance;
    
    List<Asteroid> hazardousAsteroids = [
      getImpactor2025Scenario(),
    ];
    
    // JPL famous objects ekle (Halley, Encke, vb.)
    try {
      final famousObjects = jplService.getFamousObjects();
      hazardousAsteroids.addAll(famousObjects);
      print('🌟 ${famousObjects.length} JPL famous objects loaded');
    } catch (e) {
      print('JPL famous objects loading error: $e');
    }
    
    // JPL potentially hazardous objects ekle
    try {
      final hazardousJPL = jplService.getPotentiallyHazardousObjects();
      hazardousAsteroids.addAll(hazardousJPL);
      print('⚠️ ${hazardousJPL.length} JPL hazardous objects loaded');
    } catch (e) {
      print('JPL hazardous objects loading error: $e');
    }
    
    // Predefined asteroids ekle (backup)
    try {
      hazardousAsteroids.addAll(Asteroid.getPredefinedAsteroids());
    } catch (e) {
      print('Predefined asteroids loading error: $e');
    }
    
    return hazardousAsteroids;
  }

  /// JPL Small-Body Database'den famous objects getir
  List<Asteroid> getFamousAsteroids() {
    final jplService = JPLSmallBodyService.instance;
    return jplService.getFamousObjects();
  }
  
  /// JPL'den potentially hazardous objects getir  
  List<Asteroid> getJPLHazardousObjects() {
    final jplService = JPLSmallBodyService.instance;
    return jplService.getPotentiallyHazardousObjects();
  }

  /// API durumunu kontrol et
  Future<bool> checkApiStatus() async {
    try {
      final url = '$_baseUrl/stats?api_key=$_apiKey';
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// API kullanım istatistikleri
  Future<Map<String, dynamic>?> getApiStats() async {
    try {
      final url = '$_baseUrl/stats?api_key=$_apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('API stats hatası: $e');
    }
    return null;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usgs_product.dart';
import '../models/usgs_dataset.dart';

/// USGS The National Map Access API Servisi
/// 
/// Bu servis gerçek topografik verileri alarak asteroid impact simülasyonlarında
/// daha doğru krater ve tsunami hesaplamaları yapmamızı sağlar.
class USGSTNMService {
  static const String baseUrl = 'https://tnmaccess.nationalmap.gov/api/v1';
  
  static USGSTNMService? _instance;
  static USGSTNMService get instance {
    _instance ??= USGSTNMService();
    return _instance!;
  }

  /// Belirli bir bölge için USGS ürünlerini getir
  /// 
  /// [bbox] - Bounding box (minX,minY,maxX,maxY)
  /// [datasets] - İstenen veri setleri (ör. "Elevation", "National Elevation Dataset")
  /// [format] - Dosya formatı (ör. "GeoTIFF", "IMG")
  Future<List<USGSProduct>> getProductsByBoundingBox({
    required double minX,
    required double minY,
    required double maxX,
    required double maxY,
    List<String>? datasets,
    String? format,
    int? max,
  }) async {
    try {
      final queryParams = <String, String>{
        'bbox': '$minX,$minY,$maxX,$maxY',
        'outputFormat': 'JSON',
      };
      
      if (datasets != null && datasets.isNotEmpty) {
        queryParams['datasets'] = datasets.join(',');
      }
      
      if (format != null && format.isNotEmpty) {
        queryParams['format'] = format;
      }
      
      if (max != null) {
        queryParams['max'] = max.toString();
      }
      
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
      
      print('🗺️ USGS TNM API Çağrısı: $uri');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('USGS API zaman aşımı'),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['items'] != null) {
          final List<dynamic> items = jsonData['items'];
          final products = items.map((item) => USGSProduct.fromJson(item)).toList();
          
          print('🗺️ USGS: ${products.length} ürün bulundu');
          return products;
        } else {
          print('⚠️ USGS: Veri bulunamadı');
          return [];
        }
      } else {
        throw Exception('USGS API hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ USGS API Hatası: $e');
      return [];
    }
  }

  /// Asteroid çarpma noktası çevresindeki elevation verilerini al
  /// 
  /// [latitude] - Enlem
  /// [longitude] - Boylam  
  /// [radiusKm] - Arama yarıçapı (km)
  Future<List<USGSProduct>> getElevationDataForImpactPoint({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    // Yarıçapı derece cinsine çevir (yaklaşık)
    final radiusDegrees = radiusKm / 111.0; // 1 derece ≈ 111 km
    
    final products = await getProductsByBoundingBox(
      minX: longitude - radiusDegrees,
      minY: latitude - radiusDegrees,
      maxX: longitude + radiusDegrees,
      maxY: latitude + radiusDegrees,
      datasets: ['National Elevation Dataset', 'Digital Elevation Model'],
      format: 'GeoTIFF',
      max: 20,
    );
    
    // Elevation verisi olanları filtrele ve sırala
    final elevationProducts = USGSProductFilter.filterElevationData(products);
    final sortedProducts = USGSProductFilter.sortByBestFit(elevationProducts);
    
    print('🗺️ Elevation Data: ${sortedProducts.length} ürün bulundu (${radiusKm}km yarıçap)');
    
    return sortedProducts;
  }

  /// Topografik harita verilerini al
  /// 
  /// [latitude] - Enlem
  /// [longitude] - Boylam
  /// [radiusKm] - Arama yarıçapı (km)
  Future<List<USGSProduct>> getTopographicMaps({
    required double latitude,
    required double longitude,
    double radiusKm = 25.0,
  }) async {
    final radiusDegrees = radiusKm / 111.0;
    
    final products = await getProductsByBoundingBox(
      minX: longitude - radiusDegrees,
      minY: latitude - radiusDegrees,
      maxX: longitude + radiusDegrees,
      maxY: latitude + radiusDegrees,
      datasets: ['US Topo', 'Historical Topographic Maps'],
      max: 10,
    );
    
    final topoMaps = products.where((p) => p.hasTopographicMap).toList();
    
    print('🗺️ Topographic Maps: ${topoMaps.length} harita bulundu');
    
    return topoMaps;
  }

  /// Bir koordinat için en yakın elevation değerini al
  /// 
  /// Not: Bu basitleştirilmiş bir implementation'dır.
  /// Gerçek uygulamada elevation TIFF dosyasını indirip parse etmek gerekir.
  Future<double?> getElevationAtPoint({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Çok küçük bir area için elevation data al
      final products = await getElevationDataForImpactPoint(
        latitude: latitude,
        longitude: longitude,
        radiusKm: 1.0, // 1 km yarıçap
      );
      
      if (products.isEmpty) {
        print('⚠️ Bu nokta için elevation verisi bulunamadı');
        return null;
      }
      
      // En uygun ürünü seç
      final bestProduct = products.first;
      
      print('🗺️ Elevation Product: ${bestProduct.title}');
      print('🗺️ Download URL: ${bestProduct.bestDownloadUrl}');
      
      // Gerçek implementasyonda burada TIFF dosyasını indirip
      // belirtilen koordinattaki elevation değerini extract etmemiz gerekir
      // Şimdilik mock veri dönelim
      return _getMockElevation(latitude, longitude);
      
    } catch (e) {
      print('❌ Elevation alma hatası: $e');
      return null;
    }
  }
  
  /// Mock elevation data (gerçek implementation için placeholder)
  double _getMockElevation(double lat, double lng) {
    // Coğrafi konuma göre yaklaşık elevation değerleri
    // (Bu gerçek bir hesaplama değil, sadece örnek)
    
    // Deniz seviyesine yakın alanlar
    if (lat > 40 && lat < 42 && lng > 28 && lng < 30) {
      return 50.0; // İstanbul civarı
    }
    
    // Dağlık bölgeler
    if (lat > 36 && lat < 38 && lng > 32 && lng < 35) {
      return 1200.0; // Anadolu dağları
    }
    
    // Deniz alanları
    if (lng < -120 || lng > 150) {
      return 0.0; // Okyanuslar
    }
    
    // Varsayılan kara elevation
    return 200.0;
  }

  /// Mevcut veri setlerini listele
  Future<List<String>> getAvailableDatasets() async {
    try {
      final uri = Uri.parse('$baseUrl/datasets');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          return jsonData.cast<String>();
        }
      }
      
      // Fallback - bilinen veri setleri
      return [
        'National Elevation Dataset',
        'Digital Elevation Model',
        'US Topo',
        'Historical Topographic Maps',
        'National Hydrography Dataset',
        'USGS Imagery Only',
      ];
      
    } catch (e) {
      print('❌ Dataset listesi alınamadı: $e');
      return [];
    }
  }

  /// USGS Dataset listesini al
  /// 
  /// Bu method mevcut tüm USGS dataset'lerini listeler
  Future<List<USGSDataset>> getDatasets() async {
    try {
      final uri = Uri.parse('$baseUrl/datasets');
      
      print('🗺️ USGS Datasets API Çağrısı: $uri');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('USGS Datasets API zaman aşımı'),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData is List) {
          final datasets = jsonData.map((item) => USGSDataset.fromJson(item)).toList();
          
          print('🗺️ USGS Datasets: ${datasets.length} dataset bulundu');
          return datasets;
        } else {
          print('⚠️ USGS Datasets: Beklenmedik format');
          return [];
        }
      } else {
        throw Exception('USGS Datasets API hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ USGS Datasets API Hatası: $e');
      return [];
    }
  }

  /// Impact analizi için önerilen dataset'leri al
  /// 
  /// Bu method asteroid impact analizi için en uygun dataset'leri seçer
  Future<List<USGSDatasetRecommendation>> getImpactAnalysisDatasets() async {
    try {
      final allDatasets = await getDatasets();
      
      if (allDatasets.isEmpty) {
        print('⚠️ Dataset listesi alınamadı');
        return [];
      }
      
      // Impact analizi için uygun dataset'leri filtrele
      final impactDatasets = USGSDatasetFilter.getImpactAnalysisDatasets(allDatasets);
      
      // Recommendation'ları oluştur
      final recommendations = USGSDatasetRecommendation.generateImpactRecommendations(impactDatasets);
      
      print('🗺️ Impact Analysis: ${recommendations.length} dataset önerisi oluşturuldu');
      
      return recommendations;
    } catch (e) {
      print('❌ Impact Analysis Datasets hatası: $e');
      return [];
    }
  }

  /// Impact analizi için önerilen ürünleri al
  /// 
  /// Bu method asteroid impact analizi için en uygun USGS verilerini seçer
  Future<USGSImpactData> getImpactAnalysisData({
    required double latitude,
    required double longitude,
    double radiusKm = 100.0,
  }) async {
    print('🗺️ Impact Analysis Data: Lat=$latitude, Lng=$longitude, Radius=${radiusKm}km');
    
    // Paralel olarak farklı veri tiplerini al
    final futures = await Future.wait([
      getElevationDataForImpactPoint(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      ),
      getTopographicMaps(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm / 2,
      ),
      getElevationAtPoint(latitude: latitude, longitude: longitude),
      getImpactAnalysisDatasets(),
    ]);
    
    final elevationProducts = futures[0] as List<USGSProduct>;
    final topographicMaps = futures[1] as List<USGSProduct>;
    final pointElevation = futures[2] as double?;
    final datasetRecommendations = futures[3] as List<USGSDatasetRecommendation>;
    
    return USGSImpactData(
      centerLatitude: latitude,
      centerLongitude: longitude,
      radiusKm: radiusKm,
      elevationProducts: elevationProducts,
      topographicMaps: topographicMaps,
      centerElevation: pointElevation,
      timestamp: DateTime.now(),
      datasetRecommendations: datasetRecommendations,
    );
  }
}

/// Impact analizi için USGS verilerini tutan sınıf
class USGSImpactData {
  final double centerLatitude;
  final double centerLongitude;
  final double radiusKm;
  final List<USGSProduct> elevationProducts;
  final List<USGSProduct> topographicMaps;
  final double? centerElevation;
  final DateTime timestamp;
  final List<USGSDatasetRecommendation> datasetRecommendations;

  const USGSImpactData({
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusKm,
    required this.elevationProducts,
    required this.topographicMaps,
    required this.centerElevation,
    required this.timestamp,
    this.datasetRecommendations = const [],
  });

  /// Veri kalitesi değerlendirmesi
  USGSDataQuality get dataQuality {
    int score = 0;
    List<String> issues = [];
    
    // Elevation data kontrolü
    if (elevationProducts.isNotEmpty) {
      score += 40;
    } else {
      issues.add('No elevation data available');
    }
    
    // Center elevation kontrolü  
    if (centerElevation != null) {
      score += 30;
    } else {
      issues.add('No center point elevation');
    }
    
    // Topographic maps kontrolü
    if (topographicMaps.isNotEmpty) {
      score += 20;
    } else {
      issues.add('No topographic maps available');
    }
    
    // Veri güncellik kontrolü
    final hasRecentData = elevationProducts.any((p) {
      try {
        final lastUpdate = DateTime.parse(p.lastUpdated);
        return DateTime.now().difference(lastUpdate).inDays < 365;
      } catch (e) {
        return false;
      }
    });
    
    if (hasRecentData) {
      score += 10;
    } else {
      issues.add('Data may be outdated');
    }
    
    return USGSDataQuality(
      score: score,
      level: _getQualityLevel(score),
      issues: issues,
    );
  }
  
  String _getQualityLevel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    if (score >= 30) return 'Poor';
    return 'Insufficient';
  }
  
  /// En iyi elevation ürününü al
  USGSProduct? get bestElevationProduct {
    if (elevationProducts.isEmpty) return null;
    
    // Dosya boyutu ve best fit index'e göre sırala
    final sorted = USGSProductFilter.sortByBestFit(elevationProducts);
    return sorted.first;
  }
  
  /// İndirilebilir harita URL'lerini al
  List<String> get downloadableMapUrls {
    final urls = <String>[];
    
    for (final product in [...elevationProducts, ...topographicMaps]) {
      final url = product.bestDownloadUrl;
      if (url.isNotEmpty) {
        urls.add(url);
      }
    }
    
    return urls;
  }
}

/// USGS veri kalitesi değerlendirmesi
class USGSDataQuality {
  final int score;
  final String level;
  final List<String> issues;

  const USGSDataQuality({
    required this.score,
    required this.level,
    required this.issues,
  });
  
  bool get isGoodQuality => score >= 70;
  bool get isUsable => score >= 30;
}

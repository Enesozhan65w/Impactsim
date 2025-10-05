/// USGS TNM Access API - Map Services modeli
/// 
/// Bu sınıf USGS'nin WMS/WFS harita servislerini temsil eder
/// Asteroid impact görselleştirmesi için interaktif haritalar sağlar
class USGSMapService {
  final String serviceType;
  final String displayName;
  final String serviceLink;
  final bool tiled;
  final String wmsUrl;
  final String wfsUrl;
  final String spatialRef;
  final int minScale;
  final int maxScale;
  final String serviceListCategory;
  final int rank;
  final String refreshCycle;
  final String publicationDate;
  final String thumbnailUrl;
  final bool isDeprecated;
  final String deprecationNotice;

  const USGSMapService({
    required this.serviceType,
    required this.displayName,
    required this.serviceLink,
    required this.tiled,
    required this.wmsUrl,
    required this.wfsUrl,
    required this.spatialRef,
    required this.minScale,
    required this.maxScale,
    required this.serviceListCategory,
    required this.rank,
    required this.refreshCycle,
    required this.publicationDate,
    required this.thumbnailUrl,
    required this.isDeprecated,
    required this.deprecationNotice,
  });

  factory USGSMapService.fromJson(Map<String, dynamic> json) {
    return USGSMapService(
      serviceType: json['serviceType'] ?? '',
      displayName: json['displayName'] ?? '',
      serviceLink: json['serviceLink'] ?? '',
      tiled: json['tiled'] ?? false,
      wmsUrl: json['wmsUrl'] ?? '',
      wfsUrl: json['wfsUrl'] ?? '',
      spatialRef: json['spatialRef'] ?? '',
      minScale: json['minScale'] ?? 0,
      maxScale: json['maxScale'] ?? 0,
      serviceListCategory: json['serviceListCategory'] ?? '',
      rank: json['rank'] ?? 0,
      refreshCycle: json['refreshCycle'] ?? '',
      publicationDate: json['publicationDate'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      isDeprecated: json['isDeprecated'] ?? false,
      deprecationNotice: json['deprecationNotice'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'displayName': displayName,
      'serviceLink': serviceLink,
      'tiled': tiled,
      'wmsUrl': wmsUrl,
      'wfsUrl': wfsUrl,
      'spatialRef': spatialRef,
      'minScale': minScale,
      'maxScale': maxScale,
      'serviceListCategory': serviceListCategory,
      'rank': rank,
      'refreshCycle': refreshCycle,
      'publicationDate': publicationDate,
      'thumbnailUrl': thumbnailUrl,
      'isDeprecated': isDeprecated,
      'deprecationNotice': deprecationNotice,
    };
  }

  // Asteroid impact görselleştirmesi için faydalı özellikler

  /// Bu servis aktif ve kullanılabilir mi?
  bool get isActive => !isDeprecated && wmsUrl.isNotEmpty;

  /// Bu servis elevation verisi sağlıyor mu?
  bool get providesElevationData {
    final displayLower = displayName.toLowerCase();
    final categoryLower = serviceListCategory.toLowerCase();
    return displayLower.contains('elevation') ||
           displayLower.contains('dem') ||
           displayLower.contains('digital elevation') ||
           categoryLower.contains('elevation');
  }

  /// Bu servis topografik harita sağlıyor mu?
  bool get providesTopographicMaps {
    final displayLower = displayName.toLowerCase();
    final categoryLower = serviceListCategory.toLowerCase();
    return displayLower.contains('topo') ||
           displayLower.contains('topographic') ||
           categoryLower.contains('topo');
  }

  /// Bu servis hidrografik veriler sağlıyor mu?
  bool get providesHydrographicData {
    final displayLower = displayName.toLowerCase();
    final categoryLower = serviceListCategory.toLowerCase();
    return displayLower.contains('hydro') ||
           displayLower.contains('water') ||
           displayLower.contains('stream') ||
           displayLower.contains('watershed') ||
           categoryLower.contains('hydro') ||
           categoryLower.contains('water');
  }

  /// Bu servis uydu görüntüleri sağlıyor mu?
  bool get providesImagery {
    final displayLower = displayName.toLowerCase();
    final categoryLower = serviceListCategory.toLowerCase();
    return displayLower.contains('imagery') ||
           displayLower.contains('satellite') ||
           displayLower.contains('aerial') ||
           categoryLower.contains('imagery');
  }

  /// WMS servis türü mü?
  bool get isWMSService => serviceType.toLowerCase().contains('wms') && wmsUrl.isNotEmpty;

  /// WFS servis türü mü?
  bool get isWFSService => serviceType.toLowerCase().contains('wfs') && wfsUrl.isNotEmpty;

  /// Tiled servis mi?
  bool get isTiledService => tiled;

  /// Servisin öncelik seviyesi (düşük rank = yüksek öncelik)
  MapServicePriority get priority {
    if (rank <= 10) return MapServicePriority.high;
    if (rank <= 50) return MapServicePriority.medium;
    return MapServicePriority.low;
  }

  /// Asteroid impact analizi için uygunluk skoru (0-100)
  int get impactAnalysisScore {
    if (isDeprecated) return 0;
    
    int score = 0;
    
    // Aktif servis (0-20 puan)
    if (isActive) score += 20;
    
    // Elevation data (0-30 puan) - En önemli
    if (providesElevationData) score += 30;
    
    // Topographic maps (0-20 puan)
    if (providesTopographicMaps) score += 20;
    
    // Hydrographic data (0-15 puan) - Tsunami için
    if (providesHydrographicData) score += 15;
    
    // Service type quality (0-10 puan)
    if (isWMSService) score += 10;
    else if (isWFSService) score += 5;
    
    // Rank bonus (0-5 puan)
    if (priority == MapServicePriority.high) score += 5;
    else if (priority == MapServicePriority.medium) score += 2;
    
    return score;
  }

  /// WMS GetMap URL'ini oluştur
  String buildWMSGetMapUrl({
    required double minX,
    required double minY,
    required double maxX,
    required double maxY,
    int width = 512,
    int height = 512,
    String format = 'image/png',
    String srs = 'EPSG:4326',
    String? layers,
  }) {
    if (!isWMSService) return '';
    
    final queryParams = <String, String>{
      'SERVICE': 'WMS',
      'VERSION': '1.1.1',
      'REQUEST': 'GetMap',
      'BBOX': '$minX,$minY,$maxX,$maxY',
      'WIDTH': width.toString(),
      'HEIGHT': height.toString(),
      'FORMAT': format,
      'SRS': srs,
      'LAYERS': layers ?? _getDefaultLayerName(),
    };
    
    final uri = Uri.parse(wmsUrl).replace(queryParameters: queryParams);
    return uri.toString();
  }

  /// WFS GetFeature URL'ini oluştur
  String buildWFSGetFeatureUrl({
    required double minX,
    required double minY,
    required double maxX,
    required double maxY,
    String outputFormat = 'application/json',
    String? typeName,
    int maxFeatures = 1000,
  }) {
    if (!isWFSService) return '';
    
    final queryParams = <String, String>{
      'SERVICE': 'WFS',
      'VERSION': '2.0.0',
      'REQUEST': 'GetFeature',
      'BBOX': '$minX,$minY,$maxX,$maxY',
      'OUTPUTFORMAT': outputFormat,
      'TYPENAME': typeName ?? _getDefaultLayerName(),
      'MAXFEATURES': maxFeatures.toString(),
    };
    
    final uri = Uri.parse(wfsUrl).replace(queryParameters: queryParams);
    return uri.toString();
  }

  /// Default layer name'i tahmin et
  String _getDefaultLayerName() {
    // Display name'den layer name'i türet
    return displayName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w_]'), '');
  }
}

/// Map service öncelik seviyesi
enum MapServicePriority {
  high,
  medium,
  low,
}

/// Map service filtreleme ve arama yardımcıları
class USGSMapServiceFilter {
  /// Aktif servisleri filtrele
  static List<USGSMapService> filterActiveServices(List<USGSMapService> services) {
    return services.where((s) => s.isActive).toList();
  }

  /// Elevation verisi sağlayan servisleri filtrele
  static List<USGSMapService> filterElevationServices(List<USGSMapService> services) {
    return services.where((s) => s.providesElevationData && s.isActive).toList();
  }

  /// Topografik harita servislerini filtrele
  static List<USGSMapService> filterTopographicServices(List<USGSMapService> services) {
    return services.where((s) => s.providesTopographicMaps && s.isActive).toList();
  }

  /// Hidrografik servislerini filtrele
  static List<USGSMapService> filterHydrographicServices(List<USGSMapService> services) {
    return services.where((s) => s.providesHydrographicData && s.isActive).toList();
  }

  /// WMS servislerini filtrele
  static List<USGSMapService> filterWMSServices(List<USGSMapService> services) {
    return services.where((s) => s.isWMSService && s.isActive).toList();
  }

  /// WFS servislerini filtrele
  static List<USGSMapService> filterWFSServices(List<USGSMapService> services) {
    return services.where((s) => s.isWFSService && s.isActive).toList();
  }

  /// Servis kategorisine göre filtrele
  static List<USGSMapService> filterByCategory(List<USGSMapService> services, String category) {
    return services.where((s) => 
      s.serviceListCategory.toLowerCase().contains(category.toLowerCase()) && s.isActive
    ).toList();
  }

  /// Impact analizi skoruna göre sırala
  static List<USGSMapService> sortByImpactScore(List<USGSMapService> services) {
    final sortedServices = List<USGSMapService>.from(services);
    sortedServices.sort((a, b) => b.impactAnalysisScore.compareTo(a.impactAnalysisScore));
    return sortedServices;
  }

  /// Rank'e göre sırala
  static List<USGSMapService> sortByRank(List<USGSMapService> services) {
    final sortedServices = List<USGSMapService>.from(services);
    sortedServices.sort((a, b) => a.rank.compareTo(b.rank));
    return sortedServices;
  }

  /// Asteroid impact analizi için en uygun servisleri al
  static List<USGSMapService> getImpactAnalysisServices(List<USGSMapService> services) {
    final activeServices = filterActiveServices(services);
    final scoredServices = sortByImpactScore(activeServices);
    
    // Score 50 ve üzeri olanları seç
    final relevantServices = scoredServices.where((s) => s.impactAnalysisScore >= 50).toList();
    
    // En fazla 10 servis al
    return relevantServices.take(10).toList();
  }
}

/// Impact harita görselleştirmesi için özel map service kombinasyonları
class ImpactMapServiceCombination {
  final USGSMapService? elevationService;
  final USGSMapService? topographicService;
  final USGSMapService? hydrographicService;
  final USGSMapService? imageryService;

  const ImpactMapServiceCombination({
    this.elevationService,
    this.topographicService,
    this.hydrographicService,
    this.imageryService,
  });

  /// Bu kombinasyon kullanılabilir mi?
  bool get isUsable => 
    elevationService != null || 
    topographicService != null || 
    hydrographicService != null;

  /// Kalite skoru (0-100)
  int get qualityScore {
    int score = 0;
    
    if (elevationService != null) score += 40; // En önemli
    if (topographicService != null) score += 25;
    if (hydrographicService != null) score += 20; // Tsunami için
    if (imageryService != null) score += 15;
    
    return score;
  }

  /// Optimal WMS layer stack'i oluştur
  List<String> buildLayerStack() {
    final layers = <String>[];
    
    // En altta imagery (varsa)
    if (imageryService?.isWMSService == true) {
      layers.add(imageryService!.wmsUrl);
    }
    
    // Topographic base
    if (topographicService?.isWMSService == true) {
      layers.add(topographicService!.wmsUrl);
    }
    
    // Elevation overlay
    if (elevationService?.isWMSService == true) {
      layers.add(elevationService!.wmsUrl);
    }
    
    // Hydrographic overlay (en üstte)
    if (hydrographicService?.isWMSService == true) {
      layers.add(hydrographicService!.wmsUrl);
    }
    
    return layers;
  }

  /// Impact analizi için optimal servis kombinasyonu oluştur
  static ImpactMapServiceCombination buildOptimal(List<USGSMapService> services) {
    final activeServices = USGSMapServiceFilter.filterActiveServices(services);
    
    // Her kategori için en iyi servisi seç
    final elevationServices = USGSMapServiceFilter.filterElevationServices(activeServices);
    final topographicServices = USGSMapServiceFilter.filterTopographicServices(activeServices);
    final hydrographicServices = USGSMapServiceFilter.filterHydrographicServices(activeServices);
    final imageryServices = activeServices.where((s) => s.providesImagery).toList();
    
    return ImpactMapServiceCombination(
      elevationService: elevationServices.isNotEmpty 
          ? USGSMapServiceFilter.sortByRank(elevationServices).first
          : null,
      topographicService: topographicServices.isNotEmpty
          ? USGSMapServiceFilter.sortByRank(topographicServices).first
          : null,
      hydrographicService: hydrographicServices.isNotEmpty
          ? USGSMapServiceFilter.sortByRank(hydrographicServices).first
          : null,
      imageryService: imageryServices.isNotEmpty
          ? USGSMapServiceFilter.sortByRank(imageryServices).first
          : null,
    );
  }
}

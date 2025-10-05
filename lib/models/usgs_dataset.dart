/// USGS TNM Access API - Dataset modeli
/// 
/// Bu sınıf USGS'nin mevcut veri kümelerini (datasets) temsil eder
class USGSDataset {
  final String title;
  final String sbDatasetTag;
  final String parentCategory;
  final String id;
  final String description;
  final String refreshCycle;
  final String lastPublishedDate;
  final String lastUpdatedDate;
  final String dataGovUrl;
  final String infoUrl;
  final String thumbnailUrl;
  final List<int> mapServerLayerIdsForLegend;
  final String mapServerUrl;
  final List<String> mapServerLayerNames;
  final bool showMapServerLink;
  final String mapServerLinkShowTitle;
  final String mapServerLinkHideTitle;
  final List<USGSDatasetFormat> formats;
  final String defaultExtent;
  final List<String> extents;
  final List<String> tags;

  const USGSDataset({
    required this.title,
    required this.sbDatasetTag,
    required this.parentCategory,
    required this.id,
    required this.description,
    required this.refreshCycle,
    required this.lastPublishedDate,
    required this.lastUpdatedDate,
    required this.dataGovUrl,
    required this.infoUrl,
    required this.thumbnailUrl,
    required this.mapServerLayerIdsForLegend,
    required this.mapServerUrl,
    required this.mapServerLayerNames,
    required this.showMapServerLink,
    required this.mapServerLinkShowTitle,
    required this.mapServerLinkHideTitle,
    required this.formats,
    required this.defaultExtent,
    required this.extents,
    required this.tags,
  });

  factory USGSDataset.fromJson(Map<String, dynamic> json) {
    return USGSDataset(
      title: json['title'] ?? '',
      sbDatasetTag: json['sbDatasetTag'] ?? '',
      parentCategory: json['parentCategory'] ?? '',
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      refreshCycle: json['refreshCycle'] ?? '',
      lastPublishedDate: json['lastPublishedDate'] ?? '',
      lastUpdatedDate: json['lastUpdatedDate'] ?? '',
      dataGovUrl: json['dataGovUrl'] ?? '',
      infoUrl: json['infoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      mapServerLayerIdsForLegend: List<int>.from(json['mapServerLayerIdsForLegend'] ?? []),
      mapServerUrl: json['mapServerUrl'] ?? '',
      mapServerLayerNames: List<String>.from(json['mapServerLayerNames'] ?? []),
      showMapServerLink: json['showMapServerLink'] ?? false,
      mapServerLinkShowTitle: json['mapServerLinkShowTitle'] ?? '',
      mapServerLinkHideTitle: json['mapServerLinkHideTitle'] ?? '',
      formats: (json['formats'] as List? ?? [])
          .map((format) => USGSDatasetFormat.fromJson(format))
          .toList(),
      defaultExtent: json['defaultExtent'] ?? '',
      extents: List<String>.from(json['extents'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'sbDatasetTag': sbDatasetTag,
      'parentCategory': parentCategory,
      'id': id,
      'description': description,
      'refreshCycle': refreshCycle,
      'lastPublishedDate': lastPublishedDate,
      'lastUpdatedDate': lastUpdatedDate,
      'dataGovUrl': dataGovUrl,
      'infoUrl': infoUrl,
      'thumbnailUrl': thumbnailUrl,
      'mapServerLayerIdsForLegend': mapServerLayerIdsForLegend,
      'mapServerUrl': mapServerUrl,
      'mapServerLayerNames': mapServerLayerNames,
      'showMapServerLink': showMapServerLink,
      'mapServerLinkShowTitle': mapServerLinkShowTitle,
      'mapServerLinkHideTitle': mapServerLinkHideTitle,
      'formats': formats.map((f) => f.toJson()).toList(),
      'defaultExtent': defaultExtent,
      'extents': extents,
      'tags': tags,
    };
  }

  // Asteroid impact analizi için faydalı özellikler

  /// Bu dataset elevation verisi içeriyor mu?
  bool get isElevationDataset {
    final title_lower = title.toLowerCase();
    final desc_lower = description.toLowerCase();
    return title_lower.contains('elevation') ||
           title_lower.contains('dem') ||
           title_lower.contains('digital elevation') ||
           desc_lower.contains('elevation') ||
           tags.any((tag) => tag.toLowerCase().contains('elevation'));
  }

  /// Bu dataset topografik harita verisi içeriyor mu?
  bool get isTopographicDataset {
    final title_lower = title.toLowerCase();
    final desc_lower = description.toLowerCase();
    return title_lower.contains('topo') ||
           title_lower.contains('topographic') ||
           desc_lower.contains('topographic') ||
           tags.any((tag) => tag.toLowerCase().contains('topo'));
  }

  /// Bu dataset su/deniz verisi içeriyor mu?
  bool get isHydrographicDataset {
    final title_lower = title.toLowerCase();
    final desc_lower = description.toLowerCase();
    return title_lower.contains('hydro') ||
           title_lower.contains('water') ||
           title_lower.contains('bathymetry') ||
           desc_lower.contains('water') ||
           tags.any((tag) => 
             tag.toLowerCase().contains('hydro') || 
             tag.toLowerCase().contains('water'));
  }

  /// Bu dataset güncel mi? (Son 2 yıl içinde güncellenmiş)
  bool get isRecentlyUpdated {
    try {
      final lastUpdate = DateTime.parse(lastUpdatedDate);
      final twoYearsAgo = DateTime.now().subtract(const Duration(days: 365 * 2));
      return lastUpdate.isAfter(twoYearsAgo);
    } catch (e) {
      return false;
    }
  }

  /// Dataset'in coğrafi kapsamı
  String get geographicScope {
    if (tags.contains('National')) return 'National';
    if (tags.contains('State')) return 'State';
    if (tags.contains('Regional')) return 'Regional';
    if (tags.contains('Local')) return 'Local';
    return 'Unknown';
  }

  /// En iyi formatı al (GeoTIFF, IMG, vs.)
  USGSDatasetFormat? get bestFormat {
    if (formats.isEmpty) return null;
    
    // GeoTIFF öncelikli
    final geoTiff = formats.where((f) => 
      f.value.toLowerCase().contains('geotiff') || 
      f.displayName.toLowerCase().contains('geotiff')).firstOrNull;
    if (geoTiff != null) return geoTiff;
    
    // IMG formatı
    final img = formats.where((f) => 
      f.value.toLowerCase().contains('img')).firstOrNull;
    if (img != null) return img;
    
    // Default formatı
    final defaultFormat = formats.where((f) => f.isDefault).firstOrNull;
    if (defaultFormat != null) return defaultFormat;
    
    // İlk format
    return formats.first;
  }

  /// Dataset'in kalite skoru (0-100)
  int get qualityScore {
    int score = 0;
    
    // Güncellik (0-30 puan)
    if (isRecentlyUpdated) score += 30;
    else if (lastUpdatedDate.isNotEmpty) score += 15;
    
    // Kapsamlı açıklama (0-20 puan)
    if (description.length > 100) score += 20;
    else if (description.length > 50) score += 10;
    
    // Map server varlığı (0-15 puan)
    if (mapServerUrl.isNotEmpty) score += 15;
    
    // Format çeşitliliği (0-15 puan)
    if (formats.length >= 3) score += 15;
    else if (formats.length >= 2) score += 10;
    else if (formats.isNotEmpty) score += 5;
    
    // Metadata URL'leri (0-10 puan)
    if (infoUrl.isNotEmpty) score += 5;
    if (dataGovUrl.isNotEmpty) score += 5;
    
    // Tag çeşitliliği (0-10 puan)
    if (tags.length >= 5) score += 10;
    else if (tags.length >= 3) score += 5;
    
    return score;
  }
}

/// Dataset formatı bilgisi
class USGSDatasetFormat {
  final String displayName;
  final String value;
  final bool isDefault;

  const USGSDatasetFormat({
    required this.displayName,
    required this.value,
    required this.isDefault,
  });

  factory USGSDatasetFormat.fromJson(Map<String, dynamic> json) {
    return USGSDatasetFormat(
      displayName: json['displayName'] ?? '',
      value: json['value'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'value': value,
      'isDefault': isDefault,
    };
  }

  /// Format raster (görüntü) verisi mi?
  bool get isRasterFormat {
    final formatLower = value.toLowerCase();
    return formatLower.contains('tiff') ||
           formatLower.contains('img') ||
           formatLower.contains('jp2') ||
           formatLower.contains('png') ||
           formatLower.contains('geotiff');
  }

  /// Format vector verisi mi?
  bool get isVectorFormat {
    final formatLower = value.toLowerCase();
    return formatLower.contains('shapefile') ||
           formatLower.contains('gdb') ||
           formatLower.contains('kml') ||
           formatLower.contains('gpkg');
  }
}

/// Dataset filtreleme ve arama yardımcıları
class USGSDatasetFilter {
  /// Elevation verisi olan dataset'leri filtrele
  static List<USGSDataset> filterElevationDatasets(List<USGSDataset> datasets) {
    return datasets.where((d) => d.isElevationDataset).toList();
  }

  /// Topografik harita dataset'leri filtrele
  static List<USGSDataset> filterTopographicDatasets(List<USGSDataset> datasets) {
    return datasets.where((d) => d.isTopographicDataset).toList();
  }

  /// Hidrografik veri dataset'leri filtrele
  static List<USGSDataset> filterHydrographicDatasets(List<USGSDataset> datasets) {
    return datasets.where((d) => d.isHydrographicDataset).toList();
  }

  /// Güncel dataset'leri filtrele
  static List<USGSDataset> filterRecentDatasets(List<USGSDataset> datasets) {
    return datasets.where((d) => d.isRecentlyUpdated).toList();
  }

  /// Kalite skoruna göre sırala
  static List<USGSDataset> sortByQuality(List<USGSDataset> datasets) {
    final sortedDatasets = List<USGSDataset>.from(datasets);
    sortedDatasets.sort((a, b) => b.qualityScore.compareTo(a.qualityScore));
    return sortedDatasets;
  }

  /// Coğrafi kapsamına göre filtrele
  static List<USGSDataset> filterByScope(List<USGSDataset> datasets, String scope) {
    return datasets.where((d) => d.geographicScope == scope).toList();
  }

  /// Anahtar kelime ile ara
  static List<USGSDataset> searchByKeyword(List<USGSDataset> datasets, String keyword) {
    final keywordLower = keyword.toLowerCase();
    return datasets.where((d) =>
      d.title.toLowerCase().contains(keywordLower) ||
      d.description.toLowerCase().contains(keywordLower) ||
      d.tags.any((tag) => tag.toLowerCase().contains(keywordLower))
    ).toList();
  }

  /// Asteroid impact analizi için en uygun dataset'leri al
  static List<USGSDataset> getImpactAnalysisDatasets(List<USGSDataset> datasets) {
    final relevantDatasets = <USGSDataset>[];
    
    // Elevation datasets (en önemli)
    relevantDatasets.addAll(filterElevationDatasets(datasets));
    
    // Topographic datasets
    relevantDatasets.addAll(filterTopographicDatasets(datasets));
    
    // Hydrographic datasets (tsunami analizi için)
    relevantDatasets.addAll(filterHydrographicDatasets(datasets));
    
    // Duplicateları kaldır ve kaliteye göre sırala
    final uniqueDatasets = <String, USGSDataset>{};
    for (final dataset in relevantDatasets) {
      uniqueDatasets[dataset.id] = dataset;
    }
    
    return sortByQuality(uniqueDatasets.values.toList());
  }
}

/// Impact analizi için dataset önerileri
class USGSDatasetRecommendation {
  final USGSDataset dataset;
  final String reason;
  final int priority; // 1-5, 1 = en yüksek öncelik
  final List<String> useCases;

  const USGSDatasetRecommendation({
    required this.dataset,
    required this.reason,
    required this.priority,
    required this.useCases,
  });

  /// Recommendation'ları asteroid impact analizi için oluştur
  static List<USGSDatasetRecommendation> generateImpactRecommendations(
    List<USGSDataset> datasets
  ) {
    final recommendations = <USGSDatasetRecommendation>[];
    
    for (final dataset in datasets) {
      if (dataset.isElevationDataset) {
        recommendations.add(USGSDatasetRecommendation(
          dataset: dataset,
          reason: 'Essential for crater depth and volume calculations',
          priority: 1,
          useCases: ['Crater modeling', 'Surface impact analysis', 'Volume calculations'],
        ));
      }
      
      if (dataset.isTopographicDataset) {
        recommendations.add(USGSDatasetRecommendation(
          dataset: dataset,
          reason: 'Useful for terrain visualization and context',
          priority: 2,
          useCases: ['Impact visualization', 'Terrain analysis', 'Geographic context'],
        ));
      }
      
      if (dataset.isHydrographicDataset) {
        recommendations.add(USGSDatasetRecommendation(
          dataset: dataset,
          reason: 'Critical for tsunami and water displacement modeling',
          priority: 1,
          useCases: ['Tsunami modeling', 'Water displacement', 'Coastal impact analysis'],
        ));
      }
    }
    
    // Önceliğe göre sırala
    recommendations.sort((a, b) => a.priority.compareTo(b.priority));
    
    return recommendations;
  }
}

extension on Iterable<USGSDatasetFormat> {
  USGSDatasetFormat? get firstOrNull => isEmpty ? null : first;
}

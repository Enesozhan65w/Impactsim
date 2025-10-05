class USGSProduct {
  final String title;
  final String moreInfo;
  final bool sourceId;
  final String sourceName;
  final String sourceOriginId;
  final String sourceOriginName;
  final String metaUrl;
  final String vendorMetaUrl;
  final String publicationDate;
  final String lastUpdated;
  final String dateCreated;
  final int sizeInBytes;
  final String extent;
  final String format;
  final String downloadURL;
  final String downloadURLRaster;
  final String previewGraphicURL;
  final String downloadLazURL;
  final USGSProductUrls urls;
  final List<String> datasets;
  final USGSBoundingBox boundingBox;
  final int bestFitIndex;
  final String body;
  final String processingUrl;
  final String modificationInfo;

  const USGSProduct({
    required this.title,
    required this.moreInfo,
    required this.sourceId,
    required this.sourceName,
    required this.sourceOriginId,
    required this.sourceOriginName,
    required this.metaUrl,
    required this.vendorMetaUrl,
    required this.publicationDate,
    required this.lastUpdated,
    required this.dateCreated,
    required this.sizeInBytes,
    required this.extent,
    required this.format,
    required this.downloadURL,
    required this.downloadURLRaster,
    required this.previewGraphicURL,
    required this.downloadLazURL,
    required this.urls,
    required this.datasets,
    required this.boundingBox,
    required this.bestFitIndex,
    required this.body,
    required this.processingUrl,
    required this.modificationInfo,
  });

  factory USGSProduct.fromJson(Map<String, dynamic> json) {
    return USGSProduct(
      title: json['title'] ?? '',
      moreInfo: json['moreInfo'] ?? '',
      sourceId: json['sourceId'] ?? false,
      sourceName: json['sourceName'] ?? '',
      sourceOriginId: json['sourceOriginId'] ?? '',
      sourceOriginName: json['sourceOriginName'] ?? '',
      metaUrl: json['metaUrl'] ?? '',
      vendorMetaUrl: json['vendorMetaUrl'] ?? '',
      publicationDate: json['publicationDate'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      dateCreated: json['dateCreated'] ?? '',
      sizeInBytes: json['sizeInBytes'] ?? 0,
      extent: json['extent'] ?? '',
      format: json['format'] ?? '',
      downloadURL: json['downloadURL'] ?? '',
      downloadURLRaster: json['downloadURLRaster'] ?? '',
      previewGraphicURL: json['previewGraphicURL'] ?? '',
      downloadLazURL: json['downloadLazURL'] ?? '',
      urls: USGSProductUrls.fromJson(json['urls'] ?? {}),
      datasets: List<String>.from(json['datasets'] ?? []),
      boundingBox: USGSBoundingBox.fromJson(json['boundingBox'] ?? {}),
      bestFitIndex: json['bestFitIndex'] ?? 0,
      body: json['body'] ?? '',
      processingUrl: json['processingUrl'] ?? '',
      modificationInfo: json['modificationInfo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'moreInfo': moreInfo,
      'sourceId': sourceId,
      'sourceName': sourceName,
      'sourceOriginId': sourceOriginId,
      'sourceOriginName': sourceOriginName,
      'metaUrl': metaUrl,
      'vendorMetaUrl': vendorMetaUrl,
      'publicationDate': publicationDate,
      'lastUpdated': lastUpdated,
      'dateCreated': dateCreated,
      'sizeInBytes': sizeInBytes,
      'extent': extent,
      'format': format,
      'downloadURL': downloadURL,
      'downloadURLRaster': downloadURLRaster,
      'previewGraphicURL': previewGraphicURL,
      'downloadLazURL': downloadLazURL,
      'urls': urls.toJson(),
      'datasets': datasets,
      'boundingBox': boundingBox.toJson(),
      'bestFitIndex': bestFitIndex,
      'body': body,
      'processingUrl': processingUrl,
      'modificationInfo': modificationInfo,
    };
  }

  // Asteroid impact simülasyonu için faydalı özellikler
  bool get hasElevationData => 
    format.contains('TIFF') || format.contains('DEM') || urls.geoTIFF.isNotEmpty;
  
  bool get hasTopographicMap => 
    title.toLowerCase().contains('topo') || 
    title.toLowerCase().contains('elevation') ||
    datasets.any((d) => d.toLowerCase().contains('elevation'));
  
  bool get isInRegion => boundingBox.isValid;
  
  String get bestDownloadUrl {
    if (urls.geoTIFF.isNotEmpty) return urls.geoTIFF;
    if (downloadURLRaster.isNotEmpty) return downloadURLRaster;
    if (downloadURL.isNotEmpty) return downloadURL;
    return '';
  }
}

class USGSProductUrls {
  final String laz;
  final String tiff;
  final String fileGDB;
  final String esriFileGeoDatabase;
  final String fileGDB101;
  final String geoPDF;
  final String geoTIFF;
  final String gridFloat;
  final String img;
  final String pdf;
  final String ascii;

  const USGSProductUrls({
    required this.laz,
    required this.tiff,
    required this.fileGDB,
    required this.esriFileGeoDatabase,
    required this.fileGDB101,
    required this.geoPDF,
    required this.geoTIFF,
    required this.gridFloat,
    required this.img,
    required this.pdf,
    required this.ascii,
  });

  factory USGSProductUrls.fromJson(Map<String, dynamic> json) {
    return USGSProductUrls(
      laz: json['LAZ'] ?? '',
      tiff: json['TIFF'] ?? '',
      fileGDB: json['FileGDB'] ?? '',
      esriFileGeoDatabase: json['Esri File GeoDatabase'] ?? '',
      fileGDB101: json['FileGDB 10.1'] ?? '',
      geoPDF: json['GeoPDF'] ?? '',
      geoTIFF: json['GeoTIFF'] ?? '',
      gridFloat: json['GridFloat'] ?? '',
      img: json['IMG'] ?? '',
      pdf: json['PDF'] ?? '',
      ascii: json['ASCII'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LAZ': laz,
      'TIFF': tiff,
      'FileGDB': fileGDB,
      'Esri File GeoDatabase': esriFileGeoDatabase,
      'FileGDB 10.1': fileGDB101,
      'GeoPDF': geoPDF,
      'GeoTIFF': geoTIFF,
      'GridFloat': gridFloat,
      'IMG': img,
      'PDF': pdf,
      'ASCII': ascii,
    };
  }
}

class USGSBoundingBox {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  const USGSBoundingBox({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  factory USGSBoundingBox.fromJson(Map<String, dynamic> json) {
    return USGSBoundingBox(
      minX: (json['minX'] ?? 0.0).toDouble(),
      maxX: (json['maxX'] ?? 0.0).toDouble(),
      minY: (json['minY'] ?? 0.0).toDouble(),
      maxY: (json['maxY'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minX': minX,
      'maxX': maxX,
      'minY': minY,
      'maxY': maxY,
    };
  }

  // Yardımcı özellikler
  bool get isValid => minX != 0 || maxX != 0 || minY != 0 || maxY != 0;
  
  double get width => maxX - minX;
  double get height => maxY - minY;
  double get centerX => (minX + maxX) / 2;
  double get centerY => (minY + maxY) / 2;
  
  // Bir koordinatın bu bounding box içinde olup olmadığını kontrol et
  bool contains(double lat, double lng) {
    return lng >= minX && lng <= maxX && lat >= minY && lat <= maxY;
  }
  
  // İki bounding box'ın kesişip kesişmediğini kontrol et
  bool intersects(USGSBoundingBox other) {
    return !(minX > other.maxX || maxX < other.minX || 
             minY > other.maxY || maxY < other.minY);
  }
}

// USGS veri filtreleme ve sıralama yardımcıları
class USGSProductFilter {
  static List<USGSProduct> filterByLocation(
    List<USGSProduct> products, 
    double latitude, 
    double longitude
  ) {
    return products
        .where((p) => p.boundingBox.contains(latitude, longitude))
        .toList();
  }
  
  static List<USGSProduct> filterByDataset(
    List<USGSProduct> products, 
    String dataset
  ) {
    return products
        .where((p) => p.datasets.contains(dataset))
        .toList();
  }
  
  static List<USGSProduct> filterElevationData(List<USGSProduct> products) {
    return products
        .where((p) => p.hasElevationData)
        .toList();
  }
  
  static List<USGSProduct> sortByBestFit(List<USGSProduct> products) {
    final sortedProducts = List<USGSProduct>.from(products);
    sortedProducts.sort((a, b) => a.bestFitIndex.compareTo(b.bestFitIndex));
    return sortedProducts;
  }
  
  static List<USGSProduct> sortByFileSize(List<USGSProduct> products, {bool ascending = true}) {
    final sortedProducts = List<USGSProduct>.from(products);
    sortedProducts.sort((a, b) => 
      ascending ? a.sizeInBytes.compareTo(b.sizeInBytes) 
                : b.sizeInBytes.compareTo(a.sizeInBytes)
    );
    return sortedProducts;
  }
}

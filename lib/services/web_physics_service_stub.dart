// Stub implementation for non-web platforms
class WebPhysicsService {
  static WebPhysicsService? _instance;
  static WebPhysicsService get instance => _instance ??= WebPhysicsService._();
  
  WebPhysicsService._();
  
  bool _isInitialized = false;
  
  /// Fizik motorunu başlat
  Future<void> initialize() async {
    print('WebPhysicsService: Web olmayan platformda çalışıyor, stub kullanılıyor');
    _isInitialized = false; // Web olmayan platformlarda devre dışı
  }
  
  /// Simülasyon ortamını başlat
  void initializeEnvironment(String environmentName) {
    print('WebPhysicsService: initializeEnvironment stub - $environmentName');
  }
  
  /// Roket oluştur
  void createRocket(Map<String, dynamic> rocketData) {
    print('WebPhysicsService: createRocket stub - ${rocketData['type']}');
  }
  
  /// İtki uygula
  void applyThrust({double x = 0, double y = -1, double intensity = 1.0}) {
    // Stub - hiçbir şey yapmaz
  }
  
  /// Simülasyon verilerini güncelle
  Map<String, dynamic> updateSimulation(double progress, double deltaTime, {bool isEngineRunning = false}) {
    // Stub - varsayılan değerler döndürür
    return {
      'speed': 0.0,
      'temperature': 20.0,
      'fuel': 100.0,
      'damage': 0.0,
      'warnings': <String>[],
    };
  }
  
  /// Canvas renderer'ı başlat
  void setupRenderer() {
    print('WebPhysicsService: setupRenderer stub');
  }
  
  /// Temizlik
  void cleanup() {
    print('WebPhysicsService: cleanup stub');
  }
  
  /// Fizik motorunun durumunu kontrol et
  bool get isReady => false; // Web olmayan platformlarda her zaman false
  
  /// Debug bilgileri al
  Map<String, dynamic> getDebugInfo() {
    return {
      'status': 'stub_implementation',
      'platform': 'non-web',
      'matter_loaded': false,
      'engine_loaded': false,
      'canvas_exists': false,
    };
  }
}

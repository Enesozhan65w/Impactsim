// Web implementation with dart:html and dart:js
import 'dart:html' as html;
import 'dart:js' as js;

class WebPhysicsService {
  static WebPhysicsService? _instance;
  static WebPhysicsService get instance => _instance ??= WebPhysicsService._();
  
  WebPhysicsService._();
  
  bool _isInitialized = false;
  
  /// Fizik motorunu başlat
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Matter.js'in yüklendiğinden emin ol
    await _waitForMatterJs();
    
    // Fizik motorunu başlat
    js.context.callMethod('eval', ['''
      if (typeof window.physicsEngine === 'undefined') {
        console.error('Physics engine not loaded!');
      } else {
        console.log('Physics engine ready!');
      }
    ''']);
    
    _isInitialized = true;
  }
  
  /// Matter.js'in yüklenmesini bekle
  Future<void> _waitForMatterJs() async {
    int attempts = 0;
    const maxAttempts = 50;
    
    while (attempts < maxAttempts) {
      try {
        final matterExists = js.context['Matter'] != null;
        final engineExists = js.context['physicsEngine'] != null;
        
        if (matterExists && engineExists) {
          print('Matter.js ve Physics Engine yüklendi');
          return;
        }
      } catch (e) {
        // Henüz yüklenmemiş
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    throw Exception('Matter.js veya Physics Engine yüklenemedi');
  }
  
  /// Simülasyon ortamını başlat
  void initializeEnvironment(String environmentName) {
    if (!_isInitialized) {
      throw Exception('WebPhysicsService henüz başlatılmadı');
    }
    
    try {
      js.context['physicsEngine'].callMethod('initializeEnvironment', [environmentName]);
      print('Ortam başlatıldı: $environmentName');
    } catch (e) {
      print('Ortam başlatma hatası: $e');
      rethrow;
    }
  }
  
  /// Roket oluştur
  void createRocket(Map<String, dynamic> rocketData) {
    if (!_isInitialized) {
      throw Exception('WebPhysicsService henüz başlatılmadı');
    }
    
    try {
      final jsRocketData = js.JsObject.jsify(rocketData);
      js.context['physicsEngine'].callMethod('createRocket', [jsRocketData]);
      print('Roket oluşturuldu: ${rocketData['type']}');
    } catch (e) {
      print('Roket oluşturma hatası: $e');
      rethrow;
    }
  }
  
  /// İtki uygula
  void applyThrust({double x = 0, double y = -1, double intensity = 1.0}) {
    if (!_isInitialized) return;
    
    try {
      final direction = js.JsObject.jsify({'x': x, 'y': y});
      js.context['physicsEngine'].callMethod('applyThrust', [direction, intensity]);
    } catch (e) {
      print('İtki uygulama hatası: $e');
    }
  }
  
  /// Simülasyon verilerini güncelle
  Map<String, dynamic> updateSimulation(double progress, double deltaTime, {bool isEngineRunning = false}) {
    if (!_isInitialized) {
      return {
        'speed': 0.0,
        'temperature': 20.0,
        'fuel': 100.0,
        'damage': 0.0,
        'warnings': <String>[],
      };
    }
    
    try {
      final result = js.context['physicsEngine'].callMethod('updateSimulation', [progress, deltaTime, isEngineRunning]);
      
      if (result != null) {
        return {
          'speed': _getJsProperty(result, 'speed', 0.0),
          'temperature': _getJsProperty(result, 'temperature', 20.0),
          'fuel': _getJsProperty(result, 'fuel', 100.0),
          'damage': _getJsProperty(result, 'damage', 0.0),
          'warnings': _getJsArrayProperty(result, 'warnings'),
        };
      }
    } catch (e) {
      print('Simülasyon güncelleme hatası: $e');
    }
    
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
    if (!_isInitialized) return;
    
    try {
      final canvas = html.document.getElementById('physics-canvas') as html.CanvasElement?;
      if (canvas != null) {
        js.context['physicsEngine'].callMethod('setupRenderer', [canvas]);
        print('Physics renderer başlatıldı');
      }
    } catch (e) {
      print('Renderer başlatma hatası: $e');
    }
  }
  
  /// Temizlik
  void cleanup() {
    if (!_isInitialized) return;
    
    try {
      js.context['physicsEngine'].callMethod('cleanup');
      print('Physics engine temizlendi');
    } catch (e) {
      print('Temizlik hatası: $e');
    }
  }
  
  /// JavaScript nesnesinden güvenli property alma
  dynamic _getJsProperty(js.JsObject obj, String property, dynamic defaultValue) {
    try {
      final value = obj[property];
      return value ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
  
  /// JavaScript array'ini Dart List'e çevir
  List<String> _getJsArrayProperty(js.JsObject obj, String property) {
    try {
      final jsArray = obj[property];
      if (jsArray != null && jsArray is js.JsArray) {
        return jsArray.cast<String>().toList();
      }
    } catch (e) {
      print('Array property alma hatası: $e');
    }
    return <String>[];
  }
  
  /// Fizik motorunun durumunu kontrol et
  bool get isReady => _isInitialized;
  
  /// Debug bilgileri al
  Map<String, dynamic> getDebugInfo() {
    if (!_isInitialized) {
      return {'status': 'not_initialized'};
    }
    
    try {
      return {
        'status': 'ready',
        'matter_loaded': js.context['Matter'] != null,
        'engine_loaded': js.context['physicsEngine'] != null,
        'canvas_exists': html.document.getElementById('physics-canvas') != null,
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }
}

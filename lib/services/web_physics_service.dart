// Platform-aware WebPhysicsService
// Web platformunda gerçek fizik motoru, diğer platformlarda stub kullanır

export 'web_physics_service_stub.dart'
    if (dart.library.html) 'web_physics_service_web.dart';

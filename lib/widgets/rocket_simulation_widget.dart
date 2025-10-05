import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/rocket_model.dart';
import '../services/rocket_physics_service.dart';

/// Roket simülasyon görselleştirme widget'ı
/// Canvas ile 2D roket simülasyonu gösterir
class RocketSimulationWidget extends StatefulWidget {
  final RocketModel rocket;
  final CameraMode cameraMode;
  final bool showFlameEffect;
  final bool showTrail;

  const RocketSimulationWidget({
    super.key,
    required this.rocket,
    this.cameraMode = CameraMode.isometric,
    this.showFlameEffect = true,
    this.showTrail = true,
  });

  @override
  State<RocketSimulationWidget> createState() => _RocketSimulationWidgetState();
}

class _RocketSimulationWidgetState extends State<RocketSimulationWidget>
    with TickerProviderStateMixin {
  late AnimationController _flameAnimationController;
  late Animation<double> _flameAnimation;
  late AnimationController _rotationController;

  // Trail sistemi
  final List<Vector2> _trailPositions = [];
  int _maxTrailLength = 50;

  @override
  void initState() {
    super.initState();
    
    // Alev animasyonu
    _flameAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _flameAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _flameAnimationController, curve: Curves.easeInOut),
    );
    
    // Roket rotasyon animasyonu
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _flameAnimationController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void didUpdateWidget(RocketSimulationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trail güncelleme
    if (widget.showTrail) {
      _updateTrail();
    }
  }

  void _updateTrail() {
    _trailPositions.add(Vector2(widget.rocket.position.x, widget.rocket.position.y));
    
    if (_trailPositions.length > _maxTrailLength) {
      _trailPositions.removeAt(0);
    }
  }

  @override
  void dispose() {
    _flameAnimationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF87CEEB), // Sky blue
            const Color(0xFF4682B4), // Steel blue
            const Color(0xFF191970), // Midnight blue
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_flameAnimation, _rotationController]),
        builder: (context, child) {
          return CustomPaint(
            painter: RocketSimulationPainter(
              rocket: widget.rocket,
              cameraMode: widget.cameraMode,
              flameIntensity: widget.showFlameEffect ? _flameAnimation.value : 0.0,
              rotationAngle: _rotationController.value * 2 * math.pi,
              trailPositions: widget.showTrail ? _trailPositions : [],
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

/// Roket simülasyon çizim sınıfı
class RocketSimulationPainter extends CustomPainter {
  final RocketModel rocket;
  final CameraMode cameraMode;
  final double flameIntensity;
  final double rotationAngle;
  final List<Vector2> trailPositions;

  // Kamera parametreleri
  Vector2 _cameraOffset = Vector2(0, 0);
  double _cameraScale = 1.0;

  RocketSimulationPainter({
    required this.rocket,
    required this.cameraMode,
    required this.flameIntensity,
    required this.rotationAngle,
    required this.trailPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _calculateCamera(size);
    
    canvas.save();
    
    // Kamera dönüşümü uygula
    canvas.translate(size.width / 2 + _cameraOffset.x, size.height / 2 + _cameraOffset.y);
    canvas.scale(_cameraScale);
    
    // Arka plan elementleri
    _drawBackground(canvas, size);
    _drawGround(canvas, size);
    _drawClouds(canvas, size);
    
    // Trail çiz
    _drawTrail(canvas);
    
    // Roket çiz
    _drawRocket(canvas);
    
    // Alev efekti çiz
    if (flameIntensity > 0.1) {
      _drawFlameEffect(canvas);
    }
    
    canvas.restore();
    
    // UI elementleri (kamera dönüşümünden etkilenmesin)
    _drawUI(canvas, size);
  }

  void _calculateCamera(Size size) {
    switch (cameraMode) {
      case CameraMode.isometric:
        // İzometrik: sabit pozisyon, roket her zaman görünür
        _cameraOffset = Vector2(-rocket.position.x, -rocket.position.y + 100);
        _cameraScale = 0.5;
        break;
        
      case CameraMode.follow:
        // Takip: roket merkezi takip
        _cameraOffset = Vector2(-rocket.position.x, -rocket.position.y + 50);
        _cameraScale = 0.8;
        break;
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Grid çizgileri (referans için)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Yatay grid çizgileri
    for (int y = -1000; y <= 2000; y += 100) {
      canvas.drawLine(
        Offset(-2000, y.toDouble()),
        Offset(2000, y.toDouble()),
        gridPaint,
      );
    }
    
    // Dikey grid çizgileri  
    for (int x = -1000; x <= 1000; x += 100) {
      canvas.drawLine(
        Offset(x.toDouble(), -500),
        Offset(x.toDouble(), 2000),
        gridPaint,
      );
    }
  }

  void _drawGround(Canvas canvas, Size size) {
    final groundPaint = Paint()
      ..color = const Color(0xFF228B22) // Forest green
      ..style = PaintingStyle.fill;
    
    // Zemin
    final groundRect = Rect.fromLTWH(-2000, -10, 4000, 50);
    canvas.drawRect(groundRect, groundPaint);
    
    // Zemin detayları
    final grassPaint = Paint()
      ..color = const Color(0xFF32CD32) // Lime green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Çimen efekti
    for (int x = -2000; x <= 2000; x += 20) {
      canvas.drawLine(
        Offset(x.toDouble(), 0),
        Offset(x.toDouble(), -8),
        grassPaint,
      );
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    // Statik bulutlar
    final clouds = [
      Vector2(200, 300),
      Vector2(-300, 500),
      Vector2(500, 800),
      Vector2(-150, 1200),
    ];
    
    for (final cloudPos in clouds) {
      _drawCloud(canvas, cloudPos, cloudPaint);
    }
  }

  void _drawCloud(Canvas canvas, Vector2 position, Paint paint) {
    // Basit bulut şekli (daireler)
    final centers = [
      Offset(position.x - 20, position.y),
      Offset(position.x, position.y - 10),
      Offset(position.x + 20, position.y),
      Offset(position.x + 10, position.y + 5),
      Offset(position.x - 10, position.y + 5),
    ];
    
    final radii = [15.0, 18.0, 15.0, 12.0, 12.0];
    
    for (int i = 0; i < centers.length; i++) {
      canvas.drawCircle(centers[i], radii[i], paint);
    }
  }

  void _drawTrail(Canvas canvas) {
    if (trailPositions.length < 2) return;
    
    final trailPaint = Paint()
      ..color = Colors.orange.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    
    for (int i = 0; i < trailPositions.length; i++) {
      final pos = trailPositions[i];
      final opacity = (i / trailPositions.length) * 0.6;
      
      trailPaint.color = Colors.orange.withOpacity(opacity);
      
      if (i == 0) {
        path.moveTo(pos.x, -pos.y);
      } else {
        path.lineTo(pos.x, -pos.y);
      }
    }
    
    canvas.drawPath(path, trailPaint);
  }

  void _drawRocket(Canvas canvas) {
    canvas.save();
    
    // Roket pozisyonuna git
    canvas.translate(rocket.position.x, -rocket.position.y);
    
    // Roket rotasyonu (hız yönüne göre)
    if (rocket.velocity.magnitude > 0.1) {
      final angle = math.atan2(rocket.velocity.x, rocket.velocity.y);
      canvas.rotate(angle);
    }
    
    // Roket gövdesi
    _drawRocketBody(canvas);
    
    // Roket detayları
    _drawRocketDetails(canvas);
    
    canvas.restore();
  }

  void _drawRocketBody(Canvas canvas) {
    // Ana gövde (capsule benzeri)
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE0E0E0), // Light gray
          const Color(0xFF808080), // Gray
          const Color(0xFF404040), // Dark gray
        ],
      ).createShader(const Rect.fromLTWH(-8, -20, 16, 40));
    
    // Roket gövdesi
    final bodyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-8, -20, 16, 32),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    
    // Roket burnu (cone)
    final nosePaint = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..style = PaintingStyle.fill;
    
    final nosePath = Path()
      ..moveTo(0, -20)
      ..lineTo(-6, -12)
      ..lineTo(6, -12)
      ..close();
    
    canvas.drawPath(nosePath, nosePaint);
  }

  void _drawRocketDetails(Canvas canvas) {
    // Pencere
    final windowPaint = Paint()
      ..color = const Color(0xFF87CEEB)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(const Offset(0, -8), 3, windowPaint);
    
    // Kanatlar
    final finPaint = Paint()
      ..color = const Color(0xFF696969)
      ..style = PaintingStyle.fill;
    
    // Sol kanat
    final leftFinPath = Path()
      ..moveTo(-8, 8)
      ..lineTo(-12, 12)
      ..lineTo(-8, 12)
      ..close();
    canvas.drawPath(leftFinPath, finPaint);
    
    // Sağ kanat
    final rightFinPath = Path()
      ..moveTo(8, 8)
      ..lineTo(12, 12)
      ..lineTo(8, 12)
      ..close();
    canvas.drawPath(rightFinPath, finPaint);
  }

  void _drawFlameEffect(Canvas canvas) {
    canvas.save();
    
    // Roket pozisyonuna git
    canvas.translate(rocket.position.x, -rocket.position.y);
    
    // Alev yoğunluğuna göre boyut
    final flameSize = 15.0 + (rocket.throttle * 25.0 * flameIntensity);
    
    // Alev renkleri (throttle'a göre)
    final flameColors = [
      Color.lerp(Colors.yellow, Colors.orange, rocket.throttle)!,
      Color.lerp(Colors.orange, Colors.red, rocket.throttle)!,
      Color.lerp(Colors.red, Colors.purple, rocket.throttle)!,
    ];
    
    final flamePaint = Paint()
      ..shader = RadialGradient(
        colors: flameColors,
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: const Offset(0, 15), radius: flameSize));
    
    // Ana alev
    final flamePath = Path()
      ..moveTo(0, 12)
      ..lineTo(-6, 12)
      ..lineTo(-4, 12 + flameSize * 0.3)
      ..lineTo(-2, 12 + flameSize * 0.7)
      ..lineTo(0, 12 + flameSize)
      ..lineTo(2, 12 + flameSize * 0.7)
      ..lineTo(4, 12 + flameSize * 0.3)
      ..lineTo(6, 12)
      ..close();
    
    canvas.drawPath(flamePath, flamePaint);
    
    // İç alev (daha parlak)
    final innerFlamePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    final innerFlameSize = flameSize * 0.6;
    final innerFlamePath = Path()
      ..moveTo(0, 12)
      ..lineTo(-3, 12)
      ..lineTo(-1, 12 + innerFlameSize * 0.5)
      ..lineTo(0, 12 + innerFlameSize)
      ..lineTo(1, 12 + innerFlameSize * 0.5)
      ..lineTo(3, 12)
      ..close();
    
    canvas.drawPath(innerFlamePath, innerFlamePaint);
    
    // Spark efekti
    _drawSparks(canvas, flameSize);
    
    canvas.restore();
  }

  void _drawSparks(Canvas canvas, double flameSize) {
    final sparkPaint = Paint()
      ..color = Colors.orange.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    final random = math.Random((rocket.throttle * 1000).toInt());
    
    for (int i = 0; i < (rocket.throttle * 10).toInt(); i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = 12 + random.nextDouble() * flameSize;
      final size = 1.0 + random.nextDouble() * 2.0;
      
      final sparkX = math.sin(angle) * distance;
      final sparkY = 12 + math.cos(angle).abs() * distance;
      
      canvas.drawCircle(Offset(sparkX, sparkY), size, sparkPaint);
    }
  }

  void _drawUI(Canvas canvas, Size size) {
    // Kamera modu göstergesi
    final uiPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Kamera: ${cameraMode == CameraMode.isometric ? 'İzometrik' : 'Takip'}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Arka plan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, size.height - 40, textPainter.width + 16, 24),
        const Radius.circular(12),
      ),
      Paint()..color = Colors.black.withOpacity(0.6),
    );
    
    textPainter.paint(canvas, Offset(18, size.height - 35));
    
    // Koordinat sistemi göstergesi (izometrik modda)
    if (cameraMode == CameraMode.isometric) {
      _drawCoordinateSystem(canvas, size);
    }
  }

  void _drawCoordinateSystem(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final axisLength = 30.0;
    final originX = size.width - 60;
    final originY = size.height - 60;
    
    // X ekseni (kırmızı)
    axisPaint.color = Colors.red;
    canvas.drawLine(
      Offset(originX, originY),
      Offset(originX + axisLength, originY),
      axisPaint,
    );
    
    // Y ekseni (yeşil)  
    axisPaint.color = Colors.green;
    canvas.drawLine(
      Offset(originX, originY),
      Offset(originX, originY - axisLength),
      axisPaint,
    );
    
    // Etiketler
    final xTextPainter = TextPainter(
      text: const TextSpan(text: 'X', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    xTextPainter.layout();
    xTextPainter.paint(canvas, Offset(originX + axisLength + 4, originY - 8));
    
    final yTextPainter = TextPainter(
      text: const TextSpan(text: 'Y', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    yTextPainter.layout();
    yTextPainter.paint(canvas, Offset(originX - 8, originY - axisLength - 16));
  }

  @override
  bool shouldRepaint(RocketSimulationPainter oldDelegate) {
    return oldDelegate.rocket.position != rocket.position ||
           oldDelegate.rocket.throttle != rocket.throttle ||
           oldDelegate.flameIntensity != flameIntensity ||
           oldDelegate.cameraMode != cameraMode ||
           oldDelegate.trailPositions.length != trailPositions.length;
  }
}

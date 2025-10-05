import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/impactor_2025_scenario.dart';
import '../models/vector3d.dart';

/// 3D Yörünge görselleştirme widget'ı
/// Asteroitin yörüngesini ve Dünya'ya yaklaşımını gösterir
class OrbitalVisualizationWidget extends StatefulWidget {
  final Impactor2025Scenario? scenario;
  final bool isAnimating;
  final double animationSpeed;

  const OrbitalVisualizationWidget({
    super.key,
    this.scenario,
    this.isAnimating = false,
    this.animationSpeed = 1.0,
  });

  @override
  State<OrbitalVisualizationWidget> createState() => _OrbitalVisualizationWidgetState();
}

class _OrbitalVisualizationWidgetState extends State<OrbitalVisualizationWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _orbitController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _orbitAnimation;

  double _cameraAngleX = 0.0;
  double _cameraAngleY = 0.0;
  double _zoom = 1.0;
  
  // Yörünge parametreleri
  final double _earthRadius = 50.0;
  final double _orbitRadius = 200.0;
  final double _asteroidSize = 8.0;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _orbitController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    
    _orbitAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _orbitController,
      curve: Curves.linear,
    ));
    
    _rotationController.repeat();
    
    if (widget.isAnimating) {
      _orbitController.repeat();
    }
  }

  @override
  void didUpdateWidget(OrbitalVisualizationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _orbitController.repeat();
      } else {
        _orbitController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _cameraAngleX += details.delta.dy * 0.01;
            _cameraAngleY += details.delta.dx * 0.01;
            _cameraAngleX = _cameraAngleX.clamp(-math.pi / 2, math.pi / 2);
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            _zoom = (_zoom * details.scale).clamp(0.5, 3.0);
          });
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotationAnimation, _orbitAnimation]),
          builder: (context, child) {
            return CustomPaint(
              painter: OrbitalVisualizationPainter(
                scenario: widget.scenario,
                rotationAngle: _rotationAnimation.value,
                orbitAngle: _orbitAnimation.value,
                cameraAngleX: _cameraAngleX,
                cameraAngleY: _cameraAngleY,
                zoom: _zoom,
                earthRadius: _earthRadius,
                orbitRadius: _orbitRadius,
                asteroidSize: _asteroidSize,
                isAnimating: widget.isAnimating,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

/// 3D yörünge çizim sınıfı
class OrbitalVisualizationPainter extends CustomPainter {
  final Impactor2025Scenario? scenario;
  final double rotationAngle;
  final double orbitAngle;
  final double cameraAngleX;
  final double cameraAngleY;
  final double zoom;
  final double earthRadius;
  final double orbitRadius;
  final double asteroidSize;
  final bool isAnimating;

  OrbitalVisualizationPainter({
    this.scenario,
    required this.rotationAngle,
    required this.orbitAngle,
    required this.cameraAngleX,
    required this.cameraAngleY,
    required this.zoom,
    required this.earthRadius,
    required this.orbitRadius,
    required this.asteroidSize,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Arka plan
    _drawBackground(canvas, size);
    
    // Koordinat sistemi dönüşümü
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(zoom);
    
    // Kamera rotasyonu
    _applyCameraRotation(canvas);
    
    // Yörünge çizimi
    _drawOrbit(canvas);
    
    // Dünya çizimi
    _drawEarth(canvas);
    
    // Asteroit çizimi
    _drawAsteroid(canvas);
    
    // Çarpma yolu çizimi
    if (scenario != null) {
      _drawImpactTrajectory(canvas);
    }
    
    // Saptırma yolu çizimi (eğer varsa)
    if (scenario?.appliedStrategy != null) {
      _drawDeflectionTrajectory(canvas);
    }
    
    canvas.restore();
    
    // UI elementleri
    _drawUI(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Uzay arka planı
    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          const Color(0xFF0A0E27),
          const Color(0xFF1A1F3A),
          const Color(0xFF000000),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    
    // Yıldızlar
    _drawStars(canvas, size);
  }

  void _drawStars(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42); // Sabit seed ile tutarlı yıldızlar
    
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  void _applyCameraRotation(Canvas canvas) {
    // Y ekseni etrafında rotasyon (yatay)
    final cosY = math.cos(cameraAngleY);
    final sinY = math.sin(cameraAngleY);
    
    // X ekseni etrafında rotasyon (dikey)
    final cosX = math.cos(cameraAngleX);
    final sinX = math.sin(cameraAngleX);
    
    // Basitleştirilmiş 3D dönüşüm matrisi
    // Bu gerçek 3D değil, 2.5D bir yaklaşım
    final matrix = Matrix4.identity()
      ..setEntry(0, 0, cosY)
      ..setEntry(0, 2, sinY)
      ..setEntry(1, 1, cosX)
      ..setEntry(2, 0, -sinY)
      ..setEntry(2, 2, cosY);
    
    canvas.transform(matrix.storage);
  }

  void _drawOrbit(Canvas canvas) {
    final orbitPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Ana yörünge
    canvas.drawCircle(Offset.zero, orbitRadius, orbitPaint);
    
    // Yörünge yönü ok işaretleri
    _drawOrbitArrows(canvas);
  }

  void _drawOrbitArrows(Canvas canvas) {
    final arrowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + orbitAngle * 0.1;
      final x = math.cos(angle) * orbitRadius;
      final y = math.sin(angle) * orbitRadius;
      
      final arrowAngle = angle + math.pi / 2;
      final arrowLength = 15.0;
      
      final startX = x - math.cos(arrowAngle) * arrowLength / 2;
      final startY = y - math.sin(arrowAngle) * arrowLength / 2;
      final endX = x + math.cos(arrowAngle) * arrowLength / 2;
      final endY = y + math.sin(arrowAngle) * arrowLength / 2;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        arrowPaint,
      );
      
      // Ok başı
      final headAngle1 = arrowAngle - 0.5;
      final headAngle2 = arrowAngle + 0.5;
      final headLength = 8.0;
      
      canvas.drawLine(
        Offset(endX, endY),
        Offset(endX - math.cos(headAngle1) * headLength, 
               endY - math.sin(headAngle1) * headLength),
        arrowPaint,
      );
      
      canvas.drawLine(
        Offset(endX, endY),
        Offset(endX - math.cos(headAngle2) * headLength, 
               endY - math.sin(headAngle2) * headLength),
        arrowPaint,
      );
    }
  }

  void _drawEarth(Canvas canvas) {
    // Dünya gövdesi
    final earthPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4A90E2),
          const Color(0xFF2E5C8A),
          const Color(0xFF1A3A5C),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: earthRadius));
    
    canvas.drawCircle(Offset.zero, earthRadius, earthPaint);
    
    // Dünya atmosferi
    final atmospherePaint = Paint()
      ..color = const Color(0xFF87CEEB).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    
    canvas.drawCircle(Offset.zero, earthRadius + 4, atmospherePaint);
    
    // Dünya rotasyonu (basit çizgiler)
    _drawEarthRotation(canvas);
    
    // Çarpma noktası işareti
    if (scenario != null) {
      _drawImpactPoint(canvas);
    }
  }

  void _drawEarthRotation(Canvas canvas) {
    final rotationPaint = Paint()
      ..color = Colors.green.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Basit meridyen çizgileri
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + rotationAngle * 0.5;
      final startX = math.cos(angle) * earthRadius * 0.8;
      final startY = math.sin(angle) * earthRadius * 0.8;
      final endX = math.cos(angle + math.pi) * earthRadius * 0.8;
      final endY = math.sin(angle + math.pi) * earthRadius * 0.8;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        rotationPaint,
      );
    }
  }

  void _drawImpactPoint(Canvas canvas) {
    if (scenario == null) return;
    
    // Çarpma noktasını Dünya yüzeyinde göster
    final impactAngle = (scenario!.impactLongitude * math.pi / 180) + rotationAngle;
    final impactX = math.cos(impactAngle) * earthRadius;
    final impactY = math.sin(impactAngle) * earthRadius;
    
    final impactPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(impactX, impactY), 4.0, impactPaint);
    
    // Çarpma noktası etrafında dalgalar
    final wavePaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        Offset(impactX, impactY),
        4.0 + (i * 8.0) + (orbitAngle * 5),
        wavePaint,
      );
    }
  }

  void _drawAsteroid(Canvas canvas) {
    if (scenario == null) return;
    
    // Asteroit pozisyonu
    final asteroidX = math.cos(orbitAngle) * orbitRadius;
    final asteroidY = math.sin(orbitAngle) * orbitRadius;
    
    // Asteroit gövdesi
    final asteroidPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.orange.withOpacity(0.8),
          Colors.red.withOpacity(0.6),
          Colors.brown.withOpacity(0.8),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(asteroidX, asteroidY),
        radius: asteroidSize,
      ));
    
    canvas.drawCircle(Offset(asteroidX, asteroidY), asteroidSize, asteroidPaint);
    
    // Asteroit izi
    _drawAsteroidTrail(canvas, asteroidX, asteroidY);
    
    // Asteroit bilgi etiketi
    _drawAsteroidLabel(canvas, asteroidX, asteroidY);
  }

  void _drawAsteroidTrail(Canvas canvas, double asteroidX, double asteroidY) {
    final trailPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    
    // Son birkaç pozisyonu göster
    for (int i = 1; i <= 20; i++) {
      final trailAngle = orbitAngle - (i * 0.1);
      final trailX = math.cos(trailAngle) * orbitRadius;
      final trailY = math.sin(trailAngle) * orbitRadius;
      
      if (i == 1) {
        path.moveTo(trailX, trailY);
      } else {
        path.lineTo(trailX, trailY);
      }
    }
    
    canvas.drawPath(path, trailPaint);
  }

  void _drawAsteroidLabel(Canvas canvas, double asteroidX, double asteroidY) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: scenario?.asteroid.name ?? 'Asteroit',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final labelOffset = Offset(
      asteroidX - textPainter.width / 2,
      asteroidY - asteroidSize - 20,
    );
    
    // Arka plan
    final labelBg = Paint()
      ..color = Colors.black.withOpacity(0.7);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          labelOffset.dx - 4,
          labelOffset.dy - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        ),
        const Radius.circular(4),
      ),
      labelBg,
    );
    
    textPainter.paint(canvas, labelOffset);
  }

  void _drawImpactTrajectory(Canvas canvas) {
    if (scenario == null) return;
    
    final trajectoryPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    // Asteroit'ten Dünya'ya çarpma yolu
    final asteroidX = math.cos(orbitAngle) * orbitRadius;
    final asteroidY = math.sin(orbitAngle) * orbitRadius;
    
    final impactAngle = (scenario!.impactLongitude * math.pi / 180) + rotationAngle;
    final impactX = math.cos(impactAngle) * earthRadius;
    final impactY = math.sin(impactAngle) * earthRadius;
    
    // Kesikli çizgi efekti için manuel çizim
    _drawDashedLine(canvas, Offset(asteroidX, asteroidY), Offset(impactX, impactY), trajectoryPaint);
  }

  void _drawDeflectionTrajectory(Canvas canvas) {
    if (scenario?.appliedStrategy == null) return;
    
    final deflectionPaint = Paint()
      ..color = Colors.green.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    // Saptırılmış yol
    final asteroidX = math.cos(orbitAngle) * orbitRadius;
    final asteroidY = math.sin(orbitAngle) * orbitRadius;
    
    // Saptırma sonrası yeni yörünge (basitleştirilmiş)
    final deflectionAngle = orbitAngle + 0.5; // Saptırma miktarı
    final newX = math.cos(deflectionAngle) * (orbitRadius + 50);
    final newY = math.sin(deflectionAngle) * (orbitRadius + 50);
    
    // Kesikli çizgi efekti için manuel çizim
    _drawDashedLine(canvas, Offset(asteroidX, asteroidY), Offset(newX, newY), deflectionPaint);
    
    // "MISS" etiketi
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SAPTIRMA BAŞARILI!',
        style: TextStyle(
          color: Colors.green,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, Offset(newX - textPainter.width / 2, newY + 20));
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashLength = 8.0;
    const double gapLength = 4.0;
    
    final distance = (end - start).distance;
    final unitVector = (end - start) / distance;
    
    double currentDistance = 0.0;
    bool isDash = true;
    
    while (currentDistance < distance) {
      final segmentLength = isDash ? dashLength : gapLength;
      final segmentEnd = math.min(currentDistance + segmentLength, distance);
      
      if (isDash) {
        final segmentStart = start + unitVector * currentDistance;
        final segmentEndPoint = start + unitVector * segmentEnd;
        canvas.drawLine(segmentStart, segmentEndPoint, paint);
      }
      
      currentDistance = segmentEnd;
      isDash = !isDash;
    }
  }

  void _drawUI(Canvas canvas, Size size) {
    // Kontrol bilgileri
    final infoPainter = TextPainter(
      text: const TextSpan(
        text: 'Sürükle: Kamera • Pinch: Zoom',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    infoPainter.layout();
    infoPainter.paint(canvas, Offset(10, size.height - 30));
    
    // Zoom seviyesi
    final zoomPainter = TextPainter(
      text: TextSpan(
        text: 'Zoom: ${zoom.toStringAsFixed(1)}x',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    zoomPainter.layout();
    zoomPainter.paint(canvas, Offset(size.width - zoomPainter.width - 10, 10));
    
    // Animasyon durumu
    if (isAnimating) {
      final animPainter = TextPainter(
        text: const TextSpan(
          text: '▶ Simülasyon Çalışıyor',
          style: TextStyle(
            color: Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      animPainter.layout();
      animPainter.paint(canvas, const Offset(10, 10));
    }
  }

  // Kesikli çizgi efekti oluştur
  dynamic _createDashPathEffect() {
    // Flutter'da PathEffect doğrudan desteklenmediği için null döndürüyoruz
    // Gerçek uygulamada custom dash çizimi yapılabilir
    return null;
  }

  @override
  bool shouldRepaint(OrbitalVisualizationPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
           oldDelegate.orbitAngle != orbitAngle ||
           oldDelegate.cameraAngleX != cameraAngleX ||
           oldDelegate.cameraAngleY != cameraAngleY ||
           oldDelegate.zoom != zoom ||
           oldDelegate.isAnimating != isAnimating;
  }
}

/// 3D vektör hesaplamaları için yardımcı sınıf
class Vector3D {
  final double x, y, z;
  
  const Vector3D(this.x, this.y, this.z);
  
  Vector3D operator +(Vector3D other) => Vector3D(x + other.x, y + other.y, z + other.z);
  Vector3D operator -(Vector3D other) => Vector3D(x - other.x, y - other.y, z - other.z);
  Vector3D operator *(double scalar) => Vector3D(x * scalar, y * scalar, z * scalar);
  
  double get length => math.sqrt(x * x + y * y + z * z);
  Vector3D get normalized => this * (1.0 / length);
  
  // 2D projeksiyon
  Offset project2D() => Offset(x, y);
}

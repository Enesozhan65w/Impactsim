import 'package:flutter/material.dart';
import '../services/rocket_physics_service.dart';
import '../models/rocket_model.dart';
import '../widgets/rocket_simulation_widget.dart';
import '../widgets/rocket_hud_widget.dart';

/// Ana roket simülasyon ekranı
/// Unity MVP spesifikasyonuna uygun tam ekran simülasyon
class RocketSimulationScreen extends StatefulWidget {
  const RocketSimulationScreen({super.key});

  @override
  State<RocketSimulationScreen> createState() => _RocketSimulationScreenState();
}

class _RocketSimulationScreenState extends State<RocketSimulationScreen> {
  late RocketPhysicsService _physicsService;
  CameraMode _currentCameraMode = CameraMode.isometric;

  @override
  void initState() {
    super.initState();
    _physicsService = RocketPhysicsService.instance;
    _physicsService.initialize();
  }

  @override
  void dispose() {
    // Physics service'i dispose etme - singleton olduğu için
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<RocketModel>(
        stream: _physicsService.rocketStateStream,
        builder: (context, snapshot) {
          final rocket = snapshot.data ?? _physicsService.rocket;
          
          return Stack(
            children: [
              // Ana simülasyon görünümü
              Positioned.fill(
                child: RocketSimulationWidget(
                  rocket: rocket,
                  cameraMode: _currentCameraMode,
                  showFlameEffect: true,
                  showTrail: true,
                ),
              ),
              
              // HUD Overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: RocketHudWidget(
                    rocket: rocket,
                    state: _physicsService.state,
                  ),
                ),
              ),
              
              // Kontrol paneli
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: RocketControlWidget(
                    physicsService: _physicsService,
                    onCameraChange: (mode) {
                      setState(() {
                        _currentCameraMode = mode;
                      });
                    },
                  ),
                ),
              ),
              
              // Geri butonu
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

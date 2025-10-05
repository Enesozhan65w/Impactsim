import 'package:flutter/material.dart';
import '../models/rocket_model.dart';
import '../services/rocket_physics_service.dart';

/// Roket HUD (Heads-Up Display) widget'ı
/// Unity MVP spesifikasyonuna uygun 2x2 kart ızgarası
class RocketHudWidget extends StatelessWidget {
  final RocketModel rocket;
  final RocketState state;

  const RocketHudWidget({
    super.key,
    required this.rocket,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Roket bilgisi başlığı
          _buildRocketInfoHeader(),
          const SizedBox(height: 12),
          
          // 2x2 Grid Layout
          Row(
            children: [
              Expanded(
                child: _buildHudCard(
                  'HIZ',
                  '${rocket.speedMps.toStringAsFixed(1)} m/s',
                  Icons.speed,
                  Colors.blue,
                  _getSpeedSubtitle(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHudCard(
                  'SICAKLIK',
                  '${rocket.temperatureC.toStringAsFixed(0)} °C',
                  Icons.thermostat,
                  _getTemperatureColor(),
                  _getTemperatureStatus(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildHudCard(
                  'YAKIT',
                  '${rocket.fuelPercent.toStringAsFixed(0)}%',
                  Icons.local_gas_station,
                  _getFuelColor(),
                  _getFuelStatus(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHudCard(
                  'KÜTLE',
                  '${(rocket.currentMass/1000).toStringAsFixed(0)}t',
                  Icons.fitness_center,
                  _getMassColor(),
                  '${(rocket.dryMass/1000).toStringAsFixed(0)}-${(rocket.mass/1000).toStringAsFixed(0)}t',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Durum çubuğu
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildHudCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık ve ikon
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Ana değer
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Alt başlık
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Durum ikonu
          Icon(
            _getStateIcon(),
            color: _getStateColor(),
            size: 16,
          ),
          const SizedBox(width: 8),
          // Durum metni
          Text(
            state.name,
            style: TextStyle(
              color: _getStateColor(),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          // Yükseklik
          Icon(Icons.height, color: Colors.green, size: 16),
          const SizedBox(width: 4),
          Text(
            '${rocket.position.y.toStringAsFixed(0)}m',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          // Simülasyon hızı
          Icon(Icons.speed, color: Colors.orange, size: 16),
          const SizedBox(width: 4),
          Text(
            '${rocket.simTimeScale.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Roket bilgi başlığı
  Widget _buildRocketInfoHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.rocket_launch, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rocket.rocketName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rocket.manufacturer,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Misyon zamanı
          if (rocket.missionTime > 0) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'T+${rocket.missionTime.toStringAsFixed(1)}s',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Delta-V: ${rocket.deltaV.toStringAsFixed(0)}m/s',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Kütle yardımcı fonksiyonları
  Color _getMassColor() {
    final massRatio = rocket.currentMass / rocket.mass;
    if (massRatio > 0.8) return Colors.green; // Yakıt dolu
    if (massRatio > 0.6) return Colors.yellow; // Orta
    if (massRatio > 0.4) return Colors.orange; // Düşük
    return Colors.red; // Çok düşük
  }

  // Hız yardımcı fonksiyonları - NASA STANDARTLARI
  String _getSpeedSubtitle() {
    final kmh = rocket.speedMps * 3.6;
    
    // LEO Target: 7800 m/s (28,080 km/h)
    if (rocket.speedMps >= 7800) {
      return 'LEO ORBİT! 🚀';
    } else if (rocket.speedMps >= 6240) { // %80 LEO
      return 'LEO\'ya yakın! 🎯';
    } else if (rocket.speedMps >= 3900) { // %50 LEO  
      return 'Hızlanıyor! ⬆️';
    } else if (rocket.speedMps >= 343) { // Mach 1
      return 'Süpersonik! 💨';
    } else if (rocket.speedMps >= 100) {
      return 'Kalkış! ✈️';
    }
    
    // Normal km/h gösterimi
    if (kmh > 10000) {
      return '${(kmh / 1000).toStringAsFixed(1)}K km/h';
    } else if (kmh > 1000) {
      return '${(kmh / 1000).toStringAsFixed(2)}K km/h';
    }
    return '${kmh.toStringAsFixed(0)} km/h';
  }

  // Sıcaklık yardımcı fonksiyonları
  Color _getTemperatureColor() {
    if (rocket.temperatureC > 150) return Colors.red;
    if (rocket.temperatureC > 100) return Colors.orange;
    if (rocket.temperatureC > 50) return Colors.yellow;
    return Colors.blue;
  }

  String _getTemperatureStatus() {
    if (rocket.temperatureC > 150) return 'KRİTİK';
    if (rocket.temperatureC > 100) return 'YÜKSEK';
    if (rocket.temperatureC > 50) return 'NORMAL';
    return 'SOĞUK';
  }

  // Yakıt yardımcı fonksiyonları
  Color _getFuelColor() {
    if (rocket.fuelPercent < 10) return Colors.red;
    if (rocket.fuelPercent < 25) return Colors.orange;
    if (rocket.fuelPercent < 50) return Colors.yellow;
    return Colors.green;
  }

  String _getFuelStatus() {
    if (rocket.fuelPercent < 10) return 'KRİTİK';
    if (rocket.fuelPercent < 25) return 'DÜŞÜK';
    if (rocket.fuelPercent < 50) return 'ORTA';
    return 'DOLU';
  }

  // Hasar yardımcı fonksiyonları
  Color _getDamageColor() {
    if (rocket.damagePercent > 80) return Colors.red;
    if (rocket.damagePercent > 50) return Colors.orange;
    if (rocket.damagePercent > 25) return Colors.yellow;
    return Colors.green;
  }

  String _getDamageStatus() {
    if (rocket.damagePercent > 80) return 'AĞIR';
    if (rocket.damagePercent > 50) return 'ORTA';
    if (rocket.damagePercent > 25) return 'HAFİF';
    return 'İYİ';
  }

  // Durum yardımcı fonksiyonları
  IconData _getStateIcon() {
    switch (state) {
      case RocketState.idle:
        return Icons.pause_circle;
      case RocketState.launch:
        return Icons.rocket_launch;
      case RocketState.cruise:
        return Icons.flight;
      case RocketState.paused:
        return Icons.pause;
    }
  }

  Color _getStateColor() {
    switch (state) {
      case RocketState.idle:
        return Colors.grey;
      case RocketState.launch:
        return Colors.orange;
      case RocketState.cruise:
        return Colors.green;
      case RocketState.paused:
        return Colors.yellow;
    }
  }
}

/// Roket kontrol UI widget'ı
/// MVP spesifikasyonuna uygun kontrol paneli
class RocketControlWidget extends StatefulWidget {
  final RocketPhysicsService physicsService;
  final Function(bool)? onPlayPause;
  final Function(double)? onSpeedChange;
  final Function(CameraMode)? onCameraChange;
  final Function(double)? onThrottleChange;

  const RocketControlWidget({
    super.key,
    required this.physicsService,
    this.onPlayPause,
    this.onSpeedChange,
    this.onCameraChange,
    this.onThrottleChange,
  });

  @override
  State<RocketControlWidget> createState() => _RocketControlWidgetState();
}

class _RocketControlWidgetState extends State<RocketControlWidget> {
  bool _isPlaying = false;
  double _simSpeed = 1.0;
  CameraMode _cameraMode = CameraMode.isometric;
  double _throttle = 0.0;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.physicsService.isRunning;
    _simSpeed = widget.physicsService.rocket.simTimeScale;
    _cameraMode = widget.physicsService.rocket.cameraMode;
    _throttle = widget.physicsService.rocket.throttle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ana kontroller (kompakt)
            Row(
              children: [
                // Play/Pause
                _buildCompactControlButton(
                  icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: _isPlaying ? Colors.orange : Colors.green,
                  onPressed: _togglePlayPause,
                ),
                const SizedBox(width: 8),
                
                // Launch
                _buildCompactControlButton(
                  icon: Icons.rocket_launch,
                  color: Colors.blue,
                  onPressed: widget.physicsService.state == RocketState.idle
                      ? _startLaunch
                      : null,
                ),
                const SizedBox(width: 8),
                
                // Reset
                _buildCompactControlButton(
                  icon: Icons.refresh,
                  color: Colors.red,
                  onPressed: _reset,
                ),
                
                const SizedBox(width: 16),
                
                // Hız slider (inline)
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hız: ${_simSpeed.toStringAsFixed(1)}x',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.orange,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.orange,
                            trackHeight: 2.0,
                          ),
                          child: Slider(
                            value: _simSpeed,
                            min: 0.5,
                            max: 2.0,
                            onChanged: (value) {
                              setState(() => _simSpeed = value);
                              widget.physicsService.setSimulationSpeed(value);
                              widget.onSpeedChange?.call(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactControlButton({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: onPressed != null ? color : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? color : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderControl(
    String label,
    double value,
    double min,
    double max,
    String valueText,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              valueText,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.orange,
            overlayColor: Colors.orange.withOpacity(0.2),
            trackHeight: 4.0,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildCameraDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kamera Modu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CameraMode>(
          value: _cameraMode,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
          ),
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white),
          items: const [
            DropdownMenuItem(
              value: CameraMode.isometric,
              child: Text('İzometrik'),
            ),
            DropdownMenuItem(
              value: CameraMode.follow,
              child: Text('Takip'),
            ),
          ],
          onChanged: (CameraMode? value) {
            if (value != null) {
              setState(() => _cameraMode = value);
              widget.physicsService.setCameraMode(value);
              widget.onCameraChange?.call(value);
            }
          },
        ),
      ],
    );
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    widget.physicsService.togglePlayPause();
    widget.onPlayPause?.call(_isPlaying);
  }

  void _startLaunch() {
    widget.physicsService.startLaunchSequence();
    setState(() {
      _isPlaying = true;
    });
  }

  void _reset() {
    widget.physicsService.reset();
    setState(() {
      _isPlaying = false;
      _throttle = 0.0;
      _simSpeed = 1.0;
    });
  }
}

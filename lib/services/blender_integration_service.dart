import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/asteroid.dart';
import '../models/impactor_2025_scenario.dart';

/// Flutter uygulamasından Blender simülasyonlarına veri aktaran servis
class BlenderIntegrationService {
  static const String _blenderExecutable = 'blender'; // PATH'de olmalı
  static const String _scriptsPath = 'blender_integration/scripts/';
  
  static BlenderIntegrationService? _instance;
  static BlenderIntegrationService get instance => _instance ??= BlenderIntegrationService._();
  
  BlenderIntegrationService._();

  /// Asteroid impact simülasyonu oluştur
  Future<BlenderSimulationResult> createImpactSimulation({
    required Asteroid asteroid,
    required double impactLatitude,
    required double impactLongitude,
    required String outputPath,
    BlenderRenderSettings? renderSettings,
  }) async {
    try {
      print('Starting Blender impact simulation for ${asteroid.name}...');
      
      // Asteroid verilerini NASA formatında hazırla
      final asteroidData = _prepareAsteroidDataForBlender(asteroid);
      
      // Impact koordinatları
      final impactData = {
        'latitude': impactLatitude,
        'longitude': impactLongitude,
        'location_name': _getLocationName(impactLatitude, impactLongitude),
      };
      
      // Simulation parametrelerini JSON dosyasına yaz
      final simulationConfig = {
        'asteroid': asteroidData,
        'impact_coordinates': impactData,
        'render_settings': renderSettings?.toJson() ?? BlenderRenderSettings.defaultSettings().toJson(),
        'output_path': outputPath,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final configPath = await _writeSimulationConfig(simulationConfig);
      
      // Blender script'ini çalıştır
      final result = await _runBlenderSimulation(
        scriptName: 'complete_impact_simulation.py',
        configPath: configPath,
      );
      
      return result;
      
    } catch (e) {
      print('Blender simulation error: $e');
      return BlenderSimulationResult.error(e.toString());
    }
  }

  /// Orbital mechanics visualizasyonu oluştur
  Future<BlenderSimulationResult> createOrbitalVisualization({
    required Asteroid asteroid,
    required DateTime startDate,
    required Duration timespan,
    String? outputPath,
  }) async {
    try {
      print('Creating orbital visualization for ${asteroid.name}...');
      
      // Orbital elements hazırla
      final orbitalData = {
        'asteroid': _prepareAsteroidDataForBlender(asteroid),
        'simulation_start': startDate.toIso8601String(),
        'simulation_duration_days': timespan.inDays,
        'orbital_elements': {
          'semi_major_axis': asteroid.semiMajorAxis,
          'eccentricity': asteroid.eccentricity,
          'inclination': asteroid.inclination,
          'longitude_ascending_node': asteroid.longitudeAscendingNode,
          'argument_periapsis': asteroid.argumentPeriapsis,
          'mean_anomaly': asteroid.meanAnomaly,
        },
      };
      
      final configPath = await _writeSimulationConfig(orbitalData);
      
      final result = await _runBlenderSimulation(
        scriptName: 'orbital_mechanics.py',
        configPath: configPath,
      );
      
      return result;
      
    } catch (e) {
      print('Orbital visualization error: $e');
      return BlenderSimulationResult.error(e.toString());
    }
  }

  /// Deflection scenario simülasyonu
  Future<BlenderSimulationResult> createDeflectionSimulation({
    required Impactor2025Scenario scenario,
    String? outputPath,
  }) async {
    try {
      print('Creating deflection simulation...');
      
      final deflectionData = {
        'scenario': scenario.toJson(),
        'asteroid': _prepareAsteroidDataForBlender(scenario.asteroid),
        'original_impact': {
          'latitude': scenario.impactLatitude,
          'longitude': scenario.impactLongitude,
          'date': scenario.impactDate.toIso8601String(),
        },
        'mitigation_strategy': scenario.appliedStrategy?.toJson(),
        'deflection_results': scenario.results.toJson(),
      };
      
      final configPath = await _writeSimulationConfig(deflectionData);
      
      final result = await _runBlenderSimulation(
        scriptName: 'deflection_simulation.py',
        configPath: configPath,
      );
      
      return result;
      
    } catch (e) {
      print('Deflection simulation error: $e');
      return BlenderSimulationResult.error(e.toString());
    }
  }

  /// Rocket LEO launch simulation
  Future<BlenderSimulationResult> createRocketSimulation({
    required Map<String, dynamic> rocketData,
    required Map<String, dynamic> flightProfile,
    required List<Map<String, dynamic>> telemetryData,
    BlenderRenderSettings? renderSettings,
    String? outputPath,
  }) async {
    try {
      print('Creating Blender rocket simulation...');
      
      // Rocket simulation config
      final rocketConfig = {
        'simulation_type': 'rocket',
        'rocket': rocketData,
        'flight_profile': flightProfile,
        'telemetry': telemetryData,
        'render_settings': renderSettings?.toJson() ?? BlenderRenderSettings.defaultSettings().toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final configPath = await _writeSimulationConfig(rocketConfig);
      
      final result = await _runBlenderSimulation(
        scriptName: 'rocket_simulation.py',
        configPath: configPath,
      );
      
      return result;
      
    } catch (e) {
      print('Rocket simulation error: $e');
      return BlenderSimulationResult.error(e.toString());
    }
  }

  /// Multiple asteroids comparison simulation
  Future<BlenderSimulationResult> createComparisonSimulation({
    required List<Asteroid> asteroids,
    required double impactLatitude,
    required double impactLongitude,
    String? outputPath,
  }) async {
    try {
      print('Creating comparison simulation for ${asteroids.length} asteroids...');
      
      final comparisonData = {
        'asteroids': asteroids.map((a) => _prepareAsteroidDataForBlender(a)).toList(),
        'impact_coordinates': {
          'latitude': impactLatitude,
          'longitude': impactLongitude,
        },
        'comparison_type': 'size_and_energy',
        'layout': 'grid', // Grid layout for multiple impacts
      };
      
      final configPath = await _writeSimulationConfig(comparisonData);
      
      final result = await _runBlenderSimulation(
        scriptName: 'comparison_simulation.py',
        configPath: configPath,
      );
      
      return result;
      
    } catch (e) {
      print('Comparison simulation error: $e');
      return BlenderSimulationResult.error(e.toString());
    }
  }

  /// Blender simülasyon durumunu kontrol et
  Future<BlenderSimulationStatus> checkSimulationStatus(String simulationId) async {
    try {
      final statusFile = File('blender_integration/output/status_$simulationId.json');
      
      if (!await statusFile.exists()) {
        return BlenderSimulationStatus.notFound;
      }
      
      final statusData = jsonDecode(await statusFile.readAsString());
      
      switch (statusData['status']) {
        case 'running':
          return BlenderSimulationStatus.running;
        case 'completed':
          return BlenderSimulationStatus.completed;
        case 'failed':
          return BlenderSimulationStatus.failed;
        default:
          return BlenderSimulationStatus.unknown;
      }
    } catch (e) {
      print('Status check error: $e');
      return BlenderSimulationStatus.unknown;
    }
  }

  /// Render edilen dosyaları al
  Future<List<BlenderOutputFile>> getSimulationOutput(String simulationId) async {
    try {
      final outputDir = Directory('blender_integration/output/$simulationId');
      
      if (!await outputDir.exists()) {
        return [];
      }
      
      final files = <BlenderOutputFile>[];
      
      await for (final entity in outputDir.list()) {
        if (entity is File) {
          final fileName = entity.uri.pathSegments.last;
          final fileType = _getFileType(fileName);
          
          files.add(BlenderOutputFile(
            fileName: fileName,
            filePath: entity.path,
            fileType: fileType,
            fileSize: await entity.length(),
            createdAt: (await entity.stat()).modified,
          ));
        }
      }
      
      // Zaman sırasına göre sırala
      files.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return files;
    } catch (e) {
      print('Get output error: $e');
      return [];
    }
  }

  /// Blender kurulumunu kontrol et
  Future<bool> checkBlenderInstallation() async {
    try {
      final result = await Process.run(_blenderExecutable, ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      print('Blender check failed: $e');
      return false;
    }
  }

  /// Available render engines
  Future<List<String>> getAvailableRenderEngines() async {
    try {
      // Blender'dan render engine listesi al
      final result = await Process.run(_blenderExecutable, [
        '--background',
        '--python-expr',
        'import bpy; print([engine.bl_idname for engine in bpy.types.RenderEngine.__subclasses__()])'
      ]);
      
      if (result.exitCode == 0) {
        // Parse the output to get render engines
        return ['CYCLES', 'BLENDER_EEVEE', 'BLENDER_WORKBENCH'];
      }
      
      return ['CYCLES']; // Default fallback
    } catch (e) {
      print('Get render engines error: $e');
      return ['CYCLES'];
    }
  }

  // Private helper methods
  
  Map<String, dynamic> _prepareAsteroidDataForBlender(Asteroid asteroid) {
    return {
      'id': asteroid.id,
      'name': asteroid.name,
      'full_name': asteroid.fullName,
      'diameter_km': asteroid.diameter,
      'mass_kg': asteroid.mass,
      'density_gcm3': asteroid.density,
      'albedo': asteroid.albedo,
      'absolute_magnitude': asteroid.absoluteMagnitude,
      'spectral_type': asteroid.spectralType,
      'rotation_period_hours': asteroid.rotationPeriod,
      'composition': asteroid.composition,
      'semi_major_axis_au': asteroid.semiMajorAxis,
      'eccentricity': asteroid.eccentricity,
      'inclination_deg': asteroid.inclination,
      'orbital_period_years': asteroid.orbitalPeriod,
      'v_rel_kms': asteroid.closeApproachVelocity,
      'impact_angle_deg': asteroid.impactAngle,
      'is_potentially_hazardous': asteroid.isPotentiallyHazardous,
      'torino_scale': asteroid.torinoScale,
      'palermo_scale': asteroid.palermoScale,
      'data_source': asteroid.dataSource,
    };
  }

  String _getLocationName(double latitude, double longitude) {
    // Basit konum belirleme
    if (latitude > 35 && latitude < 45 && longitude > 25 && longitude < 45) return 'Turkey';
    if (latitude > 40 && latitude < 50 && longitude > -10 && longitude < 10) return 'Europe';
    if (latitude > 25 && latitude < 50 && longitude > -130 && longitude < -65) return 'North America';
    if (latitude.abs() < 10) return 'Equatorial Region';
    if (latitude.abs() > 60) return 'Polar Region';
    return 'Ocean';
  }

  Future<String> _writeSimulationConfig(Map<String, dynamic> config) async {
    final tempDir = await getTemporaryDirectory();
    final configFile = File('${tempDir.path}/blender_simulation_config_${DateTime.now().millisecondsSinceEpoch}.json');
    
    await configFile.writeAsString(jsonEncode(config));
    
    return configFile.path;
  }

  Future<BlenderSimulationResult> _runBlenderSimulation({
    required String scriptName,
    required String configPath,
  }) async {
    final simulationId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Blender argumentları
    final args = [
      '--background', // Headless mode
      '--python', '$_scriptsPath$scriptName',
      '--', // Python script argumentları
      '--config', configPath,
      '--output-id', simulationId,
    ];
    
    print('Running Blender with args: $args');
    
    // Blender process'i başlat
    final process = await Process.start(_blenderExecutable, args);
    
    // Output'u yakala
    final stdout = <String>[];
    final stderr = <String>[];
    
    process.stdout.transform(utf8.decoder).listen((data) {
      stdout.add(data);
      print('Blender stdout: $data');
    });
    
    process.stderr.transform(utf8.decoder).listen((data) {
      stderr.add(data);
      print('Blender stderr: $data');
    });
    
    // Process'in bitmesini bekle
    final exitCode = await process.exitCode;
    
    if (exitCode == 0) {
      return BlenderSimulationResult.success(
        simulationId: simulationId,
        outputPath: 'blender_integration/output/$simulationId',
        stdout: stdout.join('\n'),
      );
    } else {
      return BlenderSimulationResult.error(
        'Blender process failed with exit code $exitCode\n'
        'stderr: ${stderr.join('\n')}'
      );
    }
  }

  BlenderOutputFileType _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'exr':
        return BlenderOutputFileType.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return BlenderOutputFileType.video;
      case 'blend':
        return BlenderOutputFileType.blendFile;
      case 'json':
        return BlenderOutputFileType.data;
      default:
        return BlenderOutputFileType.other;
    }
  }
}

/// Blender render ayarları
class BlenderRenderSettings {
  final String engine; // CYCLES, EEVEE, etc.
  final int resolutionX;
  final int resolutionY;
  final int samples;
  final int frameStart;
  final int frameEnd;
  final double frameRate;
  final String fileFormat; // PNG, EXR, MP4, etc.
  final bool denoising;
  final String outputPath;

  BlenderRenderSettings({
    this.engine = 'CYCLES',
    this.resolutionX = 1920,
    this.resolutionY = 1080,
    this.samples = 128,
    this.frameStart = 1,
    this.frameEnd = 250,
    this.frameRate = 24.0,
    this.fileFormat = 'PNG',
    this.denoising = true,
    this.outputPath = 'blender_integration/output/',
  });

  factory BlenderRenderSettings.defaultSettings() {
    return BlenderRenderSettings();
  }

  factory BlenderRenderSettings.highQuality() {
    return BlenderRenderSettings(
      engine: 'CYCLES',
      resolutionX: 3840,
      resolutionY: 2160,
      samples: 512,
      denoising: true,
      fileFormat: 'EXR',
    );
  }

  factory BlenderRenderSettings.preview() {
    return BlenderRenderSettings(
      engine: 'EEVEE',
      resolutionX: 1280,
      resolutionY: 720,
      samples: 64,
      frameEnd: 120,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'engine': engine,
      'resolution_x': resolutionX,
      'resolution_y': resolutionY,
      'samples': samples,
      'frame_start': frameStart,
      'frame_end': frameEnd,
      'frame_rate': frameRate,
      'file_format': fileFormat,
      'denoising': denoising,
      'output_path': outputPath,
    };
  }
}

/// Blender simülasyon sonucu
class BlenderSimulationResult {
  final bool isSuccess;
  final String? simulationId;
  final String? outputPath;
  final String? errorMessage;
  final String? stdout;

  BlenderSimulationResult.success({
    required this.simulationId,
    required this.outputPath,
    this.stdout,
  }) : isSuccess = true, errorMessage = null;

  BlenderSimulationResult.error(this.errorMessage)
      : isSuccess = false,
        simulationId = null,
        outputPath = null,
        stdout = null;
}

/// Simülasyon durumu
enum BlenderSimulationStatus {
  running,
  completed,
  failed,
  notFound,
  unknown,
}

/// Output file türleri
enum BlenderOutputFileType {
  image,
  video,
  blendFile,
  data,
  other,
}

/// Blender output file
class BlenderOutputFile {
  final String fileName;
  final String filePath;
  final BlenderOutputFileType fileType;
  final int fileSize;
  final DateTime createdAt;

  BlenderOutputFile({
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.createdAt,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  bool get isImage => fileType == BlenderOutputFileType.image;
  bool get isVideo => fileType == BlenderOutputFileType.video;
}

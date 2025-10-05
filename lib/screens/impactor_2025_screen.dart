import 'dart:math';
import 'package:flutter/material.dart';
import 'asteroid_selection_screen.dart';
import '../services/nasa_neo_api_service.dart';
import '../services/nasa_professional_impact_calculator.dart';
import '../services/localization_service.dart';
import '../models/asteroid.dart';

class Impactor2025Screen extends StatefulWidget {
  const Impactor2025Screen({super.key});

  @override
  State<Impactor2025Screen> createState() => _Impactor2025ScreenState();
}

class _Impactor2025ScreenState extends State<Impactor2025Screen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  
  // NASA API Integration
  final NASANeoApiService _neoApiService = NASANeoApiService.instance;
  // List<Asteroid> _todaysAsteroids = []; // Removed unused field
  Asteroid? _selectedAsteroid;
  bool _isLoadingAsteroids = true;
  // String _apiStatus = 'Connecting...'; // Removed unused field
  
  // Professional simulation variables
  bool _isSimulationRunning = false;
  double _simulationProgress = 0.0;
  double _trajectoryDeviation = 0.0;
  // String _selectedStrategy = 'Kinetic Impactor'; // Removed unused field
  double _missionBudget = 2500.0; // Million USD
  int _daysUntilImpact = 847; // Days
  double _impactProbability = 0.89; // 89%
  bool _showAdvancedMetrics = false;
  
  // Orbital parameters
  double _periapsis = 0.98; // AU
  double _apoapsis = 4.23; // AU  
  double _eccentricity = 0.624;
  double _inclination = 12.4; // degrees
  double _orbitalPeriod = 4.34; // years
  
  // Impact calculations - Realistic NASA formulas for Apophis-type asteroid
  double _kineticEnergy = 1.2e15; // Joules (realistic for 370m asteroid)
  double _tntEquivalent = 287; // Megatons (realistic calculation)
  double _craterDiameter = 6.8; // km (using NASA crater scaling laws)
  int _estimatedCasualties = 0; // Will be calculated based on impact location
  double _economicDamage = 0; // Will be calculated based on impact area
  
  // Strategy variables
  List<String> get _availableStrategies {
    final localizations = AppLocalizations.of(context);
    return localizations?.isTurkish == true ? [
      'DART Kinetik Çarpıcı',
      'Çoklu Kinetik Sistem',
      'Nükleer Pulse Propulsion',
      'Ion Beam Deflection',
      'Gravity Tractor'
    ] : [
      'DART Kinetic Impactor',
      'Multi-Kinetic System',
      'Nuclear Pulse Propulsion',
      'Ion Beam Deflection',
      'Gravity Tractor'
    ];
  }
  int _selectedStrategyIndex = 0;
  double _strategySuccessRate = 0.85;
  double _missionCost = 500.0; // Million USD
  int _preparationDays = 450;
  double _deltaVRequired = 0.5; // m/s
  bool _isStrategySelected = false;
  
  // Results variables
  bool _missionSuccessful = false;
  double _deflectionAngle = 0.0;
  double _missDistance = 0.0;
  int _savedLives = 0;
  double _economicSavings = 0.0;
  String _impactScenario = 'Direct Hit';
  
  // Settings variables
  bool _educationMode = true; // Default education mode on
  bool _gameMode = false; // Default game mode off

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    
    // Calculate realistic impact parameters using NASA formulas
    _calculateRealisticImpactParameters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load real NASA asteroid data after dependencies are available
    _loadRealAsteroidData();
  }

  Future<void> _loadRealAsteroidData() async {
    try {
      setState(() {
        _isLoadingAsteroids = true;
        // _apiStatus = 'Connecting to NASA API...';
      });

      // Check API status first
      final bool apiAvailable = await _neoApiService.checkApiStatus();
      
      if (apiAvailable) {
        setState(() {
          // _apiStatus = localizations?.isTurkish == true ? 'API bağlantısı başarılı. Asteroit verileri çekiliyor...' : 'API connection successful. Fetching asteroid data...';
        });
        
        // Get today's asteroids
        final asteroids = await _neoApiService.getTodaysAsteroids();
        
        if (asteroids.isNotEmpty) {
          setState(() {
            // _todaysAsteroids = asteroids;
            _selectedAsteroid = asteroids.first;
            // _apiStatus = localizations?.isTurkish == true ? '${asteroids.length} aktif asteroit yüklendi ✅' : '${asteroids.length} active asteroids loaded ✅';
            _isLoadingAsteroids = false;
          });
          
          // Update UI with real asteroid data
          if (_selectedAsteroid != null) {
            if (_selectedAsteroid != null) {
              _updateWithRealAsteroidData(_selectedAsteroid!);
            }
            print('✅ NASA API Success: ${asteroids.length} asteroids loaded');
            if (_selectedAsteroid != null) {
              print('📡 Selected asteroid: ${_selectedAsteroid!.name}');
            }
          }
        } else {
          throw Exception('No asteroids found for today');
        }
      } else {
        throw Exception('NASA API not available');
      }
    } catch (e) {
      setState(() {
        _isLoadingAsteroids = false;
        // _apiStatus = localizations?.isTurkish == true ? 'API bağlantısı başarısız. Varsayılan veri kullanılıyor.' : 'API connection failed. Using default data.';
      });
      
      print('❌ NASA API Error: $e');
      print('🔄 Using fallback IMPACTOR-2025 scenario');
    }
  }

  void _updateWithRealAsteroidData(Asteroid asteroid) {
    // Update orbital parameters with real data
    setState(() {
      _orbitalPeriod = asteroid.orbitalPeriod / 365.25; // Convert days to years
      _periapsis = (asteroid.distanceFromSun ?? 0) * 0.9; // Approximate
      _apoapsis = (asteroid.distanceFromSun ?? 0) * 1.1; // Approximate
    });
    
    // Recalculate impact parameters with real asteroid data
    _calculateRealisticImpactParametersWithRealData(asteroid);
    
    print('🎯 Updated UI with real asteroid: ${asteroid.name}');
    print('📊 Diameter: ${asteroid.diameter.toStringAsFixed(1)}m');
    print('🚀 Velocity: ${(asteroid.velocity / 1000).toStringAsFixed(1)} km/s');
  }

  void _calculateRealisticImpactParametersWithRealData(Asteroid asteroid) {
    print('🔬 Using NASA Professional Impact Calculator...');
    
    // Use NASA Professional Impact Assessment Calculator
    final professionalAssessment = NASAProfessionalImpactCalculator.calculateImpact(
      asteroidDiameter: asteroid.diameter, // meters
      impactVelocity: asteroid.velocity, // m/s
      asteroidDensity: asteroid.density, // kg/m³
      impactLatitude: 41.0082, // Istanbul latitude
      impactLongitude: 28.9784, // Istanbul longitude
      impactLocation: 'Istanbul',
    );
    
    // Update UI variables with professional calculations
    setState(() {
      _kineticEnergy = professionalAssessment.kineticEnergy;
      _tntEquivalent = professionalAssessment.tntEquivalentMegatons;
      _craterDiameter = professionalAssessment.craterDiameter / 1000; // Convert m to km for UI
      _estimatedCasualties = professionalAssessment.casualtyAssessment.totalCasualties;
      _economicDamage = professionalAssessment.economicImpact.totalCost / 1e9; // Convert to billions
    });
    
    // Professional debugging output
    print('🎯 NASA PROFESSIONAL IMPACT ASSESSMENT:');
    print('📏 Asteroid: ${(asteroid.diameter/1000).toStringAsFixed(3)}km diameter');
    print('🚀 Velocity: ${(asteroid.velocity/1000).toStringAsFixed(1)} km/s');
    print('⚖️ Mass: ${(professionalAssessment.mass/1e12).toStringAsFixed(2)} × 10¹² kg');
    print('⚡ Kinetic Energy: ${(professionalAssessment.kineticEnergy/1e18).toStringAsFixed(2)} × 10¹⁸ J');
    print('💥 TNT Equivalent: ${professionalAssessment.tntEquivalentMegatons.toStringAsFixed(1)} Megatons');
    print('🕳️ Crater Diameter: ${(professionalAssessment.craterDiameter/1000).toStringAsFixed(2)} km');
    print('👥 Total Casualties: ${(professionalAssessment.casualtyAssessment.totalCasualties/1000000).toStringAsFixed(2)}M people');
    print('🏙️ Population Density: ${professionalAssessment.casualtyAssessment.populationDensity.toInt()} people/km²');
    print('📊 Affected Area: ${professionalAssessment.casualtyAssessment.affectedArea.toStringAsFixed(1)} km²');
    print('💰 Economic Impact: \$${(professionalAssessment.economicImpact.totalCost/1e9).toStringAsFixed(1)}B');
    print('🔬 Method: ${professionalAssessment.calculationMethod}');
    
    // Generate professional report for console
    print('📋 PROFESSIONAL REPORT:');
    print(professionalAssessment.generateProfessionalReport());
  }

  void _calculateRealisticImpactParameters() {
    print('🔬 Using NASA Professional Calculator for Initial Values...');
    
    // Use NASA Professional Impact Calculator for IMPACTOR-2025 scenario
    final impactorScenario = NASANeoApiService.instance.getImpactor2025Scenario();
    final professionalAssessment = NASAProfessionalImpactCalculator.calculateImpact(
      asteroidDiameter: impactorScenario.diameter, // 200m
      impactVelocity: impactorScenario.velocity, // 25000 m/s  
      asteroidDensity: impactorScenario.density, // 3200 kg/m³
      impactLatitude: 41.0082, // Istanbul
      impactLongitude: 28.9784,
      impactLocation: 'Istanbul',
    );
    
    // Update UI with professional calculations
    setState(() {
      _kineticEnergy = professionalAssessment.kineticEnergy;
      _tntEquivalent = professionalAssessment.tntEquivalentMegatons;
      _craterDiameter = professionalAssessment.craterDiameter / 1000; // m to km
      _estimatedCasualties = professionalAssessment.casualtyAssessment.totalCasualties;
      _economicDamage = professionalAssessment.economicImpact.totalCost / 1e9; // to billions
    });
    
    print('🎯 NASA PROFESSIONAL INITIAL ASSESSMENT:');
    print('📊 Casualties: ${(professionalAssessment.casualtyAssessment.totalCasualties/1000000).toStringAsFixed(2)}M people');
    print('💰 Economic: \$${(professionalAssessment.economicImpact.totalCost/1e9).toStringAsFixed(1)}B');
    print('🔬 Method: ${professionalAssessment.calculationMethod}');
  }

  // NASA API Test Function
  Future<void> _testNasaApi() async {
    print('🧪 NASA API TEST BAŞLIYOR...');
    
    try {
      setState(() {
        _isLoadingAsteroids = true;
        // _apiStatus = localizations?.isTurkish == true ? 'API test ediliyor...' : 'Testing API...';
      });

      // 1. API Status Check
      print('📡 1. API Status kontrolü...');
      final bool apiAvailable = await _neoApiService.checkApiStatus();
      print('📡 API Status: ${apiAvailable ? "✅ AVAILABLE" : "❌ UNAVAILABLE"}');

      // 2. API Stats Check
      print('📊 2. API Statistics kontrolü...');
      final apiStats = await _neoApiService.getApiStats();
      if (apiStats != null) {
        print('📊 API Stats:');
        print('   - Near Earth Object Count: ${apiStats['near_earth_object_count']}');
        print('   - Links: ${apiStats['links']}');
      } else {
        print('📊 API Stats: ❌ NULL');
      }

      // 3. Today's Asteroids Test
      print('🌍 3. Bugünkü asteroidleri test et...');
      final asteroids = await _neoApiService.getTodaysAsteroids();
      print('🌍 Today\'s Asteroids: ${asteroids.length} adet bulundu');
      
      for (int i = 0; i < asteroids.length && i < 3; i++) {
        final asteroid = asteroids[i];
        print('   [$i] ${asteroid.name}:');
        print('       - Diameter: ${asteroid.diameter.toStringAsFixed(1)}m');
        print('       - Velocity: ${(asteroid.velocity / 1000).toStringAsFixed(1)} km/s');
        print('       - Density: ${asteroid.density} kg/m³');
        print('       - Composition: ${asteroid.composition}');
      }

      // 4. Specific Date Range Test
      print('📅 4. Belirli tarih aralığı test et...');
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final rangeAsteroids = await _neoApiService.getNearEarthObjects(
        startDate: DateTime.now(),
        endDate: tomorrow,
      );
      print('📅 Date Range Asteroids: ${rangeAsteroids.length} adet bulundu');

      // 5. Potentially Hazardous Test
      print('⚠️ 5. Tehlikeli asteroidleri test et...');
      final hazardousAsteroids = await _neoApiService.getPotentiallyHazardousAsteroids(
        page: 0,
        size: 5,
      );
      print('⚠️ Hazardous Asteroids: ${hazardousAsteroids.length} adet bulundu');

      // 6. IMPACTOR-2025 Scenario Test
      print('🎯 6. IMPACTOR-2025 senaryosu test et...');
      final impactorScenario = _neoApiService.getImpactor2025Scenario();
      print('🎯 IMPACTOR-2025:');
      print('   - Name: ${impactorScenario.name}');
      print('   - Diameter: ${impactorScenario.diameter}m');
      print('   - Velocity: ${(impactorScenario.velocity / 1000).toStringAsFixed(1)} km/s');

      // 7. JPL Famous Objects Test
      print('🌟 7. JPL ünlü asteroidleri test et...');
      final famousObjects = _neoApiService.getFamousAsteroids();
      print('🌟 JPL Famous Objects: ${famousObjects.length} adet bulundu');
      for (int i = 0; i < famousObjects.length && i < 3; i++) {
        final famous = famousObjects[i];
        print('   [$i] ${famous.name}:');
        print('       - Diameter: ${(famous.diameter / 1000).toStringAsFixed(2)}km');
        print('       - Velocity: ${(famous.velocity / 1000).toStringAsFixed(1)} km/s');
        print('       - Composition: ${famous.composition}');
      }

      // 8. JPL Hazardous Objects Test  
      print('⚠️ 8. JPL tehlikeli objektleri test et...');
      final jplHazardous = _neoApiService.getJPLHazardousObjects();
      print('⚠️ JPL Hazardous Objects: ${jplHazardous.length} adet bulundu');
      for (int i = 0; i < jplHazardous.length && i < 2; i++) {
        final hazardous = jplHazardous[i];
        print('   [$i] ${hazardous.name}:');
        print('       - Diameter: ${(hazardous.diameter / 1000).toStringAsFixed(2)}km');
        print('       - Velocity: ${(hazardous.velocity / 1000).toStringAsFixed(1)} km/s');
        print('       - Composition: ${hazardous.composition}');
      }

      // Success
      setState(() {
        _isLoadingAsteroids = false;
        // _apiStatus = localizations?.isTurkish == true ? '✅ Test tamamlandı! ${asteroids.length} asteroit aktif' : '✅ Test completed! ${asteroids.length} asteroids active';
        if (asteroids.isNotEmpty) {
          // _todaysAsteroids = asteroids;
          _selectedAsteroid = asteroids.first;
          if (_selectedAsteroid != null) {
            _updateWithRealAsteroidData(_selectedAsteroid!);
          }
        }
      });

      print('✅ NASA API TEST BAŞARILI!');
      
      // Show test results dialog
      _showApiTestResultsDialog(asteroids, apiStats, AppLocalizations.of(context));

    } catch (e) {
      setState(() {
        _isLoadingAsteroids = false;
        // _apiStatus = localizations?.isTurkish == true ? '❌ Test başarısız: ${e.toString()}' : '❌ Test failed: ${e.toString()}';
      });
      
      print('❌ NASA API TEST HATASI: $e');
      
      // Show error dialog
      _showApiErrorDialog(e.toString(), AppLocalizations.of(context));
    }
  }

  void _showApiTestResultsDialog(List<Asteroid> asteroids, Map<String, dynamic>? apiStats, AppLocalizations? localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              localizations?.isTurkish == true ? 'NASA API Test Sonuçları' : 'NASA API Test Results',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // API Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'API Durumu: BAŞARILI',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'API Key: ************P16 ✅\nStatus: ACTIVE\nRate Limit: OK',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Asteroid Data
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.public, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Bulunan Asteroidler: ${asteroids.length} adet',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (asteroids.isNotEmpty) ...[
                      Text(
                        localizations?.isTurkish == true ? 'Aktif Asteroit: ${asteroids.first.name}' : 'Active Asteroid: ${asteroids.first.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        localizations?.isTurkish == true ? 'Çap: ${asteroids.first.diameter.toStringAsFixed(1)}m' : 'Diameter: ${asteroids.first.diameter.toStringAsFixed(1)}m',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        localizations?.isTurkish == true ? 'Hız: ${(asteroids.first.velocity / 1000).toStringAsFixed(1)} km/s' : 'Velocity: ${(asteroids.first.velocity / 1000).toStringAsFixed(1)} km/s',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // API Stats
              if (apiStats != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.purple, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'API İstatistikleri',
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'NEO Count: ${apiStats['near_earth_object_count'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations?.close ?? 'Close', style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Automatically switch to Overview tab and show data
              _tabController.animateTo(0);
              print('🔍 Check detailed logs in console!');
              print('📊 Real data updated in Overview tab!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations?.isTurkish == true ? 'Genel Bakışa Git' : 'Go to Overview'),
          ),
        ],
      ),
    );
  }

  void _showApiErrorDialog(String error, AppLocalizations? localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'API Test Hatası',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Olası sebepler:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• İnternet bağlantısı sorunu\n• API key limiti aşıldı\n• NASA server geçici olarak kapalı\n• CORS policy sorunu (web platformu)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations?.close ?? 'Close', style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadRealAsteroidData(); // Retry
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1426),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1426),
              Color(0xFF1A2642),
              Color(0xFF2A3B5C),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Tab Navigation
              _buildTabNavigation(),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE17055),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'IMPACTOR-2025',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _testNasaApi,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isLoadingAsteroids ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isLoadingAsteroids ? Colors.orange : Colors.green,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.bug_report,
                        color: _isLoadingAsteroids ? Colors.orange : Colors.green,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showSettingsDialog,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  localizations?.isTurkish == true ? 'Impactor-2025: Küresel Tehdit Senaryosu' : 'Impactor-2025: Global Threat Scenario',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _educationMode ? const Color(0xFFE17055) : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            localizations?.education ?? 'Education',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: _educationMode ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          if (_educationMode) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _gameMode ? const Color(0xFF2ECC71) : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videogame_asset,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            localizations?.game ?? 'Game',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: _gameMode ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          if (_gameMode) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    final localizations = AppLocalizations.of(context);
    
    final tabs = [
      {'icon': Icons.dashboard, 'label': localizations?.overview ?? 'Overview'},
      {'icon': Icons.play_arrow, 'label': localizations?.impactorSimulation ?? 'Simulation'},
      {'icon': Icons.security, 'label': localizations?.strategy ?? 'Strategy'},
      {'icon': Icons.bar_chart, 'label': localizations?.results ?? 'Results'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFFE17055) : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      tabs[index]['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.white54,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tabs[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAsteroidProperties() {
    final localizations = AppLocalizations.of(context);
    
    return Column(
      children: [
        // Threat Level & Countdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE74C3C).withOpacity(0.8),
                const Color(0xFFE74C3C).withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE74C3C).withOpacity(0.6),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.warning_amber,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations?.isTurkish == true ? 'YÜKSEK TEHDİT SEVİYESİ' : 'HIGH THREAT LEVEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations?.isTurkish == true ? '$_daysUntilImpact gün kaldı' : '$_daysUntilImpact days left',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        localizations?.isTurkish == true ? 'Çarpma Olasılığı: ${(_impactProbability * 100).toStringAsFixed(1)}%' : 'Impact Probability: ${(_impactProbability * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Enhanced Asteroid Properties
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE17055).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE17055),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localizations?.advancedAsteroidAnalysis ?? '🔴 Advanced Asteroid Analysis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAdvancedMetrics = !_showAdvancedMetrics;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE17055).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _showAdvancedMetrics ? (localizations?.isTurkish == true ? 'Basit' : 'Simple') : (localizations?.isTurkish == true ? 'Gelişmiş' : 'Advanced'),
                        style: const TextStyle(
                          color: Color(0xFFE17055),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Basic Properties
              _buildClickableAsteroidName(localizations?.catalogName ?? 'Catalog Name', '1036 Ganymed A924 UB', Icons.badge),
              _buildEnhancedPropertyRow(localizations?.impactorDiameter ?? 'Diameter', '62.74 km', Icons.straighten),
              _buildEnhancedPropertyRow(localizations?.mass ?? 'Mass', '3.36×10¹¹ kg', Icons.fitness_center),
              _buildEnhancedPropertyRow(localizations?.impactorSpeed ?? 'Speed', '6.3 km/s', Icons.speed),
              _buildEnhancedPropertyRow(localizations?.impactorDensity ?? 'Density', '2.6 g/cm³', Icons.grain),
              _buildEnhancedPropertyRow(localizations?.type ?? 'Type', 'S-type (Stony)', Icons.category),
              
              // Advanced Metrics (Toggleable)
              if (_showAdvancedMetrics) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE17055), height: 1),
                const SizedBox(height: 16),
                const Text(
                  'Gelişmiş Orbital Parametreler',
                  style: TextStyle(
                    color: Color(0xFFE17055),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildEnhancedPropertyRow(localizations?.isTurkish == true ? 'Periapsis' : 'Periapsis', '${_periapsis.toStringAsFixed(3)} AU', Icons.trip_origin),
                _buildEnhancedPropertyRow(localizations?.isTurkish == true ? 'Apoapsis' : 'Apoapsis', '${_apoapsis.toStringAsFixed(3)} AU', Icons.adjust),
                _buildEnhancedPropertyRow(localizations?.isTurkish == true ? 'Eksantriklik' : 'Eccentricity', _eccentricity.toStringAsFixed(3), Icons.lens),
                _buildEnhancedPropertyRow(localizations?.isTurkish == true ? 'Eğim' : 'Inclination', '${_inclination.toStringAsFixed(1)}°', Icons.rotate_left),
                _buildEnhancedPropertyRow(localizations?.isTurkish == true ? 'Orbital Periyot' : 'Orbital Period', '${_orbitalPeriod.toStringAsFixed(2)} ${localizations?.isTurkish == true ? 'yıl' : 'years'}', Icons.sync),
                
                const SizedBox(height: 16),
                Text(
                  localizations?.isTurkish == true ? 'Etki Hesaplamaları' : 'Impact Calculations',
                  style: TextStyle(
                    color: Color(0xFFE17055),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildEnhancedPropertyRow(localizations?.isTurkish == true ? 'Kinetik Enerji' : 'Kinetic Energy', '${(_kineticEnergy / 1e15).toStringAsFixed(1)} PJ', Icons.flash_on),
                _buildEnhancedPropertyRow(localizations?.isTurkish == true ? 'TNT Eşdeğeri' : 'TNT Equivalent', '${_tntEquivalent.toStringAsFixed(1)} Mt', Icons.local_fire_department),
                _buildEnhancedPropertyRow(localizations?.isTurkish == true ? 'Krater Çapı' : 'Crater Diameter', '${_craterDiameter.toStringAsFixed(1)} km', Icons.radio_button_unchecked),
                _buildEnhancedPropertyRow(localizations?.isTurkish == true ? 'Tahmini Kayıp' : 'Estimated Loss', '${(_estimatedCasualties / 1000000).toStringAsFixed(1)}M ${localizations?.isTurkish == true ? 'kişi' : 'people'}', Icons.people),
                _buildEnhancedPropertyRow(localizations?.isTurkish == true ? 'Ekonomik Hasar' : 'Economic Damage', '\$${_economicDamage.toStringAsFixed(1)}B', Icons.trending_down),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClickableAsteroidName(String label, String value, IconData icon) {
    final localizations = AppLocalizations.of(context);
    // Gerçek asteroid verilerini göster
    String displayName = value;
    String statusText = localizations?.isTurkish == true ? 'Varsayılan' : 'Default';
    Color statusColor = Colors.orange;
    
    if (_selectedAsteroid != null) {
      if (_selectedAsteroid != null) {
        displayName = _selectedAsteroid!.name;
      }
      statusText = 'NASA API';
      statusColor = Colors.green;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white54,
            size: 16,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          _showAsteroidSelectionDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE17055).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE17055).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Color(0xFFE17055),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.edit,
                                color: Color(0xFFE17055),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPropertyRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white54,
            size: 16,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactInformation() {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9B59B6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                localizations?.impactInformation ?? 'Impact Information',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPropertyRow(localizations?.isTurkish == true ? 'Konum' : 'Location', 'Istanbul, Turkey'),
          _buildPropertyRow(localizations?.isTurkish == true ? 'Enlem' : 'Latitude', '41.0082°'),
          _buildPropertyRow(localizations?.isTurkish == true ? 'Boylam' : 'Longitude', '28.9784°'),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // Overview
        return Column(
          children: [
            _buildAsteroidProperties(),
            const SizedBox(height: 16),
            _buildImpactInformation(),
          ],
        );
      case 1: // Simulation
        return _buildSimulationTab();
      case 2: // Strategy
        return _buildStrategyTab();
      case 3: // Results
        return _buildResultsTab();
      default:
        return _buildAsteroidProperties();
    }
  }

  Widget _buildSimulationTab() {
    final localizations = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Professional Mission Control Center - Mobile Optimized
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A365D),
                  const Color(0xFF2B77AD),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.shade300,
                            Colors.blue.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isSimulationRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isSimulationRunning ? (localizations?.simulationRunning ?? 'SIMULATION ACTIVE') : (localizations?.simulationProgress ?? 'SIMULATION STANDBY'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isSimulationRunning ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isSimulationRunning ? Colors.green : Colors.orange,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _isSimulationRunning ? Colors.green : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isSimulationRunning ? 'ÇALIŞIYOR' : 'HAZIR',
                                  style: TextStyle(
                                    color: _isSimulationRunning ? Colors.green : Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'İLERLEME',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_simulationProgress * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Compact Progress Bar
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _simulationProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.cyan.shade300],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.5),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Professional 3D Orbital Visualization Suite - Mobile Optimized
          Container(
            height: 200, // Reduced from 320 to 200
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A365D).withOpacity(0.8),
                  const Color(0xFF2C5282).withOpacity(0.6),
                  const Color(0xFF3182CE).withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(16), // Reduced corner radius
              border: Border.all(color: Colors.blue.withOpacity(0.4), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10, // Reduced shadow
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Compact Header
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Colors.cyan.shade300, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.satellite_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'ORBITAL TRACKING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Compact Control Buttons
                    Row(
                      children: [
                        _buildCompactOrbitalButton('2D', _isSimulationRunning),
                        const SizedBox(width: 4),
                        _buildCompactOrbitalButton('3D', !_isSimulationRunning),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Compact Visualization Container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0D1117),
                          Color(0xFF161B22),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Space visualization
                        Positioned.fill(
                          child: CustomPaint(
                            painter: OrbitVisualizationPainter(_simulationProgress),
                          ),
                        ),
                        
                        // Compact center display
                        const Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.public, color: Colors.blue, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  'TRACKING ACTIVE',
                                  style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Compact bottom info
                        Positioned(
                          bottom: 6,
                          left: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'T-847d',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '89.3%',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        
        // Advanced Simulation Controls
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations?.isTurkish == true ? 'Gelişmiş Simülasyon Kontrolleri' : 'Advanced Simulation Controls',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Simulation Parameters
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildParameterSlider(localizations?.isTurkish == true ? 'Zaman Hızlandırma' : 'Time Acceleration', 1.0, 100.0, 25.0),
                    _buildParameterSlider(localizations?.isTurkish == true ? 'Yörünge Sapma' : 'Orbital Deviation', -5.0, 5.0, _trajectoryDeviation),
                    _buildParameterSlider(localizations?.isTurkish == true ? 'Kesinlik Seviyesi' : 'Precision Level', 1.0, 10.0, 7.0),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Enhanced Control Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSimulationRunning = !_isSimulationRunning;
                          if (_isSimulationRunning) {
                            _startSimulation();
                          }
                        });
                      },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2ECC71),
                              const Color(0xFF27AE60),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2ECC71).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSimulationRunning ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isSimulationRunning 
                                ? (localizations?.isTurkish == true ? 'DURDUR' : 'STOP')
                                : (localizations?.isTurkish == true ? 'BAŞLAT' : 'START'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations?.isTurkish == true ? 'Dinamik Simülasyon' : 'Dynamic Simulation',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 4,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.yellow, Colors.orange],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSimulationRunning = false;
                          _simulationProgress = 0.0;
                          _trajectoryDeviation = 0.0;
                        });
                      },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE74C3C),
                              const Color(0xFFC0392B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE74C3C).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh, color: Colors.white, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              localizations?.isTurkish == true ? 'SIFIRLA' : 'RESET',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations?.isTurkish == true ? 'Yeniden Başlat' : 'Restart',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Real-time Metrics
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed, color: Colors.cyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    localizations?.isTurkish == true ? 'Gerçek Zamanlı Metrikler' : 'Real-time Metrics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isSimulationRunning ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(localizations?.isTurkish == true ? 'Mevcut Hız' : 'Current Velocity', '6.34 km/s', Icons.speed, Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(localizations?.isTurkish == true ? 'Mesafe' : 'Distance', '2.4 AU', Icons.straighten, Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(localizations?.isTurkish == true ? 'Sapma' : 'Deviation', '${_trajectoryDeviation.toStringAsFixed(2)}°', Icons.rotate_left, Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(localizations?.isTurkish == true ? 'Güvenilirlik' : 'Reliability', '97.3%', Icons.verified, Colors.purple),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ); // SingleChildScrollView kapanış parantezi
  } // _buildSimulationTab kapanış parantezi

  Widget _buildParameterSlider(String label, double min, double max, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.blue.withOpacity(0.3),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: (newValue) {
                setState(() {
                  // Update corresponding parameter
                });
              },
            ),
          ),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _startSimulation() async {
    for (int i = 0; i <= 100; i++) {
      if (!_isSimulationRunning) break;
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _simulationProgress = i / 100.0;
        _trajectoryDeviation = (i / 100.0) * 2.5 - 1.25; // -1.25 to 1.25
      });
    }
    if (_isSimulationRunning) {
      setState(() {
        _isSimulationRunning = false;
      });
    }
  }

  Widget _buildStrategyTab() {
    final localizations = AppLocalizations.of(context);
    
    return Column(
      children: [
        // Mission Command Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE17055).withOpacity(0.8),
                const Color(0xFFE17055).withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE17055).withOpacity(0.6), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MISSION COMMAND CENTER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations?.isTurkish == true 
                          ? 'Bütçe: \$${_missionBudget.toStringAsFixed(0)}M | $_preparationDays gün'
                          : 'Budget: \$${_missionBudget.toStringAsFixed(0)}M | $_preparationDays days',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isStrategySelected ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isStrategySelected ? 'SEÇİLDİ' : 'BEKLİYOR',
                  style: TextStyle(
                    color: _isStrategySelected ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Strategy Selection
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE17055).withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations?.isTurkish == true ? 'NASA Onaylı Saptırma Stratejileri' : 'NASA Approved Deflection Strategies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_availableStrategies.length, (index) {
                final strategy = _availableStrategies[index];
                final isSelected = _selectedStrategyIndex == index;
                return _buildStrategyCard(strategy, index, isSelected);
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selected Strategy Details
        if (_isStrategySelected) _buildSelectedStrategyDetails(),
        const SizedBox(height: 16),

        // Professional Mission Parameters
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations?.isTurkish == true ? 'Misyon Parametreleri' : 'Mission Parameters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildParameterCard(localizations?.isTurkish == true ? 'Başarı Oranı' : 'Success Rate', '${(_strategySuccessRate * 100).toInt()}%', Icons.verified, Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildParameterCard(localizations?.isTurkish == true ? 'Maliyet' : 'Cost', '\$${_missionCost.toInt()}M', Icons.attach_money, Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildParameterCard('Delta-V', '${_deltaVRequired.toStringAsFixed(2)} m/s', Icons.speed, Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildParameterCard(
                      localizations?.isTurkish == true ? 'Hazırlık' : 'Preparation', 
                      localizations?.isTurkish == true ? '$_preparationDays gün' : '$_preparationDays days', 
                      Icons.schedule, 
                      Colors.cyan
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Risk Assessment Matrix
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assessment, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    localizations?.isTurkish == true ? 'Risk Değerlendirme Matrisi' : 'Risk Assessment Matrix',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRiskMatrix(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Execute Mission Button
        Center(
          child: GestureDetector(
            onTap: _isStrategySelected ? _executeMission : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: _isStrategySelected 
                    ? LinearGradient(colors: [Colors.green, Colors.green.shade700])
                    : LinearGradient(colors: [Colors.grey, Colors.grey.shade700]),
                borderRadius: BorderRadius.circular(25),
                boxShadow: _isStrategySelected ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.launch, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isStrategySelected 
                        ? (localizations?.isTurkish == true ? 'MİSYONU BAŞLAT' : 'START MISSION')
                        : (localizations?.isTurkish == true ? 'STRATEJİ SEÇ' : 'SELECT STRATEGY'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStrategyCard(String strategy, int index, bool isSelected) {
    final localizations = AppLocalizations.of(context);
    final strategies = {
      'DART Kinetik Çarpıcı': {
        'description': localizations?.isTurkish == true ? 'NASA DART benzeri teknoloji. 500kg uzay aracı ile 6.14 km/s hızında çarpışma.' : 'NASA DART-like technology. 500kg spacecraft collision at 6.14 km/s speed.',
        'cost': 330.0,
        'success': 85,
        'time': 450,
        'deltaV': 0.5,
        'icon': Icons.rocket_launch,
        'color': Colors.blue,
      },
      'Çoklu Kinetik Sistem': {
        'description': localizations?.isTurkish == true ? 'ESA-NASA ortaklığı. 3 adet koordineli çarpıcı sistemi. AIDA misyonuna benzer.' : 'ESA-NASA partnership. 3 coordinated impactor systems. Similar to AIDA mission.',
        'cost': 950.0,
        'success': 92,
        'time': 620,
        'deltaV': 1.2,
        'icon': Icons.multiple_stop,
        'color': Colors.purple,
      },
      'Nükleer Pulse Propulsion': {
        'description': localizations?.isTurkish == true ? 'Brookhaven Lab tasarımı. Standby nuclear explosive device (SNED) teknolojisi.' : 'Brookhaven Lab design. Standby nuclear explosive device (SNED) technology.',
        'cost': 2100.0,
        'success': 96,
        'time': 720,
        'deltaV': 5.0,
        'icon': Icons.flash_on,
        'color': Colors.red,
      },
      'Ion Beam Deflection': {
        'description': localizations?.isTurkish == true ? 'MIT-Caltech konsepti. Yüksek enerjili ion beam ile yüzey ablasyonu.' : 'MIT-Caltech concept. Surface ablation with high-energy ion beam.',
        'cost': 1400.0,
        'success': 78,
        'time': 890,
        'deltaV': 0.8,
        'icon': Icons.radio_button_unchecked,
        'color': Colors.cyan,
      },
      'Gravity Tractor': {
        'description': localizations?.isTurkish == true ? 'JPL slow-push teknolojisi. Uzun süreli yerçekimsel saptırma.' : 'JPL slow-push technology. Long-term gravitational deflection.',
        'cost': 800.0,
        'success': 65,
        'time': 1200,
        'deltaV': 0.1,
        'icon': Icons.grain,
        'color': Colors.amber,
      },
    };

    final data = strategies[strategy];
    if (data == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? (data['color'] as Color).withOpacity(0.2) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? (data['color'] as Color) : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (data['color'] as Color).withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              data['icon'] as IconData,
              color: data['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy,
                  style: TextStyle(
                    color: isSelected ? data['color'] as Color : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['description'] as String,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${(data['cost'] as double).toInt()}M',
                      style: TextStyle(
                        color: data['color'] as Color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${data['success']}%',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedStrategyIndex = index;
                _isStrategySelected = true;
                _missionCost = data['cost'] as double;
                _strategySuccessRate = (data['success'] as int) / 100.0;
                _preparationDays = data['time'] as int;
                _deltaVRequired = data['deltaV'] as double;
              });
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected ? data['color'] as Color : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: data['color'] as Color,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedStrategyDetails() {
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.2),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                localizations?.isTurkish == true ? 'Seçili Strateji: ${_availableStrategies[_selectedStrategyIndex]}' : 'Selected Strategy: ${_availableStrategies[_selectedStrategyIndex]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teknik Spesifikasyonlar:',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSpecRow(
                      localizations?.isTurkish == true ? 'Fırlatma Penceresi' : 'Launch Window', 
                      localizations?.isTurkish == true ? '45 gün' : '45 days'
                    ),
                    _buildSpecRow(
                      localizations?.isTurkish == true ? 'Seyir Süresi' : 'Cruise Duration', 
                      localizations?.isTurkish == true ? '${(_preparationDays / 30).toStringAsFixed(1)} ay' : '${(_preparationDays / 30).toStringAsFixed(1)} months'
                    ),
                    _buildSpecRow(localizations?.isTurkish == true ? 'Yakıt Gereksinimi' : 'Fuel Requirement', '${(_deltaVRequired * 1000).toInt()} kg'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performans Metrikleri:',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSpecRow(localizations?.isTurkish == true ? 'Sapma Açısı' : 'Deflection Angle', '${(_deltaVRequired * 100).toStringAsFixed(1)} mrad'),
                    _buildSpecRow(localizations?.isTurkish == true ? 'Etki Süresi' : 'Impact Duration', '${(_deltaVRequired * 10).toStringAsFixed(1)} ${localizations?.isTurkish == true ? 'saat' : 'hours'}'),
                    _buildSpecRow(localizations?.isTurkish == true ? 'Güvenlik Marjı' : 'Safety Margin', '${((_strategySuccessRate - 0.1) * 100).toInt()}%'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskMatrix() {
    final localizations = AppLocalizations.of(context);
    final risks = [
      {'name': localizations?.isTurkish == true ? 'Teknik Risk' : 'Technical Risk', 'level': localizations?.isTurkish == true ? 'ORTA' : 'MEDIUM', 'color': Colors.orange, 'value': 0.3},
      {'name': localizations?.isTurkish == true ? 'Zaman Risk' : 'Time Risk', 'level': localizations?.isTurkish == true ? 'YÜKSEK' : 'HIGH', 'color': Colors.red, 'value': 0.7},
      {'name': localizations?.isTurkish == true ? 'Bütçe Risk' : 'Budget Risk', 'level': localizations?.isTurkish == true ? 'DÜŞÜK' : 'LOW', 'color': Colors.green, 'value': 0.2},
      {'name': localizations?.isTurkish == true ? 'Politik Risk' : 'Political Risk', 'level': localizations?.isTurkish == true ? 'ORTA' : 'MEDIUM', 'color': Colors.orange, 'value': 0.4},
    ];

    return Column(
      children: risks.map((risk) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  risk['name'] as String,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: risk['value'] as double,
                    child: Container(
                      decoration: BoxDecoration(
                        color: risk['color'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (risk['color'] as Color).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  risk['level'] as String,
                  style: TextStyle(
                    color: risk['color'] as Color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _executeMission() {
    setState(() {
      _missionSuccessful = _strategySuccessRate > 0.8;
      _deflectionAngle = _missionSuccessful ? _deltaVRequired * 0.5 : 0.0;
      _missDistance = _missionSuccessful ? 150000.0 : 0.0; // km
      _savedLives = _missionSuccessful ? _estimatedCasualties : 0;
      _economicSavings = _missionSuccessful ? _economicDamage * 0.95 : 0.0;
      _impactScenario = _missionSuccessful ? 'Successful Deflection' : 'Mission Failed';
    });
    
    // Show mission result dialog
    _showMissionResultDialog();
  }

  void _showMissionResultDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        title: Row(
          children: [
            Icon(
              _missionSuccessful ? Icons.check_circle : Icons.error,
              color: _missionSuccessful ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              _missionSuccessful ? (localizations?.isTurkish == true ? 'MİSYON BAŞARILI!' : 'MISSION SUCCESSFUL!') : (localizations?.isTurkish == true ? 'MİSYON BAŞARISIZ!' : 'MISSION FAILED!'),
              style: TextStyle(
                color: _missionSuccessful ? Colors.green : Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _missionSuccessful 
                  ? (localizations?.isTurkish == true ? 'Asteroit başarıyla saptırıldı! Dünya güvende.' : 'Asteroid successfully deflected! Earth is safe.')
                  : (localizations?.isTurkish == true ? 'Saptırma başarısız. Acil tahliye planları devreye alınmalı.' : 'Deflection failed. Emergency evacuation plans must be activated.'),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (_missionSuccessful) ...[
              Text(localizations?.isTurkish == true ? 'Sapma Mesafesi: ${_missDistance.toStringAsFixed(0)} km' : 'Miss Distance: ${_missDistance.toStringAsFixed(0)} km', 
                   style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(localizations?.isTurkish == true ? 'Kurtarılan Can: ${(_savedLives / 1000000).toStringAsFixed(1)}M' : 'Lives Saved: ${(_savedLives / 1000000).toStringAsFixed(1)}M', 
                   style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(3); // Switch to Results tab
            },
            child: Text(localizations?.isTurkish == true ? 'Sonuçları Gör' : 'View Results', style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    final localizations = AppLocalizations.of(context);
    return Column(
      children: [
        // Mission Status Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _missionSuccessful 
                    ? Colors.green.withOpacity(0.8) 
                    : const Color(0xFFE74C3C).withOpacity(0.8),
                _missionSuccessful 
                    ? Colors.green.withOpacity(0.4) 
                    : const Color(0xFFE74C3C).withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _missionSuccessful 
                  ? Colors.green.withOpacity(0.6) 
                  : const Color(0xFFE74C3C).withOpacity(0.6), 
              width: 2
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _missionSuccessful ? Icons.check_circle_outline : Icons.error_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _missionSuccessful 
                        ? (localizations?.isTurkish == true ? 'MİSYON BAŞARILI' : 'MISSION SUCCESSFUL')
                        : (localizations?.isTurkish == true ? 'MİSYON BAŞARISIZ' : 'MISSION FAILED'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _missionSuccessful 
                          ? (localizations?.isTurkish == true ? 'Asteroit başarıyla saptırıldı!' : 'Asteroid successfully deflected!')
                          : (localizations?.isTurkish == true ? 'Acil tahliye planları devreye alınmalı' : 'Emergency evacuation plans must be activated'),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _impactScenario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Professional Results Dashboard
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    localizations?.isTurkish == true ? 'Profesyonel Misyon Analizi' : 'Professional Mission Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'REAL-TIME',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Key Performance Indicators
              Row(
                children: [
                  Expanded(
                    child: _buildResultCard(
                      localizations?.isTurkish == true ? 'Sapma Mesafesi' : 'Miss Distance', 
                      _missionSuccessful ? '${_missDistance.toStringAsFixed(0)} km' : '0 km',
                      Icons.straighten, 
                      _missionSuccessful ? Colors.green : const Color(0xFFE74C3C)
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildResultCard(
                      localizations?.isTurkish == true ? 'Kurtarılan Can' : 'Lives Saved', 
                      _missionSuccessful ? '${(_savedLives / 1000000).toStringAsFixed(1)}M' : '0',
                      Icons.people, 
                      _missionSuccessful ? Colors.blue : Colors.grey
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildResultCard(
                      localizations?.isTurkish == true ? 'Ekonomik Tasarruf' : 'Economic Savings', 
                      _missionSuccessful ? '\$${_economicSavings.toStringAsFixed(1)}B' : '\$0.0B',
                      Icons.savings, 
                      _missionSuccessful ? Colors.orange : Colors.grey
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildResultCard(
                      localizations?.isTurkish == true ? 'Misyon Maliyeti' : 'Mission Cost', 
                      _isStrategySelected ? '\$${_missionCost.toStringAsFixed(0)}M' : '\$0M',
                      Icons.account_balance_wallet, 
                      _isStrategySelected ? const Color(0xFF9B59B6) : Colors.grey
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Detailed Scientific Analysis
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.science, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    localizations?.isTurkish == true ? 'Bilimsel Etki Değerlendirmesi' : 'Scientific Impact Assessment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_missionSuccessful) ...[
                _buildScientificMetric(localizations?.isTurkish == true ? 'Sapma Açısı' : 'Deflection Angle', '${(_deflectionAngle * 1000).toStringAsFixed(1)} mrad', Icons.rotate_right),
                _buildScientificMetric(localizations?.isTurkish == true ? 'Delta-V Uygulanmış' : 'Delta-V Applied', '${_deltaVRequired.toStringAsFixed(2)} m/s', Icons.speed),
                _buildScientificMetric(localizations?.isTurkish == true ? 'Yörünge Değişimi' : 'Orbital Change', '${(_deflectionAngle * 180 / 3.14159).toStringAsFixed(3)}°', Icons.track_changes),
                _buildScientificMetric(localizations?.isTurkish == true ? 'Çarpma Olasılığı' : 'Impact Probability', '< 0.001%', Icons.shield),
              ] else ...[
                _buildScientificMetric(localizations?.isTurkish == true ? 'Krater Çapı (Tahmini)' : 'Estimated Crater Diameter', '${_craterDiameter} km', Icons.radio_button_unchecked),
                _buildScientificMetric(localizations?.isTurkish == true ? 'Sismik Şiddet' : 'Seismic Intensity', '8.2 Richter', Icons.vibration),
                _buildScientificMetric(localizations?.isTurkish == true ? 'Atmosferik Etki' : 'Atmospheric Impact', localizations?.isTurkish == true ? 'Küresel Kış Riski' : 'Global Winter Risk', Icons.cloud),
                _buildScientificMetric(localizations?.isTurkish == true ? 'Tsunami Yüksekliği' : 'Tsunami Height', '45-120 m', Icons.waves),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Comparative Analysis
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.compare_arrows, color: Colors.cyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    localizations?.isTurkish == true ? 'Karşılaştırmalı Analiz' : 'Comparative Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildComparisonBar(localizations?.isTurkish == true ? 'Başarı Oranı' : 'Success Rate', _strategySuccessRate, Colors.green),
              _buildComparisonBar(localizations?.isTurkish == true ? 'Maliyet Verimliliği' : 'Cost Efficiency', _missionSuccessful ? 0.9 : 0.0, Colors.orange),
              _buildComparisonBar(localizations?.isTurkish == true ? 'Teknik Zorluk' : 'Technical Difficulty', 0.7, Colors.red),
              _buildComparisonBar(localizations?.isTurkish == true ? 'Zaman Faktörü' : 'Time Factor', (_preparationDays / 1000.0), Colors.blue),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Strategy Performance Report
        if (_isStrategySelected) Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _missionSuccessful ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                _missionSuccessful ? Colors.green.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _missionSuccessful ? Colors.green.withOpacity(0.4) : Colors.orange.withOpacity(0.4), 
              width: 1
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in, 
                    color: _missionSuccessful ? Colors.green : Colors.orange, 
                    size: 24
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations?.isTurkish == true ? 'Strateji Performans Raporu' : 'Strategy Performance Report',
                    style: TextStyle(
                      color: _missionSuccessful ? Colors.green : Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildStrategyReport(localizations?.isTurkish == true ? 'Uygulanan Strateji' : 'Applied Strategy', _availableStrategies[_selectedStrategyIndex]),
              _buildStrategyReport(localizations?.isTurkish == true ? 'Görev Süresi' : 'Mission Duration', localizations?.isTurkish == true ? '${_preparationDays} gün' : '${_preparationDays} days'),
              _buildStrategyReport(localizations?.isTurkish == true ? 'Toplam Bütçe' : 'Total Budget', '\$${_missionCost.toStringAsFixed(0)}M'),
              _buildStrategyReport(localizations?.isTurkish == true ? 'ROI (Yatırım Getirisi)' : 'ROI (Return on Investment)', 
                _missionSuccessful ? '${((_economicSavings / (_missionCost / 1000.0)) * 100).toStringAsFixed(0)}x' : '0x'),
              
              if (_missionSuccessful) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localizations?.isTurkish == true ? 'Dünya Korundu! Bu misyon insanlık tarihinin en büyük başarılarından biri olarak tarihe geçecek.' : 'Earth Protected! This mission will go down in history as one of humanity\'s greatest achievements.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Historical Context & Lessons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_edu, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    localizations?.isTurkish == true ? 'Tarihsel Bağlam & Dersler' : 'Historical Context & Lessons',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildHistoricalNote(
                localizations?.isTurkish == true ? '🌍 Tunguska Olayı (1908)' : '🌍 Tunguska Event (1908)', 
                localizations?.isTurkish == true ? '60 m çapında asteroid, Sibirya\'da 2000 km² ormanı yok etti.' : '60 m diameter asteroid destroyed 2000 km² of forest in Siberia.'
              ),
              _buildHistoricalNote(
                localizations?.isTurkish == true ? '🦕 K-T Sınır Olayı (66 MY)' : '🦕 K-T Boundary Event (66 MY)', 
                localizations?.isTurkish == true ? '10 km asteroid dinozorların sonu oldu. Global bir kış yaşandı.' : '10 km asteroid ended the dinosaurs. A global winter occurred.'
              ),
              _buildHistoricalNote(
                localizations?.isTurkish == true ? '🚀 NASA DART Misyonu (2022)' : '🚀 NASA DART Mission (2022)', 
                localizations?.isTurkish == true ? 'İlk başarılı asteroid saptırma deneyi. Dimorphos\'u hedefledi.' : 'First successful asteroid deflection experiment. Targeted Dimorphos.'
              ),
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  localizations?.isTurkish == true ? '💡 Gelecek İçin: Bu simülasyon, gerçek bir tehdit durumunda alınması gereken karmaşık kararları ve uluslararası işbirliğinin önemini göstermektedir.' : '💡 For the Future: This simulation demonstrates the complex decisions and the importance of international cooperation required in a real threat situation.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificMetric(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple.withOpacity(0.7), size: 16),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: value,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyReport(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalNote(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showAsteroidSelectionDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE17055),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.explore,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              localizations?.isTurkish == true ? 'Asteroit Seçimi' : 'Asteroid Selection',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mevcut asteroit bilgisi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE17055).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE17055).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Color(0xFFE17055), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Şu anki asteroit:',
                        style: TextStyle(
                          color: Color(0xFFE17055),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1036 Ganymed A924 UB\n62.74 km çap, 6.3 km/s hız',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Seçenekler
            const Text(
              'Yeni asteroit seçmek istiyorsunuz?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // AsteroidSelectionScreen'e navigate et
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AsteroidSelectionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE17055),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Asteroit Seç',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE17055),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              localizations?.isTurkish == true ? 'Uygulama Ayarları' : 'Application Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Education Mode Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _educationMode ? const Color(0xFFE17055).withOpacity(0.1) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _educationMode ? const Color(0xFFE17055).withOpacity(0.3) : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _educationMode ? const Color(0xFFE17055) : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.isTurkish == true ? 'Eğitim Modu' : 'Education Mode',
                          style: TextStyle(
                            color: _educationMode ? const Color(0xFFE17055) : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations?.isTurkish == true ? 'Açıklamalı öğrenme deneyimi' : 'Educational learning experience',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _educationMode,
                    onChanged: (value) {
                      setState(() {
                        _educationMode = value;
                      });
                    },
                    activeColor: const Color(0xFFE17055),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Game Mode Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _gameMode ? const Color(0xFF2ECC71).withOpacity(0.1) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _gameMode ? const Color(0xFF2ECC71).withOpacity(0.3) : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _gameMode ? const Color(0xFF2ECC71) : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.videogame_asset,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.isTurkish == true ? 'Oyun Modu' : 'Game Mode',
                          style: TextStyle(
                            color: _gameMode ? const Color(0xFF2ECC71) : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations?.isTurkish == true ? 'Etkileşimli oyun deneyimi' : 'Interactive game experience',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _gameMode,
                    onChanged: (value) {
                      setState(() {
                        _gameMode = value;
                      });
                    },
                    activeColor: const Color(0xFF2ECC71),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Active Modes Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _educationMode && _gameMode 
                          ? (localizations?.isTurkish == true ? 'Hem eğitim hem oyun modu aktif' : 'Both education and game mode active')
                          : _educationMode 
                              ? (localizations?.isTurkish == true ? 'Eğitim modu aktif' : 'Education mode active')
                              : _gameMode 
                                  ? (localizations?.isTurkish == true ? 'Oyun modu aktif' : 'Game mode active')
                                  : (localizations?.isTurkish == true ? 'Hiçbir mod aktif değil' : 'No mode active'),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations?.isTurkish == true ? 'Kapat' : 'Close',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Update header badges to reflect current modes
              setState(() {
                // Force rebuild to show updated mode badges
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE17055),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              localizations?.isTurkish == true ? 'Kaydet' : 'Save',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Professional visualization helper methods - Mobile optimized compact button
  Widget _buildCompactOrbitalButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? Colors.cyan.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? Colors.cyan : Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.cyan : Colors.white70,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Removed unused functions: _buildOrbitalControlButton, _buildTechnicalData, _buildStatusIndicator
}

// Professional Orbital Visualization Painter
class OrbitVisualizationPainter extends CustomPainter {
  final double animationProgress;
  
  OrbitVisualizationPainter(this.animationProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke;
    
    // Draw Earth orbit (reference)
    paint.color = Colors.blue.withOpacity(0.3);
    paint.strokeWidth = 1;
    canvas.drawCircle(center, size.width * 0.15, paint);
    
    // Draw asteroid orbit (elliptical)
    paint.color = Colors.orange.withOpacity(0.6);
    paint.strokeWidth = 2;
    final rect = Rect.fromCenter(
      center: center, 
      width: size.width * 0.6, 
      height: size.width * 0.4
    );
    canvas.drawOval(rect, paint);
    
    // Draw asteroid position (animated)
    final angle = animationProgress * 2 * 3.14159;
    final asteroidX = center.dx + (size.width * 0.3) * cos(angle);
    final asteroidY = center.dy + (size.width * 0.2) * sin(angle);
    
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(asteroidX, asteroidY), 4, paint);
    
    // Draw trajectory line to Earth
    if (animationProgress > 0.7) {
      paint.color = Colors.red.withOpacity(0.8);
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(asteroidX, asteroidY), center, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

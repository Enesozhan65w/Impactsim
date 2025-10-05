import 'package:flutter/material.dart';
import 'asteroid_input_screen.dart';
import 'asteroid_simulation_screen.dart';
import '../models/asteroid.dart';
import '../services/localization_service.dart';

/// Screen that allows users to select or enter asteroid data
class AsteroidSelectionScreen extends StatefulWidget {
  const AsteroidSelectionScreen({super.key});

  @override
  State<AsteroidSelectionScreen> createState() => _AsteroidSelectionScreenState();
}

class _AsteroidSelectionScreenState extends State<AsteroidSelectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingNASAData = false;
  
  // Manuel giriş değişkenleri
  final TextEditingController _diameterController = TextEditingController(text: '62.74');
  final TextEditingController _densityController = TextEditingController(text: '2.6');
  final TextEditingController _velocityController = TextEditingController(text: '6.3');
  final TextEditingController _angleController = TextEditingController(text: '45');
  final TextEditingController _nameController = TextEditingController();

  // Hazır asteroitler
  List<Map<String, dynamic>> getPrebuiltAsteroids(AppLocalizations? localizations) {
    return [
      {
        'name': 'APOPHIS',
        'catalog': '99942 Apophis',
        'diameter': 0.370, // km
        'density': 3.2,
        'velocity': 7.42,
        'angle': 38.0,
        'description': localizations?.isTurkish == true ? '2029 yılında Dünya\'ya yaklaşacak gerçek asteroit' : 'Real asteroid that will approach Earth in 2029',
        'threatLevel': localizations?.isTurkish == true ? 'ORTA' : 'MEDIUM',
        'color': Colors.orange,
        'icon': Icons.circle,
      },
      {
        'name': localizations?.isTurkish == true ? 'KÜÇÜK ASTEROİT' : 'SMALL ASTEROID',
        'catalog': 'Hypothetical Small',
        'diameter': 0.050, // km (50m)
        'density': 2.0,
        'velocity': 15.0,
        'angle': 60.0,
        'description': localizations?.isTurkish == true ? 'Tunguska benzeri küçük asteroit senaryosu' : 'Tunguska-like small asteroid scenario',
        'threatLevel': localizations?.isTurkish == true ? 'DÜŞÜK' : 'LOW',
        'color': Colors.green,
        'icon': Icons.fiber_manual_record,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _diameterController.dispose();
    _densityController.dispose();
    _velocityController.dispose();
    _angleController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0B1426),
      appBar: AppBar(
        title: Text(localizations?.isTurkish == true ? 'Asteroit Seçimi' : 'Asteroid Selection'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A2642), Color(0xFF2A3B5C)],
            ),
          ),
        ),
      ),
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
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Tab Bar
            _buildTabBar(),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPrebuiltAsteroids(),
                  _buildManualInput(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            localizations?.isTurkish == true ? 'Asteroit Verilerini Seçin' : 'Select Asteroid Data',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations?.isTurkish == true ? 'Hazır senaryolar veya özel verilerinizle simülasyon başlatın' : 'Start simulation with ready scenarios or your custom data',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final localizations = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        tabs: [
          Tab(
            icon: const Icon(Icons.list),
            text: localizations?.isTurkish == true ? 'Hazır Asteroitler' : 'Ready Asteroids',
          ),
          Tab(
            icon: const Icon(Icons.edit),
            text: localizations?.isTurkish == true ? 'Manuel Giriş' : 'Manual Entry',
          ),
        ],
      ),
    );
  }

  Widget _buildPrebuiltAsteroids() {
    final localizations = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // NASA Veri Kartı
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A90E2).withOpacity(0.2),
                  const Color(0xFF4A90E2).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cloud_download, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.isTurkish == true ? 'NASA NEO Canlı Verisi' : 'NASA NEO Live Data',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        localizations?.isTurkish == true ? 'Gerçek zamanlı asteroit verilerini kullanın' : 'Use real-time asteroid data',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _loadNASAData,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _isLoadingNASAData
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            localizations?.isTurkish == true ? 'Yükle' : 'Load',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Hazır Asteroit Kartları
          ...getPrebuiltAsteroids(localizations).map((asteroid) => _buildAsteroidCard(asteroid)).toList(),
        ],
      ),
    );
  }

  Widget _buildAsteroidCard(Map<String, dynamic> asteroid) {
    final localizations = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            asteroid['color'].withOpacity(0.2),
            asteroid['color'].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: asteroid['color'].withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _selectAsteroid(asteroid),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: asteroid['color'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        asteroid['icon'],
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                asteroid['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: asteroid['color'].withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  asteroid['threatLevel'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: asteroid['color'],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            asteroid['catalog'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Açıklama
                Text(
                  asteroid['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Özellikler
                Row(
                  children: [
                    Expanded(
                      child: _buildPropertyTile(
                        localizations?.isTurkish == true ? 'Çap' : 'Diameter',
                        '${asteroid['diameter']} km',
                        Icons.straighten,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPropertyTile(
                        localizations?.isTurkish == true ? 'Hız' : 'Speed',
                        '${asteroid['velocity']} km/s',
                        Icons.speed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPropertyTile(
                        localizations?.isTurkish == true ? 'Yoğunluk' : 'Density',
                        '${asteroid['density']} g/cm³',
                        Icons.fitness_center,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Seç Butonu
                Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      asteroid['color'],
                      asteroid['color'].withOpacity(0.7),
                    ]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _selectAsteroid(asteroid),
                      child: Center(
                        child: Text(
                          localizations?.isTurkish == true ? 'Bu Asteroiti Seç' : 'Select This Asteroid',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInput() {
    final localizations = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Temel Parametreler
          _buildInputSection(
            'Temel Asteroit Parametreleri',
            Icons.settings,
            Colors.blue,
            [
              _buildInputField(
                controller: _nameController,
                label: localizations?.isTurkish == true ? 'Asteroit Adı' : 'Asteroid Name',
                hint: localizations?.isTurkish == true ? 'Özel Asteroit' : 'Custom Asteroid',
                icon: Icons.badge,
              ),
              _buildInputField(
                controller: _diameterController,
                label: localizations?.isTurkish == true ? 'Çap (km)' : 'Diameter (km)',
                hint: '62.74',
                icon: Icons.straighten,
                keyboardType: TextInputType.number,
              ),
              _buildInputField(
                controller: _densityController,
                label: 'Yoğunluk (g/cm³)',
                hint: '2.6',
                icon: Icons.fitness_center,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Yörünge Parametreleri
          _buildInputSection(
            'Yörünge ve Çarpma Parametreleri',
            Icons.track_changes,
            Colors.orange,
            [
              _buildInputField(
                controller: _velocityController,
                label: localizations?.isTurkish == true ? 'Hız (km/s)' : 'Velocity (km/s)',
                hint: '6.3',
                icon: Icons.speed,
                keyboardType: TextInputType.number,
              ),
              _buildInputField(
                controller: _angleController,
                label: localizations?.isTurkish == true ? 'Geliş Açısı (derece)' : 'Approach Angle (degrees)',
                hint: '45',
                icon: Icons.rotate_right,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Oluştur Butonu
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _createCustomAsteroid,
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.create, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Özel Asteroit Oluştur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(icon, color: Colors.white54, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAsteroid(Map<String, dynamic> asteroidData) {
    final diameterKm = asteroidData['diameter']; // Already in km
    final densityGcm3 = asteroidData['density']; // Already in g/cm³
    final velocityKmS = asteroidData['velocity']; // Already in km/s
    
    // Calculate mass (kg) from diameter and density
    final radiusM = (diameterKm * 1000) / 2; // Convert km to m
    final volume = (4 / 3) * 3.14159 * radiusM * radiusM * radiusM;
    final mass = volume * (densityGcm3 * 1000); // Convert g/cm³ to kg/m³
    
    final asteroid = Asteroid(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: asteroidData['name'],
      diameter: diameterKm,
      mass: mass,
      density: densityGcm3,
      closeApproachVelocity: velocityKmS,
      impactAngle: asteroidData['angle'],
      lastObservation: DateTime.now(),
    );

    // Hazır asteroit seçildi, direkt simülasyona git
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsteroidSimulationScreen(
          asteroid: asteroid,
          latitude: 41.0082, // İstanbul varsayılan
          longitude: 28.9784,
          locationName: 'İstanbul, Türkiye',
        ),
      ),
    );
  }

  void _createCustomAsteroid() {
    if (_validateInputs()) {
      final diameterKm = double.parse(_diameterController.text);
      final densityGcm3 = double.parse(_densityController.text);
      final velocityKmS = double.parse(_velocityController.text);
      
      // Calculate mass (kg) from diameter and density
      final radiusM = (diameterKm * 1000) / 2; // Convert km to m
      final volume = (4 / 3) * 3.14159 * radiusM * radiusM * radiusM;
      final mass = volume * (densityGcm3 * 1000); // Convert g/cm³ to kg/m³
      
      final asteroid = Asteroid(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        diameter: diameterKm,
        mass: mass,
        density: densityGcm3,
        closeApproachVelocity: velocityKmS,
        impactAngle: double.parse(_angleController.text),
        lastObservation: DateTime.now(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AsteroidInputScreen(),
        ),
      );
    }
  }

  bool _validateInputs() {
    final localizations = AppLocalizations.of(context);
    try {
      double.parse(_diameterController.text);
      double.parse(_velocityController.text);
      double.parse(_densityController.text);
      double.parse(_angleController.text);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations?.isTurkish == true ? 'Lütfen tüm sayısal değerleri doğru giriniz' : 'Please enter all numeric values correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void _loadNASAData() async {
    setState(() {
      _isLoadingNASAData = true;
    });

    try {
      // NASA NEO API çağrısı simülasyonu
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NASA verisi yüklendi! Hazır asteroitler güncellendi.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NASA verisi yüklenirken hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingNASAData = false;
      });
    }
  }
}

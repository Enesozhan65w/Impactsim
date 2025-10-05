import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/asteroid.dart';
import 'asteroid_simulation_screen.dart';
import '../services/localization_service.dart';

class AsteroidInputScreen extends StatefulWidget {
  const AsteroidInputScreen({super.key});

  @override
  State<AsteroidInputScreen> createState() => _AsteroidInputScreenState();
}

class _AsteroidInputScreenState extends State<AsteroidInputScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Manuel giriş form kontrolcüleri
  final _diameterController = TextEditingController();
  final _velocityController = TextEditingController();
  final _angleController = TextEditingController();
  final _massController = TextEditingController();
  
  String _selectedComposition = 'Stony';
  bool _useCustomMass = false;
  
  // Predefined asteroid selection
  Asteroid? _selectedPredefinedAsteroid;
  
  // Location information
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Default values
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Set default values
    _diameterController.text = '100';
    _velocityController.text = '20000';
    _angleController.text = '45';
    _latitudeController.text = '41.0082';
    _longitudeController.text = '28.9784';
    _locationController.text = 'Istanbul, Turkey';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _diameterController.dispose();
    _velocityController.dispose();
    _angleController.dispose();
    _massController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.isTurkish == true ? 'Asteroit Çarpma Simülasyonu' : 'Asteroid Impact Simulation'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.edit), text: localizations?.isTurkish == true ? 'Manuel Giriş' : 'Manual Input'),
            Tab(icon: const Icon(Icons.list), text: localizations?.isTurkish == true ? 'Hazır Asteroit' : 'Predefined Asteroid'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2A2F4A),
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildManualInputTab(),
            _buildPredefinedAsteroidTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startSimulation,
        backgroundColor: const Color(0xFF4A90E2),
        icon: const Icon(Icons.play_arrow),
        label: Text(localizations?.isTurkish == true ? 'Simülasyonu Başlat' : 'Start Simulation'),
      ),
    );
  }

  Widget _buildManualInputTab() {
    final localizations = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(localizations?.isTurkish == true ? 'Asteroit Özellikleri' : 'Asteroid Properties'),
          const SizedBox(height: 16),
          
          // Çap
          _buildNumberField(
            controller: _diameterController,
            label: localizations?.isTurkish == true ? 'Çap (metre)' : 'Diameter (meters)',
            hint: localizations?.isTurkish == true ? 'Asteroit çapını girin' : 'Enter asteroid diameter',
            icon: Icons.circle_outlined,
            suffix: 'm',
          ),
          const SizedBox(height: 16),
          
          // Hız
          _buildNumberField(
            controller: _velocityController,
            label: localizations?.isTurkish == true ? 'Hız (m/s)' : 'Velocity (m/s)',
            hint: localizations?.isTurkish == true ? 'Çarpma hızını girin' : 'Enter impact velocity',
            icon: Icons.speed,
            suffix: 'm/s',
          ),
          const SizedBox(height: 16),
          
          // Çarpma açısı
          _buildNumberField(
            controller: _angleController,
            label: localizations?.isTurkish == true ? 'Çarpma Açısı (derece)' : 'Impact Angle (degrees)',
            hint: localizations?.isTurkish == true ? '0-90 arası açı' : 'Angle between 0-90',
            icon: Icons.rotate_right,
            suffix: '°',
            maxValue: 90,
          ),
          const SizedBox(height: 16),
          
          // Kompozisyon
          _buildCompositionSelector(),
          const SizedBox(height: 16),
          
          // Özel kütle
          _buildCustomMassSection(),
          const SizedBox(height: 32),
          
          _buildSectionTitle(localizations?.isTurkish == true ? 'Çarpma Konumu' : 'Impact Location'),
          const SizedBox(height: 16),
          
          // Konum bilgileri
          _buildLocationFields(),
          const SizedBox(height: 16),
          
          // Popüler konumlar
          _buildPopularLocations(),
          
          const SizedBox(height: 100), // FAB için boşluk
        ],
      ),
    );
  }

  Widget _buildPredefinedAsteroidTab() {
    final localizations = AppLocalizations.of(context);
    final predefinedAsteroids = Asteroid.getPredefinedAsteroids();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Hazır Asteroit Örnekleri'),
          const SizedBox(height: 16),
          
          ...predefinedAsteroids.map((asteroid) => _buildAsteroidCard(asteroid)),
          
          const SizedBox(height: 32),
          
          if (_selectedPredefinedAsteroid != null) ...[
            _buildSectionTitle(localizations?.isTurkish == true ? 'Çarpma Konumu' : 'Impact Location'),
            const SizedBox(height: 16),
            _buildLocationFields(),
            const SizedBox(height: 16),
            _buildPopularLocations(),
          ],
          
          const SizedBox(height: 100), // FAB için boşluk
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
    double? maxValue,
  }) {
    final localizations = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white54),
          suffixStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return localizations?.isTurkish == true ? 'Bu alan gerekli' : 'This field is required';
          final number = double.tryParse(value);
          if (number == null) return localizations?.isTurkish == true ? 'Geçerli bir sayı girin' : 'Enter a valid number';
          if (number <= 0) return localizations?.isTurkish == true ? 'Pozitif bir değer girin' : 'Enter a positive value';
          if (maxValue != null && number > maxValue) return 'Maksimum $maxValue';
          return null;
        },
      ),
    );
  }

  Widget _buildCompositionSelector() {
    final localizations = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedComposition,
        dropdownColor: const Color(0xFF1A1F3A),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: 'Asteroit Kompozisyonu',
          prefixIcon: Icon(Icons.science, color: Color(0xFF4A90E2)),
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        items: [
          DropdownMenuItem(value: 'Stony', child: Text(localizations?.isTurkish == true ? 'Taşlı (Stony)' : 'Stony')),
          DropdownMenuItem(value: 'Iron', child: Text(localizations?.isTurkish == true ? 'Demir (Iron)' : 'Iron')),
          DropdownMenuItem(value: 'Carbonaceous', child: Text(localizations?.isTurkish == true ? 'Karbonlu (Carbonaceous)' : 'Carbonaceous')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedComposition = value!;
          });
        },
      ),
    );
  }

  Widget _buildCustomMassSection() {
    final localizations = AppLocalizations.of(context);
    return Column(
      children: [
        CheckboxListTile(
          title: Text(localizations?.isTurkish == true ? 'Özel kütle kullan' : 'Use custom mass', style: const TextStyle(color: Colors.white)),
          subtitle: Text(localizations?.isTurkish == true ? 'Varsayılan olarak çap ve yoğunluktan hesaplanır' : 'Calculated from diameter and density by default', 
                               style: TextStyle(color: Colors.white54)),
          value: _useCustomMass,
          activeColor: const Color(0xFF4A90E2),
          checkColor: Colors.white,
          onChanged: (value) {
            setState(() {
              _useCustomMass = value!;
            });
          },
        ),
        if (_useCustomMass) ...[
          const SizedBox(height: 8),
          _buildNumberField(
            controller: _massController,
            label: localizations?.isTurkish == true ? 'Kütle (kg)' : 'Mass (kg)',
            hint: localizations?.isTurkish == true ? 'Asteroit kütlesini girin' : 'Enter asteroid mass',
            icon: Icons.fitness_center,
            suffix: 'kg',
          ),
        ],
      ],
    );
  }

  Widget _buildLocationFields() {
    final localizations = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _latitudeController,
                label: localizations?.isTurkish == true ? 'Enlem' : 'Latitude',
                hint: localizations?.isTurkish == true ? '-90 ile 90 arası' : 'Between -90 and 90',
                icon: Icons.location_on,
                suffix: '°',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                controller: _longitudeController,
                label: localizations?.isTurkish == true ? 'Boylam' : 'Longitude',
                hint: localizations?.isTurkish == true ? '-180 ile 180 arası' : 'Between -180 and 180',
                icon: Icons.location_on,
                suffix: '°',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextFormField(
            controller: _locationController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: localizations?.isTurkish == true ? 'Konum Adı' : 'Location Name',
              hintText: localizations?.isTurkish == true ? 'Şehir, ülke' : 'City, country',
              prefixIcon: Icon(Icons.place, color: Color(0xFF4A90E2)),
              labelStyle: TextStyle(color: Colors.white70),
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularLocations() {
    final localizations = AppLocalizations.of(context);
    final locations = [
      {'name': 'İstanbul, Türkiye', 'lat': 41.0082, 'lng': 28.9784},
      {'name': 'Ankara, Türkiye', 'lat': 39.9334, 'lng': 32.8597},
      {'name': 'New York, ABD', 'lat': 40.7128, 'lng': -74.0060},
      {'name': 'Tokyo, Japonya', 'lat': 35.6762, 'lng': 139.6503},
      {'name': 'Londra, İngiltere', 'lat': 51.5074, 'lng': -0.1278},
      {'name': 'Pasifik Okyanusu', 'lat': 0.0, 'lng': -160.0},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.isTurkish == true ? 'Popüler Konumlar' : 'Popular Locations',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: locations.map((location) => 
            InkWell(
              onTap: () {
                setState(() {
                  _latitudeController.text = location['lat'].toString();
                  _longitudeController.text = location['lng'].toString();
                  _locationController.text = location['name'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4A90E2).withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  location['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildAsteroidCard(Asteroid asteroid) {
    final localizations = AppLocalizations.of(context);
    final isSelected = _selectedPredefinedAsteroid?.id == asteroid.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? const Color(0xFF4A90E2).withOpacity(0.3) : Colors.white.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPredefinedAsteroid = isSelected ? null : asteroid;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      asteroid.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRiskColor(asteroid.riskLevel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      asteroid.riskLevel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${asteroid.category} • ${asteroid.composition}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildAsteroidStat(localizations?.isTurkish == true ? 'Çap' : 'Diameter', '${(asteroid.diameter * 1000).round()}m'),
                  _buildAsteroidStat(localizations?.isTurkish == true ? 'Hız' : 'Speed', '${(asteroid.closeApproachVelocity).round()}km/s'),
                  _buildAsteroidStat(localizations?.isTurkish == true ? 'Kütle' : 'Mass', '${(asteroid.mass / 1e6).toStringAsFixed(1)}M ton'),
                ],
              ),
              if (asteroid.hiroshimaEquivalent > 0.1) ...[
                const SizedBox(height: 4),
                Text(
                  localizations?.isTurkish == true ? 'Hiroshima bombası eşdeğeri: ${asteroid.hiroshimaEquivalent.toStringAsFixed(1)}x' : 'Hiroshima bomb equivalent: ${asteroid.hiroshimaEquivalent.toStringAsFixed(1)}x',
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAsteroidStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Kritik':
      case 'Critical': return Colors.red;
      case 'Yüksek':
      case 'High': return Colors.orange;
      case 'Orta':
      case 'Medium': return Colors.yellow;
      case 'Düşük':
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _startSimulation() {
    Asteroid? asteroid;
    
    if (_tabController.index == 0) {
      // Manuel giriş
      if (!_validateManualInput()) return;
      
      asteroid = Asteroid.fromUserInput(
        diameter: double.parse(_diameterController.text),
        velocity: double.parse(_velocityController.text),
        impactAngle: double.parse(_angleController.text),
        composition: _selectedComposition,
        customMass: _useCustomMass ? double.tryParse(_massController.text) : null,
      );
    } else {
      // Hazır asteroit
      if (_selectedPredefinedAsteroid == null) {
        _showError('Lütfen bir asteroit seçin');
        return;
      }
      asteroid = _selectedPredefinedAsteroid!;
    }
    
    if (!_validateLocation()) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsteroidSimulationScreen(
          asteroid: asteroid!,
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          locationName: _locationController.text,
        ),
      ),
    );
  }

  bool _validateManualInput() {
    if (_diameterController.text.isEmpty || 
        _velocityController.text.isEmpty || 
        _angleController.text.isEmpty) {
      _showError('Lütfen tüm asteroit bilgilerini girin');
      return false;
    }
    
    if (_useCustomMass && _massController.text.isEmpty) {
      _showError('Lütfen kütle değerini girin');
      return false;
    }
    
    return true;
  }

  bool _validateLocation() {
    if (_latitudeController.text.isEmpty || 
        _longitudeController.text.isEmpty || 
        _locationController.text.isEmpty) {
      _showError('Lütfen konum bilgilerini girin');
      return false;
    }
    
    final lat = double.tryParse(_latitudeController.text);
    final lng = double.tryParse(_longitudeController.text);
    
    if (lat == null || lng == null) {
      _showError('Geçerli koordinatlar girin');
      return false;
    }
    
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      _showError('Koordinatlar geçerli aralıkta olmalı');
      return false;
    }
    
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

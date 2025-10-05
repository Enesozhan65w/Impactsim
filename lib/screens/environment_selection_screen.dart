import 'package:flutter/material.dart';
import 'simulation_screen.dart';
import '../services/localization_service.dart';

class EnvironmentSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> rocketData;
  
  const EnvironmentSelectionScreen({
    super.key,
    required this.rocketData,
  });

  @override
  State<EnvironmentSelectionScreen> createState() => _EnvironmentSelectionScreenState();
}

class _EnvironmentSelectionScreenState extends State<EnvironmentSelectionScreen> {
  String selectedEnvironment = 'LEO';
  
  List<Map<String, dynamic>> _getEnvironments(AppLocalizations? localizations) {
    return [
      {
        'name': 'LEO',
        'fullName': localizations?.lowEarthOrbit ?? 'Low Earth Orbit',
        'icon': Icons.public,
        'description': localizations?.isTurkish == true 
            ? 'Dünya\'nın 160-2000 km yüksekliğindeki yörüngesi'
            : 'Earth orbit at 160-2000 km altitude',
        'challenges': localizations?.isTurkish == true
            ? ['Düşük yerçekimi', 'Radyasyon', 'Orbital hız']
            : ['Low gravity', 'Radiation', 'Orbital velocity'],
        'difficulty': localizations?.easy ?? 'Easy',
        'color': Color(0xFF4CAF50),
      },
      {
        'name': 'Lunar',
        'fullName': localizations?.lunarSurface ?? 'Lunar Surface',
        'icon': Icons.brightness_3,
        'description': localizations?.isTurkish == true
            ? 'Ay\'ın yüzeyinde iniş ve çalışma'
            : 'Landing and operating on lunar surface',
        'challenges': localizations?.isTurkish == true
            ? ['Düşük yerçekimi', 'Aşırı sıcaklık', 'Toz fırtınaları']
            : ['Low gravity', 'Extreme temperature', 'Dust storms'],
        'difficulty': localizations?.medium ?? 'Medium',
        'color': Color(0xFFFF9800),
      },
      {
        'name': 'Mars',
        'fullName': localizations?.marsAtmosphere ?? 'Mars Atmosphere',
        'icon': Icons.circle,
        'description': localizations?.isTurkish == true
            ? 'Mars gezegeninin atmosferinde çalışma'
            : 'Operating in Martian atmosphere',
        'challenges': localizations?.isTurkish == true
            ? ['İnce atmosfer', 'Soğuk iklim', 'Toz fırtınaları']
            : ['Thin atmosphere', 'Cold climate', 'Dust storms'],
        'difficulty': localizations?.hard ?? 'Hard',
        'color': Color(0xFFFF5722),
      },
      {
        'name': 'Deep Space',
        'fullName': localizations?.deepSpace ?? 'Deep Space',
        'icon': Icons.star_border,
        'description': localizations?.isTurkish == true
            ? 'Gezegenler arası boşlukta seyahat'
            : 'Interplanetary space travel',
        'challenges': localizations?.isTurkish == true
            ? ['Sıfır yerçekimi', 'Aşırı radyasyon', 'İletişim gecikmesi']
            : ['Zero gravity', 'Extreme radiation', 'Communication delay'],
        'difficulty': localizations?.veryHard ?? 'Very Hard',
        'color': Color(0xFF9C27B0),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.environmentSelection ?? 'Environment Selection'),
        centerTitle: true,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.chooseTestEnvironment ?? 'Choose Test Environment',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations?.isTurkish == true 
                      ? 'Roketinizi hangi uzay ortamında test etmek istiyorsunuz?'
                      : 'Which space environment would you like to test your rocket in?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                
                // Roket özeti
                _buildRocketSummary(),
                
                const SizedBox(height: 24),
                
                // Ortam seçenekleri
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final environments = _getEnvironments(localizations);
                      return ListView.builder(
                        itemCount: environments.length,
                        itemBuilder: (context, index) {
                          final environment = environments[index];
                          return _buildEnvironmentCard(environment, localizations);
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Start simulation button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SimulationScreen(
                            rocketData: widget.rocketData,
                            environment: selectedEnvironment,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      localizations?.startSimulation ?? 'Start Simulation',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

  Widget _buildRocketSummary() {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch, color: Color(0xFF4A90E2)),
              const SizedBox(width: 12),
              Text(
                localizations?.rocketSummary ?? 'Rocket Summary',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.rocketData['type'] == 'manual') ...[
            _buildSummaryRow(localizations?.material ?? 'Material', widget.rocketData['material']),
            _buildSummaryRow(localizations?.fuel ?? 'Fuel', widget.rocketData['fuelType']),
            _buildSummaryRow(localizations?.weight ?? 'Weight', '${widget.rocketData['weight'].round()} kg'),
            _buildSummaryRow(localizations?.motorPower ?? 'Motor Power', '${widget.rocketData['motorPower'].round()} N'),
            _buildSummaryRow(localizations?.controlSystem ?? 'Control System', 
                widget.rocketData['hasControlSystem'] 
                    ? (localizations?.hasControlSystem ?? 'Available')
                    : (localizations?.noControlSystem ?? 'Not Available')),
          ] else ...[
            _buildSummaryRow('Model', widget.rocketData['model']),
            ...widget.rocketData['specs'].entries.map((entry) => 
              _buildSummaryRow(entry.key, entry.value)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentCard(Map<String, dynamic> environment, AppLocalizations? localizations) {
    bool isSelected = selectedEnvironment == environment['name'];
    
    return GestureDetector(
      onTap: () => setState(() => selectedEnvironment = environment['name']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
            ? environment['color'].withOpacity(0.2) 
            : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? environment['color'] 
              : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: environment['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    environment['icon'],
                    color: environment['color'],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        environment['fullName'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: environment['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          environment['difficulty'],
                          style: TextStyle(
                            color: environment['color'],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: environment['color'],
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              environment['description'],
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizations?.isTurkish == true ? 'Zorluklar:' : 'Challenges:',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: environment['challenges'].map<Widget>((challenge) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    challenge,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

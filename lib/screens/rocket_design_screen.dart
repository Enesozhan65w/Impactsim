import 'package:flutter/material.dart';
import 'environment_selection_screen.dart';
import '../services/localization_service.dart';

class RocketDesignScreen extends StatefulWidget {
  const RocketDesignScreen({super.key});

  @override
  State<RocketDesignScreen> createState() => _RocketDesignScreenState();
}

class _RocketDesignScreenState extends State<RocketDesignScreen> {
  bool isManualDesign = true;
  
  // Manuel tasarım değişkenleri
  String selectedMaterial = 'Aluminum';
  String selectedFuelType = 'Solid';
  double weight = 100.0;
  double motorPower = 1000.0;
  bool hasControlSystem = false;
  
  // Hazır model değişkeni
  String selectedPresetModel = 'Mini CubeSat';
  
  List<String> _getMaterials(AppLocalizations? localizations) {
    return localizations?.isTurkish == true 
        ? ['Alüminyum', 'Karbonfiber', 'Kompozit']
        : ['Aluminum', 'Carbon Fiber', 'Composite'];
  }
  
  List<String> _getFuelTypes(AppLocalizations? localizations) {
    return localizations?.isTurkish == true 
        ? ['Katı', 'Sıvı', 'Hibrit']
        : ['Solid', 'Liquid', 'Hybrid'];
  }
  
  // GERÇEKÇİ ROKET MODELLERİ - NASA standartlarında!
  List<String> getPresetModels(AppLocalizations? localizations) {
    if (localizations?.isTurkish == true) {
      return [
        'SLS (NASA)',
        'Falcon 9 (SpaceX)', 
        'Falcon Heavy (SpaceX)',
        'Atlas V (ULA)',
        'Electron (Rocket Lab)',
        '---ESKI MODELLER---',
        'Mini CubeSat',
        'Deneysel Roket', 
        'İletişim Uydusu'
      ];
    } else {
      return [
        'SLS (NASA)',
        'Falcon 9 (SpaceX)', 
        'Falcon Heavy (SpaceX)',
        'Atlas V (ULA)',
        'Electron (Rocket Lab)',
        '---OLD MODELS---',
        'Mini CubeSat',
        'Experimental Rocket', 
        'Communication Satellite'
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    // DropdownButton hatasını önlemek için selectedMaterial değerini kontrol et
    final materials = _getMaterials(localizations);
    if (!materials.contains(selectedMaterial)) {
      selectedMaterial = materials.isNotEmpty ? materials.first : 'Aluminum';
    }
    
    // DropdownButton hatasını önlemek için selectedFuelType değerini kontrol et
    final fuelTypes = _getFuelTypes(localizations);
    if (!fuelTypes.contains(selectedFuelType)) {
      selectedFuelType = fuelTypes.isNotEmpty ? fuelTypes.first : 'Solid';
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.rocketDesign ?? 'Rocket Design'),
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
                // Design type selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.chooseDesignMethod ?? 'Choose Design Method',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDesignTypeButton(
                              localizations?.createCustomRocket ?? 'Create Custom Rocket',
                              Icons.build,
                              isManualDesign,
                              () => setState(() => isManualDesign = true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDesignTypeButton(
                              localizations?.useExistingModel ?? 'Use Existing Model',
                              Icons.rocket,
                              !isManualDesign,
                              () => setState(() => isManualDesign = false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Tasarım içeriği
                Expanded(
                  child: SingleChildScrollView(
                    child: isManualDesign ? _buildManualDesign(localizations) : _buildPresetDesign(localizations),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Devam et butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnvironmentSelectionScreen(
                            rocketData: _getRocketData(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      localizations?.selectTestEnvironment ?? 'Select Test Environment',
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

  Widget _buildDesignTypeButton(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A90E2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90E2) : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualDesign(AppLocalizations? localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.createCustomRocket ?? 'Create Custom Rocket',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          // Gövde malzemesi
          _buildDropdownField(localizations?.material ?? 'Material', selectedMaterial, _getMaterials(localizations), (value) {
            setState(() => selectedMaterial = value!);
          }),
          
          const SizedBox(height: 20),
          
          // Yakıt türü
          _buildDropdownField(localizations?.fuelType ?? 'Fuel Type', selectedFuelType, _getFuelTypes(localizations), (value) {
            setState(() => selectedFuelType = value!);
          }),
          
          const SizedBox(height: 20),
          
          // Ağırlık
          _buildSliderField('${localizations?.weight ?? 'Weight'} (kg)', weight, 50, 500, (value) {
            setState(() => weight = value);
          }),
          
          const SizedBox(height: 20),
          
          // Motor gücü
          _buildSliderField('${localizations?.motorPower ?? 'Motor Power'} (N)', motorPower, 500, 5000, (value) {
            setState(() => motorPower = value);
          }),
          
          const SizedBox(height: 20),
          
          // Kontrol sistemi
          _buildSwitchField(localizations?.controlSystem ?? 'Control System', hasControlSystem, (value) {
            setState(() => hasControlSystem = value);
          }),
        ],
      ),
    );
  }

  Widget _buildPresetDesign(AppLocalizations? localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.chooseRocketModel ?? 'Choose Rocket Model',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          ...getPresetModels(localizations).map((model) => _buildPresetModelCard(model)).toList(),
        ],
      ),
    );
  }

  Widget _buildPresetModelCard(String modelName) {
    bool isSelected = selectedPresetModel == modelName;
    Map<String, String> modelSpecs = _getModelSpecs(modelName);
    
    // Ayırıcı satır için özel durum
    if (modelName == '---ESKI MODELLER---') {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 16),
            const SizedBox(width: 8),
            Text(
              'ESKI TEST MODELLERİ',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }
    
    return GestureDetector(
      onTap: () => setState(() => selectedPresetModel = modelName),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A90E2).withOpacity(0.3) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90E2) : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rocket_launch,
                  color: isSelected ? const Color(0xFF4A90E2) : Colors.white70,
                ),
                const SizedBox(width: 12),
                Text(
                  modelName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4A90E2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...modelSpecs.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1A1F3A),
            style: const TextStyle(color: Colors.white),
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderField(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            Text('${value.round()}', style: const TextStyle(color: Color(0xFF4A90E2), fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF4A90E2),
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: const Color(0xFF4A90E2),
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

  Widget _buildSwitchField(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4A90E2),
        ),
      ],
    );
  }

  Map<String, String> _getModelSpecs(String modelName) {
    final localizations = AppLocalizations.of(context);
    
    switch (modelName) {
      // GERÇEKÇİ NASA/SPACEX ROKET MODELLERİ
      case 'SLS (NASA)':
        return localizations?.isTurkish == true ? {
          'Thrust': '39.1 MN',
          'Kütle': localizations?.isTurkish == true ? '2608 ton' : '2608 tons',
          'Hız Profili': localizations?.isTurkish == true ? '2s→5m/s, 10s→150km/h, 60s→900km/h' : '2s→5m/s, 10s→150km/h, 60s→900km/h',
          'Üretici': 'NASA/Boeing',
          'Tip': 'Ağır kaldırım roketi',
        } : {
          'Thrust': '39.1 MN',
          'Mass': '2608 tons',
          'Speed Profile': '2s→5m/s, 10s→150km/h, 60s→900km/h',
          'Manufacturer': 'NASA/Boeing',
          'Type': 'Heavy-lift rocket',
        };
      case 'Falcon 9 (SpaceX)':
        return localizations?.isTurkish == true ? {
          'Thrust': '7.6 MN',
          'Kütle': localizations?.isTurkish == true ? '549 ton' : '549 tons',
          'Hız Profili': localizations?.isTurkish == true ? '2s→3m/s, 10s→100km/h, 60s→800km/h' : '2s→3m/s, 10s→100km/h, 60s→800km/h',
          'Üretici': 'SpaceX',
          'Tip': 'Yeniden kullanılabilir',
        } : {
          'Thrust': '7.6 MN',
          'Mass': '549 tons',
          'Speed Profile': '2s→3m/s, 10s→100km/h, 60s→800km/h',
          'Manufacturer': 'SpaceX',
          'Type': 'Reusable',
        };
      case 'Falcon Heavy (SpaceX)':
        return localizations?.isTurkish == true ? {
          'Thrust': '22.8 MN',
          'Kütle': localizations?.isTurkish == true ? '1420 ton' : '1420 tons',
          'Hız Profili': localizations?.isTurkish == true ? '2s→3m/s, 10s→100km/h, 60s→800km/h' : '2s→3m/s, 10s→100km/h, 60s→800km/h',
          'Üretici': 'SpaceX',
          'Tip': 'Ağır kaldırım (3×Falcon9)',
        } : {
          'Thrust': '22.8 MN',
          'Mass': '1420 tons',
          'Speed Profile': '2s→3m/s, 10s→100km/h, 60s→800km/h',
          'Manufacturer': 'SpaceX',
          'Type': 'Heavy-lift (3×Falcon9)',
        };
      case 'Atlas V (ULA)':
        return localizations?.isTurkish == true ? {
          'Thrust': '3.8 MN',
          'Kütle': localizations?.isTurkish == true ? '547 ton' : '547 tons',
          'Hız Profili': localizations?.isTurkish == true ? '2s→2.5m/s, 10s→130km/h, 60s→700km/h' : '2s→2.5m/s, 10s→130km/h, 60s→700km/h',
          'Üretici': 'ULA (Lockheed/Boeing)',
          'Tip': 'Orta sınıf güvenilir',
        } : {
          'Thrust': '3.8 MN',
          'Mass': '547 tons',
          'Speed Profile': '2s→2.5m/s, 10s→130km/h, 60s→700km/h',
          'Manufacturer': 'ULA (Lockheed/Boeing)',
          'Type': 'Medium-class reliable',
        };
      case 'Electron (Rocket Lab)':
        return localizations?.isTurkish == true ? {
          'Thrust': '0.19 MN',
          'Kütle': localizations?.isTurkish == true ? '13 ton' : '13 tons',
          'Hız Profili': localizations?.isTurkish == true ? '2s→2m/s, 10s→80km/h, 60s→450km/h' : '2s→2m/s, 10s→80km/h, 60s→450km/h',
          'Üretici': 'Rocket Lab',
          'Tip': 'Küçük uydu roketi',
        } : {
          'Thrust': '0.19 MN',
          'Mass': '13 tons',
          'Speed Profile': '2s→2m/s, 10s→80km/h, 60s→450km/h',
          'Manufacturer': 'Rocket Lab',
          'Type': 'Small satellite rocket',
        };
        
      // ESKİ TEST MODELLERİ (geriye uyumluluk için)
      case 'Mini CubeSat':
        return localizations?.isTurkish == true ? {
          'Ağırlık': '1.3 kg',
          'Malzeme': localizations?.isTurkish == true ? 'Alüminyum' : 'Aluminum',
          'Yakıt': localizations?.isTurkish == true ? 'Elektrik' : 'Electric',
          'Kontrol': localizations?.isTurkish == true ? 'Var' : 'Available',
        } : {
          'Weight': '1.3 kg',
          'Material': 'Aluminum',
          'Fuel': 'Electric',
          'Control': 'Available',
        };
      case 'Deneysel Roket':
        return localizations?.isTurkish == true ? {
          'Ağırlık': '25 kg',
          'Malzeme': localizations?.isTurkish == true ? 'Kompozit' : 'Composite',
          'Yakıt': localizations?.isTurkish == true ? 'Katı' : 'Solid',
          'Kontrol': localizations?.isTurkish == true ? 'Yok' : 'Not Available',
        } : {
          'Weight': '25 kg',
          'Material': 'Composite',
          'Fuel': 'Solid',
          'Control': 'Not Available',
        };
      case 'İletişim Uydusu':
        return localizations?.isTurkish == true ? {
          'Ağırlık': '150 kg',
          'Malzeme': localizations?.isTurkish == true ? 'Karbonfiber' : 'Carbon Fiber',
          'Yakıt': localizations?.isTurkish == true ? 'Sıvı' : 'Liquid',
          'Kontrol': localizations?.isTurkish == true ? 'Var' : 'Available',
        } : {
          'Weight': '150 kg',
          'Material': 'Carbon Fiber',
          'Fuel': 'Liquid',
          'Control': 'Available',
        };
      case '---ESKI MODELLER---':
        return {}; // Separator, tıklanamaz
      default:
        return {};
    }
  }

  Map<String, dynamic> _getRocketData() {
    if (isManualDesign) {
      return {
        'type': 'manual',
        'material': selectedMaterial,
        'fuelType': selectedFuelType,
        'weight': weight,
        'motorPower': motorPower,
        'hasControlSystem': hasControlSystem,
      };
    } else {
      return {
        'type': 'preset',
        'model': selectedPresetModel,
        'specs': _getModelSpecs(selectedPresetModel),
      };
    }
  }
}

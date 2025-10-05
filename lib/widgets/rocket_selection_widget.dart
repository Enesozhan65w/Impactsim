import 'package:flutter/material.dart';
import '../models/rocket_types.dart';

/// Roket tipi seçim widget'ı
class RocketSelectionWidget extends StatelessWidget {
  final RocketType selectedType;
  final Function(RocketType) onRocketTypeChanged;

  const RocketSelectionWidget({
    super.key,
    required this.selectedType,
    required this.onRocketTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(Icons.rocket_launch, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'ROKET SEÇİMİ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Roket kartları
          ...RocketType.values.map((type) => _buildRocketCard(type)).toList(),
        ],
      ),
    );
  }

  Widget _buildRocketCard(RocketType type) {
    final data = RocketPerformanceData.getForType(type);
    final isSelected = type == selectedType;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onRocketTypeChanged(type),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.white10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.white24,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık ve üretici
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        type.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.orange : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: Colors.orange, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  type.manufacturer,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Açıklama
                Text(
                  type.description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Teknik özellikler
                Row(
                  children: [
                    _buildSpec('Thrust', '${(data.thrust/1000000).toStringAsFixed(1)} MN'),
                    const SizedBox(width: 16),
                    _buildSpec('Mass', '${(data.wetMass/1000).toStringAsFixed(0)}t'),
                    const SizedBox(width: 16),
                    _buildSpec('ISP', '${data.specificImpulse}s'),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Performans profili
                Text(
                  'Hız Profili: 2s→${data.speedAt2Seconds.toInt()}m/s, 10s→${data.speedAt10Seconds.toInt()}m/s, 60s→${data.speedAt60Seconds.toInt()}m/s',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpec(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Kompakt roket seçimi (dropdown)
class CompactRocketSelectionWidget extends StatelessWidget {
  final RocketType selectedType;
  final Function(RocketType) onRocketTypeChanged;

  const CompactRocketSelectionWidget({
    super.key,
    required this.selectedType,
    required this.onRocketTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rocket_launch, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<RocketType>(
              value: selectedType,
              dropdownColor: Colors.grey[800],
              style: const TextStyle(color: Colors.white, fontSize: 12),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange, size: 16),
              items: RocketType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(
                        type.displayName,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${RocketPerformanceData.getForType(type).thrust ~/ 1000000}MN)',
                        style: TextStyle(color: Colors.white60, fontSize: 10),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (RocketType? value) {
                if (value != null) {
                  onRocketTypeChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/test_result.dart';
import '../services/localization_service.dart';

class TestDetailScreen extends StatelessWidget {
  final TestResult testResult;

  const TestDetailScreen({
    super.key,
    required this.testResult,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.isTurkish == true ? 'Test Detayları' : 'Test Details'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve durum
              _buildHeader(),
              
              const SizedBox(height: 24),
              
              // Roket bilgileri
              _buildRocketInfo(context),
              
              const SizedBox(height: 24),
              
              // Test sonuçları
              _buildTestResults(context),
              
              const SizedBox(height: 24),
              
              // Uyarılar
              if (testResult.finalStats['warnings'] != null && 
                  (testResult.finalStats['warnings'] as List).isNotEmpty)
                _buildWarnings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            testResult.isSuccessful ? Icons.check_circle : Icons.cancel,
            size: 60,
            color: testResult.isSuccessful ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            testResult.rocketName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            testResult.environment,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: testResult.isSuccessful ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${testResult.statusText} - ${testResult.successPercentage.round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${testResult.date.day}/${testResult.date.month}/${testResult.date.year} ${testResult.date.hour}:${testResult.date.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          Text(
            'Süre: ${testResult.duration} saniye',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRocketInfo(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Roket Bilgileri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (testResult.rocketData['type'] == 'manual') ...[
            _buildInfoRow('Tip', 'Manuel Tasarım'),
            _buildInfoRow('Ağırlık', '${testResult.rocketData['weight']} kg'),
            _buildInfoRow(localizations?.isTurkish == true ? 'Motor Gücü' : 'Motor Power', '${testResult.rocketData['motorPower']} N'),
            _buildInfoRow(localizations?.isTurkish == true ? 'Malzeme' : 'Material', testResult.rocketData['material'] ?? (localizations?.isTurkish == true ? 'Belirtilmemiş' : 'Not specified')),
            _buildInfoRow(localizations?.isTurkish == true ? 'Yakıt Türü' : 'Fuel Type', testResult.rocketData['fuelType'] ?? (localizations?.isTurkish == true ? 'Belirtilmemiş' : 'Not specified')),
            _buildInfoRow(localizations?.isTurkish == true ? 'Kontrol Sistemi' : 'Control System', 
                testResult.rocketData['hasControlSystem'] == true ? (localizations?.isTurkish == true ? 'Var' : 'Available') : (localizations?.isTurkish == true ? 'Yok' : 'Not Available')),
          ] else ...[
            _buildInfoRow('Tip', 'Hazır Model'),
            _buildInfoRow('Model', testResult.rocketData['model'] ?? 'Bilinmeyen'),
          ],
        ],
      ),
    );
  }

  Widget _buildTestResults(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final stats = testResult.finalStats;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test Sonuçları',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  localizations?.isTurkish == true ? 'Hız' : 'Velocity',
                  '${(stats['speed'] as double).round()} m/s',
                  Icons.speed,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultCard(
                  'Sıcaklık',
                  '${(stats['temperature'] as double).round()}°C',
                  Icons.thermostat,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  localizations?.isTurkish == true ? 'Yakıt' : 'Fuel',
                  '${(stats['fuelLevel'] as double).round()}%',
                  Icons.local_gas_station,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultCard(
                  'Hasar',
                  '${(stats['damage'] as double).round()}%',
                  Icons.warning,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarnings(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final warnings = testResult.finalStats['warnings'] as List<String>;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                localizations?.isTurkish == true ? 'Sistem Uyarıları' : 'System Warnings',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...warnings.map((warning) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    warning,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
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
            ),
          ),
        ],
      ),
    );
  }
}

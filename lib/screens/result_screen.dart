import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> rocketData;
  final String environment;
  final bool isSuccessful;
  final double successPercentage;
  final Map<String, dynamic> finalStats;
  
  const ResultScreen({
    super.key,
    required this.rocketData,
    required this.environment,
    required this.isSuccessful,
    required this.successPercentage,
    required this.finalStats,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.simulationResults ?? 'Simulation Results'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Başarı durumu
                _buildSuccessStatus(context),
                
                const SizedBox(height: 24),
                
                // Final istatistikleri
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildFinalStats(context),
                        const SizedBox(height: 24),
                        _buildPhysicsAnalysis(context),
                        const SizedBox(height: 24),
                        _buildChemicalAnalysis(),
                        const SizedBox(height: 24),
                        _buildSuccessfulComponents(context),
                        const SizedBox(height: 24),
                        _buildFailedComponents(context),
                        const SizedBox(height: 24),
                        _buildRealWorldComparison(),
                        const SizedBox(height: 24),
                        _buildFailureReasons(localizations),
                        const SizedBox(height: 24),
                        _buildRecommendations(context),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Alt butonlar
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSuccessStatus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isSuccessful 
          ? Colors.green.withOpacity(0.1) 
          : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuccessful 
            ? Colors.green.withOpacity(0.3) 
            : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isSuccessful ? Icons.check_circle : Icons.cancel,
            size: 80,
            color: isSuccessful ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            isSuccessful 
              ? (localizations?.isTurkish == true ? 'Simülasyon Başarılı!' : 'Simulation Successful!')
              : (localizations?.isTurkish == true ? 'Simülasyon Başarısız' : 'Simulation Failed'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isSuccessful ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations?.isTurkish == true ? '$environment ortamında test tamamlandı' : 'Test completed in $environment environment',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Başarı yüzdesi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Başarı Oranı: ${successPercentage.round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFinalStats(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
          const Text(
            'Final İstatistikleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  localizations?.isTurkish == true ? 'Son Hız' : 'Final Velocity',
                  '${finalStats['speed'].round()} m/s',
                  Icons.speed,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Son Sıcaklık',
                  '${finalStats['temperature'].round()}°C',
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
                child: _buildStatCard(
                  localizations?.isTurkish == true ? 'Kalan Yakıt' : 'Remaining Fuel',
                  '${finalStats['fuelLevel'].round()}%',
                  Icons.local_gas_station,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Toplam Hasar',
                  '${finalStats['damage'].round()}%',
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
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFailureReasons(AppLocalizations? localizations) {
    if (isSuccessful) return const SizedBox.shrink();
    
    List<String> reasons = [];
    
    if (finalStats['damage'] >= 80) {
      reasons.add(localizations?.isTurkish == true ? 'Roket kritik hasar aldı (${finalStats['damage'].round()}%)' : 'Rocket suffered critical damage (${finalStats['damage'].round()}%)');
    }
    if (finalStats['fuelLevel'] <= 0) {
      reasons.add(localizations?.isTurkish == true ? 'Yakıt tükendi' : 'Fuel exhausted');
    }
    if (finalStats['temperature'] > 150) {
      reasons.add(localizations?.isTurkish == true ? 'Aşırı ısınma nedeniyle sistem arızası' : 'System failure due to overheating');
    }
    if (finalStats['temperature'] < -200) {
      reasons.add(localizations?.isTurkish == true ? 'Aşırı soğuma nedeniyle sistem donması' : 'System freeze due to extreme cold');
    }
    
    if (reasons.isEmpty) {
      reasons.add(localizations?.isTurkish == true ? 'Genel sistem arızası' : 'General system failure');
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(width: 12),
              Text(
                'Başarısızlık Nedenleri',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reasons.map((reason) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.red, fontSize: 16)),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
  
  Widget _buildRecommendations(BuildContext context) {
    List<String> recommendations = _generateRecommendations(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Text(
                'İyileştirme Önerileri',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.map((recommendation) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.blue, fontSize: 16)),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
  
  List<String> _generateRecommendations(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    List<String> recommendations = [];
    
    // Hasar bazlı öneriler
    if (finalStats['damage'] > 50) {
      if (rocketData['type'] == 'manual') {
        if (rocketData['material'] == 'Alüminyum') {
          recommendations.add('Daha dayanıklı malzeme kullanın (Karbonfiber veya Kompozit)');
        }
      }
      recommendations.add('Daha kolay bir ortamda test yapmayı deneyin');
    }
    
    // Yakıt bazlı öneriler
    if (finalStats['fuelLevel'] < 20) {
      if (rocketData['type'] == 'manual') {
        recommendations.add(localizations?.isTurkish == true ? 'Motor gücünü azaltarak yakıt tüketimini optimize edin' : 'Optimize fuel consumption by reducing engine power');
      }
      recommendations.add('Daha verimli yakıt türü seçmeyi deneyin');
    }
    
    // Sıcaklık bazlı öneriler
    if (finalStats['temperature'] > 100) {
      recommendations.add('Soğutma sistemi ekleyin veya ısı direnci yüksek malzeme kullanın');
    }
    if (finalStats['temperature'] < -150) {
      recommendations.add('Isıtma sistemi ekleyin veya soğuk direnci yüksek malzeme kullanın');
    }
    
    // Ortam bazlı öneriler
    switch (environment) {
      case 'Boşluk':
        recommendations.add('Derin uzay için önce daha kolay ortamlarda deneyim kazanın');
        break;
      case 'Mars':
        recommendations.add('Mars atmosferi için özel koruma sistemleri geliştirin');
        break;
      case 'Ay':
        recommendations.add('Ay yüzeyi için toz koruma sistemleri ekleyin');
        break;
    }
    
    // Kontrol sistemi önerisi
    if (rocketData['type'] == 'manual' && !rocketData['hasControlSystem']) {
      recommendations.add(localizations?.isTurkish == true ? 'Kontrol sistemi ekleyerek stabiliteyi artırın' : 'Increase stability by adding control system');
    }
    
    // Genel öneriler
    if (isSuccessful) {
      recommendations.add('Daha zor ortamlarda test yapmayı deneyin');
      recommendations.add('Roket tasarımınızı optimize ederek performansı artırın');
    } else {
      recommendations.add('Tasarım parametrelerini gözden geçirin');
      recommendations.add('Daha kolay ortamda deneyim kazanın');
    }
    
    return recommendations.take(4).toList(); // En fazla 4 öneri göster
  }
  
  /// GERÇEKÇİ FİZİK ANALİZİ
  Widget _buildPhysicsAnalysis(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science, color: Colors.purple, size: 24),
              SizedBox(width: 12),
              Text(
                'Fizik Analizi',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._generatePhysicsAnalysis(context),
        ],
      ),
    );
  }

  List<Widget> _generatePhysicsAnalysis(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    List<Widget> analysis = [];
    
    // Hız analizi
    double speed = finalStats['speed'];
    if (speed > 7800) {
      analysis.add(_buildAnalysisItem('Orbital Velocity', 'LEO hızı (7.8 km/s) aşıldı - Yörünge hızı başarıldı! 🚀', Colors.green));
    } else if (speed > 1000) {
      analysis.add(_buildAnalysisItem('High Velocity', localizations?.isTurkish == true ? 'Yüksek hız elde edildi (${speed.round()} m/s)' : 'High velocity achieved (${speed.round()} m/s)', Colors.blue));
    } else {
      analysis.add(_buildAnalysisItem('Low Velocity', localizations?.isTurkish == true ? 'Düşük hız - thrust/mass oranını artırın' : 'Low velocity - increase thrust/mass ratio', Colors.orange));
    }
    
    // Termal analiz
    double temp = finalStats['temperature'];
    if (temp > 1500) {
      analysis.add(_buildAnalysisItem('Thermal Runaway', localizations?.isTurkish == true ? 'Kritik sıcaklık - malzeme eriyor! (${temp.round()}°C)' : 'Critical temperature - material melting! (${temp.round()}°C)', Colors.red));
    } else if (temp > 500) {
      analysis.add(_buildAnalysisItem('High Temperature', localizations?.isTurkish == true ? 'Yüksek sıcaklık - soğutma gerekli (${temp.round()}°C)' : 'High temperature - cooling required (${temp.round()}°C)', Colors.orange));
    } else if (temp < -200) {
      analysis.add(_buildAnalysisItem('Cryogenic Freezing', localizations?.isTurkish == true ? 'Kriojenik donma - sistem durabilir (${temp.round()}°C)' : 'Cryogenic freezing - system may stop (${temp.round()}°C)', Colors.red));
    } else {
      analysis.add(_buildAnalysisItem('Thermal Management', localizations?.isTurkish == true ? 'Sıcaklık kontrol altında (${temp.round()}°C)' : 'Temperature under control (${temp.round()}°C)', Colors.green));
    }
    
    // Atmosferik basınç etkisi
    String pressureEffect = _calculatePressureEffect();
    analysis.add(_buildAnalysisItem('Atmospheric Pressure', pressureEffect, Colors.blue));
    
    // Yerçekimi etkisi
    String gravityEffect = _calculateGravityEffect();
    analysis.add(_buildAnalysisItem('Gravitational Force', gravityEffect, Colors.indigo));
    
    return analysis;
  }

  String _calculatePressureEffect() {
    switch (environment) {
      case 'LEO':
        return 'Yüksek atmosfer - düşük basınç (~0.001 Pa)';
      case 'Mars':
        return 'İnce Mars atmosferi - orta basınç (~600 Pa)';
      case 'Ay':
        return 'Ay vakumu - basınç yok (~0 Pa)';
      case 'Boşluk':
        return 'Tam vakum - hiç basınç yok';
      default:
        return 'Standart atmosferik basınç';
    }
  }

  String _calculateGravityEffect() {
    switch (environment) {
      case 'LEO':
        return 'Mikro-yerçekimi (~90% Dünya)';
      case 'Mars':
        return 'Mars yerçekimi (~38% Dünya - 3.71 m/s²)';
      case 'Ay':
        return 'Ay yerçekimi (~17% Dünya - 1.62 m/s²)';
      case 'Boşluk':
        return 'Sıfır yerçekimi - serbest düşüş';
      default:
        return 'Dünya yerçekimi (9.81 m/s²)';
    }
  }

  /// KİMYASAL ANALİZ
  Widget _buildChemicalAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.biotech, color: Colors.teal, size: 24),
              SizedBox(width: 12),
              Text(
                'Kimyasal Analiz',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._generateChemicalAnalysis(),
        ],
      ),
    );
  }

  List<Widget> _generateChemicalAnalysis() {
    List<Widget> analysis = [];
    
    // Yakıt kimyası
    String fuelType = _getFuelType();
    analysis.add(_buildAnalysisItem('Fuel Chemistry', fuelType, Colors.teal));
    
    // Yanma verimi
    double efficiency = _calculateCombustionEfficiency();
    Color efficiencyColor = efficiency > 85 ? Colors.green : efficiency > 70 ? Colors.orange : Colors.red;
    analysis.add(_buildAnalysisItem('Combustion Efficiency', '${efficiency.round()}% - ${_getEfficiencyStatus(efficiency)}', efficiencyColor));
    
    // Oksidizer tüketimi
    analysis.add(_buildAnalysisItem('Oxidizer Consumption', _getOxidizerAnalysis(), Colors.teal));
    
    // ISP (Specific Impulse)
    String ispAnalysis = _getISPAnalysis();
    analysis.add(_buildAnalysisItem('Specific Impulse', ispAnalysis, Colors.teal));
    
    return analysis;
  }

  String _getFuelType() {
    if (rocketData['type'] == 'preset') {
      String model = rocketData['model'];
      if (model.contains('SLS')) return 'RS-25 - Sıvı H₂/O₂ (Criojenik)';
      if (model.contains('Falcon')) return 'Merlin - RP-1/O₂ (Kerosene)';
      if (model.contains('Atlas')) return 'RD-180 - RP-1/O₂ (Kerosene)';
      if (model.contains('Electron')) return 'Rutherford - RP-1/O₂ (Elektrik pompalı)';
    }
    
    String fuelType = rocketData['fuelType'] ?? 'Unknown';
    switch (fuelType) {
      case 'Sıvı':
        return 'Sıvı yakıt - Yüksek performans';
      case 'Katı':
        return 'Katı yakıt - Güvenli ama düşük kontrol';
      case 'Hibrit':
        return 'Hibrit yakıt - Orta performans';
      default:
        return 'Bilinmeyen yakıt türü';
    }
  }

  double _calculateCombustionEfficiency() {
    double baseff = 85.0; // Temel verimlilik
    
    // Sıcaklık etkisi
    double temp = finalStats['temperature'];
    if (temp > 100) baseff -= (temp - 100) * 0.1; // Aşırı ısınma verimliliği düşürür
    if (temp < 0) baseff -= (0 - temp) * 0.05; // Soğuk da düşürür
    
    // Hasar etkisi
    double damage = finalStats['damage'];
    baseff -= damage * 0.2; // Hasar verimliliği etkiler
    
    // Ortam etkisi
    switch (environment) {
      case 'Boşluk':
        baseff += 10; // Vakumda daha iyi
        break;
      case 'Mars':
        baseff -= 5; // İnce atmosfer
        break;
    }
    
    return baseff.clamp(20, 98);
  }

  String _getEfficiencyStatus(double efficiency) {
    if (efficiency > 85) return 'Mükemmel yanma';
    if (efficiency > 70) return 'İyi yanma';
    if (efficiency > 50) return 'Orta yanma';
    return 'Zayıf yanma';
  }

  String _getOxidizerAnalysis() {
    double fuelLevel = finalStats['fuelLevel'];
    if (fuelLevel > 50) return 'Oksijen fazlası - ideal O/F ratio';
    if (fuelLevel > 20) return 'Dengeli oksidizer tüketimi';
    return 'Oksidizer yetersizliği - zengin karışım';
  }

  String _getISPAnalysis() {
    if (rocketData['type'] == 'preset') {
      String model = rocketData['model'];
      if (model.contains('SLS')) return '452s (vakum) - En yüksek ISP';
      if (model.contains('Falcon')) return '282s (deniz seviyesi) - Orta ISP';
      if (model.contains('Atlas')) return '311s (vakum) - İyi ISP';
      if (model.contains('Electron')) return '303s (vakum) - Küçük motor ISP';
    }
    return 'Hesaplanmış ISP: ~300s';
  }

  /// BAŞARILI BİLEŞENLER
  Widget _buildSuccessfulComponents(BuildContext context) {
    List<String> successfulComponents = _getSuccessfulComponents(context);
    if (successfulComponents.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Text(
                'Başarılı Sistem Bileşenleri',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...successfulComponents.map((component) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    component,
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  /// BAŞARISIZ BİLEŞENLER
  Widget _buildFailedComponents(BuildContext context) {
    List<String> failedComponents = _getFailedComponents(context);
    if (failedComponents.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
              SizedBox(width: 12),
              Text(
                'Başarısız Sistem Bileşenleri',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...failedComponents.map((component) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.close, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    component,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  List<String> _getSuccessfulComponents(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    List<String> successful = [];
    
    // Performans kontrolleri
    if (finalStats['speed'] > 100) successful.add(localizations?.isTurkish == true ? 'İtki Sistemi - Yeterli hız elde edildi' : 'Propulsion System - Sufficient velocity achieved');
    if (finalStats['fuelLevel'] > 20) successful.add(localizations?.isTurkish == true ? 'Yakıt Sistemi - Yeterli yakıt kaldı' : 'Fuel System - Sufficient fuel remaining');
    if (finalStats['temperature'] < 150 && finalStats['temperature'] > -100) successful.add(localizations?.isTurkish == true ? 'Termal Kontrol - Sıcaklık kontrolü başarılı' : 'Thermal Control - Temperature control successful');
    if (finalStats['damage'] < 50) successful.add('Yapısal İntegrité - Düşük hasar seviyesi');
    
    // Roket tipine özel kontroller
    if (rocketData['type'] == 'manual') {
      if (rocketData['hasControlSystem'] == true) successful.add(localizations?.isTurkish == true ? 'Kontrol Sistemi - Guidance çalışıyor' : 'Control System - Guidance working');
      if (rocketData['material'] == 'Karbonfiber') successful.add(localizations?.isTurkish == true ? 'Malzeme - Yüksek dayanım karbonfiber' : 'Material - High strength carbon fiber');
    } else {
      String model = rocketData['model'];
      if (model.contains('Falcon')) successful.add('Grid Fins - Aerodinamik kontrol');
      if (model.contains('SLS')) successful.add('RS-25 Motors - Yüksek performans');
    }
    
    // Ortam adaptasyonu
    switch (environment) {
      case 'LEO':
        if (finalStats['speed'] > 500) successful.add('Orbital Dynamics - LEO hızına yaklaşım');
        break;
      case 'Mars':
        if (finalStats['damage'] < 30) successful.add('Mars Adaptasyon - Atmosfer direnci');
        break;
    }
    
    return successful;
  }

  List<String> _getFailedComponents(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    List<String> failed = [];
    
    // Kritik arızalar
    if (finalStats['damage'] > 80) failed.add('Yapısal İntegrité - Kritik hasar, kırılma riski');
    if (finalStats['fuelLevel'] <= 0) failed.add(localizations?.isTurkish == true ? 'Yakıt Sistemi - Yakıt tükendi, motor durdu' : 'Fuel System - Fuel exhausted, engine stopped');
    if (finalStats['temperature'] > 200) failed.add(localizations?.isTurkish == true ? 'Termal Sistem - Aşırı ısınma, sistem arızası' : 'Thermal System - Overheating, system failure');
    if (finalStats['temperature'] < -200) failed.add(localizations?.isTurkish == true ? 'Kriojenik Sistem - Aşırı soğuma, donma' : 'Cryogenic System - Excessive cooling, freezing');
    
    // Performans yetersizlikleri
    if (finalStats['speed'] < 50) failed.add(localizations?.isTurkish == true ? 'İtki Sistemi - Yetersiz hız, düşük thrust' : 'Propulsion System - Insufficient velocity, low thrust');
    if (finalStats['speed'] > 8000 && environment != 'Boşluk') failed.add('Aerodinamik - Aşırı hız, atmosfer sürtünmesi');
    
    // Ortam spesifik arızalar
    switch (environment) {
      case 'Mars':
        if (finalStats['damage'] > 60) failed.add(localizations?.isTurkish == true ? 'Mars Toz Sistemi - Toz infiltrasyonu' : 'Mars Dust System - Dust infiltration');
        break;
      case 'Ay':
        if (finalStats['temperature'] < -150) failed.add('Ay Gece Soğuğu - Kriojenik donma');
        break;
      case 'Boşluk':
        if (finalStats['temperature'] > 150) failed.add('Güneş Radyasyonu - Aşırı ısınma');
        break;
    }
    
    return failed;
  }

  /// GERÇEK DÜNYA KARŞILAŞTIRMASI
  Widget _buildRealWorldComparison() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.compare, color: Colors.amber, size: 24),
              SizedBox(width: 12),
              Text(
                'Gerçek Dünya Karşılaştırması',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._generateRealWorldComparison(),
        ],
      ),
    );
  }

  List<Widget> _generateRealWorldComparison() {
    List<Widget> comparisons = [];
    
    // Gerçek roket karşılaştırması
    if (rocketData['type'] == 'preset') {
      String model = rocketData['model'];
      if (model.contains('Falcon 9')) {
        comparisons.add(_buildAnalysisItem(
          'SpaceX Falcon 9', 
          'Gerçek: 320 m/s MECO, Sizin: ${finalStats['speed'].round()} m/s', 
          _getComparisonColor(finalStats['speed'], 320)
        ));
      } else if (model.contains('SLS')) {
        comparisons.add(_buildAnalysisItem(
          'NASA SLS', 
          'Gerçek: 350 m/s MECO, Sizin: ${finalStats['speed'].round()} m/s', 
          _getComparisonColor(finalStats['speed'], 350)
        ));
      }
    }
    
    // Tarihi misyonlar
    if (environment == 'LEO') {
      comparisons.add(_buildAnalysisItem(
        'Apollo Program', 
        'Apollo 11: 11.1 km/s lunar velocity, ISS: 7.66 km/s', 
        Colors.amber
      ));
    }
    
    // Başarı oranı karşılaştırması
    String successComparison = _getSuccessRateComparison();
    comparisons.add(_buildAnalysisItem('Industry Success Rate', successComparison, Colors.amber));
    
    // Maliyet analizi
    String costAnalysis = _getCostAnalysis();
    comparisons.add(_buildAnalysisItem('Mission Cost', costAnalysis, Colors.amber));
    
    return comparisons;
  }

  Color _getComparisonColor(double actual, double target) {
    double ratio = actual / target;
    if (ratio >= 0.9 && ratio <= 1.1) return Colors.green;
    if (ratio >= 0.7 && ratio <= 1.3) return Colors.orange;
    return Colors.red;
  }

  String _getSuccessRateComparison() {
    if (isSuccessful) {
      return 'Başarılı! Endüstri ortalaması: SpaceX 95%, ULA 98%';
    } else {
      return 'Başarısız. Geri dönüşüm: Falcon 9 %85, New Shepard %100';
    }
  }

  String _getCostAnalysis() {
    if (rocketData['type'] == 'preset') {
      String model = rocketData['model'];
      if (model.contains('Falcon 9')) return 'Falcon 9: ~62M USD fırlatma maliyeti';
      if (model.contains('SLS')) return 'SLS: ~4.1B USD per mission (dev cost)';
      if (model.contains('Atlas')) return 'Atlas V: ~110M USD typical mission';
    }
    return 'Tahmini maliyet: Geliştirme aşamasında';
  }

  Widget _buildAnalysisItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Yeni Simülasyon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text(
              'Ana Sayfaya Dön',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

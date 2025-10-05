import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.about ?? 'About'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 0,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo ve başlık
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.orange.withOpacity(0.8),
                              Colors.red.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
                        ),
                        child: const Icon(
                          Icons.public,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        localizations?.impactSim ?? 'ImpactSim',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations?.planetaryDefenseSpaceTestSim ?? 'Planetary Defense and Space Test Simulation',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Main description
                _buildSection(
                  context,
                  localizations?.whatIsImpactSim ?? 'What is ImpactSim?',
                  localizations?.impactSimDesc ?? 'ImpactSim is an interactive space simulation platform where users can model rocket and satellite tests as well as asteroid impact scenarios. The application is based on scientific accuracy while making complex data accessible to everyone with its user-friendly interface.',
                  Icons.info_outline,
                  Colors.blue,
                ),
                
                const SizedBox(height: 24),
                
                // Amacımız
                _buildSection(
                  context,
                  localizations?.ourPurpose ?? '🎯 Our Purpose',
                  localizations?.purposeDesc ?? 'The main purpose of ImpactSim is to increase user awareness and learning in an interactive environment based on scientific principles.',
                  Icons.flag_outlined,
                  Colors.orange,
                  features: localizations?.isTurkish == true ? [
                    'Uzay teknolojilerini test etmelerini',
                    'Olası göktaşı çarpma senaryolarını analiz etmelerini', 
                    'Gerçek verilerle çarpma etkilerini modellemelerini',
                    'Gezegen savunma stratejileri geliştirmelerini',
                  ] : [
                    'Test space technologies',
                    'Analyze potential asteroid impact scenarios',
                    'Model impact effects with real data',
                    'Develop planetary defense strategies',
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Neden ImpactSim?
                _buildSection(
                  context,
                  localizations?.isTurkish == true ? '🌍 Neden ImpactSim?' : '🌍 Why ImpactSim?',
                  localizations?.isTurkish == true ? 'Gezegenimizi tehdit edebilecek gök cisimleri hakkında farkındalık oluşturmak, sadece bilim insanlarının değil, toplumun da sorumluluğudur.' : 'Creating awareness about celestial objects that could threaten our planet is the responsibility of not only scientists but also society.',
                  Icons.shield_outlined,
                  Colors.green,
                  capabilities: localizations?.isTurkish == true ? [
                    {
                      'title': 'Gerçek Zamanlı Veriler',
                      'description': 'NASA, USGS ve uluslararası veritabanlarından aldığı güncel bilgilerle çalışır',
                      'color': Colors.blue,
                    },
                    {
                      'title': 'Çoklu Savunma Senaryoları', 
                      'description': 'Kinetik çarpışma, yerçekimi traktörü ve lazer sapma gibi farklı savunma yöntemlerini simüle eder',
                      'color': Colors.purple,
                    },
                    {
                      'title': 'Kapsamlı Etki Analizi',
                      'description': 'Topografik, sismik ve iklimsel sonuçları görsel olarak sunar',
                      'color': Colors.red,
                    },
                    {
                      'title': 'Çoklu Mod Desteği',
                      'description': 'Eğitim, karar destek ve oyunlaştırma modlarıyla farklı kitlelere hitap eder',
                      'color': Colors.teal,
                    },
                  ] : [
                    {
                      'title': 'Real-Time Data',
                      'description': 'Works with current information from NASA, USGS and international databases',
                      'color': Colors.blue,
                    },
                    {
                      'title': 'Multiple Defense Scenarios', 
                      'description': 'Simulates different defense methods like kinetic impact, gravity tractor and laser deflection',
                      'color': Colors.purple,
                    },
                    {
                      'title': 'Comprehensive Impact Analysis',
                      'description': 'Presents topographic, seismic and climatic results visually',
                      'color': Colors.red,
                    },
                    {
                      'title': 'Multi-Mode Support',
                      'description': 'Appeals to different audiences with education, decision support and gamification modes',
                      'color': Colors.teal,
                    },
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Kimler için?
                _buildSection(
                  context,
                  localizations?.isTurkish == true ? '🧪 Kimler İçin Tasarlandı?' : '🧪 Who Is It Designed For?',
                  localizations?.isTurkish == true ? 'ImpactSim farklı kullanıcı gruplarının ihtiyaçlarını karşılamak üzere tasarlanmıştır.' : 'ImpactSim is designed to meet the needs of different user groups.',
                  Icons.people_outline,
                  Colors.purple,
                  targetAudience: localizations?.isTurkish == true ? [
                    {
                      'title': 'Öğrenciler ve Eğitimciler',
                      'description': 'Görsel öğrenme destekleriyle zenginleştirilmiş platform',
                      'icon': Icons.school,
                      'color': Colors.blue,
                    },
                    {
                      'title': 'Bilim İnsanları ve Mühendisler',
                      'description': 'Teknik detaylara dayalı veri analizi',
                      'icon': Icons.science,
                      'color': Colors.green,
                    },
                    {
                      'title': 'Politika Yapıcılar',
                      'description': 'Senaryo tabanlı karar destek araçları',
                      'icon': Icons.account_balance,
                      'color': Colors.orange,
                    },
                    {
                      'title': 'Genel Kullanıcılar',
                      'description': 'Oyunlaştırılmış ve eğitici deneyim',
                      'icon': Icons.videogame_asset,
                      'color': Colors.purple,
                    },
                  ] : [
                    {
                      'title': 'Students and Educators',
                      'description': 'Platform enriched with visual learning supports',
                      'icon': Icons.school,
                      'color': Colors.blue,
                    },
                    {
                      'title': 'Scientists and Engineers',
                      'description': 'Data analysis based on technical details',
                      'icon': Icons.science,
                      'color': Colors.green,
                    },
                    {
                      'title': 'Policy Makers',
                      'description': 'Scenario-based decision support tools',
                      'icon': Icons.account_balance,
                      'color': Colors.orange,
                    },
                    {
                      'title': 'General Users',
                      'description': 'Gamified and educational experience',
                      'icon': Icons.videogame_asset,
                      'color': Colors.purple,
                    },
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Bilim temelli simülasyon
                _buildSection(
                  context,
                  localizations?.isTurkish == true ? '🔬 Bilim Temelli, Erişilebilir Simülasyon' : '🔬 Science-Based, Accessible Simulation',
                  localizations?.isTurkish == true ? 'ImpactSim; yörünge hesaplamaları, çarpma fiziği, krater oluşumu, tsunami modellemeleri ve atmosferik etkiler gibi alanlarda fizik temelli hesaplamaları arka planda otomatik olarak işler. Kullanıcılar, karmaşık formüllerle uğraşmadan, etkileşimli olarak senaryolar oluşturabilir, etkilerini izleyebilir ve alternatif çözümler deneyebilir.' : 'ImpactSim automatically processes physics-based calculations in the background in areas such as orbital calculations, impact physics, crater formation, tsunami modeling and atmospheric effects. Users can interactively create scenarios, monitor their effects and try alternative solutions without dealing with complex formulas.',
                  Icons.biotech,
                  Colors.cyan,
                ),
                
                const SizedBox(height: 24),
                
                // Gelecek vizyonu
                _buildSection(
                  context,
                  localizations?.isTurkish == true ? '🚀 Gelecek Vizyonu' : '🚀 Future Vision',
                  localizations?.isTurkish == true ? 'ImpactSim, gelecekte aşağıdaki modüllerle genişletilmeye uygundur:' : 'ImpactSim is suitable for expansion with the following modules in the future:',
                  Icons.rocket_launch,
                  Colors.red,
                  futureModules: localizations?.isTurkish == true ? [
                    '🌌 Derin uzay görev senaryoları',
                    '🛰 Uydu yörünge çakışma analizleri', 
                    '🌋 Süper yanardağ ve iklim senaryolarıyla entegre afet analizleri',
                    '🤖 Yapay zeka destekli savunma stratejisi önerileri',
                  ] : [
                    '🌌 Deep space mission scenarios',
                    '🛰 Satellite orbital collision analyses', 
                    '🌋 Integrated disaster analyses with supervolcano and climate scenarios',
                    '🤖 AI-supported defense strategy recommendations',
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Veri kaynakları
                _buildSection(
                  context,
                  localizations?.isTurkish == true ? '📡 Veri Kaynaklarımız' : '📡 Our Data Sources',
                  localizations?.isTurkish == true ? 'Simülasyonlarımız güvenilir ve güncel veri kaynaklarından beslenir.' : 'Our simulations are fed from reliable and current data sources.',
                  Icons.storage,
                  Colors.indigo,
                  dataSources: localizations?.isTurkish == true ? [
                    {
                      'name': 'NASA Near Earth Object Web Service (NEO-WS)',
                      'type': 'Asteroit Verileri',
                      'color': Colors.blue,
                    },
                    {
                      'name': 'USGS Topografik ve Sismik Haritaları',
                      'type': 'Jeolojik Veriler',
                      'color': Colors.green,
                    },
                    {
                      'name': 'OpenStreetMap + Mapbox',
                      'type': 'Harita Verileri',
                      'color': Colors.orange,
                    },
                    {
                      'name': 'Bilimsel Literatür ve Fiziksel Modeller',
                      'type': 'Akademik Kaynaklar',
                      'color': Colors.purple,
                    },
                  ] : [
                    {
                      'name': 'NASA Near Earth Object Web Service (NEO-WS)',
                      'type': 'Asteroid Data',
                      'color': Colors.blue,
                    },
                    {
                      'name': 'USGS Topographic and Seismic Maps',
                      'type': 'Geological Data',
                      'color': Colors.green,
                    },
                    {
                      'name': 'OpenStreetMap + Mapbox',
                      'type': 'Map Data',
                      'color': Colors.orange,
                    },
                    {
                      'name': 'Scientific Literature and Physical Models',
                      'type': 'Academic Sources',
                      'color': Colors.purple,
                    },
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Lisans
                _buildSection(
                  context,
                  localizations?.isTurkish == true ? '📋 Lisans ve Kullanım Hakkı' : '📋 License and Usage Rights',
                  localizations?.isTurkish == true ? 'ImpactSim, bilimsel amaçlar, eğitim ve kamu bilinci oluşturmak için açık kaynak ilkeleriyle geliştirilmektedir. Tüm görsel ve hesaplama altyapısı, ilgili kaynaklara uygun olarak referanslandırılmıştır.' : 'ImpactSim is being developed with open source principles for scientific purposes, education and public awareness. All visual and computational infrastructure is referenced in accordance with relevant sources.',
                  Icons.balance,
                  Colors.teal,
                ),
                
                const SizedBox(height: 32),
                
                // Uyarı notu
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                        Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations?.isTurkish == true ? 'ÖNEMLİ NOT' : 'IMPORTANT NOTE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations?.isTurkish == true ? 'Uygulama içinde yapılan tüm senaryolar kurgusal ya da teoriktir. Gerçek dünyadaki afet yönetimi ve uzay savunma stratejileri, resmi kurumlar tarafından yürütülmektedir.' : 'All scenarios made within the application are fictional or theoretical. Disaster management and space defense strategies in the real world are carried out by official institutions.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sürüm bilgisi
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.2),
                          Colors.red.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'ImpactSim v2.0.0',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'NASA Space Apps Challenge 2025',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color themeColor, {
    List<String>? features,
    List<Map<String, dynamic>>? capabilities,
    List<Map<String, dynamic>>? targetAudience,
    List<String>? futureModules,
    List<Map<String, dynamic>>? dataSources,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withOpacity(0.1),
            themeColor.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: themeColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
          
          // Özellikler listesi
          if (features != null) ...[
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: themeColor,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          
          // Yetenekler
          if (capabilities != null) ...[
            const SizedBox(height: 16),
            ...capabilities.map((capability) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: capability['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: capability['color'].withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capability['title'],
                    style: TextStyle(
                      color: capability['color'],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    capability['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          
          // Hedef kitle - Wrap kullanarak overflow önle
          if (targetAudience != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: targetAudience.map((audience) => Container(
                width: (MediaQuery.of(context).size.width - 76) / 2, // Responsive width
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: audience['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: audience['color'].withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      audience['icon'],
                      color: audience['color'],
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      audience['title'],
                      style: TextStyle(
                        color: audience['color'],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      audience['description'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
          
          // Gelecek modülleri
          if (futureModules != null) ...[
            const SizedBox(height: 16),
            ...futureModules.map((module) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      module,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          
          // Veri kaynakları
          if (dataSources != null) ...[
            const SizedBox(height: 16),
            ...dataSources.map((source) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: source['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: source['color'].withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: source['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          source['type'],
                          style: TextStyle(
                            color: source['color'],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }
}

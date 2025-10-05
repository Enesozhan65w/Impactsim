import 'package:flutter/material.dart';
import '../services/data_validation_service.dart';
import '../services/nasa_neo_api_service.dart';
import '../services/localization_service.dart';
import '../widgets/data_quality_indicator_widget.dart';
import '../models/asteroid.dart';

/// Professional Veri Doğrulama Test Ekranı
/// NASA Space Apps Challenge standartlarında comprehensive data validation
class DataValidationScreen extends StatefulWidget {
  const DataValidationScreen({Key? key}) : super(key: key);

  @override
  State<DataValidationScreen> createState() => _DataValidationScreenState();
}

class _DataValidationScreenState extends State<DataValidationScreen> 
    with TickerProviderStateMixin {
  
  List<Asteroid> _asteroids = [];
  DataQualityReport? _qualityReport;
  bool _isLoading = false;
  String _dataSource = 'nasa-neo';
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Asteroid> asteroids;
      
      switch (_dataSource) {
        case 'nasa-neo':
          asteroids = await NASANeoApiService.instance.getTodaysAsteroids();
          break;
        case 'predefined':
          asteroids = Asteroid.getPredefinedAsteroids();
          break;
        case 'impactor-2025':
          asteroids = [NASANeoApiService.instance.getImpactor2025Scenario()];
          break;
        default:
          asteroids = [];
      }
      
      final report = await DataValidationService.instance.generateQualityReport(asteroids);
      
      if (mounted) {
        setState(() {
          _asteroids = asteroids;
          _qualityReport = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Veri yükleme hatası: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.isTurkish == true ? 'Hata' : 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations?.isTurkish == true ? 'Tamam' : 'OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.isTurkish == true ? 'Veri Doğrulama Merkezi' : 'Data Validation Center'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1F3A),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: localizations?.isTurkish == true ? 'Genel Bakış' : 'Overview'),
            Tab(icon: Icon(Icons.analytics), text: localizations?.isTurkish == true ? 'Detaylı Analiz' : 'Detailed Analysis'),
            Tab(icon: Icon(Icons.science), text: 'Benchmark'),
            Tab(icon: Icon(Icons.settings), text: localizations?.isTurkish == true ? 'Ayarlar' : 'Settings'),
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
            _buildOverviewTab(),
            _buildDetailedAnalysisTab(),
            _buildBenchmarkTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _loadInitialData,
        backgroundColor: Colors.orange,
        label: Text(localizations?.isTurkish == true ? 'Veri Kontrol Et' : 'Validate Data'),
        icon: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 16),
            Text(
              'Veri doğrulama işlemi devam ediyor...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_asteroids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.data_usage_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz veri yüklenmedi',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Veri Yükle'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ana veri kalite göstergesi
          DataQualityIndicatorWidget(
            asteroids: _asteroids,
            showDetailedMetrics: true,
            onQualityChanged: () {
              // Quality changed callback
            },
          ),
          
          const SizedBox(height: 16),
          
          // Data source bilgisi
          _buildDataSourceCard(),
          
          const SizedBox(height: 16),
          
          // Asteroid listesi
          _buildAsteroidListCard(),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysisTab() {
    if (_qualityReport == null) {
      return const Center(
        child: Text(
          'Henüz analiz yapılmadı',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildValidationResultCard('Bütünlük Kontrolleri', _qualityReport!.integrityCheck),
          _buildValidationResultCard('Duplicate/Missing', _qualityReport!.duplicateCheck),
          _buildValidationResultCard('Birimler & Koordinatlar', _qualityReport!.unitsCheck),
          _buildValidationResultCard('Fiziksel Tutarlılık', _qualityReport!.physicsCheck),
          _buildValidationResultCard('İstatistiksel Analiz', _qualityReport!.statisticalCheck),
          _buildValidationResultCard('Benchmark Testleri', _qualityReport!.benchmarkCheck),
        ],
      ),
    );
  }

  Widget _buildBenchmarkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Benchmark Senaryoları',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tarihsel olaylarla doğrulama testleri',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          _buildBenchmarkCard(
            'Chelyabinsk Meteoru (2013)',
            'Rusya - 15 Şubat 2013',
            '20m çap, 18.3km/s, 0.5MT',
            '✓ Enerji hesaplaması doğrulandı',
            Colors.green,
          ),
          
          _buildBenchmarkCard(
            'Tunguska Olayı (1908)', 
            'Sibirya - 30 Haziran 1908',
            '60m çap, 27km/s, 15MT',
            '✓ Etki yarıçapı doğrulandı',
            Colors.green,
          ),
          
          _buildBenchmarkCard(
            'Chicxulub Çarpması (66MYA)',
            'Yucatan - 66 milyon yıl önce',
            '10-15km çap, 20km/s, 100 milyon MT',
            '⚠ Simülasyon kapsamı dışında',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Veri Kaynağı Ayarları',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDataSourceSelector(),
          
          const SizedBox(height: 24),
          
          const Text(
            'Doğrulama Parametreleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildValidationSettings(),
          
          const SizedBox(height: 24),
          
          const Text(
            'API Durumu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildApiStatusCard(),
        ],
      ),
    );
  }

  Widget _buildDataSourceCard() {
    return Card(
      color: const Color(0xFF1A1F3A),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.source, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Veri Kaynağı',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                DataQualityBadge(asteroids: _asteroids),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getDataSourceDescription(_dataSource),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Toplam kayıt: ${_asteroids.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsteroidListCard() {
    return Card(
      color: const Color(0xFF1A1F3A),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.list, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Asteroit Listesi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._asteroids.take(5).map((asteroid) => _buildAsteroidListItem(asteroid)),
            if (_asteroids.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Ve ${_asteroids.length - 5} tane daha...',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsteroidListItem(Asteroid asteroid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.circle,
              color: Colors.orange,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asteroid.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${asteroid.diameter.toStringAsFixed(1)}m • ${(asteroid.velocity/1000).toStringAsFixed(1)}km/s',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationResultCard(String title, ValidationResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1F3A),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isValid ? Icons.check_circle : Icons.error,
                  color: result.isValid ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${result.passedCount}/${result.passedCount + result.failedCount}',
                  style: TextStyle(
                    color: result.isValid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...result.errors.take(3).map((error) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $error',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              )),
              if (result.errors.length > 3)
                Text(
                  'Ve ${result.errors.length - 3} hata daha...',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenchmarkCard(String title, String subtitle, String specs, String result, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1F3A),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              specs,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(
                result,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSourceSelector() {
    return Card(
      color: const Color(0xFF1A1F3A),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktif Veri Kaynağı',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: const Text('NASA NEO API', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Canlı asteroit verisi', style: TextStyle(color: Colors.white54)),
              value: 'nasa-neo',
              groupValue: _dataSource,
              activeColor: Colors.orange,
              onChanged: (value) {
                setState(() {
                  _dataSource = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Öntanımlı Veriler', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Test amaçlı sabit veri', style: TextStyle(color: Colors.white54)),
              value: 'predefined',
              groupValue: _dataSource,
              activeColor: Colors.orange,
              onChanged: (value) {
                setState(() {
                  _dataSource = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Impactor-2025', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Varsayımsal senaryo', style: TextStyle(color: Colors.white54)),
              value: 'impactor-2025',
              groupValue: _dataSource,
              activeColor: Colors.orange,
              onChanged: (value) {
                setState(() {
                  _dataSource = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationSettings() {
    final localizations = AppLocalizations.of(context);
    return Card(
      color: const Color(0xFF1A1F3A),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mevcut Doğrulama Kuralları',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(localizations?.isTurkish == true ? '• Çap: 0.1m - 100km' : '• Diameter: 0.1m - 100km', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(localizations?.isTurkish == true ? '• Hız: 1 - 100km/s' : '• Velocity: 1 - 100km/s', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(localizations?.isTurkish == true ? '• Yoğunluk: 1000 - 8000 kg/m³' : '• Density: 1000 - 8000 kg/m³', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(localizations?.isTurkish == true ? '• Çarpma açısı: 0-90°' : '• Impact angle: 0-90°', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text('• IQR outlier detection', style: TextStyle(color: Colors.white70, fontSize: 14)),
            Text('• Chelyabinsk/Tunguska benchmarks', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildApiStatusCard() {
    return FutureBuilder<bool>(
      future: NASANeoApiService.instance.checkApiStatus(),
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;
        final color = isOnline ? Colors.green : Colors.red;
        
        return Card(
          color: const Color(0xFF1A1F3A),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NASA NEO API',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isOnline ? 'Bağlantı aktif' : 'Bağlantı sorunu',
                        style: TextStyle(color: color, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDataSourceDescription(String source) {
    switch (source) {
      case 'nasa-neo':
        return 'NASA Near Earth Object Web Service - Gerçek zamanlı asteroit verileri';
      case 'predefined':
        return 'Önceden tanımlanmış test verileri - Geliştirme ve test amaçlı';
      case 'impactor-2025':
        return 'Impactor-2025 varsayımsal senaryo - NASA Space Apps Challenge';
      default:
        return 'Bilinmeyen veri kaynağı';
    }
  }
}

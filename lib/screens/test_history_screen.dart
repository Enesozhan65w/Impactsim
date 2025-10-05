import 'package:flutter/material.dart';
import '../services/test_storage_service.dart';
import '../models/test_result.dart';
import 'test_detail_screen.dart';
import '../services/localization_service.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  List<TestResult> _testResults = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String _filterType = 'all'; // all, successful, failed

  @override
  void initState() {
    super.initState();
    _loadTestResults();
  }

  Future<void> _loadTestResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await TestStorageService.instance.getTestResults();
      final stats = await TestStorageService.instance.getStatistics();
      
      setState(() {
        _testResults = results;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Test sonuçları yükleme hatası: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<TestResult> get _filteredResults {
    switch (_filterType) {
      case 'successful':
        return _testResults.where((result) => result.isSuccessful).toList();
      case 'failed':
        return _testResults.where((result) => !result.isSuccessful).toList();
      default:
        return _testResults;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.testHistory ?? 'Test History'),
        centerTitle: true,
        actions: [
          if (_testResults.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showClearAllDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_forever, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(localizations?.isTurkish == true ? 'Tümünü Sil' : 'Delete All'),
                    ],
                  ),
                ),
              ],
            ),
        ],
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _testResults.isEmpty
                ? _buildEmptyState()
                : _buildTestHistory(),
      ),
    );
  }

  Widget _buildEmptyState() {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              localizations?.isTurkish == true ? 'Henüz Test Yok' : 'No Tests Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations?.isTurkish == true ? 'İlk simülasyonunuzu başlatın ve sonuçlarınız burada görünecek!' : 'Start your first simulation and your results will appear here!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: Text(localizations?.isTurkish == true ? 'Ana Sayfaya Dön' : 'Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestHistory() {
    return Column(
      children: [
        // İstatistikler
        _buildStatistics(),
        
        // Filtreler
        _buildFilters(),
        
        // Test listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredResults.length,
            itemBuilder: (context, index) {
              final result = _filteredResults[index];
              return _buildTestCard(result);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final localizations = AppLocalizations.of(context);
    if (_statistics.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.isTurkish == true ? 'Test İstatistikleri' : 'Test Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  localizations?.isTurkish == true ? 'Toplam Test' : 'Total Tests',
                  '${_statistics['totalTests']}',
                  Icons.science,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  localizations?.isTurkish == true ? 'Başarılı' : 'Successful',
                  '${_statistics['successfulTests']}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  localizations?.isTurkish == true ? 'Başarısız' : 'Failed',
                  '${_statistics['failedTests']}',
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  localizations?.isTurkish == true ? 'Başarı Oranı' : 'Success Rate',
                  '${_statistics['successRate'].round()}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  localizations?.isTurkish == true ? 'Ort. Başarı' : 'Avg. Success',
                  '${_statistics['averageSuccessPercentage'].round()}%',
                  Icons.analytics,
                  Colors.purple,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final localizations = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(localizations?.isTurkish == true ? 'Tümü' : 'All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip(localizations?.isTurkish == true ? 'Başarılı' : 'Successful', 'successful'),
          const SizedBox(width: 8),
          _buildFilterChip(localizations?.isTurkish == true ? 'Başarısız' : 'Failed', 'failed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
      },
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: const Color(0xFF4A90E2).withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF4A90E2) : Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildTestCard(TestResult result) {
    final localizations = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestDetailScreen(testResult: result),
            ),
          );
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.rocketName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.environment,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: result.isSuccessful ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      result.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result.summary,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${result.date.day}/${result.date.month}/${result.date.year} ${result.date.hour}:${result.date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${localizations?.isTurkish == true ? 'Başarı' : 'Success'}: ${result.successPercentage.round()}%',
                    style: TextStyle(
                      color: result.isSuccessful ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(
          localizations?.isTurkish == true ? 'Tüm Testleri Sil' : 'Delete All Tests',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          localizations?.isTurkish == true ? 'Tüm test sonuçlarını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.' : 'Are you sure you want to delete all test results? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations?.isTurkish == true ? 'İptal' : 'Cancel',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await TestStorageService.instance.clearAllTestResults();
              _loadTestResults();
            },
            child: Text(
              localizations?.isTurkish == true ? 'Sil' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

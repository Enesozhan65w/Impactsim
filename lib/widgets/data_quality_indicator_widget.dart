import 'package:flutter/material.dart';
import '../services/data_validation_service.dart';
import '../models/asteroid.dart';

/// Professional Veri Kalite Göstergesi Widget'ı
/// NASA Space Apps Challenge standartlarında veri güvenilirliği gösterimi
class DataQualityIndicatorWidget extends StatefulWidget {
  final List<Asteroid> asteroids;
  final bool showDetailedMetrics;
  final bool autoRefresh;
  final VoidCallback? onQualityChanged;

  const DataQualityIndicatorWidget({
    Key? key,
    required this.asteroids,
    this.showDetailedMetrics = false,
    this.autoRefresh = true,
    this.onQualityChanged,
  }) : super(key: key);

  @override
  State<DataQualityIndicatorWidget> createState() => _DataQualityIndicatorWidgetState();
}

class _DataQualityIndicatorWidgetState extends State<DataQualityIndicatorWidget> with TickerProviderStateMixin {
  DataQualityReport? _qualityReport;
  bool _isLoading = false;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _performQualityCheck();
    
    // Auto-refresh if enabled
    if (widget.autoRefresh) {
      _startAutoRefresh();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(minutes: 5), () {
      if (mounted) {
        _performQualityCheck();
        _startAutoRefresh();
      }
    });
  }

  Future<void> _performQualityCheck() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final report = await DataValidationService.instance.generateQualityReport(widget.asteroids);
      
      if (mounted) {
        setState(() {
          _qualityReport = report;
          _isLoading = false;
        });
        
        _progressController.forward(from: 0);
        
        if (widget.onQualityChanged != null) {
          widget.onQualityChanged!();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _qualityReport == null) {
      return _buildLoadingIndicator();
    }
    
    if (_qualityReport == null) {
      return _buildErrorIndicator();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1A1F3A),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1F3A),
              const Color(0xFF2A2F4A).withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildQualityScoreIndicator(),
            const SizedBox(height: 16),
            _buildStatusBadges(),
            if (widget.showDetailedMetrics) ...[
              const SizedBox(height: 16),
              _buildDetailedMetrics(),
            ],
            const SizedBox(height: 12),
            _buildLastUpdated(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1A1F3A),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + (_pulseController.value * 0.1),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Veri Kalitesi Analiz Ediliyor...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.red.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Veri Kalitesi Analizi Başarısız',
              style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _performQualityCheck,
              child: const Text('Yeniden Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(_qualityReport!.status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.verified_user,
            color: _getStatusColor(_qualityReport!.status),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Veri Kalite Durumu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _performQualityCheck,
          ),
      ],
    );
  }

  Widget _buildQualityScoreIndicator() {
    final score = _qualityReport!.overallQualityScore;
    final color = _getStatusColor(_qualityReport!.status);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Genel Kalite Skoru',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              '${score.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: (score / 100) * _progressController.value,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadges() {
    final checks = [
      ('Bütünlük', _qualityReport!.integrityCheck.isValid, Icons.fact_check),
      ('Dublicate', _qualityReport!.duplicateCheck.isValid, Icons.content_copy),
      ('Birimler', _qualityReport!.unitsCheck.isValid, Icons.straighten),
      ('Fizik', _qualityReport!.physicsCheck.isValid, Icons.science),
      ('İstatistik', _qualityReport!.statisticalCheck.isValid, Icons.trending_up),
      ('Benchmark', _qualityReport!.benchmarkCheck.isValid, Icons.verified),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: checks.map((check) => _buildStatusBadge(
        check.$1,
        check.$2,
        check.$3,
      )).toList(),
    );
  }

  Widget _buildStatusBadge(String label, bool isValid, IconData icon) {
    final color = isValid ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detaylı Metrikler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetricRow('Toplam Kayıt', '${widget.asteroids.length}'),
          _buildMetricRow('Geçerli Kayıt', '${_getValidRecordCount()}'),
          _buildMetricRow('Hata Oranı', '${_getErrorPercentage().toStringAsFixed(1)}%'),
          _buildMetricRow('Eksik Veri', '${_getNullPercentage().toStringAsFixed(1)}%'),
          _buildMetricRow('Outlier Sayısı', '${_getOutlierCount()}'),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    final lastUpdated = _qualityReport!.generatedAt;
    final timeAgo = DateTime.now().difference(lastUpdated);
    
    String timeAgoText;
    if (timeAgo.inMinutes < 1) {
      timeAgoText = 'Az önce';
    } else if (timeAgo.inHours < 1) {
      timeAgoText = '${timeAgo.inMinutes} dakika önce';
    } else if (timeAgo.inDays < 1) {
      timeAgoText = '${timeAgo.inHours} saat önce';
    } else {
      timeAgoText = '${timeAgo.inDays} gün önce';
    }

    return Row(
      children: [
        Icon(
          Icons.access_time,
          color: Colors.white54,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          'Son güncelleme: $timeAgoText',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(DataQualityStatus status) {
    switch (status) {
      case DataQualityStatus.excellent:
        return Colors.green;
      case DataQualityStatus.good:
        return Colors.lightGreen;
      case DataQualityStatus.fair:
        return Colors.orange;
      case DataQualityStatus.poor:
        return Colors.red;
      case DataQualityStatus.unknown:
        return Colors.grey;
    }
  }

  int _getValidRecordCount() {
    if (_qualityReport == null) return 0;
    return _qualityReport!.integrityCheck.passedCount;
  }

  double _getErrorPercentage() {
    if (_qualityReport == null || widget.asteroids.isEmpty) return 0;
    final totalErrors = _qualityReport!.integrityCheck.failedCount +
        _qualityReport!.duplicateCheck.failedCount +
        _qualityReport!.unitsCheck.failedCount +
        _qualityReport!.physicsCheck.failedCount;
    return (totalErrors / widget.asteroids.length) * 100;
  }

  double _getNullPercentage() {
    if (_qualityReport == null) return 0;
    return _qualityReport!.duplicateCheck.nullPercentage;
  }

  int _getOutlierCount() {
    if (_qualityReport == null) return 0;
    return _qualityReport!.statisticalCheck.failedCount;
  }
}

/// Compact Veri Kalite Badge (küçük gösterim için)
class DataQualityBadge extends StatelessWidget {
  final List<Asteroid> asteroids;
  final VoidCallback? onTap;

  const DataQualityBadge({
    Key? key,
    required this.asteroids,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataQualityReport>(
      future: DataValidationService.instance.generateQualityReport(asteroids),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingBadge();
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorBadge();
        }
        
        final report = snapshot.data!;
        final color = _getStatusColor(report.status);
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${report.overallQualityScore.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 6),
          Text(
            'Kontrol...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error,
            color: Colors.red,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            'Hata',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DataQualityStatus status) {
    switch (status) {
      case DataQualityStatus.excellent:
        return Colors.green;
      case DataQualityStatus.good:
        return Colors.lightGreen;
      case DataQualityStatus.fair:
        return Colors.orange;
      case DataQualityStatus.poor:
        return Colors.red;
      case DataQualityStatus.unknown:
        return Colors.grey;
    }
  }
}

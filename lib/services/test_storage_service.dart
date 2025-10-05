import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_result.dart';

class TestStorageService {
  static TestStorageService? _instance;
  static TestStorageService get instance => _instance ??= TestStorageService._();
  
  TestStorageService._();
  
  static const String _testResultsKey = 'test_results';
  static const int _maxResults = 50; // Maksimum 50 test sonucu sakla
  
  /// Test sonucunu kaydet
  Future<void> saveTestResult(TestResult testResult) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Mevcut sonuçları al
      List<TestResult> results = await getTestResults();
      
      // Yeni sonucu başa ekle
      results.insert(0, testResult);
      
      // Maksimum sayıyı aş
      if (results.length > _maxResults) {
        results = results.take(_maxResults).toList();
      }
      
      // JSON'a çevir ve kaydet
      final jsonList = results.map((result) => result.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await prefs.setString(_testResultsKey, jsonString);
      
      print('Test sonucu kaydedildi: ${testResult.id}');
    } catch (e) {
      print('Test sonucu kaydetme hatası: $e');
    }
  }
  
  /// Tüm test sonuçlarını al
  Future<List<TestResult>> getTestResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_testResultsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => TestResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Test sonuçları alma hatası: $e');
      return [];
    }
  }
  
  /// Belirli bir test sonucunu al
  Future<TestResult?> getTestResult(String id) async {
    try {
      final results = await getTestResults();
      return results.firstWhere(
        (result) => result.id == id,
        orElse: () => throw StateError('Test bulunamadı'),
      );
    } catch (e) {
      print('Test sonucu alma hatası: $e');
      return null;
    }
  }
  
  /// Test sonucunu sil
  Future<void> deleteTestResult(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<TestResult> results = await getTestResults();
      
      results.removeWhere((result) => result.id == id);
      
      final jsonList = results.map((result) => result.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await prefs.setString(_testResultsKey, jsonString);
      
      print('Test sonucu silindi: $id');
    } catch (e) {
      print('Test sonucu silme hatası: $e');
    }
  }
  
  /// Tüm test sonuçlarını sil
  Future<void> clearAllTestResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_testResultsKey);
      print('Tüm test sonuçları silindi');
    } catch (e) {
      print('Test sonuçları silme hatası: $e');
    }
  }
  
  /// İstatistikleri al
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final results = await getTestResults();
      
      if (results.isEmpty) {
        return {
          'totalTests': 0,
          'successfulTests': 0,
          'failedTests': 0,
          'successRate': 0.0,
          'averageSuccessPercentage': 0.0,
          'mostUsedEnvironment': 'Yok',
          'mostUsedRocket': 'Yok',
        };
      }
      
      final totalTests = results.length;
      final successfulTests = results.where((r) => r.isSuccessful).length;
      final failedTests = totalTests - successfulTests;
      final successRate = (successfulTests / totalTests) * 100;
      
      final averageSuccessPercentage = results
          .map((r) => r.successPercentage)
          .reduce((a, b) => a + b) / totalTests;
      
      // En çok kullanılan ortam
      final environmentCounts = <String, int>{};
      for (final result in results) {
        environmentCounts[result.environment] = 
            (environmentCounts[result.environment] ?? 0) + 1;
      }
      final mostUsedEnvironment = environmentCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      // En çok kullanılan roket
      final rocketCounts = <String, int>{};
      for (final result in results) {
        rocketCounts[result.rocketName] = 
            (rocketCounts[result.rocketName] ?? 0) + 1;
      }
      final mostUsedRocket = rocketCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      return {
        'totalTests': totalTests,
        'successfulTests': successfulTests,
        'failedTests': failedTests,
        'successRate': successRate,
        'averageSuccessPercentage': averageSuccessPercentage,
        'mostUsedEnvironment': mostUsedEnvironment,
        'mostUsedRocket': mostUsedRocket,
      };
    } catch (e) {
      print('İstatistik alma hatası: $e');
      return {
        'totalTests': 0,
        'successfulTests': 0,
        'failedTests': 0,
        'successRate': 0.0,
        'averageSuccessPercentage': 0.0,
        'mostUsedEnvironment': 'Hata',
        'mostUsedRocket': 'Hata',
      };
    }
  }
  
  /// Ortam bazlı sonuçları al
  Future<List<TestResult>> getTestResultsByEnvironment(String environment) async {
    final results = await getTestResults();
    return results.where((result) => result.environment == environment).toList();
  }
  
  /// Başarılı testleri al
  Future<List<TestResult>> getSuccessfulTests() async {
    final results = await getTestResults();
    return results.where((result) => result.isSuccessful).toList();
  }
  
  /// Başarısız testleri al
  Future<List<TestResult>> getFailedTests() async {
    final results = await getTestResults();
    return results.where((result) => !result.isSuccessful).toList();
  }
}

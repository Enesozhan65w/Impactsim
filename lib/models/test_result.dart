class TestResult {
  final String id;
  final DateTime date;
  final Map<String, dynamic> rocketData;
  final String environment;
  final bool isSuccessful;
  final double successPercentage;
  final Map<String, dynamic> finalStats;
  final int duration; // saniye cinsinden

  TestResult({
    required this.id,
    required this.date,
    required this.rocketData,
    required this.environment,
    required this.isSuccessful,
    required this.successPercentage,
    required this.finalStats,
    required this.duration,
  });

  // JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'rocketData': rocketData,
      'environment': environment,
      'isSuccessful': isSuccessful,
      'successPercentage': successPercentage,
      'finalStats': finalStats,
      'duration': duration,
    };
  }

  // JSON'dan oluştur
  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'],
      date: DateTime.parse(json['date']),
      rocketData: Map<String, dynamic>.from(json['rocketData']),
      environment: json['environment'],
      isSuccessful: json['isSuccessful'],
      successPercentage: json['successPercentage'].toDouble(),
      finalStats: Map<String, dynamic>.from(json['finalStats']),
      duration: json['duration'],
    );
  }

  // Roket adını al
  String get rocketName {
    if (rocketData['type'] == 'manual') {
      return 'Özel Roket (${rocketData['weight']}kg)';
    } else {
      return rocketData['model'] ?? 'Bilinmeyen Model';
    }
  }

  // Başarı durumu metni
  String get statusText {
    if (isSuccessful) {
      return 'Başarılı';
    } else {
      return 'Başarısız';
    }
  }

  // Başarı rengi
  String get statusColor {
    if (successPercentage >= 80) {
      return 'green';
    } else if (successPercentage >= 50) {
      return 'orange';
    } else {
      return 'red';
    }
  }

  // Özet bilgi
  String get summary {
    final speed = (finalStats['speed'] as double).round();
    final fuel = (finalStats['fuelLevel'] as double).round();
    final damage = (finalStats['damage'] as double).round();
    
    return 'Hız: ${speed}m/s, Yakıt: ${fuel}%, Hasar: ${damage}%';
  }
}

import 'package:flutter/material.dart';

/// Dil seçenekleri
enum AppLanguage {
  turkish,
  english,
}

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.turkish:
        return 'tr';
      case AppLanguage.english:
        return 'en';
    }
  }
  
  String get name {
    switch (this) {
      case AppLanguage.turkish:
        return 'Türkçe';
      case AppLanguage.english:
        return 'English';
    }
  }
  
  Locale get locale {
    return Locale(code);
  }
}

/// Çeviri metinleri
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  bool get isTurkish => locale.languageCode == 'tr';
  bool get isEnglish => locale.languageCode == 'en';
  
  // Ana sayfa metinleri
  String get appTitle => isTurkish ? 'Space Test Simulator' : 'Space Test Simulator';
  String get welcomeTitle => isTurkish ? 'Uzay Simülatörüne Hoş Geldiniz' : 'Welcome to Space Simulator';
  String get welcomeSubtitle => isTurkish ? 'NASA standartlarında gerçekçi roket ve asteroid simülasyonları' : 'NASA-standard realistic rocket and asteroid simulations';
  
  // Menü öğeleri
  String get rocketSimulation => isTurkish ? 'Roket Simülasyonu' : 'Rocket Simulation';
  String get asteroidSimulation => isTurkish ? 'Asteroid Simülasyonu' : 'Asteroid Simulation';
  String get impactor2025 => isTurkish ? 'Impactor-2025 Senaryosu' : 'Impactor-2025 Scenario';
  String get testHistory => isTurkish ? 'Test Geçmişi' : 'Test History';
  String get about => isTurkish ? 'Hakkında' : 'About';
  
  // Roket tasarım metinleri
  String get rocketDesign => isTurkish ? 'Roket Tasarımı' : 'Rocket Design';
  String get selectRocketType => isTurkish ? 'Roket Türünü Seçin' : 'Select Rocket Type';
  String get presetRockets => isTurkish ? 'Hazır Modeller' : 'Preset Models';
  String get customDesign => isTurkish ? 'Özel Tasarım' : 'Custom Design';
  
  // Roket özellikleri
  String get material => isTurkish ? 'Malzeme' : 'Material';
  String get fuelType => isTurkish ? 'Yakıt Türü' : 'Fuel Type';
  String get weight => isTurkish ? 'Ağırlık' : 'Weight';
  String get motorPower => isTurkish ? 'Motor Gücü' : 'Motor Power';
  String get controlSystem => isTurkish ? 'Kontrol Sistemi' : 'Control System';
  String get hasControlSystem => isTurkish ? 'Var' : 'Available';
  String get noControlSystem => isTurkish ? 'Yok' : 'Not Available';
  
  // Malzemeler
  String get aluminum => isTurkish ? 'Alüminyum' : 'Aluminum';
  String get carbonFiber => isTurkish ? 'Karbonfiber' : 'Carbon Fiber';
  String get composite => isTurkish ? 'Kompozit' : 'Composite';
  String get steel => isTurkish ? 'Çelik' : 'Steel';
  
  // Yakıt türleri
  String get liquid => isTurkish ? 'Sıvı' : 'Liquid';
  String get solid => isTurkish ? 'Katı' : 'Solid';
  String get hybrid => isTurkish ? 'Hibrit' : 'Hybrid';
  
  // Ortam seçimi
  String get environmentSelection => isTurkish ? 'Simülasyon Ortamı' : 'Simulation Environment';
  String get selectTestEnvironment => isTurkish ? 'Test Ortamını Seçin' : 'Select Test Environment';
  String get rocketSummary => isTurkish ? 'Roket Özeti' : 'Rocket Summary';
  
  // Ortamlar
  String get leo => isTurkish ? 'Alçak Dünya Yörüngesi' : 'Low Earth Orbit';
  String get moon => isTurkish ? 'Ay Yüzeyi' : 'Moon Surface';
  String get mars => isTurkish ? 'Mars Atmosferi' : 'Mars Atmosphere';
  String get deepSpace => isTurkish ? 'Derin Uzay' : 'Deep Space';
  
  // Zorluk seviyeleri
  String get easy => isTurkish ? 'Kolay' : 'Easy';
  String get medium => isTurkish ? 'Orta' : 'Medium';
  String get hard => isTurkish ? 'Zor' : 'Hard';
  String get veryHard => isTurkish ? 'Çok Zor' : 'Very Hard';
  
  // Simülasyon metinleri
  String get simulation => isTurkish ? 'Simülasyon' : 'Simulation';
  String get simulationRunning => isTurkish ? 'Simülasyon İlerliyor...' : 'Simulation Running...';
  String get simulationProgress => isTurkish ? 'Simülasyon İlerliyor...' : 'Simulation in Progress...';
  String get startSimulation => isTurkish ? 'Simülasyonu Başlat' : 'Start Simulation';
  
  // Parametreler
  String get speed => isTurkish ? 'Hız' : 'Speed';
  String get temperature => isTurkish ? 'Sıcaklık' : 'Temperature';
  String get fuel => isTurkish ? 'Yakıt' : 'Fuel';
  String get damage => isTurkish ? 'Hasar' : 'Damage';
  String get finalSpeed => isTurkish ? 'Son Hız' : 'Final Speed';
  String get finalTemperature => isTurkish ? 'Son Sıcaklık' : 'Final Temperature';
  String get remainingFuel => isTurkish ? 'Kalan Yakıt' : 'Remaining Fuel';
  String get totalDamage => isTurkish ? 'Toplam Hasar' : 'Total Damage';
  
  // Sonuçlar
  String get simulationResults => isTurkish ? 'Simülasyon Sonuçları' : 'Simulation Results';
  String get simulationSuccessful => isTurkish ? 'Simülasyon Başarılı!' : 'Simulation Successful!';
  String get simulationFailed => isTurkish ? 'Simülasyon Başarısız' : 'Simulation Failed';
  String get successRate => isTurkish ? 'Başarı Oranı' : 'Success Rate';
  String get testCompleted => isTurkish ? 'ortamında test tamamlandı' : 'environment test completed';
  String get finalStatistics => isTurkish ? 'Final İstatistikleri' : 'Final Statistics';
  
  // Analiz bölümleri
  String get physicsAnalysis => isTurkish ? 'Fizik Analizi' : 'Physics Analysis';
  String get chemicalAnalysis => isTurkish ? 'Kimyasal Analiz' : 'Chemical Analysis';
  String get successfulComponents => isTurkish ? 'Başarılı Sistem Bileşenleri' : 'Successful System Components';
  String get failedComponents => isTurkish ? 'Başarısız Sistem Bileşenleri' : 'Failed System Components';
  String get realWorldComparison => isTurkish ? 'Gerçek Dünya Karşılaştırması' : 'Real World Comparison';
  String get failureReasons => isTurkish ? 'Başarısızlık Nedenleri' : 'Failure Reasons';
  String get improvementSuggestions => isTurkish ? 'İyileştirme Önerileri' : 'Improvement Suggestions';
  
  // Butonlar
  String get newSimulation => isTurkish ? 'Yeni Simülasyon' : 'New Simulation';
  String get backToHome => isTurkish ? 'Ana Sayfaya Dön' : 'Back to Home';
  String get next => isTurkish ? 'İleri' : 'Next';
  String get back => isTurkish ? 'Geri' : 'Back';
  String get close => isTurkish ? 'Kapat' : 'Close';
  String get save => isTurkish ? 'Kaydet' : 'Save';
  String get cancel => isTurkish ? 'İptal' : 'Cancel';
  String get select => isTurkish ? 'Seç' : 'Select';
  String get continue_ => isTurkish ? 'Devam Et' : 'Continue';
  
  // Asteroid simülasyonu
  String get asteroidDiameter => isTurkish ? 'Çap' : 'Diameter';
  String get asteroidVelocity => isTurkish ? 'Hız' : 'Velocity';
  String get asteroidComposition => isTurkish ? 'Bileşim' : 'Composition';
  String get impactLocation => isTurkish ? 'Çarpma Konumu' : 'Impact Location';
  String get impactEnergy => isTurkish ? 'Çarpma Enerjisi' : 'Impact Energy';
  String get craterDiameter => isTurkish ? 'Krater Çapı' : 'Crater Diameter';
  
  // Uyarı mesajları
  String get systemWarnings => isTurkish ? 'Sistem Uyarıları' : 'System Warnings';
  String get criticalTemperature => isTurkish ? 'Kritik sıcaklık!' : 'Critical temperature!';
  String get lowFuel => isTurkish ? 'Düşük yakıt seviyesi' : 'Low fuel level';
  String get structuralDamage => isTurkish ? 'Yapısal hasar' : 'Structural damage';
  
  // Dil seçimi
  String get languageSelection => isTurkish ? 'Dil Seçimi' : 'Language Selection';
  String get selectLanguage => isTurkish ? 'Dil Seçin' : 'Select Language';
  String get language => isTurkish ? 'Dil' : 'Language';
  String get changeLanguage => isTurkish ? 'Dili Değiştir' : 'Change Language';
  
  // Scenario Selection çevirileri
  String get scenarioSelection => isTurkish ? 'Senaryo Seçimi' : 'Scenario Selection';
  String get selectSimulationType => isTurkish ? 'Simülasyon Türünü Seçin' : 'Select Simulation Type';
  String get whichSimulationExperience => isTurkish ? 'Hangi simülasyon deneyimini yaşamak istiyorsunuz?' : 'Which simulation experience would you like to have?';
  String get rocketSatelliteTest => isTurkish ? 'Roket / Uydu Test Simülasyonu' : 'Rocket / Satellite Test Simulation';
  String get spaceEngineering => isTurkish ? 'Uzay Mühendisliği' : 'Space Engineering';
  String get designRocketAndTest => isTurkish ? 'Roketinizi tasarlayın ve uzay ortamında test edin.' : 'Design your rocket and test it in space environment.';
  String get asteroidImpactDefense => isTurkish ? 'Asteroit Çarpma ve Savunma' : 'Asteroid Impact and Defense';
  String get planetaryDefense => isTurkish ? 'Gezegen Savunması' : 'Planetary Defense';
  String get simulateThreateningAsteroids => isTurkish ? 'Dünya\'yı tehdit eden asteroidleri simüle edin ve savunma stratejileri geliştirin.' : 'Simulate threatening asteroids to Earth and develop defense strategies.';
  String get keyFeatures => isTurkish ? 'Temel Özellikler:' : 'Key Features:';
  String get customizeRocketComponents => isTurkish ? 'Roket bileşenlerini özelleştirin' : 'Customize rocket components';
  String get testInDifferentEnvironments => isTurkish ? 'Farklı uzay ortamlarında test yapın' : 'Test in different space environments';
  String get physicsSimulationRealistic => isTurkish ? 'Fizik simülasyonu ile gerçekçi sonuçlar' : 'Realistic results with physics simulation';
  String get performanceAnalysisReporting => isTurkish ? 'Performans analizi ve raporlama' : 'Performance analysis and reporting';
  String get useRealNASAData => isTurkish ? 'Gerçek NASA verilerini kullanın' : 'Use real NASA data';
  String get calculateImpactEffects => isTurkish ? 'Çarpma etkilerini hesaplayın' : 'Calculate impact effects';
  String get tryDeflectionStrategies => isTurkish ? 'Sapma stratejileri deneyin' : 'Try deflection strategies';
  String get planetaryDefenseTraining => isTurkish ? 'Gezegen savunması eğitimi' : 'Planetary defense training';
  String get selectThisSimulation => isTurkish ? 'Bu Simülasyonu Seç' : 'Select This Simulation';
  String get scientificAccuracy => isTurkish ? 'Bilimsel Doğruluk' : 'Scientific Accuracy';
  String get bothSimulationTypesDesigned => isTurkish ? 'Her iki simülasyon türü de eğitim amaçlı tasarlanmış olup, bilimsel verilere dayanmaktadır.' : 'Both simulation types are designed for educational purposes and are based on scientific data.';
  
  // Rocket Design çevirileri
  String get chooseDesignMethod => isTurkish ? 'Tasarım Yöntemini Seçin' : 'Choose Design Method';
  String get useExistingModel => isTurkish ? 'Hazır Modeli Kullan' : 'Use Existing Model';
  String get createCustomRocket => isTurkish ? 'Özel Roket Oluştur' : 'Create Custom Rocket';
  String get realRocketModels => isTurkish ? 'Gerçek roket modellerinden seçim yapın' : 'Choose from real rocket models';
  String get designOwnRocket => isTurkish ? 'Kendi roketinizi tasarlayın' : 'Design your own rocket';
  String get rocketModels => isTurkish ? 'Roket Modelleri' : 'Rocket Models';
  String get chooseRocketModel => isTurkish ? 'Roket Modelini Seçin' : 'Choose Rocket Model';
  String get height => isTurkish ? 'Yükseklik' : 'Height';
  String get thrust => isTurkish ? 'İtki' : 'Thrust';
  String get payload => isTurkish ? 'Yük Kapasitesi' : 'Payload Capacity';
  String get specifications => isTurkish ? 'Özellikler' : 'Specifications';
  String get selectModel => isTurkish ? 'Modeli Seç' : 'Select Model';
  
  // Environment Selection çevirileri
  String get testEnvironment => isTurkish ? 'Test Ortamı' : 'Test Environment';
  String get chooseTestEnvironment => isTurkish ? 'Test ortamını seçin' : 'Choose test environment';
  String get difficultyLevel => isTurkish ? 'Zorluk Seviyesi' : 'Difficulty Level';
  String get environmentDescription => isTurkish ? 'Ortam Açıklaması' : 'Environment Description';
  String get startTest => isTurkish ? 'Teste Başla' : 'Start Test';
  String get lowEarthOrbit => isTurkish ? 'Alçak Dünya Yörüngesi' : 'Low Earth Orbit';
  String get geostationary => isTurkish ? 'Jeostasyoner Yörünge' : 'Geostationary Orbit';
  String get lunarSurface => isTurkish ? 'Ay Yüzeyi' : 'Lunar Surface';
  String get marsAtmosphere => isTurkish ? 'Mars Atmosferi' : 'Mars Atmosphere';
  
  // Result Screen çevirileri
  String get missionComplete => isTurkish ? 'Görev Tamamlandı' : 'Mission Complete';
  String get missionFailed => isTurkish ? 'Görev Başarısız' : 'Mission Failed';
  String get congratulations => isTurkish ? 'Tebrikler!' : 'Congratulations!';
  String get betterLuckNextTime => isTurkish ? 'Bir dahaki sefere!' : 'Better luck next time!';
  String get missionSummary => isTurkish ? 'Görev Özeti' : 'Mission Summary';
  String get duration => isTurkish ? 'Süre' : 'Duration';
  String get maxAltitude => isTurkish ? 'Maksimum Yükseklik' : 'Maximum Altitude';
  String get maxSpeed => isTurkish ? 'Maksimum Hız' : 'Maximum Speed';
  String get fuelUsed => isTurkish ? 'Kullanılan Yakıt' : 'Fuel Used';
  String get damages => isTurkish ? 'Hasar' : 'Damage';
  String get tryAgain => isTurkish ? 'Tekrar Dene' : 'Try Again';
  String get backToMenu => isTurkish ? 'Ana Menüye Dön' : 'Back to Menu';
  String get shareResult => isTurkish ? 'Sonucu Paylaş' : 'Share Result';
  
  // Asteroid Input çevirileri
  String get asteroidParameters => isTurkish ? 'Asteroit Parametreleri' : 'Asteroid Parameters';
  String get asteroidSize => isTurkish ? 'Asteroit Boyutu' : 'Asteroid Size';
  String get diameter => isTurkish ? 'Çap' : 'Diameter';
  String get velocity => isTurkish ? 'Hız' : 'Velocity';
  String get composition => isTurkish ? 'Bileşim' : 'Composition';
  String get density => isTurkish ? 'Yoğunluk' : 'Density';
  String get impactAngle => isTurkish ? 'Çarpma Açısı' : 'Impact Angle';
  String get targetLocation => isTurkish ? 'Hedef Konum' : 'Target Location';
  String get calculateImpact => isTurkish ? 'Etkiyi Hesapla' : 'Calculate Impact';
  String get meters => isTurkish ? 'metre' : 'meters';
  String get kmPerSecond => isTurkish ? 'km/s' : 'km/s';
  String get degrees => isTurkish ? 'derece' : 'degrees';
  String get kgPerCubicMeter => isTurkish ? 'kg/m³' : 'kg/m³';
  
  // About Screen çevirileri
  String get aboutApp => isTurkish ? 'Uygulama Hakkında' : 'About the App';
  String get appVersion => isTurkish ? 'Uygulama Sürümü' : 'App Version';
  String get developer => isTurkish ? 'Geliştirici' : 'Developer';
  String get description => isTurkish ? 'Açıklama' : 'Description';
  String get features => isTurkish ? 'Özellikler' : 'Features';
  String get contact => isTurkish ? 'İletişim' : 'Contact';
  String get licenses => isTurkish ? 'Lisanslar' : 'Licenses';
  String get privacyPolicy => isTurkish ? 'Gizlilik Politikası' : 'Privacy Policy';
  String get termsOfService => isTurkish ? 'Hizmet Şartları' : 'Terms of Service';
  
  // Test History çevirileri
  String get testHistoryTitle => isTurkish ? 'Test Geçmişi' : 'Test History';
  String get noTestsYet => isTurkish ? 'Henüz test yapılmadı' : 'No tests performed yet';
  String get startFirstTest => isTurkish ? 'İlk testinizi yapın!' : 'Perform your first test!';
  String get testDate => isTurkish ? 'Test Tarihi' : 'Test Date';
  String get testType => isTurkish ? 'Test Türü' : 'Test Type';
  String get result => isTurkish ? 'Sonuç' : 'Result';
  String get viewDetails => isTurkish ? 'Detayları Gör' : 'View Details';
  String get deleteTest => isTurkish ? 'Testi Sil' : 'Delete Test';
  String get successful => isTurkish ? 'Başarılı' : 'Successful';
  String get failed => isTurkish ? 'Başarısız' : 'Failed';
  
  // Simulation Screen ek çevirileri
  String get rocketTelemetry => isTurkish ? 'Roket Telemetrisi' : 'Rocket Telemetry';
  String get altitude => isTurkish ? 'Yükseklik' : 'Altitude';
  String get engineStatus => isTurkish ? 'Motor Durumu' : 'Engine Status';
  String get running => isTurkish ? 'Çalışıyor' : 'Running';
  String get stopped => isTurkish ? 'Durmuş' : 'Stopped';
  String get timeElapsed => isTurkish ? 'Geçen Süre' : 'Time Elapsed';
  String get seconds => isTurkish ? 'saniye' : 'seconds';
  
  // Genel UI metinleri
  String get loading => isTurkish ? 'Yükleniyor...' : 'Loading...';
  String get error => isTurkish ? 'Hata' : 'Error';
  String get warning => isTurkish ? 'Uyarı' : 'Warning';
  String get info => isTurkish ? 'Bilgi' : 'Info';
  String get success => isTurkish ? 'Başarılı' : 'Success';
  String get confirm => isTurkish ? 'Onayla' : 'Confirm';
  String get delete => isTurkish ? 'Sil' : 'Delete';
  String get edit => isTurkish ? 'Düzenle' : 'Edit';
  String get settings => isTurkish ? 'Ayarlar' : 'Settings';
  String get help => isTurkish ? 'Yardım' : 'Help';
  
  // Asteroid Deflection Strategies
  String get asteroidDeflectionStrategies => isTurkish ? 'Asteroit Saptırma Stratejileri' : 'Asteroid Deflection Strategies';
  String get strategyList => isTurkish ? 'Strateji Listesi' : 'Strategy List';
  String get comparison => isTurkish ? 'Karşılaştırma' : 'Comparison';
  String get kineticImpactor => isTurkish ? 'Kinetik Çarpıcı' : 'Kinetic Impactor';
  String get gravitationalTractor => isTurkish ? 'Yerçekimi Traktörü' : 'Gravitational Tractor';
  String get nuclearExplosive => isTurkish ? 'Nükleer Patlayıcı' : 'Nuclear Explosive';
  String get ionDriveSlowPush => isTurkish ? 'İyon Motoru/Uzun Süreli İtme' : 'Ion Drive/Slow Push';
  String get solarSail => isTurkish ? 'Güneş Yelkeni' : 'Solar Sail';
  
  String get kineticImpactorDesc => isTurkish ? 'Yüksek hızda bir uzay aracını asteroide çarptırarak yörüngesini değiştirme' : 'Change orbit by impacting asteroid with high-speed spacecraft';
  String get gravTractorDesc => isTurkish ? 'Uzun süre asteroidin yanında kalarak yerçekimi ile yavaşça saptırma' : 'Slowly deflect by staying near asteroid for extended time using gravity';
  String get nuclearExplosiveDesc => isTurkish ? 'Nükleer bir patlayıcı ile asteroidi parçalama veya saptırma' : 'Fragment or deflect asteroid using nuclear explosive';
  String get ionDriveDesc => isTurkish ? 'Asteroide monte edilen iyon motorları ile uzun süreli itme' : 'Long-duration push using ion motors mounted on asteroid';
  String get solarSailDesc => isTurkish ? 'Güneş radyasyon basıncı ile astronomi yörünge değişikliği' : 'Change orbit using solar radiation pressure';
  
  String get effectiveness => isTurkish ? 'Etkinlik' : 'Effectiveness';
  String get strategyDuration => isTurkish ? 'Süre' : 'Duration';
  String get cost => isTurkish ? 'Maliyet' : 'Cost';
  String get advantages => isTurkish ? 'Avantajlar:' : 'Advantages:';
  String get disadvantages => isTurkish ? 'Dezavantajlar:' : 'Disadvantages:';
  String get technicalDetails => isTurkish ? 'Teknik Detaylar:' : 'Technical Details:';
  String get realWorldExample => isTurkish ? 'Gerçek Dünya Örneği:' : 'Real World Example:';
  
  String get minimum5Years => isTurkish ? 'Minimum 5 yıl' : 'Minimum 5 years';
  String get strategyMedium => isTurkish ? 'Orta' : 'Medium';
  String get strategyHigh => isTurkish ? 'Yüksek' : 'High';
  String get strategyLow => isTurkish ? 'Düşük' : 'Low';
  
  // Test Statistics
  String get testStatistics => isTurkish ? 'Test İstatistikleri' : 'Test Statistics';
  String get totalTests => isTurkish ? 'Toplam Test' : 'Total Tests';
  String get successfulTests => isTurkish ? 'Başarılı' : 'Successful';
  String get failedTests => isTurkish ? 'Başarısız' : 'Failed';
  String get successRatePercent => isTurkish ? 'Başarı Oranı' : 'Success Rate';
  String get averageSuccess => isTurkish ? 'Ort. Başarı' : 'Avg. Success';
  String get allTests => isTurkish ? 'Tümü' : 'All';
  
  // About Screen
  String get impactSim => isTurkish ? 'ImpactSim' : 'ImpactSim';
  String get planetaryDefenseSpaceTestSim => isTurkish ? 'Gezegen Savunma ve Uzay Test Simülasyonu' : 'Planetary Defense and Space Test Simulation';
  String get whatIsImpactSim => isTurkish ? 'ImpactSim Nedir?' : 'What is ImpactSim?';
  String get impactSimDesc => isTurkish ? 'ImpactSim, kullanıcıların roket ve uydu testlerinin yanı sıra, asteroit çarpma senaryolarını da modelleyebildiği interaktif bir uzay simülasyon platformudur. Uygulama, hem bilimsel doğruluğu temel alır, hem de kullanıcı dostu arayüzüyle karmaşık verileri herkes için erişilebilir hale getirir.' : 'ImpactSim is an interactive space simulation platform where users can model rocket and satellite tests as well as asteroid impact scenarios. The application is based on scientific accuracy while making complex data accessible to everyone with its user-friendly interface.';
  String get ourPurpose => isTurkish ? '🎯 Amacımız' : '🎯 Our Purpose';
  String get purposeDesc => isTurkish ? 'ImpactSim\'in temel amacı, kullanıcıların bilimsel prensiplere dayalı ve etkileşimli bir ortamda farkındalık ve öğrenme düzeyini artırmaktır.' : 'The main purpose of ImpactSim is to increase user awareness and learning in an interactive environment based on scientific principles.';
  String get testSpaceTech => isTurkish ? 'Uzay teknolojilerini test etmelerini' : 'Test space technologies';
  String get analyzeImpactScenarios => isTurkish ? 'Olası göktaşı çarpma senaryolarını analiz etmelerini' : 'Analyze possible asteroid impact scenarios';
  String get understandComplexData => isTurkish ? 'Karmaşık verileri görselleştirme ile daha iyi etmelerini' : 'Better understand complex data through visualization';
  
  // Impactor-2025 Screen
  String get impactor2025Title => isTurkish ? 'Impactor-2025: Küresel Tehdit Senaryosu' : 'Impactor-2025: Global Threat Scenario';
  String get educationalMode => isTurkish ? '🎓 Eğitim' : '🎓 Educational';
  String get gameMode => isTurkish ? '🎮 Oyun' : '🎮 Game';
  String get overview => isTurkish ? 'Genel Bakış' : 'Overview';
  String get impactorSimulation => isTurkish ? 'Simülasyon' : 'Simulation';
  String get strategy => isTurkish ? 'Strateji' : 'Strategy';
  String get results => isTurkish ? 'Sonuçlar' : 'Results';
  String get highThreatLevel => isTurkish ? 'YÜKSEK TEHDİT SEVİYESİ' : 'HIGH THREAT LEVEL';
  String get daysRemaining => isTurkish ? '847 gün kaldı' : '847 days remaining';
  String get impactProbability => isTurkish ? 'Çarpma Olasılığı: 89.0%' : 'Impact Probability: 89.0%';
  String get advancedAsteroidAnalysis => isTurkish ? '🔴 Gelişmiş Asteroit Analizi' : '🔴 Advanced Asteroid Analysis';
  String get advanced => isTurkish ? 'Gelişmiş' : 'Advanced';
  String get catalogName => isTurkish ? 'Katalog Adı' : 'Catalog Name';
  String get impactorDiameter => isTurkish ? 'Çap' : 'Diameter';
  String get mass => isTurkish ? 'Kütle' : 'Mass';
  String get impactorSpeed => isTurkish ? 'Hız' : 'Speed';
  String get impactorDensity => isTurkish ? 'Yoğunluk' : 'Density';
  String get type => isTurkish ? 'Tip' : 'Type';
  String get stonyType => isTurkish ? 'S-type (Stony)' : 'S-type (Stony)';
  String get impactorLocation => isTurkish ? '📍 Çarpma Bilgileri' : '📍 Impact Information';
  
  String get versionsAvailable => isTurkish ? 'Versiyonlar' : 'Versions Available';
  String get km => isTurkish ? 'km' : 'km';
  String get kg => isTurkish ? 'kg' : 'kg';
  String get impactorKmPerSecond => isTurkish ? 'km/s' : 'km/s';
  String get gPerCubicCm => isTurkish ? 'g/cm³' : 'g/cm³';
  
  // Asteroid Simulation Screen
  String get asteroidImpactSimulation => isTurkish ? 'Asteroit Çarpma Simülasyonu' : 'Asteroid Impact Simulation';
  String get asteroidApproaching => isTurkish ? 'Asteroit Yaklaşıyor' : 'Asteroid Approaching';
  String get atmosphereEntry => isTurkish ? 'Atmosfere Giriş' : 'Atmosphere Entry';
  String get impact => isTurkish ? 'Çarpma!' : 'Impact!';
  String get shockwave => isTurkish ? 'Şok Dalgası' : 'Shockwave';
  String get thermalEffect => isTurkish ? 'Termal Etki' : 'Thermal Effect';
  String get seismicWave => isTurkish ? 'Sismik Dalga' : 'Seismic Wave';
  String get impactResults => isTurkish ? 'Sonuçlar' : 'Results';
  String get preparation => isTurkish ? 'Hazırlık' : 'Preparation';
  String get impactSite => isTurkish ? 'Çarpma Konumu' : 'Impact Site';
  String get predictedEffects => isTurkish ? 'Tahmin Edilen Etkiler' : 'Predicted Effects';
  String get shockRadius => isTurkish ? 'Şok Yarıçapı' : 'Shock Radius';
  String get earthquake => isTurkish ? 'Deprem' : 'Earthquake';
  String get casualties => isTurkish ? 'Kayıp' : 'Casualties';
  String get estimatedCasualties => isTurkish ? 'Tahmini Kayıp' : 'Estimated Casualties';
  String get category => isTurkish ? 'Kategori' : 'Category';
  String get riskLevel => isTurkish ? 'Risk' : 'Risk';
  String get energy => isTurkish ? 'Enerji' : 'Energy';
  String get coordinates => isTurkish ? 'Koordinatlar' : 'Coordinates';
  String get tntEquivalent => isTurkish ? 'ton TNT eşdeğeri' : 'tons TNT equivalent';
  String get tsunamiRisk => isTurkish ? 'TSUNAMI RİSKİ' : 'TSUNAMI RISK';
  String get waveHeight => isTurkish ? 'dalga yüksekliği' : 'wave height';
  String get tsunami => isTurkish ? 'Tsunami' : 'Tsunami';
  String get asteroidIsApproaching => isTurkish ? 'Asteroit yaklaşıyor...' : 'Asteroid is approaching...';
  String get people => isTurkish ? 'kişi' : 'people';
  String get richter => isTurkish ? 'Richter' : 'Richter';
  String get mTons => isTurkish ? 'M ton' : 'M tons';
  
  // Additional Impactor 2025 Screen translations
  String get impactor2025Subtitle => isTurkish ? 'Küresel Tehdit Senaryosu' : 'Global Threat Scenario';
  String get education => isTurkish ? 'Eğitim' : 'Education';
  String get game => isTurkish ? 'Oyun' : 'Game';
  String get impactInformation => isTurkish ? 'Çarpma Bilgileri' : 'Impact Information';
  String get nasaApiConnecting => isTurkish ? 'NASA API\'ye bağlanıyor...' : 'Connecting to NASA API...';
  String get apiConnectionSuccess => isTurkish ? 'API bağlantısı başarılı' : 'API connection successful';
  String get apiDataLoaded => isTurkish ? 'asteroit yüklendi' : 'asteroids loaded';
  String get apiConnectionFailed => isTurkish ? 'API bağlantısı başarısız' : 'API connection failed';
  String get usingDefaultData => isTurkish ? 'Varsayılan veri kullanılıyor' : 'Using default data';
}

/// Localization Delegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['tr', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

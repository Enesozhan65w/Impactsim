# Blender Asteroid Impact Simulation System

Bu sistem, NASA standartlarındaki asteroid verilerini kullanarak Blender'da gerçekçi 3D impact simülasyonları oluşturur.

## Özellikler

### 🌍 **3D Dünya Modeli**
- Gerçek dünya topografyası
- Okyanus ve kıtalar
- Atmosfer efektleri
- Bulut katmanları

### ☄️ **Asteroid Modelleri**
- NASA verilerine dayalı gerçek boyutlar
- Spektral tipe göre materyal özellikleri
- Procedurel yüzey detayları
- Rotasyon animasyonları

### 💥 **Impact Simülasyonu**
- Fizik tabanlı çarpışma
- Krater oluşumu animasyonu
- Debris ve ejecta simülasyonu
- Şok dalgası yayılımı

### 🛰️ **Orbital Mechanics**
- Keplerian yörünge elemanları
- Gerçek orbital hareket
- Close approach animasyonları
- Deflection senaryoları

## Kullanım

1. Blender 3.6+ gerekli
2. Python scriptlerini Blender'da çalıştır
3. Flutter uygulamasından parametreleri aktar
4. Render ve animasyonu dışa aktar

## Dosya Yapısı

```
blender_integration/
├── README.md
├── scripts/
│   ├── asteroid_generator.py      # Asteroid model oluşturucu
│   ├── earth_setup.py            # Dünya sahne kurulumu
│   ├── impact_simulation.py      # Impact animasyon sistemi
│   ├── orbital_mechanics.py      # Yörünge hesaplamaları
│   └── material_system.py        # Materyal ve shader sistemi
├── assets/
│   ├── earth_textures/           # Dünya doku haritaları
│   ├── asteroid_textures/        # Asteroid yüzey dokuları
│   └── hdri/                     # Space HDRI backgrounds
└── output/
    ├── animations/               # Render çıktıları
    └── screenshots/              # Önizleme görüntüleri

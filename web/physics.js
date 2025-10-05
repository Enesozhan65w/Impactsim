// Matter.js tabanlı gerçek fizik simülasyonu
class PhysicsEngine {
    constructor() {
        // Matter.js motor kurulumu
        this.engine = Matter.Engine.create();
        this.world = this.engine.world;
        this.render = null;
        
        // Fizik sabitleri
        this.EARTH_GRAVITY = 9.81;
        this.MOON_GRAVITY = 1.62;
        this.MARS_GRAVITY = 3.71;
        this.SPACE_GRAVITY = 0.0;
        
        // Ortam parametreleri
        this.environments = {
            'LEO': {
                gravity: this.EARTH_GRAVITY * 0.9,
                atmosphere: 1e-12,
                temperature: { min: -157, max: 121 },
                radiation: 0.3,
                orbitalVelocity: 7800
            },
            'Ay': {
                gravity: this.MOON_GRAVITY,
                atmosphere: 0.0,
                temperature: { min: -173, max: 127 },
                radiation: 0.8,
                escapeVelocity: 2380
            },
            'Mars': {
                gravity: this.MARS_GRAVITY,
                atmosphere: 0.02,
                temperature: { min: -87, max: -5 },
                radiation: 0.6,
                escapeVelocity: 5030
            },
            'Boşluk': {
                gravity: this.SPACE_GRAVITY,
                atmosphere: 0.0,
                temperature: { min: -270, max: -200 },
                radiation: 1.0,
                cosmicRadiation: true
            }
        };
        
        this.currentEnvironment = null;
        this.rocket = null;
        this.simulationData = {
            speed: 0,
            temperature: 20,
            fuel: 100,
            damage: 0,
            warnings: []
        };
    }
    
    initializeEnvironment(environmentName) {
        this.currentEnvironment = this.environments[environmentName];
        
        // Yerçekimini ayarla
        this.engine.world.gravity.y = this.currentEnvironment.gravity / 100; // Matter.js için ölçekleme
        this.engine.world.gravity.x = 0;
        
        console.log(`Ortam başlatıldı: ${environmentName}`, this.currentEnvironment);
    }
    
    createRocket(rocketData) {
        // Roket fizik gövdesi oluştur
        let mass = 100; // varsayılan
        let thrust = 1000; // varsayılan
        
        if (rocketData.type === 'manual') {
            mass = rocketData.weight;
            thrust = rocketData.motorPower;
        } else {
            // Hazır modeller
            switch (rocketData.model) {
                case 'Mini CubeSat':
                    mass = 1.3;
                    thrust = 0.1;
                    break;
                case 'Deneysel Roket':
                    mass = 25;
                    thrust = 1000;
                    break;
                case 'İletişim Uydusu':
                    mass = 150;
                    thrust = 500;
                    break;
            }
        }
        
        // Matter.js roket gövdesi
        this.rocket = Matter.Bodies.rectangle(400, 300, 20, 60, {
            mass: mass,
            frictionAir: this.currentEnvironment.atmosphere * 0.001,
            render: {
                fillStyle: '#4A90E2',
                strokeStyle: '#2E5BBA',
                lineWidth: 2
            }
        });
        
        // Roketi dünyaya ekle
        Matter.World.add(this.world, this.rocket);
        
        // Roket özellikleri
        this.rocket.thrust = thrust;
        this.rocket.fuelCapacity = 100;
        this.rocket.currentFuel = 100;
        this.rocket.material = rocketData.material || 'Alüminyum';
        this.rocket.hasControlSystem = rocketData.hasControlSystem || false;
        
        return this.rocket;
    }
    
    applyThrust(direction = { x: 0, y: -1 }, intensity = 1.0) {
        if (!this.rocket || this.rocket.currentFuel <= 0) return;
        
        const thrustForce = this.rocket.thrust * intensity * 0.001; // Ölçekleme
        
        Matter.Body.applyForce(this.rocket, this.rocket.position, {
            x: direction.x * thrustForce,
            y: direction.y * thrustForce
        });
        
        // Yakıt tüketimi
        const fuelConsumption = this.calculateFuelConsumption(intensity);
        this.rocket.currentFuel = Math.max(0, this.rocket.currentFuel - fuelConsumption);
    }
    
    calculateFuelConsumption(thrustIntensity) {
        let baseConsumption = 0.1 * thrustIntensity; // %/saniye
        
        // Ortam zorluğu etkisi
        if (this.currentEnvironment.atmosphere > 0) {
            baseConsumption *= (1 + this.currentEnvironment.atmosphere * 10);
        }
        
        return baseConsumption;
    }
    
    calculateTemperature(progress, isEngineRunning) {
        const tempRange = this.currentEnvironment.temperature;
        let baseTemp = tempRange.min + (tempRange.max - tempRange.min) * progress;
        
        // Motor ısısı
        if (isEngineRunning && this.rocket.currentFuel > 0) {
            baseTemp += 50 + (progress * 100);
        }
        
        // Güneş radyasyonu (LEO için)
        if (this.currentEnvironment.orbitalVelocity) {
            const solarCycle = Math.sin(progress * Math.PI * 4) * 30;
            baseTemp += solarCycle;
        }
        
        // Atmosfer etkisi
        if (this.currentEnvironment.atmosphere > 0) {
            baseTemp += this.currentEnvironment.atmosphere * 1000; // Atmosfer ısınması
        }
        
        return baseTemp;
    }
    
    calculateDamage(temperature, progress, deltaTime) {
        let damageRate = 0;
        
        // Sıcaklık hasarı
        if (temperature > 150) {
            damageRate += (temperature - 150) * 0.01;
        } else if (temperature < -200) {
            damageRate += (-200 - temperature) * 0.005;
        }
        
        // Radyasyon hasarı
        damageRate += this.currentEnvironment.radiation * 0.1 * progress;
        
        // Malzeme direnci
        if (this.rocket.material === 'Karbonfiber') {
            damageRate *= 0.6;
        } else if (this.rocket.material === 'Kompozit') {
            damageRate *= 0.8;
        }
        
        // Kontrol sistemi koruması
        if (this.rocket.hasControlSystem) {
            damageRate *= 0.7;
        }
        
        // Hız hasarı (aşırı hızda)
        const velocity = Math.sqrt(
            this.rocket.velocity.x ** 2 + this.rocket.velocity.y ** 2
        );
        if (velocity > 100) { // Matter.js birimlerinde
            damageRate += (velocity - 100) * 0.001;
        }
        
        return damageRate * deltaTime;
    }
    
    generateWarnings(temperature, fuel, damage, speed) {
        const warnings = [];
        
        // Sıcaklık uyarıları
        if (temperature > 200) {
            warnings.push(`KRİTİK: Sistem Aşırı Isındı (${Math.round(temperature)}°C)`);
        } else if (temperature > 100) {
            warnings.push(`UYARI: Motor Yüksek Sıcaklık (${Math.round(temperature)}°C)`);
        }
        
        if (temperature < -250) {
            warnings.push(`KRİTİK: Sistem Donma Riski (${Math.round(temperature)}°C)`);
        } else if (temperature < -200) {
            warnings.push(`UYARI: Düşük Sıcaklık Riski (${Math.round(temperature)}°C)`);
        }
        
        // Yakıt uyarıları
        if (fuel < 10) {
            warnings.push(`KRİTİK: Yakıt Kritik Seviyede (${Math.round(fuel)}%)`);
        } else if (fuel < 25) {
            warnings.push(`UYARI: Yakıt Seviyesi Düşük (${Math.round(fuel)}%)`);
        }
        
        // Hasar uyarıları
        if (damage > 80) {
            warnings.push(`KRİTİK: Sistem Arızası Riski (${Math.round(damage)}% hasar)`);
        } else if (damage > 50) {
            warnings.push(`UYARI: Yüksek Hasar Seviyesi (${Math.round(damage)}%)`);
        }
        
        // Hız uyarıları
        if (speed > 200) { // Matter.js birimlerinde
            warnings.push('UYARI: Yüksek Hız - Kontrol Kaybı Riski');
        }
        
        // Radyasyon uyarıları
        if (this.currentEnvironment.radiation > 0.7) {
            warnings.push('UYARI: Yüksek Radyasyon Seviyesi');
        }
        
        // Ortam özel uyarıları
        if (this.currentEnvironment.cosmicRadiation) {
            warnings.push('UYARI: Kozmik Radyasyon Tespit Edildi');
        }
        
        return warnings;
    }
    
    updateSimulation(progress, deltaTime, isEngineRunning = false) {
        // Fizik motorunu güncelle
        Matter.Engine.update(this.engine, deltaTime * 1000);
        
        if (!this.rocket) return this.simulationData;
        
        // Hız hesaplama (Matter.js birimlerinden gerçek birimlere)
        const velocity = Math.sqrt(
            this.rocket.velocity.x ** 2 + this.rocket.velocity.y ** 2
        );
        this.simulationData.speed = velocity * 100; // m/s'ye çevir
        
        // Sıcaklık hesaplama
        this.simulationData.temperature = this.calculateTemperature(progress, isEngineRunning);
        
        // Yakıt seviyesi
        this.simulationData.fuel = this.rocket.currentFuel;
        
        // Hasar hesaplama
        const damageIncrease = this.calculateDamage(
            this.simulationData.temperature,
            progress,
            deltaTime
        );
        this.simulationData.damage = Math.min(100, this.simulationData.damage + damageIncrease);
        
        // Uyarılar
        this.simulationData.warnings = this.generateWarnings(
            this.simulationData.temperature,
            this.simulationData.fuel,
            this.simulationData.damage,
            this.simulationData.speed
        );
        
        return this.simulationData;
    }
    
    setupRenderer(canvas) {
        this.render = Matter.Render.create({
            canvas: canvas,
            engine: this.engine,
            options: {
                width: 800,
                height: 600,
                wireframes: false,
                background: 'transparent',
                showAngleIndicator: true,
                showVelocity: true
            }
        });
        
        Matter.Render.run(this.render);
    }
    
    cleanup() {
        if (this.render) {
            Matter.Render.stop(this.render);
        }
        Matter.Engine.clear(this.engine);
    }
}

// Global fizik motoru instance
window.physicsEngine = new PhysicsEngine();

import bpy
import bmesh
import mathutils
import math
import random
import json
from mathutils import Vector, noise

class AsteroidGenerator:
    """
    NASA verilerine dayalı gerçekçi asteroid modelleri oluşturan Blender script'i
    """
    
    def __init__(self):
        self.spectral_materials = {
            'C': {'albedo': 0.04, 'color': (0.2, 0.2, 0.25), 'roughness': 0.9},
            'S': {'albedo': 0.15, 'color': (0.5, 0.4, 0.3), 'roughness': 0.8},
            'M': {'albedo': 0.25, 'color': (0.6, 0.5, 0.4), 'roughness': 0.3},
            'X': {'albedo': 0.08, 'color': (0.3, 0.3, 0.3), 'roughness': 0.7},
            'B': {'albedo': 0.05, 'color': (0.15, 0.15, 0.2), 'roughness': 0.95},
        }
    
    def create_asteroid_from_nasa_data(self, asteroid_data):
        """
        NASA JPL SBDB formatındaki asteroid verisinden 3D model oluşturur
        """
        # Asteroid parametreleri
        name = asteroid_data.get('name', 'Unknown Asteroid')
        diameter_km = asteroid_data.get('diameter_km', 1.0)
        spectral_type = asteroid_data.get('spec_B', 'S')[0]  # İlk harf
        rotation_period = asteroid_data.get('rot_per', 24.0)  # saat
        
        # Blender units: 1 unit = 1000 km (scale için)
        radius = diameter_km / 2000.0  # Blender ölçeği
        
        print(f"Creating asteroid: {name}")
        print(f"Diameter: {diameter_km} km")
        print(f"Spectral Type: {spectral_type}")
        print(f"Rotation Period: {rotation_period} hours")
        
        # Mesh oluştur
        asteroid_obj = self._create_asteroid_mesh(name, radius, spectral_type)
        
        # Materyal uygula
        self._apply_asteroid_material(asteroid_obj, spectral_type)
        
        # Rotasyon animasyonu ekle
        self._add_rotation_animation(asteroid_obj, rotation_period)
        
        return asteroid_obj
    
    def _create_asteroid_mesh(self, name, radius, spectral_type):
        """
        Procedurel asteroid mesh'i oluşturur
        """
        # Yeni mesh oluştur
        bpy.ops.mesh.primitive_ico_sphere_add(
            subdivisions=4, 
            radius=radius,
            location=(0, 0, 0)
        )
        
        asteroid_obj = bpy.context.active_object
        asteroid_obj.name = f"Asteroid_{name}"
        
        # Edit mode'a geç ve mesh'i düzenle
        bpy.context.view_layer.objects.active = asteroid_obj
        bpy.ops.object.mode_set(mode='EDIT')
        
        # Bmesh ile detaylar ekle
        bm = bmesh.from_mesh(asteroid_obj.data)
        
        # Crater ve surface detayları ekle
        self._add_surface_details(bm, spectral_type)
        
        # Mesh'i güncelle
        bm.to_mesh(asteroid_obj.data)
        bm.free()
        
        bpy.ops.object.mode_set(mode='OBJECT')
        
        return asteroid_obj
    
    def _add_surface_details(self, bm, spectral_type):
        """
        Asteroid yüzeyine gerçekçi detaylar ekler
        """
        # Vertex'leri random deplase et (çukurlar, tümsekler)
        for vert in bm.verts:
            # Noise tabanlı displacement
            noise_scale = 2.0
            noise_value = noise.noise(vert.co * noise_scale)
            
            # Spectral type'a göre surface roughness
            roughness_factor = {
                'C': 0.3,  # Carbonaceous - pürüzlü
                'S': 0.2,  # Stony - orta
                'M': 0.1,  # Metallic - düz
                'X': 0.25, # Mixed
                'B': 0.35  # Very rough
            }.get(spectral_type, 0.2)
            
            displacement = noise_value * roughness_factor
            vert.co += vert.normal * displacement
            
        # Kraterler ekle (random lokasyonlarda)
        self._add_craters(bm, spectral_type)
        
        # Mesh'i düzelt
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    
    def _add_craters(self, bm, spectral_type):
        """
        Asteroid yüzeyine kraterler ekler
        """
        # Krater sayısı spectral type'a göre
        crater_count = {
            'C': 8,   # Carbonaceous - çok krater
            'S': 5,   # Stony - orta
            'M': 3,   # Metallic - az krater
            'X': 6,
            'B': 10   # Very cratered
        }.get(spectral_type, 5)
        
        for i in range(crater_count):
            # Random lokasyon seç
            if bm.faces:
                face = random.choice(bm.faces)
                center = face.calc_center_median()
                normal = face.normal
                
                # Küçük krater oluştur
                crater_radius = random.uniform(0.1, 0.3)
                crater_depth = random.uniform(0.05, 0.15)
                
                self._create_crater(bm, center, normal, crater_radius, crater_depth)
    
    def _create_crater(self, bm, center, normal, radius, depth):
        """
        Belirli bir noktada krater oluşturur
        """
        # Kratere yakın vertex'leri bul
        affected_verts = []
        for vert in bm.verts:
            dist = (vert.co - center).length
            if dist <= radius:
                affected_verts.append((vert, dist))
        
        # Vertex'leri krater şeklinde deplase et
        for vert, dist in affected_verts:
            # Smooth falloff için
            falloff = 1.0 - (dist / radius)
            falloff = falloff * falloff  # Quadratic falloff
            
            # İçe doğru deplase et
            displacement = -normal * depth * falloff
            vert.co += displacement
    
    def _apply_asteroid_material(self, obj, spectral_type):
        """
        Spectral type'a göre gerçekçi materyal uygular
        """
        # Materyal oluştur
        mat_name = f"Asteroid_Material_{spectral_type}"
        
        # Eğer materyal zaten varsa kullan
        if mat_name in bpy.data.materials:
            material = bpy.data.materials[mat_name]
        else:
            material = bpy.data.materials.new(name=mat_name)
            material.use_nodes = True
            
            # Node setup
            self._setup_material_nodes(material, spectral_type)
        
        # Objeye materyal ata
        obj.data.materials.append(material)
    
    def _setup_material_nodes(self, material, spectral_type):
        """
        Materyal node'larını kurar
        """
        nodes = material.node_tree.nodes
        links = material.node_tree.links
        
        # Tüm node'ları temizle
        nodes.clear()
        
        # Output node
        output_node = nodes.new('ShaderNodeOutputMaterial')
        output_node.location = (400, 0)
        
        # Principled BSDF
        principled = nodes.new('ShaderNodeBsdfPrincipled')
        principled.location = (0, 0)
        
        # Spectral properties
        props = self.spectral_materials.get(spectral_type, self.spectral_materials['S'])
        
        # Base color
        principled.inputs['Base Color'].default_value = (*props['color'], 1.0)
        principled.inputs['Roughness'].default_value = props['roughness']
        principled.inputs['Metallic'].default_value = 1.0 if spectral_type == 'M' else 0.0
        
        # Noise texture for surface variation
        noise_tex = nodes.new('ShaderNodeTexNoise')
        noise_tex.location = (-400, 200)
        noise_tex.inputs['Scale'].default_value = 15.0
        noise_tex.inputs['Detail'].default_value = 10.0
        
        # ColorRamp for contrast
        color_ramp = nodes.new('ShaderNodeValToRGB')
        color_ramp.location = (-200, 200)
        
        # Musgrave texture for larger features
        musgrave = nodes.new('ShaderNodeTexMusgrave')
        musgrave.location = (-400, 0)
        musgrave.inputs['Scale'].default_value = 5.0
        
        # Mix node
        mix_node = nodes.new('ShaderNodeMixRGB')
        mix_node.location = (-200, 0)
        mix_node.blend_type = 'MULTIPLY'
        
        # Bağlantılar
        links.new(noise_tex.outputs['Fac'], color_ramp.inputs['Fac'])
        links.new(color_ramp.outputs['Color'], mix_node.inputs['Color1'])
        links.new(musgrave.outputs['Fac'], mix_node.inputs['Color2'])
        links.new(mix_node.outputs['Color'], principled.inputs['Base Color'])
        links.new(principled.outputs['BSDF'], output_node.inputs['Surface'])
    
    def _add_rotation_animation(self, obj, rotation_period_hours):
        """
        Gerçek rotasyon periyoduna göre animasyon ekler
        """
        # Animation data oluştur
        if obj.animation_data is None:
            obj.animation_data_create()
        
        # Keyframe'ler
        bpy.context.scene.frame_set(1)
        obj.rotation_euler = (0, 0, 0)
        obj.keyframe_insert(data_path="rotation_euler", index=2)
        
        # Rotasyon periyodunu frame'e çevir (24 fps varsayım)
        frames_per_rotation = int(rotation_period_hours * 3600 / 24)  # 1 saniye = 24 frame
        
        bpy.context.scene.frame_set(frames_per_rotation)
        obj.rotation_euler = (0, 0, math.radians(360))
        obj.keyframe_insert(data_path="rotation_euler", index=2)
        
        # Linear interpolation
        if obj.animation_data and obj.animation_data.action:
            for fcurve in obj.animation_data.action.fcurves:
                for keyframe in fcurve.keyframe_points:
                    keyframe.interpolation = 'LINEAR'
    
    def create_predefined_asteroids(self):
        """
        Ön tanımlı NASA asteroidlerini oluşturur
        """
        # Apophis
        apophis_data = {
            'name': 'Apophis',
            'diameter_km': 0.370,
            'spec_B': 'Sq',
            'rot_per': 30.56
        }
        apophis = self.create_asteroid_from_nasa_data(apophis_data)
        apophis.location = (5, 0, 0)
        
        # Bennu
        bennu_data = {
            'name': 'Bennu',
            'diameter_km': 0.492,
            'spec_B': 'B',
            'rot_per': 4.297
        }
        bennu = self.create_asteroid_from_nasa_data(bennu_data)
        bennu.location = (0, 5, 0)
        
        # Chelyabinsk
        chelyabinsk_data = {
            'name': 'Chelyabinsk',
            'diameter_km': 0.020,
            'spec_B': 'LL',
            'rot_per': 12.0
        }
        chelyabinsk = self.create_asteroid_from_nasa_data(chelyabinsk_data)
        chelyabinsk.location = (-2, -2, 0)
        
        # Tunguska
        tunguska_data = {
            'name': 'Tunguska',
            'diameter_km': 0.060,
            'spec_B': 'S',
            'rot_per': 8.0
        }
        tunguska = self.create_asteroid_from_nasa_data(tunguska_data)
        tunguska.location = (2, -2, 0)
        
        print("Predefined asteroids created successfully!")
        return [apophis, bennu, chelyabinsk, tunguska]

# Blender'da kullanım
def main():
    """
    Ana fonksiyon - Blender'da çalıştırılacak
    """
    # Scene'i temizle
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    
    # Generator oluştur
    generator = AsteroidGenerator()
    
    # Test için ön tanımlı asteroidleri oluştur
    asteroids = generator.create_predefined_asteroids()
    
    # Kamera ayarla
    bpy.ops.object.camera_add(location=(10, -10, 5))
    camera = bpy.context.active_object
    camera.rotation_euler = (math.radians(60), 0, math.radians(45))
    
    # Işık ekle
    bpy.ops.object.light_add(type='SUN', location=(5, 5, 10))
    sun = bpy.context.active_object
    sun.data.energy = 5.0
    
    # HDRI environment (eğer varsa)
    world = bpy.context.scene.world
    if world.use_nodes:
        env_tex = world.node_tree.nodes.new('ShaderNodeTexEnvironment')
        background = world.node_tree.nodes['Background']
        world.node_tree.links.new(env_tex.outputs['Color'], background.inputs['Color'])
    
    print("Asteroid generation completed!")

# Eğer Blender'da çalışıyorsa otomatik başlat
if __name__ == "__main__":
    main()

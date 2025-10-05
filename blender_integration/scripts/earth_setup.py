import bpy
import bmesh
import mathutils
import math
import random
from mathutils import Vector

class EarthModelGenerator:
    """
    Gerçekçi Dünya modeli oluşturan Blender script'i
    Impact simülasyonları için detaylı Dünya modeli
    """
    
    def __init__(self):
        self.earth_radius = 6.371  # Blender units (6371 km)
        self.atmosphere_height = 0.1  # 100 km in scale
        
    def create_complete_earth_system(self):
        """
        Komplet Dünya sistemi oluşturur: Dünya, Atmosfer, Bulutlar
        """
        print("Creating complete Earth system...")
        
        # Ana Dünya objesi
        earth_obj = self._create_earth_sphere()
        
        # Atmosfer
        atmosphere_obj = self._create_atmosphere(earth_obj)
        
        # Bulut katmanı
        clouds_obj = self._create_cloud_layer(earth_obj)
        
        # Dünya malzemeleri
        self._setup_earth_materials(earth_obj)
        
        # Atmosfer malzemeleri
        self._setup_atmosphere_materials(atmosphere_obj)
        
        # Bulut malzemeleri
        self._setup_cloud_materials(clouds_obj)
        
        # Parent relationship
        atmosphere_obj.parent = earth_obj
        clouds_obj.parent = earth_obj
        
        print("Earth system creation completed!")
        
        return {
            'earth': earth_obj,
            'atmosphere': atmosphere_obj,
            'clouds': clouds_obj
        }
    
    def _create_earth_sphere(self):
        """
        Ana Dünya küresini oluşturur
        """
        # UV Sphere oluştur
        bpy.ops.mesh.primitive_uv_sphere_add(
            radius=self.earth_radius,
            location=(0, 0, 0),
            segments=64,
            rings=32
        )
        
        earth_obj = bpy.context.active_object
        earth_obj.name = "Earth"
        
        # Smooth shading
        bpy.ops.object.shade_smooth()
        
        return earth_obj
    
    def _create_atmosphere(self, earth_obj):
        """
        Atmosfer katmanı oluşturur
        """
        atmosphere_radius = self.earth_radius + self.atmosphere_height
        
        bpy.ops.mesh.primitive_uv_sphere_add(
            radius=atmosphere_radius,
            location=(0, 0, 0),
            segments=32,
            rings=16
        )
        
        atmosphere_obj = bpy.context.active_object
        atmosphere_obj.name = "Earth_Atmosphere"
        
        # Smooth shading
        bpy.ops.object.shade_smooth()
        
        return atmosphere_obj
    
    def _create_cloud_layer(self, earth_obj):
        """
        Bulut katmanı oluşturur
        """
        cloud_radius = self.earth_radius + 0.02  # 20 km yükseklik
        
        bpy.ops.mesh.primitive_uv_sphere_add(
            radius=cloud_radius,
            location=(0, 0, 0),
            segments=32,
            rings=16
        )
        
        clouds_obj = bpy.context.active_object
        clouds_obj.name = "Earth_Clouds"
        
        # Smooth shading
        bpy.ops.object.shade_smooth()
        
        return clouds_obj
    
    def _setup_earth_materials(self, earth_obj):
        """
        Dünya için gerçekçi materyal sistemi
        """
        # Materyal oluştur
        earth_mat = bpy.data.materials.new(name="Earth_Material")
        earth_mat.use_nodes = True
        
        nodes = earth_mat.node_tree.nodes
        links = earth_mat.node_tree.links
        
        # Temizle
        nodes.clear()
        
        # Output
        output = nodes.new('ShaderNodeOutputMaterial')
        output.location = (800, 0)
        
        # Principled BSDF
        principled = nodes.new('ShaderNodeBsdfPrincipled')
        principled.location = (400, 0)
        
        # Earth Day Texture (Diffuse)
        day_tex = nodes.new('ShaderNodeTexImage')
        day_tex.location = (-400, 200)
        day_tex.label = "Day Texture"
        
        # Earth Night Texture (Emission)
        night_tex = nodes.new('ShaderNodeTexImage')
        night_tex.location = (-400, -200)
        night_tex.label = "Night Texture"
        
        # Normal Map
        normal_tex = nodes.new('ShaderNodeTexImage')
        normal_tex.location = (-400, -500)
        normal_tex.label = "Normal Map"
        normal_tex.image.colorspace_settings.name = 'Non-Color'
        
        # Normal Map Node
        normal_map = nodes.new('ShaderNodeNormalMap')
        normal_map.location = (0, -400)
        
        # Day/Night Mix için Light Path
        light_path = nodes.new('ShaderNodeLightPath')
        light_path.location = (-600, 0)
        
        # Fresnel için kamera açısı
        fresnel = nodes.new('ShaderNodeFresnel')
        fresnel.location = (-200, 0)
        
        # Mix shader for day/night
        mix_shader = nodes.new('ShaderNodeMixShader')
        mix_shader.location = (600, 0)
        
        # Emission shader for night side
        emission = nodes.new('ShaderNodeEmission')
        emission.location = (200, -200)
        emission.inputs['Strength'].default_value = 0.5
        
        # Bağlantılar
        links.new(day_tex.outputs['Color'], principled.inputs['Base Color'])
        links.new(normal_tex.outputs['Color'], normal_map.inputs['Color'])
        links.new(normal_map.outputs['Normal'], principled.inputs['Normal'])
        links.new(night_tex.outputs['Color'], emission.inputs['Color'])
        
        # Mix day/night
        links.new(principled.outputs['BSDF'], mix_shader.inputs[2])
        links.new(emission.outputs['Emission'], mix_shader.inputs[1])
        links.new(fresnel.outputs['Fac'], mix_shader.inputs['Fac'])
        links.new(mix_shader.outputs['Shader'], output.inputs['Surface'])
        
        # Materyal ata
        earth_obj.data.materials.append(earth_mat)
        
        # Procedurel texture'lar ekle (gerçek texture yoksa)
        self._add_procedural_earth_textures(earth_mat)
    
    def _add_procedural_earth_textures(self, material):
        """
        Procedurel Dünya dokuları ekler
        """
        nodes = material.node_tree.nodes
        links = material.node_tree.links
        
        # Koordinat sistemi
        tex_coord = nodes.new('ShaderNodeTexCoord')
        tex_coord.location = (-800, 0)
        
        # Mapping node
        mapping = nodes.new('ShaderNodeMapping')
        mapping.location = (-600, 0)
        
        # Land/Ocean mask için Noise
        noise_land = nodes.new('ShaderNodeTexNoise')
        noise_land.location = (-600, 200)
        noise_land.inputs['Scale'].default_value = 3.0
        noise_land.inputs['Detail'].default_value = 8.0
        
        # ColorRamp for land/ocean separation
        land_ramp = nodes.new('ShaderNodeValToRGB')
        land_ramp.location = (-400, 300)
        
        # Land color
        land_ramp.color_ramp.elements[0].color = (0.1, 0.3, 0.8, 1.0)  # Ocean blue
        land_ramp.color_ramp.elements[1].color = (0.3, 0.6, 0.2, 1.0)  # Land green
        
        # Bağlantılar
        links.new(tex_coord.outputs['Generated'], mapping.inputs['Vector'])
        links.new(mapping.outputs['Vector'], noise_land.inputs['Vector'])
        links.new(noise_land.outputs['Fac'], land_ramp.inputs['Fac'])
        
        # Day texture'ı bul ve bağla
        if 'Day Texture' in [node.label for node in nodes]:
            day_tex = next(node for node in nodes if node.label == 'Day Texture')
            links.new(land_ramp.outputs['Color'], day_tex.inputs['Vector'])
    
    def _setup_atmosphere_materials(self, atmosphere_obj):
        """
        Atmosfer malzemesi
        """
        atmos_mat = bpy.data.materials.new(name="Atmosphere_Material")
        atmos_mat.use_nodes = True
        atmos_mat.blend_method = 'BLEND'
        
        nodes = atmos_mat.node_tree.nodes
        links = atmos_mat.node_tree.links
        
        nodes.clear()
        
        # Output
        output = nodes.new('ShaderNodeOutputMaterial')
        output.location = (400, 0)
        
        # Volume Scatter
        volume_scatter = nodes.new('ShaderNodeVolumeScatter')
        volume_scatter.location = (0, -200)
        volume_scatter.inputs['Density'].default_value = 0.01
        volume_scatter.inputs['Color'].default_value = (0.4, 0.7, 1.0, 1.0)  # Sky blue
        
        # Transparent BSDF for surface
        transparent = nodes.new('ShaderNodeBsdfTransparent')
        transparent.location = (0, 0)
        
        # Fresnel for atmosphere thickness
        fresnel = nodes.new('ShaderNodeFresnel')
        fresnel.location = (-200, 0)
        fresnel.inputs['IOR'].default_value = 1.33
        
        # Bağlantılar
        links.new(transparent.outputs['BSDF'], output.inputs['Surface'])
        links.new(volume_scatter.outputs['Volume'], output.inputs['Volume'])
        
        atmosphere_obj.data.materials.append(atmos_mat)
    
    def _setup_cloud_materials(self, clouds_obj):
        """
        Bulut malzemesi
        """
        cloud_mat = bpy.data.materials.new(name="Cloud_Material")
        cloud_mat.use_nodes = True
        cloud_mat.blend_method = 'BLEND'
        
        nodes = cloud_mat.node_tree.nodes
        links = cloud_mat.node_tree.links
        
        nodes.clear()
        
        # Output
        output = nodes.new('ShaderNodeOutputMaterial')
        output.location = (600, 0)
        
        # Principled BSDF
        principled = nodes.new('ShaderNodeBsdfPrincipled')
        principled.location = (200, 0)
        principled.inputs['Base Color'].default_value = (1.0, 1.0, 1.0, 1.0)
        principled.inputs['Transmission'].default_value = 0.8
        principled.inputs['Alpha'].default_value = 0.3
        
        # Noise texture for clouds
        noise = nodes.new('ShaderNodeTexNoise')
        noise.location = (-400, 0)
        noise.inputs['Scale'].default_value = 8.0
        noise.inputs['Detail'].default_value = 12.0
        
        # ColorRamp for cloud density
        ramp = nodes.new('ShaderNodeValToRGB')
        ramp.location = (-200, 0)
        ramp.color_ramp.elements[0].color = (0, 0, 0, 0)  # Transparent
        ramp.color_ramp.elements[1].color = (1, 1, 1, 0.8)  # White clouds
        
        # Texture coordinate
        tex_coord = nodes.new('ShaderNodeTexCoord')
        tex_coord.location = (-600, 0)
        
        # Bağlantılar
        links.new(tex_coord.outputs['Generated'], noise.inputs['Vector'])
        links.new(noise.outputs['Fac'], ramp.inputs['Fac'])
        links.new(ramp.outputs['Alpha'], principled.inputs['Alpha'])
        links.new(principled.outputs['BSDF'], output.inputs['Surface'])
        
        clouds_obj.data.materials.append(cloud_mat)
    
    def add_impact_location_marker(self, latitude, longitude, name="Impact_Site"):
        """
        Çarpma lokasyonu için marker ekler
        """
        # Coğrafi koordinatları Cartesian'a çevir
        lat_rad = math.radians(latitude)
        lon_rad = math.radians(longitude)
        
        x = self.earth_radius * math.cos(lat_rad) * math.cos(lon_rad)
        y = self.earth_radius * math.cos(lat_rad) * math.sin(lon_rad)
        z = self.earth_radius * math.sin(lat_rad)
        
        # Marker objesi oluştur
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=0.1,
            location=(x, y, z)
        )
        
        marker = bpy.context.active_object
        marker.name = name
        
        # Kırmızı materyal
        marker_mat = bpy.data.materials.new(name=f"{name}_Material")
        marker_mat.use_nodes = True
        
        principled = marker_mat.node_tree.nodes['Principled BSDF']
        principled.inputs['Base Color'].default_value = (1.0, 0.0, 0.0, 1.0)  # Red
        principled.inputs['Emission'].default_value = (1.0, 0.2, 0.2, 1.0)  # Glowing red
        principled.inputs['Emission Strength'].default_value = 2.0
        
        marker.data.materials.append(marker_mat)
        
        return marker
    
    def setup_earth_lighting(self):
        """
        Dünya için ışık sistemi kurar
        """
        # Ana güneş ışığı
        bpy.ops.object.light_add(
            type='SUN',
            location=(20, 0, 0)
        )
        sun = bpy.context.active_object
        sun.name = "Sun"
        sun.data.energy = 5.0
        sun.data.color = (1.0, 0.95, 0.8)  # Güneş rengi
        sun.data.angle = math.radians(0.53)  # Güneş'in açısal boyutu
        
        # HDRI world environment
        world = bpy.context.scene.world
        world.use_nodes = True
        
        nodes = world.node_tree.nodes
        links = world.node_tree.links
        
        # Background shader
        background = nodes.get('Background')
        if background:
            background.inputs['Strength'].default_value = 0.1  # Düşük ambient
            background.inputs['Color'].default_value = (0.01, 0.01, 0.05, 1.0)  # Space black
        
        return sun

# Ana fonksiyonlar
def create_earth_impact_scene():
    """
    Impact simülasyonu için komplet sahne oluşturur
    """
    # Scene'i temizle
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    
    # Earth generator
    earth_gen = EarthModelGenerator()
    
    # Dünya sistemi oluştur
    earth_system = earth_gen.create_complete_earth_system()
    
    # Işık sistemi
    sun = earth_gen.setup_earth_lighting()
    
    # Örnek impact lokasyonu (İstanbul)
    impact_marker = earth_gen.add_impact_location_marker(
        latitude=41.0082,
        longitude=28.9784,
        name="Istanbul_Impact"
    )
    
    # Kamera ayarla
    bpy.ops.object.camera_add(location=(15, -15, 10))
    camera = bpy.context.active_object
    camera.name = "Main_Camera"
    
    # Kamerayı Dünya'ya odakla
    constraint = camera.constraints.new('TRACK_TO')
    constraint.target = earth_system['earth']
    constraint.track_axis = 'TRACK_NEGATIVE_Z'
    constraint.up_axis = 'UP_Y'
    
    # Render ayarları
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.samples = 128
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    
    print("Earth impact scene created successfully!")
    
    return {
        'earth_system': earth_system,
        'sun': sun,
        'camera': camera,
        'impact_marker': impact_marker
    }

if __name__ == "__main__":
    create_earth_impact_scene()

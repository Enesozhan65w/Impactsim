import bpy
import bmesh
import mathutils
import math
import random
from mathutils import Vector, noise

class ImpactSimulation:
    """
    Asteroid çarpması için gerçekçi fizik simülasyonu
    Krater oluşumu, şok dalgaları, debris ve ejecta efektleri
    """
    
    def __init__(self):
        self.earth_radius = 6.371  # Blender units
        
    def simulate_asteroid_impact(self, asteroid_data, impact_coords, earth_obj):
        """
        Komplet asteroid impact simülasyonu
        """
        print(f"Simulating impact for {asteroid_data.get('name', 'Unknown')}")
        
        # Impact parametrelerini hesapla
        impact_params = self._calculate_impact_parameters(asteroid_data)
        
        # Çarpma lokasyonunu Cartesian koordinatlara çevir
        impact_pos = self._geo_to_cartesian(
            impact_coords['latitude'], 
            impact_coords['longitude']
        )
        
        # Impact timeline oluştur
        timeline = self._create_impact_timeline(impact_params)
        
        # Ana simülasyon bileşenleri
        simulation_objects = {}
        
        # 1. Asteroid approach trajectory
        trajectory = self._create_approach_trajectory(asteroid_data, impact_pos)
        simulation_objects['trajectory'] = trajectory
        
        # 2. Krater oluşumu
        crater = self._create_crater_formation(earth_obj, impact_pos, impact_params)
        simulation_objects['crater'] = crater
        
        # 3. Şok dalgası
        shockwave = self._create_shockwave_animation(impact_pos, impact_params)
        simulation_objects['shockwave'] = shockwave
        
        # 4. Debris ve Ejecta
        debris = self._create_debris_system(impact_pos, impact_params)
        simulation_objects['debris'] = debris
        
        # 5. Atmosfer efektleri
        atmosphere_fx = self._create_atmosphere_effects(impact_pos, impact_params)
        simulation_objects['atmosphere'] = atmosphere_fx
        
        # 6. Animasyon kurulumu
        self._setup_impact_animation(simulation_objects, timeline)
        
        print("Impact simulation created successfully!")
        return simulation_objects
    
    def _calculate_impact_parameters(self, asteroid_data):
        """
        NASA verilerinden impact parametrelerini hesaplar
        """
        diameter_km = asteroid_data.get('diameter_km', 1.0)
        velocity_kms = asteroid_data.get('v_rel_kms', 20.0)
        density_gcm3 = asteroid_data.get('density_gcm3', 2.6)
        angle_deg = asteroid_data.get('impact_angle', 45.0)
        
        # Kütle hesapla (kg)
        radius_m = (diameter_km * 1000) / 2
        volume_m3 = (4/3) * math.pi * (radius_m ** 3)
        mass_kg = volume_m3 * (density_gcm3 * 1000)
        
        # Kinetik enerji (Joule)
        velocity_ms = velocity_kms * 1000
        kinetic_energy = 0.5 * mass_kg * (velocity_ms ** 2)
        
        # TNT eşdeğeri (ton)
        tnt_equivalent = kinetic_energy / 4.184e9
        
        # Krater çapı (Collins et al. 2005 scaling law)
        crater_diameter_km = 1.161 * (tnt_equivalent ** 0.22) * (math.sin(math.radians(angle_deg)) ** (1/3))
        
        # Blender ölçeği
        crater_radius_units = crater_diameter_km / 2000.0  # km to blender units
        
        return {
            'mass_kg': mass_kg,
            'velocity_ms': velocity_ms,
            'kinetic_energy': kinetic_energy,
            'tnt_equivalent': tnt_equivalent,
            'crater_radius': crater_radius_units,
            'impact_angle': angle_deg,
            'diameter_km': diameter_km
        }
    
    def _geo_to_cartesian(self, latitude, longitude):
        """
        Coğrafi koordinatları Cartesian'a çevirir
        """
        lat_rad = math.radians(latitude)
        lon_rad = math.radians(longitude)
        
        x = self.earth_radius * math.cos(lat_rad) * math.cos(lon_rad)
        y = self.earth_radius * math.cos(lat_rad) * math.sin(lon_rad)
        z = self.earth_radius * math.sin(lat_rad)
        
        return Vector((x, y, z))
    
    def _create_impact_timeline(self, impact_params):
        """
        Impact animasyon timeline'ı oluşturur
        """
        return {
            'approach_start': 1,
            'impact_moment': 120,
            'crater_formation': 150,
            'shockwave_start': 160,
            'debris_peak': 200,
            'simulation_end': 300
        }
    
    def _create_approach_trajectory(self, asteroid_data, impact_pos):
        """
        Asteroid yaklaşma yörüngesi oluşturur
        """
        # Asteroid objesi oluştur (küçük versiyon)
        diameter_km = asteroid_data.get('diameter_km', 1.0)
        asteroid_radius = diameter_km / 2000.0
        
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=asteroid_radius,
            location=(0, 0, 50)  # Başlangıç pozisyonu (uzayda)
        )
        
        asteroid_obj = bpy.context.active_object
        asteroid_obj.name = f"Asteroid_{asteroid_data.get('name', 'Impact')}"
        
        # Materyal ekle
        self._add_asteroid_approach_material(asteroid_obj)
        
        # Approach trajectory path
        approach_distance = 100.0  # Blender units
        approach_angle = math.radians(asteroid_data.get('impact_angle', 45.0))
        
        # Start position
        start_pos = impact_pos + Vector((
            approach_distance * math.cos(approach_angle),
            0,
            approach_distance * math.sin(approach_angle)
        ))
        
        asteroid_obj.location = start_pos
        
        # Trajectory trail
        trail = self._create_trajectory_trail(start_pos, impact_pos)
        
        return {
            'asteroid': asteroid_obj,
            'trail': trail,
            'start_pos': start_pos,
            'impact_pos': impact_pos
        }
    
    def _create_trajectory_trail(self, start_pos, end_pos):
        """
        Asteroid trajectory için trail oluşturur
        """
        # Curve path oluştur
        curve_data = bpy.data.curves.new(name='Trajectory_Trail', type='CURVE')
        curve_data.dimensions = '3D'
        
        # Spline ekle
        spline = curve_data.splines.new(type='BEZIER')
        spline.bezier_points.add(1)  # 2 nokta total
        
        # İlk nokta
        spline.bezier_points[0].co = start_pos
        spline.bezier_points[0].handle_left_type = 'AUTO'
        spline.bezier_points[0].handle_right_type = 'AUTO'
        
        # Son nokta
        spline.bezier_points[1].co = end_pos
        spline.bezier_points[1].handle_left_type = 'AUTO'
        spline.bezier_points[1].handle_right_type = 'AUTO'
        
        # Curve objesi oluştur
        curve_obj = bpy.data.objects.new('Trajectory_Trail', curve_data)
        bpy.context.collection.objects.link(curve_obj)
        
        # Trail material
        trail_mat = bpy.data.materials.new(name="Trajectory_Material")
        trail_mat.use_nodes = True
        
        # Glowing trail effect
        principled = trail_mat.node_tree.nodes['Principled BSDF']
        principled.inputs['Emission'].default_value = (1.0, 0.5, 0.0, 1.0)  # Orange glow
        principled.inputs['Emission Strength'].default_value = 5.0
        
        curve_data.materials.append(trail_mat)
        curve_data.bevel_depth = 0.01  # Trail thickness
        
        return curve_obj
    
    def _add_asteroid_approach_material(self, asteroid_obj):
        """
        Yaklaşan asteroid için glowing material
        """
        mat = bpy.data.materials.new(name="Approaching_Asteroid")
        mat.use_nodes = True
        
        principled = mat.node_tree.nodes['Principled BSDF']
        principled.inputs['Base Color'].default_value = (0.7, 0.4, 0.2, 1.0)  # Rocky color
        principled.inputs['Emission'].default_value = (1.0, 0.3, 0.0, 1.0)  # Hot glow
        principled.inputs['Emission Strength'].default_value = 2.0
        principled.inputs['Roughness'].default_value = 0.9
        
        asteroid_obj.data.materials.append(mat)
    
    def _create_crater_formation(self, earth_obj, impact_pos, impact_params):
        """
        Krater oluşumu animasyonu
        """
        crater_radius = impact_params['crater_radius']
        
        # Displacement modifier ile krater oluştur
        displace_mod = earth_obj.modifiers.new(name="Crater_Displacement", type='DISPLACE')
        
        # Crater texture oluştur
        crater_tex = bpy.data.textures.new(name="Crater_Texture", type='CLOUDS')
        crater_tex.noise_scale = 0.5
        crater_tex.noise_depth = 4
        
        displace_mod.texture = crater_tex
        displace_mod.strength = -crater_radius * 0.1  # Negative = inward
        displace_mod.mid_level = 0.5
        
        # Keyframe animation
        displace_mod.strength = 0.0
        displace_mod.keyframe_insert(data_path="strength", frame=120)  # Impact moment
        
        displace_mod.strength = -crater_radius * 0.1
        displace_mod.keyframe_insert(data_path="strength", frame=150)  # Crater formed
        
        # Crater rim (elevated edge)
        rim_particles = self._create_crater_rim_particles(impact_pos, crater_radius)
        
        return {
            'displacement': displace_mod,
            'rim_particles': rim_particles
        }
    
    def _create_crater_rim_particles(self, impact_pos, crater_radius):
        """
        Krater kenarı için yükselen toprak parçacıkları
        """
        # Particle system
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=0.01,
            location=impact_pos
        )
        
        emitter = bpy.context.active_object
        emitter.name = "Crater_Rim_Emitter"
        
        # Particle system ekle
        particle_sys = emitter.modifiers.new(name="Crater_Rim_Particles", type='PARTICLE_SYSTEM')
        psettings = particle_sys.particle_system.settings
        
        # Particle ayarları
        psettings.count = 500
        psettings.frame_start = 155
        psettings.frame_end = 180
        psettings.emit_from = 'FACE'
        psettings.distribution = 'RAND'
        
        # Physics
        psettings.physics_type = 'NEWTON'
        psettings.normal_factor = crater_radius * 10  # Upward velocity
        psettings.factor_random = 0.5
        
        # Life settings
        psettings.lifetime = 100
        psettings.lifetime_random = 0.3
        
        return emitter
    
    def _create_shockwave_animation(self, impact_pos, impact_params):
        """
        Şok dalgası animasyonu
        """
        # Shockwave ring
        bpy.ops.mesh.primitive_uv_sphere_add(
            radius=0.1,
            location=impact_pos
        )
        
        shockwave = bpy.context.active_object
        shockwave.name = "Shockwave"
        
        # Material
        shock_mat = bpy.data.materials.new(name="Shockwave_Material")
        shock_mat.use_nodes = True
        shock_mat.blend_method = 'BLEND'
        
        nodes = shock_mat.node_tree.nodes
        links = shock_mat.node_tree.links
        nodes.clear()
        
        # Output
        output = nodes.new('ShaderNodeOutputMaterial')
        output.location = (400, 0)
        
        # Emission shader
        emission = nodes.new('ShaderNodeEmission')
        emission.location = (0, 0)
        emission.inputs['Color'].default_value = (1.0, 0.8, 0.3, 1.0)  # Explosion color
        emission.inputs['Strength'].default_value = 10.0
        
        # Fresnel for ring effect
        fresnel = nodes.new('ShaderNodeFresnel')
        fresnel.location = (-200, 0)
        fresnel.inputs['IOR'].default_value = 5.0
        
        links.new(fresnel.outputs['Fac'], emission.inputs['Strength'])
        links.new(emission.outputs['Emission'], output.inputs['Surface'])
        
        shockwave.data.materials.append(shock_mat)
        
        # Animasyon
        max_radius = impact_params['crater_radius'] * 10  # Shockwave extends beyond crater
        
        # Start small
        shockwave.scale = (0.01, 0.01, 0.01)
        shockwave.keyframe_insert(data_path="scale", frame=160)
        
        # Expand rapidly
        shockwave.scale = (max_radius, max_radius, max_radius * 0.1)  # Flattened sphere
        shockwave.keyframe_insert(data_path="scale", frame=200)
        
        # Alpha fade out
        emission.inputs['Strength'].default_value = 10.0
        emission.keyframe_insert(data_path='inputs[1].default_value', frame=160)
        
        emission.inputs['Strength'].default_value = 0.0
        emission.keyframe_insert(data_path='inputs[1].default_value', frame=220)
        
        return shockwave
    
    def _create_debris_system(self, impact_pos, impact_params):
        """
        Debris ve ejecta sistemi
        """
        debris_objects = []
        
        # Ana debris emitter
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=0.01,
            location=impact_pos
        )
        
        main_emitter = bpy.context.active_object
        main_emitter.name = "Main_Debris_Emitter"
        
        # Particle system
        particle_sys = main_emitter.modifiers.new(name="Debris_Particles", type='PARTICLE_SYSTEM')
        psettings = particle_sys.particle_system.settings
        
        # Debris ayarları
        psettings.count = 1000
        psettings.frame_start = 120  # Impact anında
        psettings.frame_end = 140
        psettings.emit_from = 'FACE'
        
        # Physics
        psettings.physics_type = 'NEWTON'
        psettings.normal_factor = impact_params['crater_radius'] * 50  # Launch velocity
        psettings.factor_random = 0.8
        psettings.object_align_factor = (0, 0, 1)  # Mostly upward
        
        # Life
        psettings.lifetime = 200
        psettings.lifetime_random = 0.5
        
        # Render as objects
        psettings.render_type = 'OBJECT'
        
        # Debris chunk mesh
        bpy.ops.mesh.primitive_cube_add(radius=0.02)
        debris_mesh = bpy.context.active_object
        debris_mesh.name = "Debris_Chunk"
        debris_mesh.location = (100, 100, 100)  # Hide it
        
        psettings.instance_object = debris_mesh
        psettings.use_rotation_instance = True
        
        debris_objects.append(main_emitter)
        debris_objects.append(debris_mesh)
        
        # Ejecta plume (high-speed particles)
        self._create_ejecta_plume(impact_pos, impact_params, debris_objects)
        
        return debris_objects
    
    def _create_ejecta_plume(self, impact_pos, impact_params, debris_objects):
        """
        Yüksek hızlı ejecta plume
        """
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=0.005,
            location=impact_pos
        )
        
        ejecta_emitter = bpy.context.active_object
        ejecta_emitter.name = "Ejecta_Emitter"
        
        # Particle system
        particle_sys = ejecta_emitter.modifiers.new(name="Ejecta_Particles", type='PARTICLE_SYSTEM')
        psettings = particle_sys.particle_system.settings
        
        # High-velocity particles
        psettings.count = 2000
        psettings.frame_start = 118
        psettings.frame_end = 125
        
        # Physics
        psettings.physics_type = 'NEWTON'
        psettings.normal_factor = impact_params['crater_radius'] * 100  # Very high velocity
        psettings.factor_random = 0.9
        
        # Life
        psettings.lifetime = 150
        
        # Size variation
        psettings.particle_size = 0.001
        psettings.size_random = 0.8
        
        debris_objects.append(ejecta_emitter)
    
    def _create_atmosphere_effects(self, impact_pos, impact_params):
        """
        Atmosfer efektleri (fireball, plasma plume)
        """
        atmosphere_fx = []
        
        # Fireball
        bpy.ops.mesh.primitive_uv_sphere_add(
            radius=impact_params['crater_radius'] * 2,
            location=impact_pos
        )
        
        fireball = bpy.context.active_object
        fireball.name = "Impact_Fireball"
        
        # Fireball material
        fireball_mat = bpy.data.materials.new(name="Fireball_Material")
        fireball_mat.use_nodes = True
        
        nodes = fireball_mat.node_tree.nodes
        nodes.clear()
        
        # Output
        output = nodes.new('ShaderNodeOutputMaterial')
        output.location = (400, 0)
        
        # Volume shader
        volume = nodes.new('ShaderNodeVolumeScatter')
        volume.location = (0, 0)
        volume.inputs['Color'].default_value = (1.0, 0.3, 0.1, 1.0)  # Fire color
        volume.inputs['Density'].default_value = 0.5
        
        # Emission for glow
        emission = nodes.new('ShaderNodeEmission')
        emission.location = (0, 200)
        emission.inputs['Color'].default_value = (1.0, 0.5, 0.0, 1.0)
        emission.inputs['Strength'].default_value = 20.0
        
        nodes.new('ShaderNodeOutputMaterial').location = (400, 0)
        
        fireball_mat.node_tree.links.new(emission.outputs['Emission'], output.inputs['Surface'])
        fireball_mat.node_tree.links.new(volume.outputs['Volume'], output.inputs['Volume'])
        
        fireball.data.materials.append(fireball_mat)
        
        # Fireball expansion animation
        fireball.scale = (0.01, 0.01, 0.01)
        fireball.keyframe_insert(data_path="scale", frame=120)
        
        max_scale = impact_params['crater_radius'] * 5
        fireball.scale = (max_scale, max_scale, max_scale)
        fireball.keyframe_insert(data_path="scale", frame=180)
        
        # Fade out
        emission.inputs['Strength'].default_value = 20.0
        emission.keyframe_insert(data_path='inputs[1].default_value', frame=120)
        
        emission.inputs['Strength'].default_value = 0.0
        emission.keyframe_insert(data_path='inputs[1].default_value', frame=250)
        
        atmosphere_fx.append(fireball)
        
        return atmosphere_fx
    
    def _setup_impact_animation(self, simulation_objects, timeline):
        """
        Tüm animasyon elementlerini senkronize eder
        """
        # Timeline setup
        bpy.context.scene.frame_start = timeline['approach_start']
        bpy.context.scene.frame_end = timeline['simulation_end']
        bpy.context.scene.frame_set(timeline['approach_start'])
        
        # Asteroid approach animation
        trajectory = simulation_objects['trajectory']
        asteroid = trajectory['asteroid']
        
        # Approach keyframes
        asteroid.location = trajectory['start_pos']
        asteroid.keyframe_insert(data_path="location", frame=timeline['approach_start'])
        
        asteroid.location = trajectory['impact_pos']
        asteroid.keyframe_insert(data_path="location", frame=timeline['impact_moment'])
        
        # Hide asteroid after impact
        asteroid.hide_viewport = False
        asteroid.keyframe_insert(data_path="hide_viewport", frame=timeline['impact_moment'] - 1)
        
        asteroid.hide_viewport = True
        asteroid.keyframe_insert(data_path="hide_viewport", frame=timeline['impact_moment'])
        
        print("Impact animation setup completed!")

# Ana fonksiyonlar
def simulate_apophis_impact():
    """
    Apophis impact senaryosu için örnek simülasyon
    """
    # Apophis verisi
    apophis_data = {
        'name': 'Apophis',
        'diameter_km': 0.370,
        'v_rel_kms': 12.6,
        'density_gcm3': 3.2,
        'impact_angle': 45.0
    }
    
    # Impact koordinatları (İstanbul)
    impact_coords = {
        'latitude': 41.0082,
        'longitude': 28.9784
    }
    
    # Dünya objesi (varsa)
    earth_obj = bpy.data.objects.get('Earth')
    if not earth_obj:
        print("Earth object not found! Please run earth_setup.py first.")
        return
    
    # Simülasyon oluştur
    impact_sim = ImpactSimulation()
    simulation = impact_sim.simulate_asteroid_impact(apophis_data, impact_coords, earth_obj)
    
    print("Apophis impact simulation created!")
    return simulation

if __name__ == "__main__":
    simulate_apophis_impact()

import bpy
import bmesh
import mathutils
import math
import json
import sys
from mathutils import Vector, Euler

class RocketSimulation3D:
    """
    LEO (Low Earth Orbit) roket simülasyonu için Blender 3D sistemi
    Flutter'dan gelen telemetri verilerini gerçekçi 3D animasyonda görselleştirir
    """
    
    def __init__(self):
        self.earth_radius = 6.371  # Blender units (6371 km)
        self.atmosphere_layers = {
            'troposphere': 0.012,    # 12 km
            'stratosphere': 0.050,   # 50 km
            'mesosphere': 0.085,     # 85 km
            'thermosphere': 0.600,   # 600 km (LEO bölgesi)
        }
        
    def create_rocket_simulation(self, config_data):
        """
        Komplet roket LEO simülasyonu oluşturur
        """
        print("Creating Rocket LEO Simulation...")
        
        rocket_data = config_data.get('rocket', {})
        flight_profile = config_data.get('flight_profile', {})
        telemetry_data = config_data.get('telemetry', [])
        
        # Scene setup
        self._setup_space_environment()
        
        # Dünya modeli (LEO perspektifi için)
        earth_system = self._create_earth_for_leo()
        
        # Roket modeli oluştur
        rocket_obj = self._create_rocket_model(rocket_data)
        
        # Atmosfer katmanları
        atmosphere_layers = self._create_atmosphere_layers()
        
        # Roket trajectory ve physics
        trajectory_system = self._create_rocket_trajectory(rocket_obj, flight_profile, telemetry_data)
        
        # Effects systems
        effects = self._create_rocket_effects(rocket_obj, telemetry_data)
        
        # Camera system
        cameras = self._setup_rocket_cameras(rocket_obj)
        
        # Telemetry HUD
        hud_elements = self._create_telemetry_hud(telemetry_data)
        
        print("Rocket simulation created successfully!")
        
        return {
            'rocket': rocket_obj,
            'earth': earth_system,
            'atmosphere': atmosphere_layers,
            'trajectory': trajectory_system,
            'effects': effects,
            'cameras': cameras,
            'hud': hud_elements
        }
    
    def _setup_space_environment(self):
        """
        Uzay ortamı kurar
        """
        # Scene temizle
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete(use_global=False)
        
        # Space background
        world = bpy.context.scene.world
        world.use_nodes = True
        
        nodes = world.node_tree.nodes
        nodes.clear()
        
        # Deep space background
        background = nodes.new('ShaderNodeBackground')
        background.inputs['Color'].default_value = (0.001, 0.001, 0.008, 1.0)
        background.inputs['Strength'].default_value = 0.3
        
        # Star field texture
        tex_coord = nodes.new('ShaderNodeTexCoord')
        noise_tex = nodes.new('ShaderNodeTexNoise')
        noise_tex.inputs['Scale'].default_value = 1000.0
        noise_tex.inputs['Detail'].default_value = 15.0
        
        color_ramp = nodes.new('ShaderNodeValToRGB')
        color_ramp.color_ramp.elements[0].position = 0.95
        color_ramp.color_ramp.elements[1].position = 1.0
        color_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
        color_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
        
        mix = nodes.new('ShaderNodeMixRGB')
        mix.blend_type = 'ADD'
        mix.inputs['Fac'].default_value = 0.3
        
        output = nodes.new('ShaderNodeOutputWorld')
        
        # Bağlantılar
        world.node_tree.links.new(tex_coord.outputs['Generated'], noise_tex.inputs['Vector'])
        world.node_tree.links.new(noise_tex.outputs['Fac'], color_ramp.inputs['Fac'])
        world.node_tree.links.new(background.outputs['Background'], mix.inputs['Color1'])
        world.node_tree.links.new(color_ramp.outputs['Color'], mix.inputs['Color2'])
        world.node_tree.links.new(mix.outputs['Color'], output.inputs['Surface'])
    
    def _create_earth_for_leo(self):
        """
        LEO perspektifi için Dünya modeli
        """
        # Dünya küresi
        bpy.ops.mesh.primitive_uv_sphere_add(
            radius=self.earth_radius,
            location=(0, 0, -self.earth_radius - 0.4),  # LEO yüksekliği
            segments=64,
            rings=32
        )
        
        earth = bpy.context.active_object
        earth.name = "Earth_LEO"
        
        # Earth material
        earth_mat = bpy.data.materials.new(name="Earth_LEO_Material")
        earth_mat.use_nodes = True
        
        nodes = earth_mat.node_tree.nodes
        principled = nodes['Principled BSDF']
        
        # Earth colors
        principled.inputs['Base Color'].default_value = (0.2, 0.4, 0.8, 1.0)
        principled.inputs['Roughness'].default_value = 0.7
        
        # City lights for night side
        emission = nodes.new('ShaderNodeEmission')
        emission.inputs['Color'].default_value = (1.0, 0.8, 0.3, 1.0)
        emission.inputs['Strength'].default_value = 0.5
        
        # Mix for day/night
        mix_shader = nodes.new('ShaderNodeMixShader')
        fresnel = nodes.new('ShaderNodeFresnel')
        fresnel.inputs['IOR'].default_value = 1.45
        
        earth_mat.node_tree.links.new(fresnel.outputs['Fac'], mix_shader.inputs['Fac'])
        earth_mat.node_tree.links.new(principled.outputs['BSDF'], mix_shader.inputs[1])
        earth_mat.node_tree.links.new(emission.outputs['Emission'], mix_shader.inputs[2])
        
        output = nodes['Material Output']
        earth_mat.node_tree.links.new(mix_shader.outputs['Shader'], output.inputs['Surface'])
        
        earth.data.materials.append(earth_mat)
        
        # Earth rotation animation
        earth.rotation_euler = (0, 0, 0)
        earth.keyframe_insert(data_path="rotation_euler", frame=1)
        
        earth.rotation_euler = (0, 0, math.radians(360))
        earth.keyframe_insert(data_path="rotation_euler", frame=1440)  # 24 saat = 1440 frame
        
        return earth
    
    def _create_atmosphere_layers(self):
        """
        Atmosfer katmanlarını oluşturur
        """
        layers = {}
        
        colors = {
            'troposphere': (0.5, 0.7, 1.0, 0.3),
            'stratosphere': (0.4, 0.6, 0.9, 0.2),
            'mesosphere': (0.3, 0.5, 0.8, 0.15),
            'thermosphere': (0.2, 0.3, 0.6, 0.1),
        }
        
        for layer_name, height in self.atmosphere_layers.items():
            layer_radius = self.earth_radius + height
            
            bpy.ops.mesh.primitive_uv_sphere_add(
                radius=layer_radius,
                location=(0, 0, -self.earth_radius - 0.4),
                segments=32,
                rings=16
            )
            
            layer_obj = bpy.context.active_object
            layer_obj.name = f"Atmosphere_{layer_name}"
            
            # Atmosphere material
            layer_mat = bpy.data.materials.new(name=f"Atmosphere_{layer_name}_Material")
            layer_mat.use_nodes = True
            layer_mat.blend_method = 'BLEND'
            
            nodes = layer_mat.node_tree.nodes
            nodes.clear()
            
            output = nodes.new('ShaderNodeOutputMaterial')
            transparent = nodes.new('ShaderNodeBsdfTransparent')
            
            color = colors[layer_name]
            transparent.inputs['Color'].default_value = color
            
            layer_mat.node_tree.links.new(transparent.outputs['BSDF'], output.inputs['Surface'])
            
            layer_obj.data.materials.append(layer_mat)
            layers[layer_name] = layer_obj
            
        return layers
    
    def _create_rocket_model(self, rocket_data):
        """
        Detaylı roket modeli oluşturur
        """
        # Main rocket body
        bpy.ops.mesh.primitive_cylinder_add(
            radius=0.05,
            depth=0.5,
            location=(0, 0, 0)
        )
        
        rocket_body = bpy.context.active_object
        rocket_body.name = "Rocket_Body"
        
        # Rocket nose cone
        bpy.ops.mesh.primitive_cone_add(
            radius1=0.05,
            radius2=0.01,
            depth=0.15,
            location=(0, 0, 0.325)
        )
        
        nose_cone = bpy.context.active_object
        nose_cone.name = "Rocket_Nose"
        nose_cone.parent = rocket_body
        
        # Rocket fins
        self._add_rocket_fins(rocket_body)
        
        # Engine nozzles
        self._add_engine_nozzles(rocket_body)
        
        # Solar panels (for satellites)
        if rocket_data.get('has_solar_panels', True):
            self._add_solar_panels(rocket_body)
        
        # Rocket material
        self._apply_rocket_materials(rocket_body, rocket_data)
        
        return rocket_body
    
    def _add_rocket_fins(self, rocket_body):
        """
        Roket kanatları ekler
        """
        for i in range(4):
            angle = (i * 90) * math.pi / 180
            x = 0.07 * math.cos(angle)
            y = 0.07 * math.sin(angle)
            
            bpy.ops.mesh.primitive_cube_add(
                size=0.02,
                location=(x, y, -0.2)
            )
            
            fin = bpy.context.active_object
            fin.name = f"Rocket_Fin_{i}"
            fin.scale = (0.5, 3.0, 5.0)
            fin.parent = rocket_body
    
    def _add_engine_nozzles(self, rocket_body):
        """
        Motor nozulları ekler
        """
        for i in range(rocket_data.get('engine_count', 1)):
            if i == 0:
                # Main engine
                bpy.ops.mesh.primitive_cone_add(
                    radius1=0.04,
                    radius2=0.02,
                    depth=0.08,
                    location=(0, 0, -0.29)
                )
            else:
                # Additional engines
                angle = (i * 60) * math.pi / 180
                x = 0.03 * math.cos(angle)
                y = 0.03 * math.sin(angle)
                
                bpy.ops.mesh.primitive_cone_add(
                    radius1=0.02,
                    radius2=0.01,
                    depth=0.06,
                    location=(x, y, -0.29)
                )
            
            nozzle = bpy.context.active_object
            nozzle.name = f"Engine_Nozzle_{i}"
            nozzle.parent = rocket_body
    
    def _add_solar_panels(self, rocket_body):
        """
        Solar paneller ekler
        """
        for i in range(2):
            side = 1 if i == 0 else -1
            
            bpy.ops.mesh.primitive_cube_add(
                location=(side * 0.2, 0, 0.1)
            )
            
            panel = bpy.context.active_object
            panel.name = f"Solar_Panel_{i}"
            panel.scale = (0.05, 0.3, 0.2)
            panel.parent = rocket_body
            
            # Solar panel material
            panel_mat = bpy.data.materials.new(name=f"Solar_Panel_Material_{i}")
            panel_mat.use_nodes = True
            
            principled = panel_mat.node_tree.nodes['Principled BSDF']
            principled.inputs['Base Color'].default_value = (0.1, 0.1, 0.4, 1.0)
            principled.inputs['Metallic'].default_value = 0.8
            principled.inputs['Roughness'].default_value = 0.1
            
            panel.data.materials.append(panel_mat)
    
    def _apply_rocket_materials(self, rocket_body, rocket_data):
        """
        Roket materyallerini uygular
        """
        # Main body material
        rocket_mat = bpy.data.materials.new(name="Rocket_Material")
        rocket_mat.use_nodes = True
        
        nodes = rocket_mat.node_tree.nodes
        principled = nodes['Principled BSDF']
        
        # Metallic white rocket
        principled.inputs['Base Color'].default_value = (0.9, 0.9, 0.9, 1.0)
        principled.inputs['Metallic'].default_value = 0.7
        principled.inputs['Roughness'].default_value = 0.3
        
        # Heat effects based on temperature
        temperature = rocket_data.get('temperature', 20)  # Celsius
        if temperature > 100:
            # Hot glow
            principled.inputs['Emission'].default_value = (1.0, 0.5, 0.2, 1.0)
            principled.inputs['Emission Strength'].default_value = (temperature - 100) / 1000
        
        rocket_body.data.materials.append(rocket_mat)
    
    def _create_rocket_trajectory(self, rocket_obj, flight_profile, telemetry_data):
        """
        Roket trajectory ve physics animasyonu
        """
        trajectory_objects = {}
        
        # Launch trajectory path
        trajectory_path = self._create_trajectory_path(flight_profile)
        trajectory_objects['path'] = trajectory_path
        
        # Animate rocket along trajectory
        self._animate_rocket_flight(rocket_obj, flight_profile, telemetry_data)
        
        # Orbital elements (for LEO insertion)
        if flight_profile.get('target_orbit'):
            orbit_viz = self._create_orbital_visualization(flight_profile['target_orbit'])
            trajectory_objects['target_orbit'] = orbit_viz
        
        return trajectory_objects
    
    def _create_trajectory_path(self, flight_profile):
        """
        Launch trajectory path oluşturur
        """
        # Launch phases
        phases = [
            {'name': 'launch', 'altitude': 0, 'duration': 30},
            {'name': 'gravity_turn', 'altitude': 0.01, 'duration': 60},
            {'name': 'main_engine_cutoff', 'altitude': 0.08, 'duration': 120},
            {'name': 'second_stage', 'altitude': 0.15, 'duration': 180},
            {'name': 'leo_insertion', 'altitude': 0.4, 'duration': 240},
        ]
        
        # Create curve path
        curve_data = bpy.data.curves.new(name='Launch_Trajectory', type='CURVE')
        curve_data.dimensions = '3D'
        
        spline = curve_data.splines.new(type='BEZIER')
        spline.bezier_points.add(len(phases) - 1)
        
        for i, phase in enumerate(phases):
            altitude = phase['altitude']
            # Parabolic trajectory simulation
            x = altitude * math.sin(i * 0.3)
            y = 0
            z = -self.earth_radius - 0.4 + altitude
            
            spline.bezier_points[i].co = (x, y, z)
            spline.bezier_points[i].handle_left_type = 'AUTO'
            spline.bezier_points[i].handle_right_type = 'AUTO'
        
        # Create curve object
        trajectory_obj = bpy.data.objects.new('Launch_Trajectory', curve_data)
        bpy.context.collection.objects.link(trajectory_obj)
        
        # Trajectory material
        traj_mat = bpy.data.materials.new(name="Trajectory_Material")
        traj_mat.use_nodes = True
        
        principled = traj_mat.node_tree.nodes['Principled BSDF']
        principled.inputs['Emission'].default_value = (0.0, 1.0, 0.5, 1.0)
        principled.inputs['Emission Strength'].default_value = 2.0
        
        curve_data.materials.append(traj_mat)
        curve_data.bevel_depth = 0.002
        
        return trajectory_obj
    
    def _animate_rocket_flight(self, rocket_obj, flight_profile, telemetry_data):
        """
        Roket uçuş animasyonu
        """
        # Animation timeline
        total_frames = len(telemetry_data) if telemetry_data else 300
        
        for frame_i, data_point in enumerate(telemetry_data or []):
            frame = frame_i + 1
            
            # Position based on altitude and velocity
            altitude = data_point.get('altitude', 0) / 1000  # km to Blender units
            velocity = data_point.get('velocity', 0)
            
            # Trajectory position
            progress = frame_i / len(telemetry_data)
            x = altitude * math.sin(progress * 0.5) * 0.5
            y = 0
            z = -self.earth_radius - 0.4 + (altitude / 1000)  # Scale altitude
            
            rocket_obj.location = (x, y, z)
            rocket_obj.keyframe_insert(data_path="location", frame=frame)
            
            # Rotation (pitch based on trajectory)
            pitch = math.atan2(velocity, 100) if velocity > 0 else 0
            rocket_obj.rotation_euler = (pitch, 0, 0)
            rocket_obj.keyframe_insert(data_path="rotation_euler", frame=frame)
            
            # Scale effects based on speed
            scale_factor = 1.0 + (velocity / 10000)  # Speed blur effect
            rocket_obj.scale = (1.0, 1.0, scale_factor)
            rocket_obj.keyframe_insert(data_path="scale", frame=frame)
    
    def _create_rocket_effects(self, rocket_obj, telemetry_data):
        """
        Roket efektleri (exhaust, vapor trail, etc.)
        """
        effects = {}
        
        # Engine exhaust
        exhaust = self._create_engine_exhaust(rocket_obj, telemetry_data)
        effects['exhaust'] = exhaust
        
        # Vapor trail
        vapor_trail = self._create_vapor_trail(rocket_obj)
        effects['vapor_trail'] = vapor_trail
        
        # Stage separation effects
        if any(data.get('stage_separation') for data in telemetry_data or []):
            separation_fx = self._create_separation_effects(rocket_obj, telemetry_data)
            effects['separation'] = separation_fx
        
        return effects
    
    def _create_engine_exhaust(self, rocket_obj, telemetry_data):
        """
        Motor exhaust efekti
        """
        # Exhaust emitter
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=0.01,
            location=(0, 0, -0.35)
        )
        
        exhaust_emitter = bpy.context.active_object
        exhaust_emitter.name = "Exhaust_Emitter"
        exhaust_emitter.parent = rocket_obj
        
        # Particle system for exhaust
        particle_sys = exhaust_emitter.modifiers.new(name="Exhaust_Particles", type='PARTICLE_SYSTEM')
        psettings = particle_sys.particle_system.settings
        
        # Exhaust settings
        psettings.count = 1000
        psettings.frame_start = 1
        psettings.frame_end = len(telemetry_data) if telemetry_data else 300
        psettings.emit_from = 'FACE'
        
        # Physics
        psettings.physics_type = 'NEWTON'
        psettings.normal_factor = -20.0  # Downward thrust
        psettings.factor_random = 0.3
        
        # Life and appearance
        psettings.lifetime = 30
        psettings.particle_size = 0.05
        psettings.size_random = 0.5
        
        # Material
        exhaust_mat = bpy.data.materials.new(name="Exhaust_Material")
        exhaust_mat.use_nodes = True
        
        nodes = exhaust_mat.node_tree.nodes
        principled = nodes['Principled BSDF']
        principled.inputs['Emission'].default_value = (1.0, 0.5, 0.1, 1.0)
        principled.inputs['Emission Strength'].default_value = 5.0
        
        # Animate exhaust based on thrust
        for frame_i, data_point in enumerate(telemetry_data or []):
            frame = frame_i + 1
            thrust_percent = data_point.get('thrust_percent', 100) / 100.0
            
            # Adjust emission strength based on thrust
            principled.inputs['Emission Strength'].default_value = thrust_percent * 5.0
            principled.keyframe_insert(data_path='inputs[1].default_value', frame=frame)
        
        return exhaust_emitter
    
    def _create_vapor_trail(self, rocket_obj):
        """
        Vapor trail efekti
        """
        # Trail emitter
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=0.005,
            location=(0, 0, 0)
        )
        
        trail_emitter = bpy.context.active_object
        trail_emitter.name = "Vapor_Trail_Emitter"
        trail_emitter.parent = rocket_obj
        
        # Particle system
        particle_sys = trail_emitter.modifiers.new(name="Vapor_Particles", type='PARTICLE_SYSTEM')
        psettings = particle_sys.particle_system.settings
        
        # Trail settings
        psettings.count = 500
        psettings.frame_start = 1
        psettings.frame_end = 300
        psettings.lifetime = 120
        psettings.emit_from = 'FACE'
        psettings.physics_type = 'NEWTON'
        psettings.normal_factor = 0.1
        
        return trail_emitter
    
    def _create_separation_effects(self, rocket_obj, telemetry_data):
        """
        Stage separation efektleri
        """
        separation_effects = []
        
        for frame_i, data_point in enumerate(telemetry_data or []):
            if data_point.get('stage_separation'):
                frame = frame_i + 1
                
                # Separation debris
                bpy.ops.mesh.primitive_ico_sphere_add(
                    radius=0.02,
                    location=rocket_obj.location
                )
                
                debris = bpy.context.active_object
                debris.name = f"Stage_Debris_{frame}"
                
                # Animate debris separation
                debris.location = rocket_obj.location
                debris.keyframe_insert(data_path="location", frame=frame)
                
                # Debris falls away
                debris.location = (
                    rocket_obj.location.x + random.uniform(-0.5, 0.5),
                    rocket_obj.location.y + random.uniform(-0.5, 0.5),
                    rocket_obj.location.z - 1.0
                )
                debris.keyframe_insert(data_path="location", frame=frame + 60)
                
                separation_effects.append(debris)
        
        return separation_effects
    
    def _setup_rocket_cameras(self, rocket_obj):
        """
        Roket kamera sistemi
        """
        cameras = {}
        
        # Chase camera
        bpy.ops.object.camera_add(location=(0, -2, 0.5))
        chase_cam = bpy.context.active_object
        chase_cam.name = "Rocket_Chase_Camera"
        
        # Track to rocket
        constraint = chase_cam.constraints.new('TRACK_TO')
        constraint.target = rocket_obj
        constraint.track_axis = 'TRACK_NEGATIVE_Z'
        constraint.up_axis = 'UP_Y'
        
        # Parent to rocket for following
        chase_cam.parent = rocket_obj
        cameras['chase'] = chase_cam
        
        # Ground view camera
        bpy.ops.object.camera_add(location=(0, -5, -self.earth_radius - 0.3))
        ground_cam = bpy.context.active_object
        ground_cam.name = "Ground_View_Camera"
        
        # Track rocket from ground
        constraint = ground_cam.constraints.new('TRACK_TO')
        constraint.target = rocket_obj
        cameras['ground'] = ground_cam
        
        # Orbital overview camera
        bpy.ops.object.camera_add(location=(2, -3, 1))
        orbital_cam = bpy.context.active_object
        orbital_cam.name = "Orbital_Overview_Camera"
        cameras['orbital'] = orbital_cam
        
        return cameras
    
    def _create_telemetry_hud(self, telemetry_data):
        """
        Telemetri HUD elementleri oluşturur
        """
        hud_elements = {}
        
        # Velocity indicator
        bpy.ops.object.text_add(location=(1.5, 1.0, 0.8))
        velocity_text = bpy.context.active_object
        velocity_text.name = "Velocity_HUD"
        velocity_text.data.body = "Hız: 0 m/s"
        velocity_text.data.size = 0.15
        
        # Animate velocity text
        for frame_i, data_point in enumerate(telemetry_data or []):
            frame = frame_i + 1
            velocity = data_point.get('velocity', 0)
            velocity_text.data.body = f"Hız: {velocity:.1f} m/s"
            velocity_text.keyframe_insert(data_path='data.body', frame=frame)
        
        hud_elements['velocity'] = velocity_text
        
        # Altitude indicator
        bpy.ops.object.text_add(location=(1.5, 1.0, 0.6))
        altitude_text = bpy.context.active_object
        altitude_text.name = "Altitude_HUD"
        altitude_text.data.body = "Yükseklik: 0 m"
        altitude_text.data.size = 0.15
        
        # Temperature indicator
        bpy.ops.object.text_add(location=(1.5, 1.0, 0.4))
        temp_text = bpy.context.active_object
        temp_text.name = "Temperature_HUD"
        temp_text.data.body = "Sıcaklık: 20°C"
        temp_text.data.size = 0.15
        
        # Fuel indicator
        bpy.ops.object.text_add(location=(1.5, 1.0, 0.2))
        fuel_text = bpy.context.active_object
        fuel_text.name = "Fuel_HUD"
        fuel_text.data.body = "Yakıt: 100%"
        fuel_text.data.size = 0.15
        
        hud_elements['altitude'] = altitude_text
        hud_elements['temperature'] = temp_text
        hud_elements['fuel'] = fuel_text
        
        return hud_elements

# Main execution function
def main():
    """
    Roket simülasyonu ana fonksiyonu
    """
    print("=== Rocket LEO Simulation ===")
    
    if '--' in sys.argv:
        argv = sys.argv[sys.argv.index('--') + 1:]
        
        config_path = None
        output_id = None
        
        for i, arg in enumerate(argv):
            if arg == '--config' and i + 1 < len(argv):
                config_path = argv[i + 1]
            elif arg == '--output-id' and i + 1 < len(argv):
                output_id = argv[i + 1]
        
        if config_path:
            try:
                with open(config_path, 'r') as f:
                    config_data = json.load(f)
                
                # Create rocket simulation
                rocket_sim = RocketSimulation3D()
                result = rocket_sim.create_rocket_simulation(config_data)
                
                # Setup rendering
                scene = bpy.context.scene
                render_settings = config_data.get('render_settings', {})
                
                scene.render.engine = render_settings.get('engine', 'EEVEE')
                scene.render.resolution_x = render_settings.get('resolution_x', 1920)
                scene.render.resolution_y = render_settings.get('resolution_y', 1080)
                scene.frame_start = 1
                scene.frame_end = len(config_data.get('telemetry', [])) or 300
                
                # Output path
                if output_id:
                    import os
                    output_dir = f"blender_integration/output/{output_id}/"
                    os.makedirs(output_dir, exist_ok=True)
                    scene.render.filepath = f"{output_dir}rocket_simulation_"
                
                print(f"Rocket simulation setup complete! Output ID: {output_id}")
                
            except Exception as e:
                print(f"Rocket simulation error: {e}")
                sys.exit(1)
        else:
            print("No config file provided!")
    else:
        # Test mode
        print("Running in test mode...")
        
        # Example telemetry data
        test_telemetry = [
            {'velocity': 0, 'altitude': 0, 'temperature': 20, 'fuel_percent': 100, 'thrust_percent': 100},
            {'velocity': 50, 'altitude': 100, 'temperature': 25, 'fuel_percent': 98, 'thrust_percent': 100},
            {'velocity': 150, 'altitude': 500, 'temperature': 30, 'fuel_percent': 95, 'thrust_percent': 100},
            {'velocity': 300, 'altitude': 1000, 'temperature': 40, 'fuel_percent': 90, 'thrust_percent': 90},
            {'velocity': 500, 'altitude': 2000, 'temperature': 60, 'fuel_percent': 85, 'thrust_percent': 80},
            {'velocity': 800, 'altitude': 5000, 'temperature': 100, 'fuel_percent': 75, 'thrust_percent': 70, 'stage_separation': True},
            {'velocity': 1200, 'altitude': 10000, 'temperature': 150, 'fuel_percent': 60, 'thrust_percent': 60},
            {'velocity': 2000, 'altitude': 20000, 'temperature': 200, 'fuel_percent': 40, 'thrust_percent': 40},
            {'velocity': 3500, 'altitude': 50000, 'temperature': 300, 'fuel_percent': 20, 'thrust_percent': 20},
            {'velocity': 7800, 'altitude': 400000, 'temperature': 500, 'fuel_percent': 0, 'thrust_percent': 0},
        ]
        
        test_config = {
            'rocket': {
                'name': 'Test Rocket',
                'engine_count': 3,
                'has_solar_panels': True,
                'temperature': 20
            },
            'flight_profile': {
                'target_orbit': {
                    'altitude': 400,  # km
                    'inclination': 51.6  # ISS orbit
                }
            },
            'telemetry': test_telemetry,
            'render_settings': {
                'engine': 'EEVEE',
                'resolution_x': 1280,
                'resolution_y': 720
            }
        }
        
        rocket_sim = RocketSimulation3D()
        result = rocket_sim.create_rocket_simulation(test_config)
        
        print("Test rocket simulation created!")

if __name__ == "__main__":
    main()

import bpy
import bmesh
import mathutils
import math
import json
import sys
from mathutils import Vector

class OrbitalMechanicsVisualizer:
    """
    NASA Keplerian orbital elements ile gerçek asteroid yörünge simülasyonu
    """
    
    def __init__(self):
        self.au_to_blender = 0.1  # 1 AU = 0.1 Blender units (scale factor)
        self.earth_radius = 6.371e-6  # Earth radius in AU, scaled to Blender
        self.asteroid_scale_factor = 1000.0  # Asteroid visibility için büyütme
        
    def create_orbital_visualization(self, config_data):
        """
        Config'den orbital visualization oluşturur
        """
        print("Creating orbital mechanics visualization...")
        
        asteroid_data = config_data['asteroid']
        orbital_elements = config_data.get('orbital_elements', {})
        simulation_days = config_data.get('simulation_duration_days', 365)
        
        # Scene setup
        self._setup_solar_system_scene()
        
        # Güneş oluştur
        sun = self._create_sun()
        
        # Dünya yörüngesi
        earth_orbit = self._create_earth_orbit()
        
        # Asteroid oluştur
        asteroid_obj = self._create_asteroid_object(asteroid_data)
        
        # Asteroid yörüngesi
        orbit_path = self._create_asteroid_orbit(orbital_elements)
        
        # Orbital animation
        self._animate_orbital_motion(asteroid_obj, earth_orbit, orbital_elements, simulation_days)
        
        # Close approach markers
        self._add_close_approach_markers(orbital_elements)
        
        # Information panels
        self._create_orbital_info_panels(asteroid_data, orbital_elements)
        
        print("Orbital visualization completed!")
        
        return {
            'sun': sun,
            'earth_orbit': earth_orbit,
            'asteroid': asteroid_obj,
            'orbit_path': orbit_path
        }
    
    def _setup_solar_system_scene(self):
        """
        Solar system sahnesini hazırlar
        """
        # Scene temizle
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete(use_global=False)
        
        # Space environment
        world = bpy.context.scene.world
        world.use_nodes = True
        
        nodes = world.node_tree.nodes
        nodes.clear()
        
        # Background
        background = nodes.new('ShaderNodeBackground')
        background.inputs['Color'].default_value = (0.001, 0.001, 0.005, 1.0)  # Deep space
        background.inputs['Strength'].default_value = 0.1
        
        output = nodes.new('ShaderNodeOutputWorld')
        world.node_tree.links.new(background.outputs['Background'], output.inputs['Surface'])
        
        # Camera setup
        bpy.ops.object.camera_add(location=(0, -5, 2))
        camera = bpy.context.active_object
        camera.name = "Orbital_Camera"
        
        # Track empty for camera target
        bpy.ops.object.empty_add(location=(0, 0, 0))
        target = bpy.context.active_object
        target.name = "Camera_Target"
        
        # Camera constraint
        constraint = camera.constraints.new('TRACK_TO')
        constraint.target = target
        constraint.track_axis = 'TRACK_NEGATIVE_Z'
        constraint.up_axis = 'UP_Y'
    
    def _create_sun(self):
        """
        Güneş objesi oluşturur
        """
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=0.05,  # Scaled sun
            location=(0, 0, 0)
        )
        
        sun = bpy.context.active_object
        sun.name = "Sun"
        
        # Sun material
        sun_mat = bpy.data.materials.new(name="Sun_Material")
        sun_mat.use_nodes = True
        
        nodes = sun_mat.node_tree.nodes
        principled = nodes['Principled BSDF']
        principled.inputs['Base Color'].default_value = (1.0, 0.8, 0.3, 1.0)
        principled.inputs['Emission'].default_value = (1.0, 0.8, 0.2, 1.0)
        principled.inputs['Emission Strength'].default_value = 10.0
        
        sun.data.materials.append(sun_mat)
        
        # Sun light
        bpy.ops.object.light_add(type='POINT', location=(0, 0, 0))
        sun_light = bpy.context.active_object
        sun_light.name = "Sun_Light"
        sun_light.data.energy = 100.0
        sun_light.data.color = (1.0, 0.9, 0.7)
        
        return sun
    
    def _create_earth_orbit(self):
        """
        Dünya ve yörüngesi oluşturur
        """
        # Dünya yörüngesi (1 AU radius)
        earth_orbit_radius = 1.0 * self.au_to_blender
        
        # Earth orbit path
        bpy.ops.mesh.primitive_circle_add(
            radius=earth_orbit_radius,
            vertices=64,
            location=(0, 0, 0)
        )
        
        orbit_path = bpy.context.active_object
        orbit_path.name = "Earth_Orbit_Path"
        
        # Convert to curve
        bpy.ops.object.convert(target='CURVE')
        orbit_path.data.bevel_depth = 0.001
        
        # Orbit material
        orbit_mat = bpy.data.materials.new(name="Orbit_Path_Material")
        orbit_mat.use_nodes = True
        
        principled = orbit_mat.node_tree.nodes['Principled BSDF']
        principled.inputs['Base Color'].default_value = (0.3, 0.7, 1.0, 1.0)
        principled.inputs['Emission'].default_value = (0.3, 0.7, 1.0, 1.0)
        principled.inputs['Emission Strength'].default_value = 0.5
        
        orbit_path.data.materials.append(orbit_mat)
        
        # Dünya objesi
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=0.02,  # Scaled Earth
            location=(earth_orbit_radius, 0, 0)
        )
        
        earth = bpy.context.active_object
        earth.name = "Earth"
        
        # Earth material
        earth_mat = bpy.data.materials.new(name="Earth_Material")
        earth_mat.use_nodes = True
        
        principled = earth_mat.node_tree.nodes['Principled BSDF']
        principled.inputs['Base Color'].default_value = (0.2, 0.4, 0.8, 1.0)
        
        earth.data.materials.append(earth_mat)
        
        return {'path': orbit_path, 'earth': earth}
    
    def _create_asteroid_object(self, asteroid_data):
        """
        Asteroid objesi oluşturur
        """
        diameter_km = asteroid_data.get('diameter_km', 1.0)
        # Blender scale (visibility için büyütülmüş)
        radius = (diameter_km / 1000.0) * self.asteroid_scale_factor
        
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=max(radius, 0.005),  # Minimum size
            location=(0, 0, 0)
        )
        
        asteroid = bpy.context.active_object
        asteroid.name = f"Asteroid_{asteroid_data.get('name', 'Unknown')}"
        
        # Asteroid material
        spectral_type = asteroid_data.get('spectral_type', 'S')[0]
        asteroid_mat = self._create_asteroid_material(spectral_type)
        asteroid.data.materials.append(asteroid_mat)
        
        return asteroid
    
    def _create_asteroid_material(self, spectral_type):
        """
        Spectral type'a göre asteroid materyali
        """
        mat_name = f"Asteroid_Material_{spectral_type}"
        mat = bpy.data.materials.new(name=mat_name)
        mat.use_nodes = True
        
        nodes = mat.node_tree.nodes
        principled = nodes['Principled BSDF']
        
        # Spectral type colors
        colors = {
            'C': (0.15, 0.15, 0.2, 1.0),   # Carbonaceous - dark
            'S': (0.4, 0.35, 0.25, 1.0),   # Stony - brownish
            'M': (0.5, 0.45, 0.4, 1.0),    # Metallic - greyish
            'X': (0.3, 0.3, 0.3, 1.0),     # Unknown - grey
            'B': (0.1, 0.1, 0.15, 1.0),    # Very dark
        }
        
        color = colors.get(spectral_type, colors['S'])
        principled.inputs['Base Color'].default_value = color
        principled.inputs['Roughness'].default_value = 0.9
        principled.inputs['Metallic'].default_value = 1.0 if spectral_type == 'M' else 0.0
        
        return mat
    
    def _create_asteroid_orbit(self, orbital_elements):
        """
        Asteroid yörüngesi oluşturur
        """
        # Orbital elements
        a = orbital_elements.get('semi_major_axis', 2.0)  # AU
        e = orbital_elements.get('eccentricity', 0.1)
        i = math.radians(orbital_elements.get('inclination', 5.0))  # degrees
        omega = math.radians(orbital_elements.get('longitude_ascending_node', 0.0))
        w = math.radians(orbital_elements.get('argument_periapsis', 0.0))
        
        # Scale to Blender
        a_scaled = a * self.au_to_blender
        
        # Orbit points hesapla
        orbit_points = []
        num_points = 128
        
        for i_point in range(num_points):
            # Mean anomaly
            M = (2 * math.pi * i_point) / num_points
            
            # Eccentric anomaly (Newton-Raphson)
            E = self._solve_kepler_equation(M, e)
            
            # True anomaly
            nu = 2 * math.atan2(
                math.sqrt(1 + e) * math.sin(E/2),
                math.sqrt(1 - e) * math.cos(E/2)
            )
            
            # Distance
            r = a_scaled * (1 - e * math.cos(E))
            
            # Position in orbital plane
            x_orbit = r * math.cos(nu)
            y_orbit = r * math.sin(nu)
            z_orbit = 0
            
            # Transform to 3D space (orbital elements)
            pos = self._transform_orbital_to_3d(x_orbit, y_orbit, z_orbit, omega, w, i)
            orbit_points.append(pos)
        
        # Create curve from points
        curve_data = bpy.data.curves.new(name='Asteroid_Orbit', type='CURVE')
        curve_data.dimensions = '3D'
        
        spline = curve_data.splines.new(type='BEZIER')
        spline.bezier_points.add(len(orbit_points) - 1)
        
        for i, point in enumerate(orbit_points):
            spline.bezier_points[i].co = point
            spline.bezier_points[i].handle_left_type = 'AUTO'
            spline.bezier_points[i].handle_right_type = 'AUTO'
        
        spline.use_cyclic_u = True  # Close the orbit
        
        # Create object
        orbit_obj = bpy.data.objects.new('Asteroid_Orbit', curve_data)
        bpy.context.collection.objects.link(orbit_obj)
        
        # Orbit material
        orbit_mat = bpy.data.materials.new(name="Asteroid_Orbit_Material")
        orbit_mat.use_nodes = True
        
        principled = orbit_mat.node_tree.nodes['Principled BSDF']
        principled.inputs['Base Color'].default_value = (1.0, 0.5, 0.0, 1.0)
        principled.inputs['Emission'].default_value = (1.0, 0.5, 0.0, 1.0)
        principled.inputs['Emission Strength'].default_value = 1.0
        
        curve_data.materials.append(orbit_mat)
        curve_data.bevel_depth = 0.002
        
        return orbit_obj
    
    def _solve_kepler_equation(self, M, e, tolerance=1e-6):
        """
        Kepler denklemini Newton-Raphson ile çözer
        """
        E = M  # Initial guess
        
        for _ in range(20):  # Max iterations
            f = E - e * math.sin(E) - M
            f_prime = 1 - e * math.cos(E)
            
            if abs(f_prime) < tolerance:
                break
                
            E_new = E - f / f_prime
            
            if abs(E_new - E) < tolerance:
                break
                
            E = E_new
        
        return E
    
    def _transform_orbital_to_3d(self, x, y, z, omega, w, i):
        """
        Orbital plane koordinatlarını 3D space'e transform eder
        """
        # Rotation matrices
        cos_omega = math.cos(omega)
        sin_omega = math.sin(omega)
        cos_w = math.cos(w)
        sin_w = math.sin(w)
        cos_i = math.cos(i)
        sin_i = math.sin(i)
        
        # Transform matrix elements
        P11 = cos_omega * cos_w - sin_omega * sin_w * cos_i
        P12 = -cos_omega * sin_w - sin_omega * cos_w * cos_i
        P21 = sin_omega * cos_w + cos_omega * sin_w * cos_i
        P22 = -sin_omega * sin_w + cos_omega * cos_w * cos_i
        P31 = sin_w * sin_i
        P32 = cos_w * sin_i
        
        # Transform
        X = P11 * x + P12 * y
        Y = P21 * x + P22 * y
        Z = P31 * x + P32 * y
        
        return Vector((X, Y, Z))
    
    def _animate_orbital_motion(self, asteroid_obj, earth_orbit, orbital_elements, simulation_days):
        """
        Orbital motion animasyonu
        """
        # Animation setup
        frame_start = 1
        frame_end = min(simulation_days, 1000)  # Limit frames
        bpy.context.scene.frame_start = frame_start
        bpy.context.scene.frame_end = frame_end
        
        # Orbital period
        orbital_period_days = orbital_elements.get('orbital_period_years', 2.0) * 365.25
        
        # Earth motion (reference)
        earth_obj = earth_orbit['earth']
        self._animate_circular_orbit(earth_obj, 1.0 * self.au_to_blender, 365.25, frame_start, frame_end)
        
        # Asteroid motion
        a = orbital_elements.get('semi_major_axis', 2.0) * self.au_to_blender
        e = orbital_elements.get('eccentricity', 0.1)
        i = math.radians(orbital_elements.get('inclination', 5.0))
        omega = math.radians(orbital_elements.get('longitude_ascending_node', 0.0))
        w = math.radians(orbital_elements.get('argument_periapsis', 0.0))
        
        self._animate_elliptical_orbit(asteroid_obj, a, e, i, omega, w, orbital_period_days, frame_start, frame_end)
    
    def _animate_circular_orbit(self, obj, radius, period_days, frame_start, frame_end):
        """
        Circular orbit animation (Dünya için)
        """
        for frame in range(frame_start, frame_end + 1):
            days = (frame - frame_start) * (365.25 / (frame_end - frame_start + 1))
            angle = (days / period_days) * 2 * math.pi
            
            x = radius * math.cos(angle)
            y = radius * math.sin(angle)
            z = 0
            
            obj.location = (x, y, z)
            obj.keyframe_insert(data_path="location", frame=frame)
    
    def _animate_elliptical_orbit(self, obj, a, e, i, omega, w, period_days, frame_start, frame_end):
        """
        Elliptical orbit animation (Asteroid için)
        """
        for frame in range(frame_start, frame_end + 1):
            days = (frame - frame_start) * (period_days / (frame_end - frame_start + 1))
            
            # Mean anomaly
            M = (days / period_days) * 2 * math.pi
            
            # Solve Kepler's equation
            E = self._solve_kepler_equation(M, e)
            
            # True anomaly
            nu = 2 * math.atan2(
                math.sqrt(1 + e) * math.sin(E/2),
                math.sqrt(1 - e) * math.cos(E/2)
            )
            
            # Distance
            r = a * (1 - e * math.cos(E))
            
            # Position in orbital plane
            x_orbit = r * math.cos(nu)
            y_orbit = r * math.sin(nu)
            z_orbit = 0
            
            # Transform to 3D
            pos = self._transform_orbital_to_3d(x_orbit, y_orbit, z_orbit, omega, w, i)
            
            obj.location = pos
            obj.keyframe_insert(data_path="location", frame=frame)
    
    def _add_close_approach_markers(self, orbital_elements):
        """
        Close approach noktalarına marker ekler
        """
        # Perihelion marker
        a = orbital_elements.get('semi_major_axis', 2.0) * self.au_to_blender
        e = orbital_elements.get('eccentricity', 0.1)
        i = math.radians(orbital_elements.get('inclination', 5.0))
        omega = math.radians(orbital_elements.get('longitude_ascending_node', 0.0))
        w = math.radians(orbital_elements.get('argument_periapsis', 0.0))
        
        # Perihelion distance
        perihelion_dist = a * (1 - e)
        
        # Perihelion position
        pos_perihelion = self._transform_orbital_to_3d(perihelion_dist, 0, 0, omega, w, i)
        
        bpy.ops.mesh.primitive_ico_sphere_add(
            radius=0.01,
            location=pos_perihelion
        )
        
        perihelion_marker = bpy.context.active_object
        perihelion_marker.name = "Perihelion_Marker"
        
        # Marker material
        marker_mat = bpy.data.materials.new(name="Perihelion_Material")
        marker_mat.use_nodes = True
        
        principled = marker_mat.node_tree.nodes['Principled BSDF']
        principled.inputs['Base Color'].default_value = (1.0, 0.0, 0.0, 1.0)
        principled.inputs['Emission'].default_value = (1.0, 0.0, 0.0, 1.0)
        principled.inputs['Emission Strength'].default_value = 3.0
        
        perihelion_marker.data.materials.append(marker_mat)
    
    def _create_orbital_info_panels(self, asteroid_data, orbital_elements):
        """
        Orbital bilgi panelleri oluşturur
        """
        # Text object for orbital info
        bpy.ops.object.text_add(location=(2, 2, 1))
        text_obj = bpy.context.active_object
        text_obj.name = "Orbital_Info"
        
        # Orbital info text
        info_text = f"""Asteroid: {asteroid_data.get('name', 'Unknown')}
Semi-major Axis: {orbital_elements.get('semi_major_axis', 2.0):.3f} AU
Eccentricity: {orbital_elements.get('eccentricity', 0.1):.3f}
Inclination: {orbital_elements.get('inclination', 5.0):.1f}°
Orbital Period: {orbital_elements.get('orbital_period_years', 2.0):.2f} years
Diameter: {asteroid_data.get('diameter_km', 1.0):.3f} km
Spectral Type: {asteroid_data.get('spectral_type', 'S')}"""
        
        text_obj.data.body = info_text
        text_obj.data.size = 0.3
        
        # Text material
        text_mat = bpy.data.materials.new(name="Info_Text_Material")
        text_mat.use_nodes = True
        
        principled = text_mat.node_tree.nodes['Principled BSDF']
        principled.inputs['Base Color'].default_value = (1.0, 1.0, 1.0, 1.0)
        principled.inputs['Emission'].default_value = (0.8, 0.8, 1.0, 1.0)
        principled.inputs['Emission Strength'].default_value = 2.0
        
        text_obj.data.materials.append(text_mat)

# Main execution
def main():
    """
    Command line arguments'dan config'i al ve çalıştır
    """
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
                
                # Visualizer oluştur ve çalıştır
                visualizer = OrbitalMechanicsVisualizer()
                result = visualizer.create_orbital_visualization(config_data)
                
                # Render settings
                render_settings = config_data.get('render_settings', {})
                scene = bpy.context.scene
                scene.render.engine = render_settings.get('engine', 'CYCLES')
                scene.render.resolution_x = render_settings.get('resolution_x', 1920)
                scene.render.resolution_y = render_settings.get('resolution_y', 1080)
                scene.cycles.samples = render_settings.get('samples', 128)
                
                # Output path
                if output_id:
                    output_dir = f"blender_integration/output/{output_id}/"
                    import os
                    os.makedirs(output_dir, exist_ok=True)
                    scene.render.filepath = f"{output_dir}orbital_visualization_"
                
                print(f"Orbital visualization setup complete! Output ID: {output_id}")
                
            except Exception as e:
                print(f"Error: {e}")
                sys.exit(1)
        else:
            print("No config path provided!")
            sys.exit(1)
    else:
        # Test mode - create example visualization
        print("Running in test mode...")
        
        # Example config
        test_config = {
            'asteroid': {
                'name': 'Apophis',
                'diameter_km': 0.370,
                'spectral_type': 'Sq'
            },
            'orbital_elements': {
                'semi_major_axis': 0.9224,
                'eccentricity': 0.1911,
                'inclination': 3.331,
                'longitude_ascending_node': 204.4,
                'argument_periapsis': 126.4,
                'orbital_period_years': 0.886
            },
            'simulation_duration_days': 365
        }
        
        visualizer = OrbitalMechanicsVisualizer()
        result = visualizer.create_orbital_visualization(test_config)
        
        print("Test visualization created!")

if __name__ == "__main__":
    main()

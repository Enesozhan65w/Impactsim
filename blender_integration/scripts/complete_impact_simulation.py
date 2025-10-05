import bpy
import json
import sys
import os
from pathlib import Path

# Import our modules
from asteroid_generator import AsteroidGenerator
from earth_setup import EarthModelGenerator
from impact_simulation import ImpactSimulation
from orbital_mechanics import OrbitalMechanicsVisualizer

class CompleteImpactSimulation:
    """
    Tüm simülasyon bileşenlerini koordine eden master sınıf
    Flutter'dan gelen config'e göre komplet asteroid impact simülasyonu oluşturur
    """
    
    def __init__(self):
        self.asteroid_generator = AsteroidGenerator()
        self.earth_generator = EarthModelGenerator()
        self.impact_simulator = ImpactSimulation()
        self.orbital_visualizer = OrbitalMechanicsVisualizer()
    
    def create_complete_simulation(self, config_data):
        """
        Config'e göre komplet simülasyon oluşturur
        """
        print("=== Starting Complete Impact Simulation ===")
        
        simulation_type = config_data.get('simulation_type', 'impact')
        asteroid_data = config_data.get('asteroid', {})
        render_settings = config_data.get('render_settings', {})
        
        result = {
            'simulation_id': config_data.get('output_id', 'unknown'),
            'components': {},
            'render_info': {}
        }
        
        try:
            if simulation_type == 'impact':
                result = self._create_impact_simulation(config_data)
            elif simulation_type == 'orbital':
                result = self._create_orbital_simulation(config_data)
            elif simulation_type == 'comparison':
                result = self._create_comparison_simulation(config_data)
            elif simulation_type == 'deflection':
                result = self._create_deflection_simulation(config_data)
            else:
                # Default: comprehensive impact simulation
                result = self._create_comprehensive_simulation(config_data)
            
            # Setup rendering
            self._setup_render_pipeline(render_settings, result['simulation_id'])
            
            # Create status file
            self._create_status_file(result['simulation_id'], 'completed', result)
            
            print("=== Simulation Creation Completed Successfully ===")
            
        except Exception as e:
            print(f"=== Simulation Creation Failed: {e} ===")
            self._create_status_file(result['simulation_id'], 'failed', {'error': str(e)})
            raise
        
        return result
    
    def _create_impact_simulation(self, config_data):
        """
        Asteroid impact simülasyonu oluşturur
        """
        print("Creating Impact Simulation...")
        
        asteroid_data = config_data['asteroid']
        impact_coords = config_data['impact_coordinates']
        
        # 1. Dünya sistemi oluştur
        print("- Setting up Earth system...")
        earth_system = self.earth_generator.create_complete_earth_system()
        
        # Impact marker ekle
        impact_marker = self.earth_generator.add_impact_location_marker(
            impact_coords['latitude'],
            impact_coords['longitude'],
            f"Impact_{asteroid_data.get('name', 'Unknown')}"
        )
        
        # Lighting setup
        sun = self.earth_generator.setup_earth_lighting()
        
        # 2. Impact simülasyonu
        print("- Creating impact simulation...")
        simulation_objects = self.impact_simulator.simulate_asteroid_impact(
            asteroid_data,
            impact_coords,
            earth_system['earth']
        )
        
        return {
            'simulation_id': config_data.get('output_id', 'unknown'),
            'simulation_type': 'impact',
            'components': {
                'earth_system': earth_system,
                'impact_marker': impact_marker,
                'sun': sun,
                'impact_simulation': simulation_objects
            },
            'render_info': {
                'primary_camera': 'Main_Camera',
                'animation_frames': (1, 300),
                'focus_object': 'Earth'
            }
        }
    
    def _create_orbital_simulation(self, config_data):
        """
        Orbital mechanics simülasyonu oluşturur
        """
        print("Creating Orbital Simulation...")
        
        orbital_components = self.orbital_visualizer.create_orbital_visualization(config_data)
        
        return {
            'simulation_id': config_data.get('output_id', 'unknown'),
            'simulation_type': 'orbital',
            'components': orbital_components,
            'render_info': {
                'primary_camera': 'Orbital_Camera',
                'animation_frames': (1, min(config_data.get('simulation_duration_days', 365), 1000)),
                'focus_object': 'Camera_Target'
            }
        }
    
    def _create_comparison_simulation(self, config_data):
        """
        Çoklu asteroid karşılaştırma simülasyonu
        """
        print("Creating Comparison Simulation...")
        
        asteroids = config_data.get('asteroids', [])
        impact_coords = config_data['impact_coordinates']
        
        # Layout ayarları
        grid_size = int(len(asteroids) ** 0.5) + 1
        spacing = 20.0  # Blender units
        
        components = {
            'earth_systems': [],
            'impact_simulations': [],
            'cameras': []
        }
        
        for i, asteroid_data in enumerate(asteroids):
            print(f"- Creating simulation {i+1}/{len(asteroids)} for {asteroid_data.get('name', 'Unknown')}...")
            
            # Grid position
            x_pos = (i % grid_size) * spacing - (grid_size * spacing / 2)
            z_pos = (i // grid_size) * spacing - (grid_size * spacing / 2)
            
            # Earth system
            earth_system = self.earth_generator.create_complete_earth_system()
            
            # Position earth system
            earth_system['earth'].location = (x_pos, 0, z_pos)
            earth_system['atmosphere'].location = (x_pos, 0, z_pos)
            earth_system['clouds'].location = (x_pos, 0, z_pos)
            
            # Impact simulation
            impact_sim = self.impact_simulator.simulate_asteroid_impact(
                asteroid_data,
                impact_coords,
                earth_system['earth']
            )
            
            # Individual camera
            bpy.ops.object.camera_add(location=(x_pos + 15, -15, z_pos + 10))
            camera = bpy.context.active_object
            camera.name = f"Camera_{asteroid_data.get('name', f'Asteroid_{i}')}"
            
            components['earth_systems'].append(earth_system)
            components['impact_simulations'].append(impact_sim)
            components['cameras'].append(camera)
        
        # Master overview camera
        bpy.ops.object.camera_add(location=(0, -grid_size * spacing * 1.5, grid_size * spacing))
        master_camera = bpy.context.active_object
        master_camera.name = "Master_Overview_Camera"
        
        return {
            'simulation_id': config_data.get('output_id', 'unknown'),
            'simulation_type': 'comparison',
            'components': components,
            'render_info': {
                'primary_camera': 'Master_Overview_Camera',
                'animation_frames': (1, 300),
                'grid_size': grid_size,
                'asteroid_count': len(asteroids)
            }
        }
    
    def _create_deflection_simulation(self, config_data):
        """
        Deflection scenario simülasyonu
        """
        print("Creating Deflection Simulation...")
        
        scenario_data = config_data.get('scenario', {})
        asteroid_data = config_data['asteroid']
        original_impact = config_data['original_impact']
        
        components = {}
        
        # 1. Original trajectory ve impact
        print("- Creating original impact scenario...")
        original_components = self._create_impact_simulation({
            'asteroid': asteroid_data,
            'impact_coordinates': {
                'latitude': original_impact['latitude'],
                'longitude': original_impact['longitude']
            }
        })
        
        # Position original simulation
        for comp_name, comp_obj in original_components['components'].items():
            if hasattr(comp_obj, 'location'):
                comp_obj.location.x -= 30  # Offset to left
        
        components['original'] = original_components
        
        # 2. Deflected trajectory (eğer varsa)
        deflection_results = config_data.get('deflection_results', {})
        if deflection_results.get('isSuccessful', False):
            print("- Creating successful deflection scenario...")
            
            # Deflected impact simulation (miss)
            # Bu durumda asteroid Dünya'yı ıskalar
            
            # Orbital visualization of deflected path
            orbital_config = {
                'asteroid': asteroid_data,
                'orbital_elements': {
                    'semi_major_axis': asteroid_data.get('semi_major_axis_au', 1.5),
                    'eccentricity': asteroid_data.get('eccentricity', 0.1),
                    # Modified by deflection
                    'inclination': asteroid_data.get('inclination_deg', 5.0) + 0.5,  # Small change
                }
            }
            
            deflected_components = self.orbital_visualizer.create_orbital_visualization(orbital_config)
            
            # Position deflected simulation
            for comp_name, comp_obj in deflected_components.items():
                if hasattr(comp_obj, 'location'):
                    comp_obj.location.x += 30  # Offset to right
            
            components['deflected'] = deflected_components
        
        return {
            'simulation_id': config_data.get('output_id', 'unknown'),
            'simulation_type': 'deflection',
            'components': components,
            'render_info': {
                'primary_camera': 'Main_Camera',
                'animation_frames': (1, 500),
                'deflection_successful': deflection_results.get('isSuccessful', False)
            }
        }
    
    def _create_comprehensive_simulation(self, config_data):
        """
        Tüm bileşenleri içeren comprehensive simülasyon
        """
        print("Creating Comprehensive Simulation...")
        
        asteroid_data = config_data['asteroid']
        impact_coords = config_data['impact_coordinates']
        
        components = {}
        
        # 1. Orbital approach phase
        print("- Phase 1: Orbital approach...")
        orbital_components = self.orbital_visualizer.create_orbital_visualization({
            'asteroid': asteroid_data,
            'orbital_elements': {
                'semi_major_axis': asteroid_data.get('semi_major_axis_au', 2.0),
                'eccentricity': asteroid_data.get('eccentricity', 0.1),
                'inclination': asteroid_data.get('inclination_deg', 5.0),
                'orbital_period_years': asteroid_data.get('orbital_period_years', 2.0)
            },
            'simulation_duration_days': 100
        })
        
        # Position orbital components
        for name, obj in orbital_components.items():
            if hasattr(obj, 'location'):
                obj.location.y -= 50  # Offset backward
        
        components['orbital_phase'] = orbital_components
        
        # 2. Impact phase
        print("- Phase 2: Impact simulation...")
        impact_components = self._create_impact_simulation({
            'asteroid': asteroid_data,
            'impact_coordinates': impact_coords,
            'output_id': config_data.get('output_id')
        })
        
        components['impact_phase'] = impact_components
        
        # 3. Multi-camera system
        self._setup_multicamera_system(components)
        
        return {
            'simulation_id': config_data.get('output_id', 'unknown'),
            'simulation_type': 'comprehensive',
            'components': components,
            'render_info': {
                'primary_camera': 'Master_Camera',
                'animation_frames': (1, 600),
                'phases': ['orbital', 'impact'],
                'camera_count': 4
            }
        }
    
    def _setup_multicamera_system(self, components):
        """
        Multi-camera sistem kurar
        """
        # Master camera (overview)
        bpy.ops.object.camera_add(location=(50, -50, 30))
        master_cam = bpy.context.active_object
        master_cam.name = "Master_Camera"
        
        # Orbital phase camera  
        bpy.ops.object.camera_add(location=(0, -40, 20))
        orbital_cam = bpy.context.active_object
        orbital_cam.name = "Orbital_Phase_Camera"
        
        # Impact close-up camera
        bpy.ops.object.camera_add(location=(10, -10, 5))
        impact_cam = bpy.context.active_object
        impact_cam.name = "Impact_Closeup_Camera"
        
        # Side view camera
        bpy.ops.object.camera_add(location=(0, 30, 0))
        side_cam = bpy.context.active_object
        side_cam.name = "Side_View_Camera"
        
        # Camera switching animation
        scene = bpy.context.scene
        
        # Frame ranges for different cameras
        cameras = [
            (master_cam, 1, 150),      # Master overview
            (orbital_cam, 151, 300),   # Orbital phase
            (impact_cam, 301, 450),    # Impact close-up
            (side_cam, 451, 600),      # Side view finale
        ]
        
        for camera, start_frame, end_frame in cameras:
            camera.hide_viewport = True
            camera.keyframe_insert(data_path="hide_viewport", frame=start_frame-1)
            
            camera.hide_viewport = False
            camera.keyframe_insert(data_path="hide_viewport", frame=start_frame)
            camera.keyframe_insert(data_path="hide_viewport", frame=end_frame)
            
            camera.hide_viewport = True
            camera.keyframe_insert(data_path="hide_viewport", frame=end_frame+1)
    
    def _setup_render_pipeline(self, render_settings, simulation_id):
        """
        Render pipeline'ı kurar
        """
        print("Setting up render pipeline...")
        
        scene = bpy.context.scene
        
        # Engine
        engine = render_settings.get('engine', 'CYCLES')
        scene.render.engine = engine
        print(f"- Render Engine: {engine}")
        
        # Resolution
        scene.render.resolution_x = render_settings.get('resolution_x', 1920)
        scene.render.resolution_y = render_settings.get('resolution_y', 1080)
        scene.render.resolution_percentage = 100
        
        # Frame range
        scene.frame_start = render_settings.get('frame_start', 1)
        scene.frame_end = render_settings.get('frame_end', 250)
        scene.frame_set(scene.frame_start)
        
        # Output settings
        scene.render.image_settings.file_format = render_settings.get('file_format', 'PNG')
        scene.render.image_settings.color_mode = 'RGBA'
        scene.render.image_settings.compression = 15
        
        # Output path
        output_dir = f"blender_integration/output/{simulation_id}/"
        os.makedirs(output_dir, exist_ok=True)
        scene.render.filepath = f"{output_dir}simulation_"
        
        # Cycles settings (if using Cycles)
        if engine == 'CYCLES':
            scene.cycles.samples = render_settings.get('samples', 128)
            scene.cycles.use_denoising = render_settings.get('denoising', True)
            scene.cycles.denoiser = 'OPTIX' if render_settings.get('use_optix', False) else 'OIDN'
            scene.cycles.device = 'GPU' if render_settings.get('use_gpu', True) else 'CPU'
        
        # Animation settings
        if render_settings.get('render_animation', True):
            scene.render.fps = int(render_settings.get('frame_rate', 24))
            
            # Video output
            if render_settings.get('create_video', True):
                scene.render.image_settings.file_format = 'FFMPEG'
                scene.render.ffmpeg.format = 'MPEG4'
                scene.render.ffmpeg.codec = 'H264'
                scene.render.ffmpeg.constant_rate_factor = 'HIGH'
        
        print(f"- Resolution: {scene.render.resolution_x}x{scene.render.resolution_y}")
        print(f"- Frames: {scene.frame_start}-{scene.frame_end}")
        print(f"- Output: {scene.render.filepath}")
    
    def _create_status_file(self, simulation_id, status, data=None):
        """
        Simülasyon durumu için JSON dosyası oluşturur
        """
        status_data = {
            'simulation_id': simulation_id,
            'status': status,
            'timestamp': str(bpy.context.scene.frame_current),
            'blender_version': bpy.app.version_string,
            'data': data or {}
        }
        
        status_path = f"blender_integration/output/status_{simulation_id}.json"
        os.makedirs(os.path.dirname(status_path), exist_ok=True)
        
        with open(status_path, 'w') as f:
            json.dump(status_data, f, indent=2)
        
        print(f"Status file created: {status_path}")

def main():
    """
    Main execution function
    """
    print("=== Blender Complete Impact Simulation ===")
    
    if '--' in sys.argv:
        argv = sys.argv[sys.argv.index('--') + 1:]
        
        config_path = None
        output_id = None
        
        for i, arg in enumerate(argv):
            if arg == '--config' and i + 1 < len(argv):
                config_path = argv[i + 1]
            elif arg == '--output-id' and i + 1 < len(argv):
                output_id = argv[i + 1]
        
        if config_path and os.path.exists(config_path):
            try:
                print(f"Loading config from: {config_path}")
                
                with open(config_path, 'r') as f:
                    config_data = json.load(f)
                
                # Add output ID to config
                if output_id:
                    config_data['output_id'] = output_id
                
                # Create status file
                simulator = CompleteImpactSimulation()
                simulator._create_status_file(output_id or 'unknown', 'running', {'config_loaded': True})
                
                # Run simulation
                result = simulator.create_complete_simulation(config_data)
                
                print("=== SIMULATION COMPLETED SUCCESSFULLY ===")
                print(f"Simulation ID: {result['simulation_id']}")
                print(f"Type: {result.get('simulation_type', 'unknown')}")
                print(f"Components: {len(result.get('components', {}))}")
                
            except Exception as e:
                print(f"=== SIMULATION FAILED ===")
                print(f"Error: {e}")
                
                if output_id:
                    simulator = CompleteImpactSimulation()
                    simulator._create_status_file(output_id, 'failed', {'error': str(e)})
                
                sys.exit(1)
        else:
            print(f"Config file not found: {config_path}")
            sys.exit(1)
    else:
        # Test mode
        print("Running in TEST MODE...")
        
        test_config = {
            'simulation_type': 'impact',
            'asteroid': {
                'name': 'Test_Asteroid',
                'diameter_km': 0.2,
                'v_rel_kms': 20.0,
                'density_gcm3': 3.0,
                'spectral_type': 'S'
            },
            'impact_coordinates': {
                'latitude': 41.0082,
                'longitude': 28.9784,
                'location_name': 'Istanbul'
            },
            'render_settings': {
                'engine': 'EEVEE',
                'resolution_x': 1280,
                'resolution_y': 720,
                'samples': 64,
                'frame_end': 120
            },
            'output_id': 'test_simulation'
        }
        
        simulator = CompleteImpactSimulation()
        result = simulator.create_complete_simulation(test_config)
        
        print("=== TEST SIMULATION COMPLETED ===")

if __name__ == "__main__":
    main()

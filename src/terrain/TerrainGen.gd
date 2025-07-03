extends GridMap
class_name TerrainGen

@export_category('Terrain Size')
@export var x_radius:int = 16;
@export var y_radius:int = 1;
@export var z_radius:int = 16;

@export_category('Noise Settings')
@export var init_seed:int; #initial seed
@export var noise_type:FastNoiseLite.NoiseType = FastNoiseLite.TYPE_PERLIN; #noise type with perlin as default
@export var freqency:float = 0.001; #how often blobs appear

var _debug_mesh_lib:MeshLibrary = load("res://assets/debug/debug_mesh_library.tres");

var terrain_noise:FastNoiseLite = FastNoiseLite.new();

func clear_blocks(length:int, height:int, width:int):
	for x in range(-length, length):
		for y in range(-height, height):
			for z in range(-width, width):
				set_cell_item(Vector3i(x, y, z), -1);

func generate_blocks(length:int, height:int, width:int, block_id:int, threshold:float, new_seed:int):
	terrain_noise.seed = new_seed;
	for x in range(-length, length):
		for y in range(-height, height):
			for z in range(-width, width):
				if terrain_noise.get_noise_2d(x, z) > threshold:
					set_cell_item(Vector3i(x,y,z), block_id);

func _ready() -> void:
	terrain_noise.noise_type = noise_type;
	terrain_noise.frequency = freqency;
	terrain_noise.seed = init_seed;
	
	if mesh_library == null:
		mesh_library = _debug_mesh_lib;
	
	generate_blocks(x_radius, y_radius, z_radius, 0, 0, randi());

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		clear_blocks(x_radius,y_radius,z_radius);

	if Input.is_action_just_pressed("ui_accept"):
		generate_blocks(x_radius, y_radius, z_radius, 0, 0, randi());
